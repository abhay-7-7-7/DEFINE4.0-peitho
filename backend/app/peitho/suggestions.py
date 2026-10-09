"""
Peitho Tactical Response Generator — Generates natural suggested replies and AI deal diagnostics.
Supports direct Gemini 2.0 Flash, OpenRouter, and polished deterministic template fallback.
"""
import os
import json
from typing import Dict, List, Optional, Tuple, Any
import structlog

from ..agents.negotiation_engine import EngineResult, NegotiationState
from ..infrastructure.llm.openai_client import OpenRouterClient
from ..infrastructure.llm.gemini_direct import GeminiDirectClient

logger = structlog.get_logger(__name__)

SUGGESTION_SYSTEM_PROMPT = """You are an elite commercial sales executive and negotiation strategist whispering live tactical guidance to a seller chatting with a buyer.
The pricing engine has already calculated the strategic decision and exact target counter price.
You must return a JSON object with:
1. "executive_summary": A concise 1-2 sentence commercial diagnostic analyzing the buyer's posture, current margin health, and recommended tactic.
2. "replies": A list of 3 distinct, natural, realistic chat responses the seller can send to the buyer right now:
   - Reply 1 (Value-Add Compromise): Confidently presents counter price with strong product value or warranty justification.
   - Reply 2 (Conditional Closer): Offers counter price tied to quick commitment (e.g. closing today or confirming order).
   - Reply 3 (Firm Boundary): A polite but firm commercial boundary maintaining price integrity without offending the buyer.

CRITICAL RULES:
- Never contradict the engine action or counter price.
- If quantity is 1, write "1 unit" (NEVER "1 units").
- Never use robotic corporate buzzwords. Sound like a sharp, professional human seller.
- Return ONLY valid JSON matching: {"executive_summary": "...", "replies": ["...", "...", "..."]}"""

SUGGESTION_USER_TEMPLATE = """DEAL CONTEXT:
- Product: {product_name}
- Listed Asking Price: ${base_price}
- Cost Price: ${cost_price} | Walk-Away Floor: ${min_floor}
- Strategy Action: {action}
- Target Counter: ${counter_price}
- Deal Quantity: {quantity} unit{s_suffix}
- Buyer Message: \"\"\"{buyer_message}\"\"\"
- Round: {round_num}/{max_rounds} (Firmness: {firmness}/3)

Generate executive summary and 3 realistic chat replies."""


class PeithoIntelClient(OpenRouterClient):
    """Specialized OpenRouter client tailored for Peitho live tactical copilot."""
    def __init__(self):
        super().__init__()
        from ..core.config import get_settings
        settings = get_settings()
        self.model = settings.peitho_intel_model or self.model
        self.max_tokens = settings.peitho_intel_max_tokens
        self.timeout = settings.peitho_intel_timeout_seconds


def _get_template_diagnostic(
    action: str,
    counter_price: float,
    base_price: float,
    cost_price: float,
    min_floor: float,
    quantity: int,
    firmness: int,
    round_num: int,
) -> Tuple[str, List[str]]:
    """Deterministic, grammatically clean fallback replies and executive summary."""
    unit_label = f"{quantity} unit{'s' if quantity > 1 else ''}"
    margin_cushion = round(counter_price - cost_price, 2)
    margin_pct = round((margin_cushion / counter_price * 100.0), 1) if counter_price > 0 else 0.0

    if action == "ACCEPT":
        summary = (
            f"Buyer terms are acceptable. Deal secured at ${counter_price:.2f} per unit "
            f"yielding +${margin_cushion:.2f} profit (+{margin_pct}% margin)."
        )
        replies = [
            f"That sounds fair to me. Let's lock in ${counter_price:.2f} for {unit_label}.",
            f"We have a deal at ${counter_price:.2f}. I'll prepare the paperwork right away.",
            f"Agreed at ${counter_price:.2f}. Thank you for working with us on this order.",
        ]
    elif action in ("WALK_AWAY", "REJECT"):
        summary = (
            f"Buyer offer violates your commercial thresholds. Standing firm at ${counter_price:.2f} "
            f"to protect the ${min_floor:.2f} minimum survival floor."
        )
        replies = [
            f"I really appreciate your interest, but at that number the margins don't work for us. Our best standing price is ${counter_price:.2f}.",
            f"I understand your budget constraints, but we cannot go below ${counter_price:.2f} without operating at an unviable margin.",
            f"Our component and operating costs don't allow that price point. Let me know if ${counter_price:.2f} works for you down the road.",
        ]
    else:  # COUNTER
        is_anchor_hold = abs(counter_price - base_price) < 0.01

        if is_anchor_hold:
            summary = (
                f"Initial exploration round. Holding firm on ${counter_price:.2f} asking price "
                f"to gauge buyer flexibility and defend full margin."
            )
            replies = [
                f"Our standard listed price is ${counter_price:.2f} for {unit_label}, which includes full warranty and priority support.",
                f"We typically hold firm at ${counter_price:.2f} for {unit_label}, but I'm happy to discuss what order volume or timeline you have in mind.",
                f"At ${counter_price:.2f}, this reflects our guaranteed tier-one quality and immediate dispatch.",
            ]
        elif firmness >= 2:
            summary = (
                f"High firmness active (Round {round_num}). Near concession ceiling. "
                f"Countering at ${counter_price:.2f} to signal our final bottom line."
            )
            replies = [
                f"Given current inventory and demand, ${counter_price:.2f} is really our bottom line for {unit_label}.",
                f"I've sharpened my pencil as much as possible — ${counter_price:.2f} is our final position.",
                f"We can confirm the order at ${counter_price:.2f}, but we cannot concede further on this item.",
            ]
        elif firmness == 1:
            summary = (
                f"Intermediate negotiation phase. Conceding moderately to ${counter_price:.2f} "
                f"(maintaining +{margin_pct}% margin) to incentivize closing."
            )
            replies = [
                f"I can meet you partway at ${counter_price:.2f} per unit if we can confirm the order today.",
                f"How about we split the difference at ${counter_price:.2f}? That keeps it workable on our end.",
                f"I can adjust the price to ${counter_price:.2f} for {unit_label} if that works for your timeline.",
            ]
        else:
            summary = (
                f"Early negotiation round. Exploring compromise at ${counter_price:.2f} "
                f"with substantial profit protection."
            )
            replies = [
                f"I'm willing to work with you on price. How does ${counter_price:.2f} per unit sound for {unit_label}?",
                f"I can do ${counter_price:.2f} if we can get the paperwork finalized this week.",
                f"Let's see if we can meet at ${counter_price:.2f} for {unit_label}. That works within our current tier.",
            ]

    return summary, replies


def _get_template_replies(
    action: str,
    counter_price: float,
    quantity: int,
    firmness: int,
) -> List[str]:
    """Backward-compatible helper returning list of replies."""
    _, replies = _get_template_diagnostic(
        action=action,
        counter_price=counter_price,
        base_price=counter_price,
        cost_price=counter_price * 0.5,
        min_floor=counter_price * 0.6,
        quantity=quantity,
        firmness=firmness,
        round_num=1,
    )
    return replies


async def generate_tactical_intelligence(
    engine_result: EngineResult,
    buyer_text: str,
    state: NegotiationState,
    product_name: str = "Standard Product",
    llm_client: Optional[Any] = None,
    gemini_key: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Generate comprehensive AI negotiation intelligence:
    Returns dict: {"executive_summary": str, "replies": List[str], "source": "ai" | "template"}
    """
    counter_val = float(
        getattr(engine_result, "counter_unit_price", None)
        if getattr(engine_result, "counter_unit_price", None) is not None
        else state.base_price
    )
    decision_raw = str(getattr(engine_result, "decision", "counter")).upper()
    if decision_raw in ("ACCEPT", "REJECT", "FINAL_OFFER"):
        action_val = decision_raw
    else:
        action_val = "COUNTER"

    # Default template baseline
    fallback_summary, fallback_replies = _get_template_diagnostic(
        action=action_val,
        counter_price=counter_val,
        base_price=state.base_price,
        cost_price=state.cost_price,
        min_floor=state.min_floor,
        quantity=state.quantity,
        firmness=state.firmness_level,
        round_num=state.current_round + 1,
    )

    prompt = SUGGESTION_USER_TEMPLATE.format(
        product_name=product_name,
        base_price=f"{state.base_price:.2f}",
        cost_price=f"{state.cost_price:.2f}",
        min_floor=f"{state.min_floor:.2f}",
        action=action_val,
        counter_price=f"{counter_val:.2f}",
        quantity=state.quantity,
        s_suffix="s" if state.quantity > 1 else "",
        buyer_message=buyer_text,
        round_num=state.current_round + 1,
        max_rounds=state.max_rounds,
        firmness=state.firmness_level,
    )

    # 1. Try Gemini 2.0 Flash first (fastest and highest quality)
    effective_gemini_key = gemini_key or os.getenv("GEMINI_API_KEY", "").strip()
    if effective_gemini_key:
        try:
            gemini = GeminiDirectClient(api_key=effective_gemini_key)
            result = await gemini.generate_json(
                system_instruction=SUGGESTION_SYSTEM_PROMPT,
                prompt=prompt,
            )
            if result and isinstance(result, dict):
                summary = result.get("executive_summary", fallback_summary)
                replies = result.get("replies", [])
                if isinstance(replies, list) and len(replies) > 0:
                    cleaned_replies = [str(r).strip() for r in replies if str(r).strip()][:3]
                    if cleaned_replies:
                        return {
                            "executive_summary": summary,
                            "replies": cleaned_replies,
                            "source": "ai",
                        }
        except Exception as e:
            logger.warning("gemini_generation_failed", error=str(e))

    # 2. Try OpenRouter client if enabled
    client = llm_client or PeithoIntelClient()
    if getattr(client, "enabled", False):
        try:
            resp = await client.generate(
                system_prompt=SUGGESTION_SYSTEM_PROMPT,
                user_prompt=prompt,
                temperature=0.6,
            )
            if resp.success and resp.content:
                raw = resp.content.strip()
                if raw.startswith("```"):
                    lines = raw.splitlines()
                    raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])
                parsed = json.loads(raw)
                if isinstance(parsed, dict):
                    summary = parsed.get("executive_summary", fallback_summary)
                    replies = parsed.get("replies", [])
                    if isinstance(replies, list) and len(replies) > 0:
                        cleaned = [str(r).strip() for r in replies if str(r).strip()][:3]
                        if cleaned:
                            return {
                                "executive_summary": summary,
                                "replies": cleaned,
                                "source": "ai",
                            }
        except Exception as e:
            logger.warning("openrouter_generation_failed", error=str(e))

    return {
        "executive_summary": fallback_summary,
        "replies": fallback_replies,
        "source": "template",
    }


async def generate_tactical_replies(
    engine_result: EngineResult,
    buyer_text: str,
    state: NegotiationState,
    llm_client: Optional[OpenRouterClient] = None,
) -> List[str]:
    """Compatibility wrapper returning list of replies."""
    intel = await generate_tactical_intelligence(
        engine_result=engine_result,
        buyer_text=buyer_text,
        state=state,
        llm_client=llm_client,
    )
    return intel.get("replies", [])
