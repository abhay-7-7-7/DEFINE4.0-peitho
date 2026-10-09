"""
Peitho Live Tactical Intelligence Engine — Real-time tactical suggestion generation.

Produces up to 3 context-aware, intent-classified suggestions:
- HOLD: Defend current price with value or terms.
- BRIDGE: Concession or non-price trade (delivery, warranty, payment terms, bundle).
- CLOSE: Advance toward final agreement.
- PROBE: Clarify objection, budget, or timeline without leaking margin.

RULES:
- Zero cost/margin/floor leaks into prompts or suggestions.
- All numbers must trace strictly to FACTS (engine counter, buyer numbers, quantity).
- Async LLM client only.
- Suggestions never repeat across 3 turns.
- Deterministic template fallback on error or offline.
"""
from __future__ import annotations

import json
import re
from typing import Dict, List, Optional, Any, Set
from dataclasses import dataclass, field
import structlog

from ..agents.negotiation_engine import NegotiationState, EngineResult
from ..infrastructure.llm.openai_client import OpenRouterClient
from .fallbacks import get_fallback_options, FallbackOption

logger = structlog.get_logger(__name__)

INTEL_SYSTEM_PROMPT = """You are an elite live negotiation copilot whispering real-time tactical spoken options to a human seller on Google Meet.
The pricing engine has already calculated the strategic decision and the exact counter quote.
Generate up to 3 distinct, spoken-language options for the seller.

Output ONLY a JSON array of up to 3 objects with this exact structure:
[
  {
    "text": "Spoken line in seller's voice (< 25 words)",
    "intent": "hold|bridge|close|probe",
    "why": "One sentence explaining tactical rationale",
    "followup": "If buyer says X, then Y (provide for the top option only, null for others)"
  }
]

STRICT RULES:
1. NEVER mention or reference cost price, margin, floor price, or internal limits.
2. ONLY use numbers from FACTS (the exact Counter Price, Buyer's stated numbers, Quantity). Never invent new discount numbers.
3. Permitted Intents:
   - For REJECT or FINAL_OFFER (firmness=3): DO NOT suggest any discount. Only HOLD, PROBE, or standing counter.
   - For ACCEPT: Suggest closing line and confirmation of order terms.
   - For COUNTER: Suggest diverse mix of HOLD, BRIDGE (trade non-price value like delivery/warranty/terms), and PROBE.
4. Voice & Style: Conversational, confident, punchy spoken English (< 25 words per text). No corporate jargon.
5. Context: Do NOT repeat or contradict previous seller statements. Address active objections. Match the deal likelihood tone.
6. Return ONLY the raw JSON array without markdown formatting."""

INTEL_USER_TEMPLATE = """FACTS:
- Engine Action: {action}
- Counter Price: ${counter_price:.2f} (Qty: {quantity})
- Strategy Guidance: {strategy_tag}
- Deal Likelihood: {deal_score}/100 ({score_band})
- Key Score Drivers: {score_drivers}
- Buyer Stated: \"\"\"{buyer_text}\"\"\"
- Open Objections: {objections}
- Recent Seller Quotes: {recent_seller_statements}
- Round: {current_round}/{max_rounds}
- Firmness: {firmness}/3

Options:"""

LEAK_PHRASES = (
    "cost price", "our cost", "profit margin", "margin is", "floor price",
    "minimum price", "below floor", "cannot go below our cost", "margin buffer",
    "internal threshold", "dynamic floor", "breakeven", "break-even"
)


@dataclass
class SuggestedOption:
    text: str
    intent: str
    why: str
    followup: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "text": self.text,
            "intent": self.intent.lower(),
            "why": self.why,
            "followup": self.followup,
        }


class PeithoIntelClient(OpenRouterClient):
    """Specialized async OpenRouter client for Peitho live tactical copilot."""
    def __init__(self):
        super().__init__()
        from ..core.config import get_settings
        settings = get_settings()
        self.model = settings.peitho_intel_model or self.model
        self.max_tokens = settings.peitho_intel_max_tokens or 350
        self.timeout = settings.peitho_intel_timeout_seconds or 12.0


class SuggestionHistoryTracker:
    """Tracks recently shown suggestions per session to prevent repetition across turns."""

    def __init__(self, window_turns: int = 3):
        self.window_turns = window_turns
        # History queue: list of sets of normalized suggestion texts
        self._history: List[Set[str]] = []

    def _normalize(self, text: str) -> str:
        return re.sub(r"[^a-z0-9]", "", text.lower())

    def record_turn_options(self, options: List[str]):
        normalized_set = {self._normalize(opt) for opt in options if opt}
        self._history.append(normalized_set)
        if len(self._history) > self.window_turns:
            self._history.pop(0)

    def is_repeated(self, text: str) -> bool:
        norm = self._normalize(text)
        for past_set in self._history:
            if norm in past_set:
                return True
        return False


def _validate_option_security(
    option: SuggestedOption,
    counter_price: float,
    quantity: int,
    buyer_offer: Optional[float],
) -> bool:
    """
    Ensure suggestion has no leak phrases, word count is within bounds,
    and numbers only refer to allowed FACTS.
    """
    text_lower = option.text.lower()

    # 1. Check leak phrases
    for leak in LEAK_PHRASES:
        if leak in text_lower:
            return False

    # 2. Check length (< 28 words tolerance)
    words = option.text.split()
    if len(words) > 28:
        return False

    # 3. Check number traceability
    allowed_numbers = {
        round(counter_price, 2),
        round(counter_price),
        int(quantity),
        1, 2, 3, 5, 7, 10, 14, 30, 60, 90, 365, # Standard time / unit integers (days, warranty)
    }
    if buyer_offer is not None and buyer_offer > 0:
        allowed_numbers.add(round(buyer_offer, 2))
        allowed_numbers.add(round(buyer_offer))

    detected_nums = re.findall(r"\b\d+(?:\.\d+)?\b", option.text)
    for n_str in detected_nums:
        try:
            val = float(n_str)
            val_rounded = round(val, 2)
            if val_rounded not in allowed_numbers and round(val) not in allowed_numbers:
                return False
        except ValueError:
            pass

    return True


async def generate_tactical_options(
    engine_result: EngineResult,
    buyer_text: str,
    state: NegotiationState,
    history_tracker: Optional[SuggestionHistoryTracker] = None,
    deal_score: int = 50,
    score_band: str = "medium",
    score_drivers: Optional[List[Dict[str, str]]] = None,
    recent_seller_lines: Optional[List[str]] = None,
    open_objections: Optional[List[str]] = None,
    llm_client: Optional[OpenRouterClient] = None,
) -> List[SuggestedOption]:
    """
    Generate up to 3 tactical response options with intent badges and follow-up hints.
    Employs async LLM with deterministic fallback on failure or rule violation.
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

    firmness = getattr(state, "firmness_level", 0)
    buyer_offers = getattr(state, "offer_history", [])
    latest_buyer_offer = buyer_offers[-1] if buyer_offers else None

    # Fallback options
    raw_fallbacks = get_fallback_options(
        action=action_val,
        counter_price=counter_val,
        quantity=state.quantity,
        firmness=firmness,
        buyer_offer=latest_buyer_offer,
    )
    fallback_options = [
        SuggestedOption(text=fb.text, intent=fb.intent, why=fb.why, followup=fb.followup)
        for fb in raw_fallbacks
    ]

    client = llm_client or PeithoIntelClient()
    if not client.enabled:
        return fallback_options

    reasoning_tag = getattr(engine_result, "reasoning_tag", None)
    tag_str = reasoning_tag.value if hasattr(reasoning_tag, "value") else str(reasoning_tag or "Standard strategic pricing")

    drivers_str = ", ".join(d.get("text", "") for d in (score_drivers or [])[:3]) or "None"
    recent_seller_str = " | ".join(recent_seller_lines[-2:]) if recent_seller_lines else "None"
    objections_str = ", ".join(open_objections) if open_objections else "None noted"

    prompt = INTEL_USER_TEMPLATE.format(
        action=action_val,
        counter_price=counter_val,
        quantity=state.quantity,
        strategy_tag=tag_str,
        deal_score=deal_score,
        score_band=score_band,
        score_drivers=drivers_str,
        buyer_text=buyer_text or "(No buyer utterance)",
        objections=objections_str,
        recent_seller_statements=recent_seller_str,
        current_round=state.current_round + 1,
        max_rounds=state.max_rounds,
        firmness=firmness,
    )

    try:
        response = await client.generate(
            system_prompt=INTEL_SYSTEM_PROMPT,
            user_prompt=prompt,
            temperature=0.6,
        )

        if response.success and response.content:
            raw = response.content.strip()
            # Strip markdown fences if present
            if raw.startswith("```"):
                lines = raw.splitlines()
                raw = "\n".join(lines[1:-1] if lines[-1].strip() == "```" else lines[1:])

            parsed = json.loads(raw)
            if isinstance(parsed, list) and len(parsed) > 0:
                validated_options: List[SuggestedOption] = []
                for idx, item in enumerate(parsed[:3]):
                    if not isinstance(item, dict):
                        continue
                    text = str(item.get("text", "")).strip()
                    intent = str(item.get("intent", "hold")).lower().strip()
                    why = str(item.get("why", "Tactical positioning")).strip()
                    followup = item.get("followup") if idx == 0 else None

                    # Validate intent legality
                    if (action_val in ("REJECT", "FINAL_OFFER") or firmness >= 3) and intent == "bridge":
                        # Discount/bridge not permitted during final offer or reject
                        intent = "hold"

                    cand = SuggestedOption(
                        text=text,
                        intent=intent if intent in ("hold", "bridge", "close", "probe") else "hold",
                        why=why,
                        followup=str(followup).strip() if followup else None,
                    )

                    # Security and truth validation
                    if not _validate_option_security(cand, counter_val, state.quantity, latest_buyer_offer):
                        continue

                    # Check repetition filter
                    if history_tracker and history_tracker.is_repeated(cand.text):
                        continue

                    validated_options.append(cand)

                if validated_options:
                    # Record into history tracker
                    if history_tracker:
                        history_tracker.record_turn_options([opt.text for opt in validated_options])
                    return validated_options

    except Exception as e:
        logger.warning("peitho_intel_generation_error", error_type=type(e).__name__)

    return fallback_options
