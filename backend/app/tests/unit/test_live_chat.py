"""
Unit tests for Peitho Live Chat feature.
"""
import pytest
from app.peitho.live_chat_schemas import (
    LiveChatSessionConfig,
    ProfitabilityStatus,
)
from app.peitho.live_chat_store import LiveChatStore
from app.peitho.live_chat_routes import calculate_profitability, get_local_ip


def test_calculate_profitability_no_offer():
    config = LiveChatSessionConfig(
        product_name="Wireless Headphones",
        base_price=200.0,
        cost_price=100.0,
        min_floor=120.0,
        mode="MAX_PROFIT",
    )
    prof = calculate_profitability(config, buyer_offer=None)
    assert prof.status == ProfitabilityStatus.NO_OFFER_YET
    assert prof.severity == "info"
    assert prof.unit_profit is None


def test_calculate_profitability_high_profit():
    config = LiveChatSessionConfig(
        product_name="Wireless Headphones",
        base_price=200.0,
        cost_price=100.0,
        min_floor=120.0,
        mode="MAX_PROFIT",
        quantity=2,
    )
    prof = calculate_profitability(config, buyer_offer=160.0, quantity=2)
    assert prof.status == ProfitabilityStatus.PROFITABLE
    assert prof.severity == "success"
    assert prof.unit_profit == 60.0
    assert prof.margin_pct == 37.5
    assert prof.total_profit == 120.0
    assert prof.total_deal_value == 320.0


def test_calculate_profitability_acceptable_margin():
    config = LiveChatSessionConfig(
        product_name="Server Rack",
        base_price=1000.0,
        cost_price=900.0,
        min_floor=850.0,
        mode="MAX_PROFIT",
    )
    # Offer 950 gives (50 / 950) = 5.3% margin
    prof = calculate_profitability(config, buyer_offer=950.0)
    assert prof.status == ProfitabilityStatus.ACCEPTABLE
    assert prof.severity == "info"
    assert prof.unit_profit == 50.0
    assert prof.margin_pct == 5.3


def test_calculate_profitability_controlled_loss():
    config = LiveChatSessionConfig(
        product_name="Clearance Inventory",
        base_price=100.0,
        cost_price=70.0,
        min_floor=50.0,
        mode="MIN_LOSS",
    )
    # Offer 60 is below cost (70) but above floor (50)
    prof = calculate_profitability(config, buyer_offer=60.0)
    assert prof.status == ProfitabilityStatus.CONTROLLED_LOSS
    assert prof.severity == "warning"
    assert prof.unit_profit == -10.0


def test_calculate_profitability_floor_violation():
    config = LiveChatSessionConfig(
        product_name="Smartwatch",
        base_price=300.0,
        cost_price=150.0,
        min_floor=200.0,
        mode="MAX_PROFIT",
    )
    # Offer 180 is below min floor 200
    prof = calculate_profitability(config, buyer_offer=180.0)
    assert prof.status == ProfitabilityStatus.BELOW_FLOOR_VIOLATION
    assert prof.severity == "critical"
    assert "BELOW" in prof.explanation


def test_live_chat_store_lifecycle():
    store = LiveChatStore(ttl_seconds=3600)
    config = LiveChatSessionConfig(
        product_name="Widget Pro",
        base_price=50.0,
        cost_price=25.0,
        min_floor=35.0,
        mode="MAX_PROFIT",
    )
    session = store.create_session(config)
    assert session.session_id is not None
    assert len(session.messages) == 1  # initial system welcome message

    # Add messages
    m1 = session.add_message("buyer", "Hello, can you do $40?")
    assert m1.sender == "buyer"
    assert m1.text == "Hello, can you do $40?"
    assert len(session.messages) == 2

    # Retrieval
    retrieved = store.get_session(session.session_id)
    assert retrieved is not None
    assert retrieved.session_id == session.session_id

    # Delete
    deleted = store.delete_session(session.session_id)
    assert deleted is True
    assert store.get_session(session.session_id) is None


def test_get_local_ip():
    ip = get_local_ip()
    assert isinstance(ip, str)
    assert len(ip.split(".")) == 4
