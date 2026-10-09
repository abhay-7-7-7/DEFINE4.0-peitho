"""
Peitho Schemas — Pydantic models and data structures for the Peitho Live Assistant.
"""
from dataclasses import dataclass, field
from enum import Enum
import time
from typing import Dict, List, Literal, Optional, Any
from uuid import uuid4
from pydantic import BaseModel, Field

from ..agents.negotiation_engine import NegotiationState, BuyerArchetype


class ChannelType(str, Enum):
    SELLER = "SELLER"
    BUYER = "BUYER"


class PeithoSessionConfig(BaseModel):
    """Configuration required to start a Peitho copilot session."""
    product_id: Optional[str] = Field(default=None, description="Optional DB product identifier")
    product_name: str = Field(default="Standard Item", description="Name of the product")
    base_price: float = Field(gt=0, description="Seller asking price / MSRP")
    cost_price: float = Field(gt=0, description="Seller unit cost")
    min_floor: float = Field(gt=0, description="Absolute floor price seller cannot go below")
    mode: Literal["MAX_PROFIT", "MIN_LOSS"] = Field(
        default="MAX_PROFIT", description="Negotiation engine strategy mode"
    )
    max_rounds: int = Field(default=5, ge=1, le=20, description="Max allowed rounds")
    quantity: int = Field(default=1, ge=1, description="Quantity being negotiated")
    available_inventory: int = Field(default=100, ge=1, description="Current stock level")
    reference_inventory: int = Field(default=100, ge=1, description="Baseline inventory")
    buyer_archetype: str = Field(
        default="UNKNOWN",
        description="Buyer archetype (UNKNOWN, ENTERPRISE, SMB, BUDGET_CONSCIOUS, PROCUREMENT)",
    )
    stt_provider: Optional[str] = Field(
        default=None,
        description="STT provider override ('typed' or 'elevenlabs')",
    )
    language: Optional[str] = Field(
        default=None,
        description="STT language code override (e.g. 'en', 'hi', or 'auto')",
    )


class TranscriptLine(BaseModel):
    """A line of transcribed speech or typed utterance."""
    id: str = Field(default_factory=lambda: str(uuid4()))
    channel: ChannelType
    text: str
    is_partial: bool = False
    timestamp: float = Field(default_factory=time.time)
    confidence: Optional[float] = None


class AdvisoryMetrics(BaseModel):
    """Deterministic telemetry from PRANE-X engine state."""
    bbi: float = Field(description="Buyer Bargaining Index [0-100]")
    p_high_wtp: float = Field(description="Probability of high willingness to pay")
    surplus_share: float = Field(description="Current seller surplus share [0-1]")
    buyer_concession_velocity: float = Field(description="Rate of buyer concession")
    consecutive_stagnant: int = Field(description="Number of stagnant rounds")
    firmness_level: int = Field(description="Engine firmness level [0-3]")
    current_round: int
    max_rounds: int


class SuggestedOptionSchema(BaseModel):
    """Structured tactical suggestion option with intent categorization."""
    text: str = Field(description="Natural spoken reply line for seller")
    intent: str = Field(default="hold", description="Intent badge: hold | bridge | close | probe")
    why: str = Field(default="", description="1-sentence strategic rationale")
    followup: Optional[str] = Field(default=None, description="If buyer says X, then Y hint (top option)")


class AdvisoryResult(BaseModel):
    """Recommendation produced for the human seller when a buyer line is processed."""
    action: str = Field(description="ACCEPT | COUNTER | REJECT | WALK_AWAY")
    counter_price: float = Field(description="Recommended per-unit counter price")
    walk_away: bool = Field(default=False)
    reasoning: str = Field(description="Explanation of why this action was advised")
    extracted_buyer_offer: Optional[float] = None
    extracted_buyer_intent: Optional[str] = None
    extracted_quantity: Optional[int] = None
    suggested_replies: List[str] = Field(
        default_factory=list,
        description="1-2 suggested natural spoken replies for the seller",
    )
    options: Optional[List[SuggestedOptionSchema]] = Field(
        default=None,
        description="Up to 3 rich tactical options categorized by intent (HOLD, BRIDGE, CLOSE, PROBE)",
    )
    buyer_score: Optional[int] = Field(
        default=None,
        description="Current Deal Likelihood score (0-100)",
    )
    buyer_score_band: Optional[str] = Field(
        default=None,
        description="Deal Likelihood band (low | medium | high)",
    )
    metrics: AdvisoryMetrics
    timestamp: float = Field(default_factory=time.time)
    recommendation_id: Optional[str] = Field(
        default=None,
        description="Unique identifier for this recommendation turn",
    )
    source: Literal["template", "ai"] = Field(
        default="template",
        description="Source of tactical responses: 'template' (Stage 1) or 'ai' (Stage 2)",
    )
    timing: Optional[Dict[str, float]] = Field(
        default=None,
        description="Content-free millisecond timing markers for the turn",
    )


class BuyerScoreMessage(BaseModel):
    """Protocol message broadcasting real-time Deal Likelihood score updates."""
    type: Literal["buyer_score"] = "buyer_score"
    call_id: str
    turn: int
    score: int
    band: str
    trend: str
    delta: int
    confidence: str
    provisional: bool = False
    drivers: List[Dict[str, str]] = Field(default_factory=list)
    history: List[Dict[str, int]] = Field(default_factory=list)
    buyer_state: Optional[Dict[str, Any]] = None


@dataclass
class PeithoSession:
    """Live state container for an active Peitho call session."""
    session_id: str
    config: PeithoSessionConfig
    master_state: NegotiationState
    transcript_history: List[TranscriptLine] = field(default_factory=list)
    last_advisory: Optional[AdvisoryResult] = None
    is_active: bool = True
    created_at: float = field(default_factory=time.time)
    updated_at: float = field(default_factory=time.time)
    scoring_engine: Any = None
    history_tracker: Any = None
    last_buyer_score: Optional[Dict[str, Any]] = None
    open_objections: List[str] = field(default_factory=list)
    resolved_objections: List[str] = field(default_factory=list)
    seller_recent_quotes: List[str] = field(default_factory=list)

    def touch(self) -> None:
        self.updated_at = time.time()


class PeithoSessionSummary(BaseModel):
    """Summary of a session for status and health checks."""
    session_id: str
    product_name: str
    created_at: float
    current_round: int
    max_rounds: int
    is_active: bool
    last_counter: Optional[float] = None
    transcript_count: int = 0
