"""
Peitho Live Assistant Routes — REST endpoints and dual-channel WebSocket copilot.

Receives audio or text streams from Seller Mic and Buyer Google Meet tab,
computes PRANE-X advisory recommendations, and feeds live suggestions to the seller.
"""
import asyncio
import base64
import json
import os
import re
import time
from typing import Optional
from uuid import uuid4
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException, Query, status
from fastapi.responses import JSONResponse
import structlog

from ..core.config import get_settings
from .schemas import (
    PeithoSessionConfig,
    TranscriptLine,
    ChannelType,
    AdvisoryResult,
    AdvisoryMetrics,
)
from .session_store import peitho_store
from .advisory import AdvisoryEngine
from .normalizer import normalize_transcript
from .suggestions import (
    generate_tactical_replies,
    _get_template_replies,
    _get_template_options,
    PeithoIntelClient,
)
from .intel import generate_tactical_options, SuggestedOption, SuggestionHistoryTracker
from .scoring import DealLikelihoodEngine, DealLikelihoodResult
from .stt import get_stt_adapter, TypedSTTAdapter

logger = structlog.get_logger(__name__)
settings = get_settings()


def is_peitho_debug() -> bool:
    return settings.peitho_debug or os.getenv("PEITHO_DEBUG", "false").lower() in ("true", "1", "yes")


peitho_router = APIRouter(prefix="/api/v1/peitho", tags=["Peitho Live Assistant"])


@peitho_router.post("/start")
async def start_peitho_session(config: PeithoSessionConfig):
    """
    Initialize a new live negotiation session for Peitho.
    Returns session_id to be used in the WebSocket connection.
    """
    session = peitho_store.create_session(config)
    initial_counter = (
        session.master_state.counter_history[-1]
        if session.master_state.counter_history
        else config.base_price
    )
    return {
        "session_id": session.session_id,
        "product_name": config.product_name,
        "base_price": config.base_price,
        "cost_price": config.cost_price,
        "min_floor": config.min_floor,
        "mode": config.mode,
        "max_rounds": config.max_rounds,
        "initial_counter": initial_counter,
        "stt_provider": config.stt_provider or settings.peitho_stt_provider,
        "language": config.language or settings.elevenlabs_language,
        "message": "Peitho session initialized successfully.",
    }


@peitho_router.get("/health")
async def peitho_health():
    """Check Peitho health and STT provider status."""
    has_elevenlabs = bool(settings.elevenlabs_api_key)
    active_sessions = peitho_store.list_active_sessions()
    return {
        "status": "online",
        "stt_provider": settings.peitho_stt_provider,
        "elevenlabs_configured": has_elevenlabs,
        "elevenlabs_model": settings.elevenlabs_stt_model,
        "active_sessions_count": len(active_sessions),
    }


@peitho_router.get("/sessions")
async def list_sessions():
    """List all currently active Peitho sessions."""
    return peitho_store.list_active_sessions()


@peitho_router.get("/sessions/{session_id}")
async def get_session(session_id: str):
    """Retrieve details for a specific session."""
    session = peitho_store.get_session(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or expired",
        )
    return {
        "session_id": session.session_id,
        "product_name": session.config.product_name,
        "is_active": session.is_active,
        "current_round": session.master_state.current_round,
        "max_rounds": session.config.max_rounds,
        "counter_history": session.master_state.counter_history,
        "transcript_count": len(session.transcript_history),
        "last_advisory": session.last_advisory,
    }


@peitho_router.delete("/sessions/{session_id}")
async def delete_session(session_id: str):
    """End and delete a session."""
    deleted = peitho_store.delete_session(session_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found",
        )
    return {"message": "Session closed successfully"}


@peitho_router.websocket("/ws/{session_id}")
async def peitho_websocket(
    websocket: WebSocket,
    session_id: str,
    token: Optional[str] = Query(default=None),
):
    """
    Dual-channel real-time WebSocket for live Meet call copilot.
    
    Streams:
    - Inbound: Seller Mic audio / Buyer Google Meet audio (or typed transcript lines)
    - Outbound: Partial & final transcripts, deterministic advisory updates, and tactical responses
    """
    session = peitho_store.get_session(session_id)
    if not session:
        await websocket.accept()
        await websocket.send_json({
            "type": "error",
            "message": "Peitho session not found or expired. Please create a session first.",
        })
        await websocket.close(code=4004, reason="Session not found")
        return

    await websocket.accept()
    logger.info("peitho_ws_connected", session_id=session_id)

    # State tracking for channels and provider
    channel_states = {
        "provider": (session.config.stt_provider or settings.peitho_stt_provider or "typed").lower(),
        "seller_status": "connecting",
        "seller_reason": "Initializing seller audio channel...",
        "buyer_status": "connecting",
        "buyer_reason": "Initializing buyer audio channel...",
    }

    ws_lock = asyncio.Lock()

    async def safe_send(payload: dict):
        async with ws_lock:
            try:
                await websocket.send_json(payload)
            except Exception as e:
                logger.debug("peitho_ws_send_failed", error_type=type(e).__name__)

    async def broadcast_state():
        await safe_send({
            "type": "state",
            "stt_provider": channel_states["provider"],
            "seller_status": channel_states["seller_status"],
            "seller_reason": channel_states["seller_reason"],
            "buyer_status": channel_states["buyer_status"],
            "buyer_reason": channel_states["buyer_reason"],
        })

    def on_seller_status(status: str, reason: str = ""):
        channel_states["seller_status"] = status
        channel_states["seller_reason"] = reason or f"Seller channel is {status}"
        asyncio.create_task(broadcast_state())

    def on_buyer_status(status: str, reason: str = ""):
        channel_states["buyer_status"] = status
        channel_states["buyer_reason"] = reason or f"Buyer channel is {status}"
        asyncio.create_task(broadcast_state())

    # State tracking and optimization caches
    speculative_cache: dict = {}
    active_llm_task: Optional[asyncio.Task] = None
    intel_client = PeithoIntelClient()
    last_processed_rec_id: Optional[str] = None

    # Ensure in-memory scoring engine and history tracker exist for this session
    if session.scoring_engine is None:
        session.scoring_engine = DealLikelihoodEngine(session_id)
    if session.history_tracker is None:
        session.history_tracker = SuggestionHistoryTracker(window_turns=3)

    seller_is_speaking = False
    pending_advisory_payload: Optional[dict] = None

    # Instantiate initial STT adapters with session language preference
    stt_choice = channel_states["provider"]
    session_lang = session.config.language or settings.elevenlabs_language
    seller_stt = get_stt_adapter(
        provider=stt_choice,
        channel="SELLER",
        on_status_change=on_seller_status,
        language_code=session_lang,
    )
    buyer_stt = get_stt_adapter(
        provider=stt_choice,
        channel="BUYER",
        on_status_change=on_buyer_status,
        language_code=session_lang,
    )

    # Send initial connection acknowledgment
    await websocket.send_json({
        "type": "ready",
        "session_id": session_id,
        "product_name": session.config.product_name,
        "base_price": session.config.base_price,
        "current_counter": (
            session.master_state.counter_history[-1]
            if session.master_state.counter_history
            else session.config.base_price
        ),
        "stt_provider": seller_stt.__class__.__name__,
        "language": session_lang,
        "message": "Connected to Peitho copilot. Audio capture active.",
    })

    # Task done callback logging exception type only
    def task_done_logger(t: asyncio.Task) -> None:
        if not t.cancelled():
            exc = t.exception()
            if exc:
                logger.error("peitho_async_task_error", error_type=type(exc).__name__)

    # ── Register SELLER STT Callbacks ──
    async def on_seller_partial(text: str):
        nonlocal seller_is_speaking
        seller_is_speaking = True
        await safe_send({
            "type": "partial_transcript",
            "channel": ChannelType.SELLER.value,
            "text": text,
        })

    async def on_seller_final(text: str):
        nonlocal seller_is_speaking, pending_advisory_payload
        seller_is_speaking = False
        session.seller_recent_quotes.append(text)
        if len(session.seller_recent_quotes) > 6:
            session.seller_recent_quotes.pop(0)

        line = TranscriptLine(
            channel=ChannelType.SELLER,
            text=text,
            is_partial=False,
            timestamp=time.time(),
        )
        session.transcript_history.append(line)

        await safe_send({
            "type": "final_transcript",
            "id": line.id,
            "channel": ChannelType.SELLER.value,
            "text": text,
            "timestamp": line.timestamp,
        })

        detected_price = AdvisoryEngine.apply_seller_line(session.master_state, text)
        if detected_price is not None:
            await safe_send({
                "type": "seller_update",
                "detected_price": detected_price,
                "current_counter": session.master_state.counter_history[-1],
                "round": session.master_state.current_round,
            })

        # Release queued suggestion once the seller pauses speaking
        if pending_advisory_payload is not None:
            to_flush = pending_advisory_payload
            pending_advisory_payload = None
            to_flush["seller_speaking"] = False
            await safe_send(to_flush)

    # ── Register BUYER STT Callbacks with Speculative Pre-Compute & Two-Stage Push ──
    async def on_buyer_partial(text: str):
        await safe_send({
            "type": "partial_transcript",
            "channel": ChannelType.BUYER.value,
            "text": text,
        })

        # Intra-turn provisional Deal Likelihood score nudge
        if session.scoring_engine and text:
            prov = session.scoring_engine.compute_provisional_nudge(text)
            if prov:
                await safe_send({
                    "type": "buyer_score",
                    "call_id": session_id,
                    "turn": session.scoring_engine.turn_count,
                    "score": prov.score,
                    "band": prov.band,
                    "trend": prov.trend,
                    "delta": prov.delta,
                    "confidence": prov.confidence,
                    "provisional": True,
                    "drivers": prov.drivers,
                    "history": prov.history,
                })

        # Speculative pre-compute: if partial utterance has numbers/price clues, evaluate in background
        if text and any(char.isdigit() for char in text):
            try:
                norm = normalize_transcript(text)
                cur_counter = (
                    session.master_state.counter_history[-1]
                    if session.master_state.counter_history
                    else session.config.base_price
                )
                ext = AdvisoryEngine.extract_intent_from_text(
                    norm,
                    base_price=session.config.base_price,
                    current_counter=cur_counter,
                    current_quantity=session.config.quantity,
                )
                cand_price = ext.get("unit_price_offered")
                if cand_price is not None and cand_price not in speculative_cache:
                    eng_res, _ = AdvisoryEngine.advise(session.master_state, buyer_text=text)
                    speculative_cache[cand_price] = (eng_res, ext)
            except Exception:
                pass

    async def on_buyer_final(text: str):
        nonlocal active_llm_task, last_processed_rec_id, pending_advisory_payload
        t2 = time.time()
        # Retrieve t0 from buyer_stt if available
        t0 = getattr(buyer_stt, "_last_audio_send_time", t2)

        # Buyer interrupted or spoke again: clear any pending stale queued suggestion
        pending_advisory_payload = None

        # ── VAD Merge Guard ──
        # If previous line was BUYER within 1.0s and lacked terminal punctuation (. ! ?),
        # merge with this line to treat as a continuous turn.
        prev_line = session.transcript_history[-1] if session.transcript_history else None
        is_merge = False
        if (
            prev_line
            and prev_line.channel == ChannelType.BUYER
            and (t2 - prev_line.timestamp) <= 1.0
            and not prev_line.text.rstrip().endswith((".", "!", "?"))
        ):
            # Cancel prior in-flight Stage 2 task
            if active_llm_task and not active_llm_task.done():
                active_llm_task.cancel()

            merged_text = f"{prev_line.text.rstrip()} {text.lstrip()}"
            prev_line.text = merged_text
            prev_line.timestamp = t2
            effective_text = merged_text
            line_id = prev_line.id
            is_merge = True
        else:
            line = TranscriptLine(
                channel=ChannelType.BUYER,
                text=text,
                is_partial=False,
                timestamp=t2,
            )
            session.transcript_history.append(line)
            effective_text = text
            line_id = line.id

        await safe_send({
            "type": "final_transcript",
            "id": line_id,
            "channel": ChannelType.BUYER.value,
            "text": effective_text,
            "timestamp": t2,
            "is_merged": is_merge,
        })

        # ── Update Objections State ──
        lower_eff = effective_text.lower()
        if any(w in lower_eff for w in ("expensive", "too high", "over budget", "cheaper", "discount", "can't afford")):
            if "price" not in session.open_objections:
                session.open_objections.append("price")
        if any(w in lower_eff for w in ("shipping", "delivery", "timeline", "lead time", "slow")):
            if "delivery" not in session.open_objections:
                session.open_objections.append("delivery")
        if any(w in lower_eff for w in ("deal", "agreed", "done", "sounds good", "take it", "accept")):
            session.resolved_objections.extend(session.open_objections)
            session.open_objections.clear()

        # ── STAGE 1: IMMEDIATE TEMPLATE RECOMMENDATION & SCORE (< 10 ms) ──
        try:
            norm_text = normalize_transcript(effective_text)
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
            if offered_p is not None and offered_p in speculative_cache:
                engine_result, cached_ext = speculative_cache[offered_p]
                speculative_cache.clear()
            else:
                speculative_cache.clear()
                engine_result, extraction = AdvisoryEngine.advise(
                    session.master_state,
                    buyer_text=effective_text,
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
            velocity = 0.0
            if len(buyer_offers) >= 2:
                velocity = round(buyer_offers[-1] - buyer_offers[-2], 2)

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

            # ── Calculate Deal Likelihood Score ──
            intel_signals = {
                "sentiment": (
                    "positive" if any(w in lower_eff for w in ("great", "good", "agree", "fair", "works", "deal", "perfect"))
                    else ("negative" if any(w in lower_eff for w in ("too much", "high", "expensive", "cannot", "no way", "terrible"))
                    else "neutral")
                ),
                "buying_signal": (
                    "high" if any(w in lower_eff for w in ("ready", "buy", "order", "invoice", "deal", "send", "take it"))
                    else ("low" if any(w in lower_eff for w in ("walk", "leave", "forget it", "pass", "no thanks"))
                    else "medium")
                ),
                "open_objections_count": len(session.open_objections),
                "resolved_objections_count": len(session.resolved_objections),
                "urgency_signal": bool(re.search(r"\b(?:urgent|today|asap|this week|immediately|need it fast)\b", lower_eff)),
                "commitment_made": bool(re.search(r"\b(?:will buy|ready to purchase|commit|signing|take \d+)\b", lower_eff)),
                "competitor_mention": bool(re.search(r"\b(?:competitor|other vendor|alternate|cheaper elsewhere|another quote)\b", lower_eff)),
            }

            dl_result = session.scoring_engine.evaluate(
                state=session.master_state,
                engine_result=engine_result,
                intel_data=intel_signals,
                extraction=extraction,
            )
            session.last_buyer_score = {
                "score": dl_result.score,
                "band": dl_result.band,
                "trend": dl_result.trend,
                "delta": dl_result.delta,
                "confidence": dl_result.confidence,
                "drivers": dl_result.drivers,
                "history": dl_result.history,
            }

            # Emit buyer_score message immediately
            await safe_send({
                "type": "buyer_score",
                "call_id": session_id,
                "turn": session.scoring_engine.turn_count,
                "score": dl_result.score,
                "band": dl_result.band,
                "trend": dl_result.trend,
                "delta": dl_result.delta,
                "confidence": dl_result.confidence,
                "provisional": False,
                "drivers": dl_result.drivers,
                "history": dl_result.history,
                "buyer_state": {
                    "sentiment": intel_signals["sentiment"],
                    "buying_signal": intel_signals["buying_signal"],
                    "open_objections": intel_signals["open_objections_count"],
                },
            })

            # ── Template Options (Stage 1) ──
            template_options_objs = _get_template_options(
                action=action_str,
                counter_price=counter_val,
                quantity=session.config.quantity,
                firmness=session.master_state.firmness_level,
                buyer_offer=extraction.get("unit_price_offered"),
            )
            template_replies = [opt.text for opt in template_options_objs]
            template_options_dicts = [opt.to_dict() for opt in template_options_objs]

            t5 = time.time()
            rec_id = str(uuid4())
            last_processed_rec_id = rec_id

            timing_stage1 = {
                "t0": round(t0 * 1000, 2),
                "t2": round(t2 * 1000, 2),
                "t5": round(t5 * 1000, 2),
                "t0_to_t2_ms": round((t2 - t0) * 1000, 2),
                "t2_to_t5_ms": round((t5 - t2) * 1000, 2),
            }

            # Check if deal is lockable (buyer agreed / near target and >= min_floor)
            buyer_price = extraction.get("unit_price_offered")
            has_agreement_cue = any(
                w in lower_eff for w in ("deal", "agree", "done", "take it", "sounds good", "accept", "lock", "fair", "fine", "ok", "okay", "let's do it", "we have a deal")
            )
            min_floor_val = float(session.config.min_floor)
            is_deal_lockable = False
            lockable_price = counter_val
            lock_reason = ""

            if action_str == "ACCEPT":
                is_deal_lockable = True
                lockable_price = buyer_price if (buyer_price and buyer_price >= min_floor_val) else counter_val
                lock_reason = "Engine recommended ACCEPT: Favorable terms reached"
            elif buyer_price is not None and buyer_price >= min_floor_val:
                gap_ratio = (counter_val - buyer_price) / max(counter_val, 1.0)
                if buyer_price >= counter_val:
                    is_deal_lockable = True
                    lockable_price = buyer_price
                    lock_reason = "Buyer offer meets or exceeds target quote"
                elif gap_ratio <= 0.10 and (has_agreement_cue or dl_result.score >= 70):
                    is_deal_lockable = True
                    lockable_price = buyer_price
                    lock_reason = "Buyer agreed near target counter"

            advisory = AdvisoryResult(
                action=action_str,
                counter_price=counter_val,
                walk_away=is_walk_away,
                reasoning=reasoning_str,
                extracted_buyer_offer=extraction.get("unit_price_offered"),
                extracted_buyer_intent=extraction.get("intent"),
                extracted_quantity=extraction.get("quantity"),
                suggested_replies=template_replies,
                options=template_options_dicts,
                buyer_score=dl_result.score,
                buyer_score_band=dl_result.band,
                deal_lockable=is_deal_lockable,
                lockable_price=round(lockable_price, 2) if is_deal_lockable else None,
                lock_reason=lock_reason or None,
                metrics=metrics,
                timestamp=t5,
                recommendation_id=rec_id,
                source="template",
                timing=timing_stage1,
            )
            session.last_advisory = advisory

            advisory_payload = {
                "type": "advisory",
                "data": advisory.model_dump(),
                "recommendation_id": rec_id,
                "source": "template",
                "timing": timing_stage1,
                "options": template_options_dicts,
                "deal_lockable": is_deal_lockable,
                "lockable_price": round(lockable_price, 2) if is_deal_lockable else None,
                "lock_reason": lock_reason or None,
                "seller_speaking": seller_is_speaking,
            }

            # If seller is actively speaking, queue the suggestion card until they pause
            if seller_is_speaking:
                pending_advisory_payload = advisory_payload
            else:
                await safe_send(advisory_payload)

            if is_peitho_debug():
                logger.info(
                    "peitho_stage1_pushed",
                    rec_id=rec_id,
                    t2_to_t5_ms=timing_stage1["t2_to_t5_ms"],
                    action=action_str,
                )

        except Exception as e:
            logger.error("buyer_advisory_stage1_failed", error_type=type(e).__name__)
            return

        # ── STAGE 2: ASYNC AI UPGRADE (CONCURRENT) ──
        if active_llm_task and not active_llm_task.done():
            active_llm_task.cancel()

        async def run_stage2_upgrade(
            target_rec_id: str,
            eng_res: any,
            buyer_msg: str,
            st: any,
            start_t0: float,
            start_t2: float,
            start_t5: float,
            current_score: int,
            current_band: str,
            current_drivers: list,
        ):
            try:
                ai_options_objs = await generate_tactical_options(
                    engine_result=eng_res,
                    buyer_text=buyer_msg,
                    state=st,
                    history_tracker=session.history_tracker,
                    deal_score=current_score,
                    score_band=current_band,
                    score_drivers=current_drivers,
                    recent_seller_lines=session.seller_recent_quotes,
                    open_objections=session.open_objections,
                    llm_client=intel_client,
                )
                ai_replies = [opt.text for opt in ai_options_objs]
                ai_options_dicts = [opt.to_dict() for opt in ai_options_objs]

                t7 = time.time()
                timing_stage2 = {
                    "t0": round(start_t0 * 1000, 2),
                    "t2": round(start_t2 * 1000, 2),
                    "t5": round(start_t5 * 1000, 2),
                    "t7": round(t7 * 1000, 2),
                    "t2_to_t7_ms": round((t7 - start_t2) * 1000, 2),
                    "t0_to_t7_ms": round((t7 - start_t0) * 1000, 2),
                }

                if target_rec_id == last_processed_rec_id:
                    if session.last_advisory and session.last_advisory.recommendation_id == target_rec_id:
                        session.last_advisory.suggested_replies = ai_replies
                        session.last_advisory.options = ai_options_dicts
                        session.last_advisory.source = "ai"
                        session.last_advisory.timing = timing_stage2

                    rec_update_msg = {
                        "type": "recommendation_update",
                        "recommendation_id": target_rec_id,
                        "source": "ai",
                        "suggested_replies": ai_replies,
                        "options": ai_options_dicts,
                        "timing": timing_stage2,
                    }

                    if seller_is_speaking and pending_advisory_payload is not None:
                        # If seller is still speaking, upgrade the queued payload with AI options
                        if pending_advisory_payload.get("recommendation_id") == target_rec_id:
                            pending_advisory_payload["data"]["suggested_replies"] = ai_replies
                            pending_advisory_payload["data"]["options"] = ai_options_dicts
                            pending_advisory_payload["data"]["source"] = "ai"
                            pending_advisory_payload["options"] = ai_options_dicts
                    else:
                        await safe_send(rec_update_msg)

                    if is_peitho_debug():
                        logger.info(
                            "peitho_stage2_upgraded",
                            rec_id=target_rec_id,
                            t2_to_t7_ms=timing_stage2["t2_to_t7_ms"],
                        )
            except asyncio.CancelledError:
                pass
            except Exception as e:
                logger.warning("peitho_stage2_failed", error_type=type(e).__name__)

        active_llm_task = asyncio.create_task(
            run_stage2_upgrade(
                target_rec_id=rec_id,
                eng_res=engine_result,
                buyer_msg=effective_text,
                st=session.master_state,
                start_t0=t0,
                start_t2=t2,
                start_t5=t5,
                current_score=dl_result.score,
                current_band=dl_result.band,
                current_drivers=dl_result.drivers,
            )
        )
        active_llm_task.add_done_callback(task_done_logger)

    def bind_adapters(s_adapter, b_adapter):
        s_adapter.on_partial(on_seller_partial)
        s_adapter.on_final(on_seller_final)
        b_adapter.on_partial(on_buyer_partial)
        b_adapter.on_final(on_buyer_final)

    bind_adapters(seller_stt, buyer_stt)

    # Start STT adapters
    await seller_stt.start()
    await buyer_stt.start()

    # Fallback check: if elevenlabs failed to activate, fall back to Sarvam, then Typed
    if channel_states["provider"] == "elevenlabs" and (not seller_stt.is_active or not buyer_stt.is_active):
        if settings.sarvam_api_key:
            logger.warning("elevenlabs_failed_falling_back_to_sarvam")
            channel_states["provider"] = "sarvam"
            try:
                await seller_stt.close()
                await buyer_stt.close()
            except Exception:
                pass
            seller_stt = get_stt_adapter(provider="sarvam", channel="SELLER", on_status_change=on_seller_status)
            buyer_stt = get_stt_adapter(provider="sarvam", channel="BUYER", on_status_change=on_buyer_status)
            bind_adapters(seller_stt, buyer_stt)
            await seller_stt.start()
            await buyer_stt.start()
        else:
            logger.warning("elevenlabs_failed_falling_back_to_typed")
            channel_states["provider"] = "typed"
            channel_states["seller_status"] = "live"
            channel_states["seller_reason"] = "Typed input fallback active"
            channel_states["buyer_status"] = "live"
            channel_states["buyer_reason"] = "Typed input fallback active"

    await broadcast_state()

    try:
        while True:
            raw_text = await websocket.receive_text()
            try:
                msg = json.loads(raw_text)
            except Exception:
                continue

            msg_type = msg.get("type")

            if msg_type == "audio":
                # Audio chunk from seller mic or buyer tab
                ch = str(msg.get("channel", "BUYER")).strip().upper()
                is_seller = ch in ("SELLER", "MIC")
                b64_data = msg.get("data", "")
                if b64_data:
                    try:
                        pcm_bytes = base64.b64decode(b64_data)
                        if is_seller:
                            await seller_stt.send_audio(pcm_bytes)
                        else:
                            await buyer_stt.send_audio(pcm_bytes)
                    except Exception as e:
                        logger.error("audio_decode_error", error_type=type(e).__name__)

            elif msg_type in ("transcript_line", "typed_line"):
                # Direct typed text injection (fallback or testing mode)
                ch = str(msg.get("channel", "BUYER")).strip().upper()
                is_seller = ch in ("SELLER", "MIC")
                text_content = msg.get("text", "")
                is_final = msg.get("is_final", True)

                target_adapter = seller_stt if is_seller else buyer_stt
                if isinstance(target_adapter, TypedSTTAdapter):
                    await target_adapter.send_text(text_content, is_final=is_final)
                else:
                    if is_seller:
                        if is_final:
                            await on_seller_final(text_content)
                        else:
                            await on_seller_partial(text_content)
                    else:
                        if is_final:
                            await on_buyer_final(text_content)
                        else:
                            await on_buyer_partial(text_content)

            elif msg_type == "ping":
                await safe_send({
                    "type": "pong",
                    "ts": time.time(),
                })

            elif msg_type == "lock_deal":
                agreed_p = float(msg.get("agreed_price") or (session.master_state.counter_history[-1] if session.master_state.counter_history else session.config.base_price))
                logger.info("peitho_deal_locked", session_id=session_id)
                session.master_state.session_terminated = True
                await safe_send({
                    "type": "deal_locked",
                    "call_id": session_id,
                    "agreed_price": round(agreed_p, 2),
                    "quantity": session.config.quantity,
                    "total_value": round(agreed_p * session.config.quantity, 2),
                    "timestamp": time.time(),
                })

            elif msg_type == "end_call":
                logger.info("peitho_call_ended_by_user", session_id=session_id)
                await safe_send({
                    "type": "call_ended",
                    "session_id": session_id,
                })
                break

    except WebSocketDisconnect:
        logger.info("peitho_ws_disconnected", session_id=session_id)
    except Exception as e:
        logger.error("peitho_ws_unhandled_error", error_type=type(e).__name__, session_id=session_id)
    finally:
        try:
            await seller_stt.close()
            await buyer_stt.close()
        except Exception:
            pass

