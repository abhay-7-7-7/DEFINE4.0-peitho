"""
Peitho Live Chat Schemas — Data models for the seller-buyer live chat with AI copilot.
"""
from enum import Enum
import time
from typing import Dict, List, Literal, Optional
from uuid import uuid4
from pydantic import BaseModel, Field

from .schemas import AdvisoryResult, AdvisoryMetrics


class LiveChatSender(str, Enum):
    SELLER = "seller"
    BUYER = "buyer"
    SYSTEM = "system"


class LiveChatMessage(BaseModel):
    """A single chat message in the live negotiation session."""
    id: str = Field(default_factory=lambda: str(uuid4()))
    sender: Literal["seller", "buyer", "system"]
    text: str
    timestamp: float = Field(default_factory=time.time)


class LiveChatSessionConfig(BaseModel):
    """Configuration required to start a Peitho Live Chat session."""
    product_id: Optional[str] = Field(default=None, description="Optional DB product identifier")
    product_name: str = Field(default="Standard Item", description="Name of the product")
    base_price: float = Field(gt=0, description="Seller asking price / MSRP")
    cost_price: float = Field(gt=0, description="Seller unit cost")
    min_floor: float = Field(gt=0, description="Absolute floor price seller cannot go below")
    mode: Literal["MAX_PROFIT", "MIN_LOSS"] = Field(
        default="MAX_PROFIT", description="Negotiation engine strategy mode"
    )
    max_rounds: int = Field(default=6, ge=1, le=20, description="Max allowed negotiation rounds")
    quantity: int = Field(default=1, ge=1, description="Quantity being negotiated")
    available_inventory: int = Field(default=100, ge=1, description="Current stock level")
    reference_inventory: int = Field(default=100, ge=1, description="Baseline inventory")
    buyer_archetype: str = Field(
        default="UNKNOWN",
        description="Buyer archetype (UNKNOWN, ENTERPRISE, SMB, BUDGET_CONSCIOUS, PROCUREMENT)",
    )


class ProfitabilityStatus(str, Enum):
    PROFITABLE = "PROFITABLE"
    ACCEPTABLE = "ACCEPTABLE"
    CONTROLLED_LOSS = "CONTROLLED_LOSS"
    BELOW_FLOOR_VIOLATION = "BELOW_FLOOR_VIOLATION"
    NO_OFFER_YET = "NO_OFFER_YET"


class LiveChatProfitability(BaseModel):
    """Real-time unit economics and profit/loss assessment of the buyer's offer."""
    detected_offer: Optional[float] = None
    detected_quantity: Optional[int] = None
    unit_cost: float
    base_price: float
    min_floor: float
    unit_profit: Optional[float] = None
    margin_pct: Optional[float] = None
    total_deal_value: Optional[float] = None
    total_profit: Optional[float] = None
    status: ProfitabilityStatus = ProfitabilityStatus.NO_OFFER_YET
    severity: Literal["success", "info", "warning", "critical"] = "info"
    explanation: str = "Awaiting buyer offer or pricing statement."


class LiveChatAdvisoryPayload(BaseModel):
    """Comprehensive advisory data streamed to the seller."""
    profitability: LiveChatProfitability
    advisory: Optional[AdvisoryResult] = None
    recommendation_id: Optional[str] = None
    source: Literal["template", "ai"] = "template"
    timestamp: float = Field(default_factory=time.time)
