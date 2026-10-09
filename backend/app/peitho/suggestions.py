"""
Peitho Tactical Response Generator — Generates natural suggested replies for human sellers.

Bridges to backend.app.peitho.intel and backend.app.peitho.fallbacks,
providing both string lists for legacy callers and rich SuggestedOption objects
for the enhanced copilot.
"""
from typing import List, Optional, Dict, Any
import structlog

from ..agents.negotiation_engine import EngineResult, NegotiationState
from ..infrastructure.llm.openai_client import OpenRouterClient
from .intel import (
    PeithoIntelClient,
    SuggestedOption,
    generate_tactical_options,
    SuggestionHistoryTracker,
)
from .fallbacks import get_fallback_options, FallbackOption

logger = structlog.get_logger(__name__)


def _get_template_replies(
    action: str,
    counter_price: float,
    quantity: int,
    firmness: int,
) -> List[str]:
    """Fast, deterministic fallback suggestions when LLM is offline or unconfigured."""
    if action == "ACCEPT":
        return [
            f"That sounds fair to me. Let's lock in ${counter_price:.2f} for {quantity} units.",
            f"We have a deal at ${counter_price:.2f}. I'll prepare the invoice right away.",
        ]
    elif action in ("WALK_AWAY", "REJECT"):
        return [
            f"I really appreciate your time, but at that number the margins don't work for us. Our best standing price is ${counter_price:.2f}.",
            f"I understand your constraints, but I can't go below ${counter_price:.2f}. Let me know if that works for you down the road.",
        ]
    else:  # COUNTER
        if firmness >= 2:
            return [
                f"Given the quality and current stock, ${counter_price:.2f} is really our bottom line for {quantity} units.",
                f"I've sharpened my pencil as much as I can — I can do ${counter_price:.2f}, but that is my final position.",
            ]
        elif firmness == 1:
            return [
                f"I can meet you partway at ${counter_price:.2f} per unit if we can confirm the order today.",
                f"How about we split the difference at ${counter_price:.2f}? That keeps it workable on our end.",
            ]
        else:
            return [
                f"I can work with you on price. How does ${counter_price:.2f} per unit sound for {quantity} units?",
                f"I can do ${counter_price:.2f} if we can get the paperwork finalized this week.",
            ]


def _get_template_options(
    action: str,
    counter_price: float,
    quantity: int,
    firmness: int,
    buyer_offer: Optional[float] = None,
) -> List[SuggestedOption]:
    """Retrieve structured template options with intent tags and follow-up hints."""
    raw = get_fallback_options(
        action=action,
        counter_price=counter_price,
        quantity=quantity,
        firmness=firmness,
        buyer_offer=buyer_offer,
    )
    return [
        SuggestedOption(text=opt.text, intent=opt.intent, why=opt.why, followup=opt.followup)
        for opt in raw
    ]


async def generate_tactical_replies(
    engine_result: EngineResult,
    buyer_text: str,
    state: NegotiationState,
    llm_client: Optional[OpenRouterClient] = None,
    history_tracker: Optional[SuggestionHistoryTracker] = None,
    deal_score: int = 50,
    score_band: str = "medium",
    score_drivers: Optional[List[Dict[str, str]]] = None,
    recent_seller_lines: Optional[List[str]] = None,
    open_objections: Optional[List[str]] = None,
) -> List[str]:
    """
    Generate suggested spoken responses for the seller (returns list of strings).
    Preserves exact backwards compatibility with earlier components.
    """
    options = await generate_tactical_options(
        engine_result=engine_result,
        buyer_text=buyer_text,
        state=state,
        history_tracker=history_tracker,
        deal_score=deal_score,
        score_band=score_band,
        score_drivers=score_drivers,
        recent_seller_lines=recent_seller_lines,
        open_objections=open_objections,
        llm_client=llm_client,
    )
    return [opt.text for opt in options]
