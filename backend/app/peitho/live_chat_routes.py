"""
Peitho Live Chat Routes — Dual-role WebSocket and REST API for real-time seller-buyer chat with AI copilot.
"""
import asyncio
import json
import socket
import time
from typing import Optional
from uuid import uuid4
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException, Query, status
import structlog

from ..core.config import get_settings
from .live_chat_schemas import (
    LiveChatMessage,
    LiveChatSessionConfig,
    LiveChatProfitability,
    ProfitabilityStatus,
    LiveChatAdvisoryPayload,
)
from .live_chat_store import live_chat_store, LiveChatSession
from .advisory import AdvisoryEngine
from .normalizer import normalize_transcript
from .suggestions import generate_tactical_replies, _get_template_replies, PeithoIntelClient
from .schemas import AdvisoryResult, AdvisoryMetrics

logger = structlog.get_logger(__name__)
settings = get_settings()

live_chat_router = APIRouter(prefix="/api/v1/peitho/live-chat", tags=["Peitho Live Chat"])


def get_local_ip() -> str:
    """Detect machine's local LAN IP for cross-device mobile scanning."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Does not actually transmit packets, used to determine default outbound route
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip


def calculate_profitability(
    config: LiveChatSessionConfig,
    buyer_offer: Optional[float],
    quantity: Optional[int] = None,
) -> LiveChatProfitability:
    """Calculate unit economics, gross margin %, and deal profitability."""
    qty = quantity or config.quantity or 1

    if buyer_offer is None or buyer_offer <= 0:
        return LiveChatProfitability(
            unit_cost=config.cost_price,
            base_price=config.base_price,
            min_floor=config.min_floor,
            status=ProfitabilityStatus.NO_OFFER_YET,
            severity="info",
            explanation=f"Awaiting buyer offer. Listed price: ${config.base_price:.2f} (Cost: ${config.cost_price:.2f}, Floor: ${config.min_floor:.2f}).",
        )

    unit_profit = round(buyer_offer - config.cost_price, 2)
    margin_pct = round((unit_profit / buyer_offer) * 100.0, 1) if buyer_offer > 0 else 0.0
    total_deal_value = round(buyer_offer * qty, 2)
    total_profit = round(unit_profit * qty, 2)

    if buyer_offer < config.min_floor:
        status_val = ProfitabilityStatus.BELOW_FLOOR_VIOLATION
        severity_val = "critical"
        explanation = (
            f"FLOOR VIOLATION: Buyer offer ${buyer_offer:.2f} is BELOW your absolute survival floor "
            f"of ${config.min_floor:.2f}. Accepting this violates seller constraints. Firm counter or rejection required."
        )
    elif buyer_offer < config.cost_price:
        status_val = ProfitabilityStatus.CONTROLLED_LOSS
        severity_val = "warning"
        explanation = (
            f"CONTROLLED LOSS: Offer ${buyer_offer:.2f} is below cost ${config.cost_price:.2f} "
            f"(Loss: -${abs(unit_profit):.2f}/unit, {margin_pct:.1f}% margin). Acceptable only in MIN_LOSS inventory clearing mode."
        )
    elif margin_pct >= 20.0:
        status_val = ProfitabilityStatus.PROFITABLE
        severity_val = "success"
        explanation = (
            f"STRONG PROFIT: Offer ${buyer_offer:.2f} secures +{margin_pct:.1f}% margin "
            f"(+${unit_profit:.2f}/unit, +${total_profit:.2f} total profit across {qty} units)."
        )
    else:
        status_val = ProfitabilityStatus.ACCEPTABLE
        severity_val = "info"
        explanation = (
            f"MODERATE PROFIT: Offer ${buyer_offer:.2f} gives +{margin_pct:.1f}% margin "
            f"(+${unit_profit:.2f}/unit, +${total_profit:.2f} total profit)."
        )

    return LiveChatProfitability(
        detected_offer=buyer_offer,
        detected_quantity=qty,
        unit_cost=config.cost_price,
        base_price=config.base_price,
        min_floor=config.min_floor,
        unit_profit=unit_profit,
        margin_pct=margin_pct,
        total_deal_value=total_deal_value,
        total_profit=total_profit,
        status=status_val,
        severity=severity_val,
        explanation=explanation,
    )


@live_chat_router.get("/network-info")
async def get_network_info():
    """Returns local LAN IP and ports for cross-device connectivity and QR generation."""
    local_ip = get_local_ip()
    return {
        "local_ip": local_ip,
        "frontend_port": 5173,
        "backend_port": 8000,
        "example_buyer_url": f"http://{local_ip}:5173/buyer-chat/",
    }


@live_chat_router.post("/start")
async def start_live_chat_session(config: LiveChatSessionConfig):
    """
    Initialize a new live chat negotiation session.
    Returns session details, unique session_id, and shareable buyer links.
    """
    session = live_chat_store.create_session(config)
    local_ip = get_local_ip()
    buyer_link = f"http://{local_ip}:5173/buyer-chat/{session.session_id}"

    return {
        "session_id": session.session_id,
        "product_name": config.product_name,
        "base_price": config.base_price,
        "cost_price": config.cost_price,
        "min_floor": config.min_floor,
        "mode": config.mode,
        "max_rounds": config.max_rounds,
        "quantity": config.quantity,
        "buyer_link": buyer_link,
        "local_ip": local_ip,
        "message": "Live chat session created successfully. Share buyer link to connect.",
    }


@live_chat_router.get("/{session_id}")
async def get_live_chat_session(session_id: str, role: str = Query(default="buyer")):
    """
    Retrieve session details.
    For buyer: returns sanitized product info and chat history only.
    For seller: returns full pricing constraints, profitability, and AI advisory.
    """
    session = live_chat_store.get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Live chat session not found or expired",
        )

    if role == "buyer":
        return {
            "session_id": session.session_id,
            "product_name": session.config.product_name,
            "base_price": session.config.base_price,
            "quantity": session.config.quantity,
            "messages": [m.model_dump() for m in session.messages],
            "is_active": session.is_active,
            "seller_online": session.is_seller_online,
        }

    return {
        "session_id": session.session_id,
        "config": session.config.model_dump(),
        "messages": [m.model_dump() for m in session.messages],
        "is_active": session.is_active,
        "buyer_online": session.is_buyer_online,
        "last_profitability": (
            session.last_profitability.model_dump() if session.last_profitability else None
        ),
        "last_advisory": (
            session.last_advisory.model_dump() if session.last_advisory else None
        ),
        "current_round": session.master_state.current_round,
    }


@live_chat_router.websocket("/ws/{session_id}")
async def live_chat_websocket(
    websocket: WebSocket,
    session_id: str,
    role: str = Query(default="buyer"),
):
    """
    Bidirectional WebSocket for Live Chat negotiation.
    - Role 'seller': Receives buyer messages, real-time profitability radar, and AI copilot suggestions.
    - Role 'buyer': Receives seller messages and public notifications only.
    """
    session = live_chat_store.get_session(session_id)
    if not session:
        await websocket.accept()
        await websocket.send_json({
            "type": "error",
            "message": "Live chat session not found or expired.",
        })
        await websocket.close(code=4004, reason="Session not found")
        return

    role = role.lower()
    if role not in ("seller", "buyer"):
        role = "buyer"

    await websocket.accept()
    session.register_socket(role, websocket)
    logger.info("live_chat_ws_connected", session_id=session_id, role=role)

    # Safe send helper
    async def safe_send(ws: WebSocket, payload: dict):
        try:
            await ws.send_json(payload)
        except Exception:
            pass

    async def broadcast_to_group(sockets: set, payload: dict):
        dead_sockets = set()
        for s in list(sockets):
            try:
                await s.send_json(payload)
            except Exception:
                dead_sockets.add(s)
        for s in dead_sockets:
            sockets.discard(s)

    # Broadcast presence change
    if role == "buyer":
        await broadcast_to_group(session.seller_sockets, {
            "type": "presence",
            "buyer_online": True,
            "message": "Buyer connected to live chat.",
        })
    elif role == "seller":
        await broadcast_to_group(session.buyer_sockets, {
            "type": "presence",
            "seller_online": True,
            "message": "Seller connected.",
        })

    # Send initial greeting & state sync to connecting client
    init_payload = {
        "type": "init",
        "session_id": session_id,
        "role": role,
        "product_name": session.config.product_name,
        "base_price": session.config.base_price,
        "quantity": session.config.quantity,
        "messages": [m.model_dump() for m in session.messages],
        "buyer_online": session.is_buyer_online,
        "seller_online": session.is_seller_online,
    }

    if role == "seller":
        init_payload.update({
            "cost_price": session.config.cost_price,
            "min_floor": session.config.min_floor,
            "mode": session.config.mode,
            "current_round": session.master_state.current_round,
            "max_rounds": session.config.max_rounds,
            "last_profitability": (
                session.last_profitability.model_dump() if session.last_profitability else None
            ),
            "last_advisory": (
                session.last_advisory.model_dump() if session.last_advisory else None
            ),
        })

    await safe_send(websocket, init_payload)

    intel_client = PeithoIntelClient()
    active_llm_task: Optional[asyncio.Task] = None
    last_rec_id: Optional[str] = None

    try:
        while True:
            raw_text = await websocket.receive_text()
            try:
                msg_data = json.loads(raw_text)
            except Exception:
                continue

            msg_type = msg_data.get("type", "")

            if msg_type == "ping":
                await safe_send(websocket, {"type": "pong", "ts": time.time()})
                continue

            elif msg_type == "typing":
                # Relays typing indicator to opposite side
                is_typing = bool(msg_data.get("typing", False))
                target_sockets = session.seller_sockets if role == "buyer" else session.buyer_sockets
                await broadcast_to_group(target_sockets, {
                    "type": "typing",
                    "role": role,
                    "typing": is_typing,
                })
                continue

            elif msg_type == "chat_message":
                text = str(msg_data.get("text", "")).strip()
                if not text:
                    continue

                # Add message to history
                new_msg = session.add_message(role, text)
                msg_payload = {
                    "type": "new_message",
                    "message": new_msg.model_dump(),
                }

                # Broadcast to both seller and buyer
                await broadcast_to_group(session.seller_sockets, msg_payload)
                await broadcast_to_group(session.buyer_sockets, msg_payload)

                # ── IF SENDER IS SELLER ──
                if role == "seller":
                    # Update counter history if seller verbalized a quote
                    detected_price = AdvisoryEngine.apply_seller_line(session.master_state, text)
                    if detected_price is not None:
                        logger.info("seller_counter_updated", price=detected_price, session_id=session_id)
                        await broadcast_to_group(session.seller_sockets, {
                            "type": "seller_update",
                            "detected_price": detected_price,
                            "current_counter": session.master_state.counter_history[-1],
                            "round": session.master_state.current_round,
                        })

                # ── IF SENDER IS BUYER ──
                elif role == "buyer":
                    # Process with PRANE-X engine & calculate live profitability
                    norm_text = normalize_transcript(text)
                    cur_counter = (
                        session.master_state.counter_history[-1]
                        if session.master_state.counter_history
                        else session.config.base_price
                    )

                    extraction = AdvisoryEngine.extract_intent_from_text(
                        norm_text,
                        base_price=session.config.base_price,
                        current_counter=cur_counter,
                        current_quantity=session.config.quantity,
                    )

                    offered_p = extraction.get("unit_price_offered")
                    offered_qty = extraction.get("quantity") or session.config.quantity

                    # 1. Real-time Profitability Radar
                    profitability = calculate_profitability(session.config, offered_p, offered_qty)
                    session.last_profitability = profitability

                    # 2. PRANE-X Advisory Recommendation
                    engine_result, extraction = AdvisoryEngine.advise(
                        session.master_state,
                        buyer_text=text,
                    )

                    decision_raw = str(getattr(engine_result, "decision", "counter")).lower()
                    if decision_raw == "accept":
                        action_str = "ACCEPT"
                    elif decision_raw in ("reject", "session_terminated"):
                        action_str = "REJECT"
                    elif decision_raw == "final_offer":
                        action_str = "FINAL_OFFER"
                    else:
                        action_str = "COUNTER"

                    counter_val = float(
                        getattr(engine_result, "counter_unit_price", None)
                        if getattr(engine_result, "counter_unit_price", None) is not None
                        else (
                            session.master_state.counter_history[-1]
                            if session.master_state.counter_history
                            else session.config.base_price
                        )
                    )

                    is_walk_away = bool(getattr(engine_result, "session_terminated", False))
                    reasoning_tag = getattr(engine_result, "reasoning_tag", None)
                    tag_name = reasoning_tag.value if hasattr(reasoning_tag, "value") else str(reasoning_tag or "STRATEGIC_ADVISORY")
                    phase_obj = getattr(engine_result, "phase", None)
                    phase_name = phase_obj.value if hasattr(phase_obj, "value") else str(phase_obj or "EXPLORATION")
                    reasoning_str = f"{tag_name} ({phase_name} Phase)"

                    buyer_offers = session.master_state.offer_history
                    velocity = round(buyer_offers[-1] - buyer_offers[-2], 2) if len(buyer_offers) >= 2 else 0.0
                    budget_denom = max(1.0, getattr(session.master_state, "total_concession_budget", 1.0))
                    rem_budget = getattr(session.master_state, "remaining_concession_budget", 0.0)

                    metrics = AdvisoryMetrics(
                        bbi=round(getattr(engine_result, "bbi", session.master_state.bbi), 1),
                        p_high_wtp=round(getattr(engine_result, "p_high_wtp", session.master_state.p_high_wtp), 2),
                        surplus_share=round(max(0.0, min(1.0, rem_budget / budget_denom)), 2),
                        buyer_concession_velocity=velocity,
                        consecutive_stagnant=session.master_state.consecutive_stagnant,
                        firmness_level=session.master_state.firmness_level,
                        current_round=session.master_state.current_round,
                        max_rounds=session.config.max_rounds,
                    )

                    template_replies = _get_template_replies(
                        action=action_str,
                        counter_price=counter_val,
                        quantity=session.config.quantity,
                        firmness=session.master_state.firmness_level,
                    )

                    rec_id = str(uuid4())
                    last_rec_id = rec_id

                    advisory = AdvisoryResult(
                        action=action_str,
                        counter_price=counter_val,
                        walk_away=is_walk_away,
                        reasoning=reasoning_str,
                        extracted_buyer_offer=offered_p,
                        extracted_buyer_intent=extraction.get("intent"),
                        extracted_quantity=offered_qty,
                        suggested_replies=template_replies,
                        metrics=metrics,
                        timestamp=time.time(),
                        recommendation_id=rec_id,
                        source="template",
                    )
                    session.last_advisory = advisory

                    # 3. Stream advisory & profitability packet EXCLUSIVELY to SELLER
                    advisory_payload = {
                        "type": "advisory_update",
                        "recommendation_id": rec_id,
                        "profitability": profitability.model_dump(),
                        "advisory": advisory.model_dump(),
                        "current_round": session.master_state.current_round,
                        "max_rounds": session.config.max_rounds,
                    }
                    await broadcast_to_group(session.seller_sockets, advisory_payload)

                    # 4. Asynchronous Stage 2 AI Enhancement for Tactical Replies
                    if active_llm_task and not active_llm_task.done():
                        active_llm_task.cancel()

                    async def run_stage2_upgrade(target_id: str, eng_res: any, buyer_line: str, state_snap: any):
                        try:
                            ai_replies = await generate_tactical_replies(
                                engine_result=eng_res,
                                buyer_text=buyer_line,
                                state=state_snap,
                                llm_client=intel_client,
                            )
                            if target_id == last_rec_id and session.last_advisory:
                                session.last_advisory.suggested_replies = ai_replies
                                session.last_advisory.source = "ai"
                                await broadcast_to_group(session.seller_sockets, {
                                    "type": "recommendation_upgrade",
                                    "recommendation_id": target_id,
                                    "source": "ai",
                                    "suggested_replies": ai_replies,
                                })
                        except asyncio.CancelledError:
                            pass
                        except Exception as e:
                            logger.warning("stage2_upgrade_failed", error=type(e).__name__)

                    active_llm_task = asyncio.create_task(
                        run_stage2_upgrade(
                            target_id=rec_id,
                            eng_res=engine_result,
                            buyer_line=text,
                            state_snap=session.master_state,
                        )
                    )

    except WebSocketDisconnect:
        logger.info("live_chat_ws_disconnect", session_id=session_id, role=role)
    except Exception as e:
        logger.error("live_chat_ws_error", error=type(e).__name__, session_id=session_id)
    finally:
        session.unregister_socket(role, websocket)
        if role == "buyer":
            await broadcast_to_group(session.seller_sockets, {
                "type": "presence",
                "buyer_online": session.is_buyer_online,
                "message": "Buyer disconnected.",
            })
        elif role == "seller":
            await broadcast_to_group(session.buyer_sockets, {
                "type": "presence",
                "seller_online": session.is_seller_online,
                "message": "Seller disconnected.",
            })
