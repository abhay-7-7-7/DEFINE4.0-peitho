"""
Unit tests for Peitho WebSocket protocol additions:
- buyer_score broadcast on buyer final transcripts
- optional additive fields on options (intent, why, followup)
- backwards compatibility of all existing message shapes
"""
import pytest
from fastapi.testclient import TestClient

from app.main import app


def test_buyer_score_emitted_for_buyer_final():
    """Verify buyer_score is broadcast over WebSocket for every buyer final utterance."""
    client = TestClient(app)
    start_res = client.post(
        "/api/v1/peitho/start",
        json={
            "product_name": "Test Office Chair",
            "base_price": 7499.0,
            "cost_price": 4200.0,
            "min_floor": 5000.0,
            "mode": "MAX_PROFIT",
            "max_rounds": 6,
            "stt_provider": "typed",
        },
    )
    assert start_res.status_code == 200
    session_id = start_res.json()["session_id"]

    with client.websocket_connect(f"/api/v1/peitho/ws/{session_id}") as ws:
        ready_msg = ws.receive_json()
        assert ready_msg["type"] == "ready"

        # Send buyer line
        ws.send_json({
            "type": "transcript_line",
            "channel": "tab",
            "text": "Would you take $5800 for this chair?",
            "is_final": True,
        })

        received_types = []
        buyer_score_msg = None
        advisory_msg = None

        # Collect messages for this turn
        for _ in range(8):
            msg = ws.receive_json()
            m_type = msg.get("type")
            received_types.append(m_type)
            if m_type == "buyer_score":
                buyer_score_msg = msg
            elif m_type == "advisory":
                advisory_msg = msg
            if buyer_score_msg and advisory_msg:
                break

        assert buyer_score_msg is not None, f"Expected buyer_score in {received_types}"
        assert buyer_score_msg["type"] == "buyer_score"
        assert buyer_score_msg["call_id"] == session_id
        assert isinstance(buyer_score_msg["turn"], int)
        assert 0 <= buyer_score_msg["score"] <= 100
        assert buyer_score_msg["band"] in ("low", "medium", "high")
        assert buyer_score_msg["trend"] in ("up", "flat", "down")
        assert isinstance(buyer_score_msg["delta"], int)
        assert buyer_score_msg["confidence"] in ("low", "medium", "high")
        assert isinstance(buyer_score_msg["provisional"], bool)
        assert isinstance(buyer_score_msg["drivers"], list)
        assert len(buyer_score_msg["drivers"]) > 0
        for driver in buyer_score_msg["drivers"]:
            assert "text" in driver
            assert driver["effect"] in ("positive", "negative")
        assert isinstance(buyer_score_msg["history"], list)

        # Verify advisory has backward-compatible shape plus additive options
        assert advisory_msg is not None
        assert advisory_msg["type"] == "advisory"
        assert "data" in advisory_msg
        assert "action" in advisory_msg["data"]
        assert "suggested_replies" in advisory_msg["data"]
        # Additive options array
        assert "options" in advisory_msg
        assert isinstance(advisory_msg["options"], list)
        for opt in advisory_msg["options"]:
            assert "text" in opt
            assert "intent" in opt
            assert opt["intent"] in ("hold", "bridge", "close", "probe")

        # Cleanup
        ws.send_json({"type": "end_call"})


def test_lock_deal_websocket_roundtrip():
    """Verify lock_deal client event causes server to broadcast deal_locked with terms."""
    client = TestClient(app)
    start_res = client.post(
        "/api/v1/peitho/start",
        json={
            "product_name": "Test Office Chair",
            "base_price": 7499.0,
            "cost_price": 4200.0,
            "min_floor": 5000.0,
            "mode": "MAX_PROFIT",
            "max_rounds": 6,
            "stt_provider": "typed",
        },
    )
    assert start_res.status_code == 200
    session_id = start_res.json()["session_id"]

    with client.websocket_connect(f"/api/v1/peitho/ws/{session_id}") as ws:
        ready_msg = ws.receive_json()
        assert ready_msg["type"] == "ready"

        # Send buyer line where buyer agrees near target
        ws.send_json({
            "type": "transcript_line",
            "channel": "tab",
            "text": "Okay, that's a deal at $6800. Let's do it.",
            "is_final": True,
        })

        # Collect advisory and check deal_lockable
        advisory_msg = None
        for _ in range(8):
            msg = ws.receive_json()
            if msg.get("type") == "advisory":
                advisory_msg = msg
                break

        assert advisory_msg is not None
        assert advisory_msg.get("deal_lockable") is True
        assert advisory_msg.get("lockable_price") == 6800.0

        # Send lock_deal event
        ws.send_json({
            "type": "lock_deal",
            "agreed_price": 6800.0,
        })

        # Receive deal_locked broadcast
        deal_locked_msg = None
        for _ in range(5):
            msg = ws.receive_json()
            if msg.get("type") == "deal_locked":
                deal_locked_msg = msg
                break

        assert deal_locked_msg is not None
        assert deal_locked_msg["type"] == "deal_locked"
        assert deal_locked_msg["agreed_price"] == 6800.0
        assert deal_locked_msg["quantity"] == 1
        assert deal_locked_msg["total_value"] == 6800.0
        assert "timestamp" in deal_locked_msg

        # Cleanup
        ws.send_json({"type": "end_call"})
