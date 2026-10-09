"""
Peitho Live Chat Session Store — In-memory session tracking and connection management.
"""
from dataclasses import dataclass, field
import time
from typing import Dict, List, Optional, Set
from uuid import uuid4
from fastapi import WebSocket
import structlog

from ..agents.negotiation_engine import NegotiationState, BuyerArchetype
from .live_chat_schemas import (
    LiveChatMessage,
    LiveChatSessionConfig,
    LiveChatProfitability,
    ProfitabilityStatus,
)
from .schemas import AdvisoryResult

logger = structlog.get_logger(__name__)


@dataclass
class LiveChatSession:
    """Active live chat negotiation session with seller and buyer channels."""
    session_id: str
    config: LiveChatSessionConfig
    master_state: NegotiationState
    messages: List[LiveChatMessage] = field(default_factory=list)
    seller_sockets: Set[WebSocket] = field(default_factory=set)
    buyer_sockets: Set[WebSocket] = field(default_factory=set)
    last_profitability: Optional[LiveChatProfitability] = None
    last_advisory: Optional[AdvisoryResult] = None
    is_active: bool = True
    created_at: float = field(default_factory=time.time)
    updated_at: float = field(default_factory=time.time)

    def touch(self) -> None:
        self.updated_at = time.time()

    def add_message(self, sender: str, text: str) -> LiveChatMessage:
        self.touch()
        msg = LiveChatMessage(sender=sender, text=text, timestamp=time.time())
        self.messages.append(msg)
        return msg

    def register_socket(self, role: str, ws: WebSocket) -> None:
        self.touch()
        if role == "seller":
            self.seller_sockets.add(ws)
        else:
            self.buyer_sockets.add(ws)

    def unregister_socket(self, role: str, ws: WebSocket) -> None:
        self.touch()
        if role == "seller":
            self.seller_sockets.discard(ws)
        else:
            self.buyer_sockets.discard(ws)

    @property
    def is_buyer_online(self) -> bool:
        return len(self.buyer_sockets) > 0

    @property
    def is_seller_online(self) -> bool:
        return len(self.seller_sockets) > 0


class LiveChatStore:
    """Manages active live chat sessions."""

    def __init__(self, ttl_seconds: int = 7200):
        self._sessions: Dict[str, LiveChatSession] = {}
        self._ttl_seconds = ttl_seconds

    def create_session(self, config: LiveChatSessionConfig) -> LiveChatSession:
        self.cleanup_expired()
        session_id = str(uuid4())

        try:
            archetype = BuyerArchetype[config.buyer_archetype.upper()]
        except (KeyError, AttributeError):
            archetype = BuyerArchetype.UNKNOWN

        master_state = NegotiationState(
            base_price=float(config.base_price),
            cost_price=float(config.cost_price),
            min_floor=float(config.min_floor),
            mode=config.mode,
            max_rounds=config.max_rounds,
            quantity=config.quantity,
            total_sessions=0,
            accepted_deals=0,
            historical_avg_margin=0.0,
            historical_revenue=0.0,
            available_inventory=config.available_inventory,
            reference_inventory=config.reference_inventory,
            buyer_archetype=archetype,
        )
        master_state.counter_history.append(float(config.base_price))

        initial_profitability = LiveChatProfitability(
            unit_cost=config.cost_price,
            base_price=config.base_price,
            min_floor=config.min_floor,
            status=ProfitabilityStatus.NO_OFFER_YET,
            severity="info",
            explanation=f"Awaiting buyer offer. Target listing price is ${config.base_price:.2f} (Cost: ${config.cost_price:.2f}, Floor: ${config.min_floor:.2f}).",
        )

        session = LiveChatSession(
            session_id=session_id,
            config=config,
            master_state=master_state,
            last_profitability=initial_profitability,
        )

        # Initial system welcome message
        session.add_message("system", f"Session started for {config.product_name}. Seller listed price: ${config.base_price:.2f}")

        self._sessions[session_id] = session
        logger.info("live_chat_session_created", session_id=session_id, product_name=config.product_name)
        return session

    def get_session(self, session_id: str) -> Optional[LiveChatSession]:
        session = self._sessions.get(session_id)
        if not session:
            return None
        now = time.time()
        if now - session.updated_at > self._ttl_seconds:
            logger.info("live_chat_session_expired", session_id=session_id)
            del self._sessions[session_id]
            return None
        session.touch()
        return session

    def delete_session(self, session_id: str) -> bool:
        if session_id in self._sessions:
            del self._sessions[session_id]
            logger.info("live_chat_session_deleted", session_id=session_id)
            return True
        return False

    def cleanup_expired(self) -> None:
        now = time.time()
        expired = [sid for sid, s in self._sessions.items() if now - s.updated_at > self._ttl_seconds]
        for sid in expired:
            del self._sessions[sid]


live_chat_store = LiveChatStore()
