"""
Deterministic Fallback Templates for Peitho Tactical Copilot.

Provides instant, rule-based response options categorized by intent:
- HOLD: Defend current price with value or policy justification.
- BRIDGE: Non-price concessions (delivery, payment terms, extended support, warranty, bundle).
- CLOSE: Finalize deal terms and prompt for sign-off or order confirmation.
- PROBE: Clarify objection, budget constraint, or purchase timeline without leaking margin.

RULES:
- Zero cost/floor/margin leak.
- Natural spoken phrasing (< 25 words per line).
- Strictly follows engine permission rules.
"""
from typing import Dict, List, Optional
from dataclasses import dataclass


@dataclass
class FallbackOption:
    text: str
    intent: str      # "hold" | "bridge" | "close" | "probe"
    why: str
    followup: Optional[str] = None


def get_fallback_options(
    action: str,
    counter_price: float,
    quantity: int,
    firmness: int = 0,
    objection_type: Optional[str] = None,
    buyer_offer: Optional[float] = None,
) -> List[FallbackOption]:
    """
    Produce up to 3 compliant fallback options honoring the engine action.
    """
    options: List[FallbackOption] = []
    qty_str = f"for {quantity} units" if quantity > 1 else "per unit"
    price_str = f"${counter_price:.2f}"

    if action == "ACCEPT":
        options.append(FallbackOption(
            text=f"That works for us at {price_str} {qty_str}. Let's lock this in today.",
            intent="close",
            why="Accepts the agreed figure and initiates closing.",
            followup="If buyer requests expedited shipping, agree in exchange for immediate PO.",
        ))
        options.append(FallbackOption(
            text=f"We have an agreement at {price_str}. I'll send over the order details right now.",
            intent="close",
            why="Confirms terms and smoothly transitions to invoicing.",
            followup=None,
        ))
        return options

    if action in ("REJECT", "WALK_AWAY") or firmness >= 3:
        # Strictly NO discounts allowed!
        options.append(FallbackOption(
            text=f"I appreciate your interest, but {price_str} is our absolute bottom line {qty_str}.",
            intent="hold",
            why="Politely establishes firm pricing ceiling with zero concession.",
            followup="If buyer threatens to walk, thank them respectfully and let the quote stand.",
        ))
        options.append(FallbackOption(
            text=f"At {price_str}, we're already providing our full warranty and priority support.",
            intent="hold",
            why="Anchors to existing value bundle rather than price cuts.",
            followup=None,
        ))
        options.append(FallbackOption(
            text="If that number doesn't fit your budget, would a smaller order size work better?",
            intent="probe",
            why="Offers an alternative scope path without lowering unit valuation.",
            followup="If buyer agrees to smaller quantity, preserve the same unit price.",
        ))
        return options

    # COUNTER action
    if firmness >= 2:
        # High firmness: Strong HOLD, tight BRIDGE (non-price only), calibrated PROBE
        options.append(FallbackOption(
            text=f"I've sharpened our figures as far as possible — {price_str} {qty_str} is our best standing rate.",
            intent="hold",
            why="Defends current counter firmly to resist further aggressive haggling.",
            followup="If buyer asks for a split, hold at the counter and offer net-30 terms instead.",
        ))
        options.append(FallbackOption(
            text=f"If we stay at {price_str}, I can include expedited delivery at no extra charge.",
            intent="bridge",
            why="Trades non-price delivery value to protect price integrity.",
            followup=None,
        ))
        options.append(FallbackOption(
            text="Help me understand: what specific timeline are you targeting for deployment?",
            intent="probe",
            why="Shifts discussion away from price pressure toward logistical needs.",
            followup=None,
        ))
        return options

    # Normal / fluid COUNTER: Diverse blend of BRIDGE, HOLD, and PROBE
    options.append(FallbackOption(
        text=f"I can meet you at {price_str} {qty_str} if we can finalize the paperwork today.",
        intent="bridge",
        why="Offers reciprocal concession tied to rapid commitment.",
        followup="If buyer accepts, transition immediately to contract sign-off.",
    ))
    options.append(FallbackOption(
        text=f"At {price_str}, you get our complete support package and guaranteed stock allocation.",
        intent="hold",
        why="Reinforces tangible product value to justify current position.",
        followup=None,
    ))
    options.append(FallbackOption(
        text="What overall budget ceiling are you working with for this purchase?",
        intent="probe",
        why="Uncovers true financial parameters to guide subsequent rounds.",
        followup="If buyer specifies a realistic range, bridge with value-add options.",
    ))
    return options
