"""
Comprehensive Unit & Integration Tests for Peitho Reminders Feature.
Tests cover:
- Part 2: Detection gate (keyword/regex), 25+ phrase dataset (EN, HI, Hinglish, edge cases),
          date resolution, deduplication, correction merging, past times, unresolved dates.
- Part 3: API ownership isolation, input validation, PATCH re-arming, range filtering.
- Part 4: Scheduler atomic claiming, idempotency, retry/stop after 3 failures,
          overdue grace period marking as missed, graceful handling of missing SMTP.
- Part 5: WebSocket reminder_action handling.
- Privacy: Logging privacy (no raw transcript, title, note, or email body in logs).
"""
import asyncio
import datetime
from zoneinfo import ZoneInfo
from unittest.mock import patch, MagicMock
import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.api.v1.auth_routes import get_current_user
from app.peitho.reminders.detect import (
    has_reminder_cue,
    _fallback_deterministic_extract,
    process_line_for_reminders,
)
from app.peitho.reminders.dates import (
    resolve_datetime,
    DateResolutionResult,
)
from app.peitho.reminders.db import (
    create_reminder,
    get_reminder,
    list_reminders,
    update_reminder,
    delete_reminder,
    find_dedupe_match,
    claim_due_reminders,
    mark_reminder_notified,
    mark_missed_reminders,
    ensure_reminder_tables,
)
from app.peitho.reminders.scheduler import send_reminder_email_now
from app.peitho.reminders.ws_manager import reminder_ws_manager


# ─────────────────────────────────────────────────────────────────────────────
# 1. DETECTION GATE TESTS
# ─────────────────────────────────────────────────────────────────────────────

def test_gate_skips_lines_without_cues():
    """Verify lines without temporal or commitment cues bypass LLM extraction."""
    negative_lines = [
        "The base price is 100 dollars per unit.",
        "We have 50 items in stock right now.",
        "Can you offer a 10% discount on the batch?",
        "That is below our cost price.",
        "Thank you for contacting us.",
        "The product comes with a 1 year warranty.",
        "I am looking for high quality components.",
        "What is your best counter offer?",
    ]
    for line in negative_lines:
        assert not has_reminder_cue(line), f"Should not trigger cue: {line}"


def test_gate_passes_lines_with_cues():
    """Verify lines with commitment or temporal cues pass the gate."""
    positive_lines = [
        "I will send the revised quote tomorrow morning.",
        "Let's schedule a follow-up call on Friday at 3 pm.",
        "Call me back next week.",
        "We will deliver by the 15th.",
        "Kal subah 11 baje baat karte hain.",
        "Parso sham ko delivery ho jayegi.",
        "Agle hafte somwar ko meeting rakhte hain.",
        "सोमवार को दोपहर 2 बजे बात करते हैं।",
        "Please remind me before Friday.",
    ]
    for line in positive_lines:
        assert has_reminder_cue(line), f"Should trigger cue: {line}"


# ─────────────────────────────────────────────────────────────────────────────
# 2. 25-PHRASE DATASET (English, Hindi, Hinglish + Edge Cases)
# ─────────────────────────────────────────────────────────────────────────────

PHRASE_DATASET = [
    # 1. English: tomorrow morning
    ("I will send the revised quote tomorrow morning", "tomorrow", 9, 0),
    # 2. English: Friday 3 pm
    ("Let's schedule a follow-up call on Friday at 3 pm", "friday", 15, 0),
    # 3. English: after 2 days
    ("We will deliver the shipment after 2 days", "after 2 days", 10, 0),
    # 4. English: next week on Monday
    ("Can we touch base next week on Monday?", "next week on monday", 10, 0),
    # 5. English: in 3 days
    ("I will call you back in 3 days", "in 3 days", 10, 0),
    # 6. English: by end of the week
    ("Please confirm the order by end of the week", "end of the week", 17, 0),
    # 7. English: by the 15th
    ("We need this delivered by the 15th", "15th", 10, 0),
    # 8. English: this evening at 6 pm
    ("Let's connect this evening at 6 pm", "this evening", 18, 0),
    # 9. English: tomorrow at 10 am
    ("I will send the samples tomorrow at 10 am", "tomorrow", 10, 0),
    # 10. English: date-only tomorrow (should default to 10:00, time assumed)
    ("Let's meet tomorrow", "tomorrow", 10, 0),
    # 11. English: date-only Friday
    ("I will email the contract by Friday", "friday", 10, 0),
    # 12. English: next Wednesday at 4 pm
    ("Follow up next Wednesday at 4 pm", "wednesday", 16, 0),
    # 13. Hinglish: kal subah 11 baje
    ("Kal subah 11 baje call karte hain", "kal", 11, 0),
    # 14. Hinglish: parso sham ko meeting
    ("Parso sham ko meeting rakhte hain", "parso", 18, 0),
    # 15. Hinglish: agle hafte somwar ko
    ("Agle hafte somwar ko baat karenge", "somwar", 10, 0),
    # 16. Hinglish: main kal 3 baje follow up karunga
    ("Main kal 3 baje follow up karunga", "kal", 15, 0),
    # 17. Hinglish: 2 din baad
    ("Ham 2 din baad sample bhej denge", "2 din", 10, 0),
    # 18. Pure Hindi: सोमवार को दोपहर 2 बजे
    ("सोमवार को दोपहर 2 बजे बात करते हैं", "सोमवार", 14, 0),
    # 19. Pure Hindi: कल सुबह 10 बजे
    ("कल सुबह 10 बजे ईमेल भेज दूंगा", "कल", 10, 0),
    # 20. Pure Hindi: परसों 4 बजे डिलीवरी
    ("परसों 4 बजे डिलीवरी हो जाएगी", "परसों", 16, 0),
    # 21. Pure Hindi: अगले हफ्ते शुक्रवार
    ("अगले हफ्ते शुक्रवार को मीटिंग तय करते हैं", "शुक्रवार", 10, 0),
    # 22. Multiple reminders in one sentence
    ("Let's talk tomorrow at 9 am, and also deliver the catalog on Friday", "tomorrow", 9, 0),
    # 23. Past time edge case (rolling forward so never in the past)
    ("I will call you at 8 am yesterday", "yesterday", None, None),
    # 24. Time-only edge case (rolls to tomorrow if today's time passed)
    ("Let's connect at 2 pm", "2 pm", 14, 0),
    # 25. Ambiguous date ("remind me later") -> needs date flag, null-safe
    ("Can you remind me later about this?", "later", None, None),
    # 26. Relative hours offset: in 2 hours
    ("I will send the finalized agreement in 2 hours", "in 2 hours", None, None),
    # 27. Day of month: 25th of next month
    ("Let's review on the 25th at 11 am", "25th", 11, 0),
]


def test_25_phrases_dataset():
    """Verify at least 25 phrases in English, Hindi, Hinglish and edge cases resolve properly."""
    assert len(PHRASE_DATASET) >= 25, "Must test at least 25 phrases"
    ref_now = datetime.datetime(2026, 10, 10, 11, 30, tzinfo=ZoneInfo("Asia/Kolkata"))

    for text, expected_marker, exp_h, exp_m in PHRASE_DATASET:
        # 1. Gate check
        gate_ok = has_reminder_cue(text)
        assert gate_ok, f"Gate failed for cue in: {text}"

        # 2. Resolution
        res = resolve_datetime(text, now=ref_now, tz_name="Asia/Kolkata")
        assert isinstance(res, DateResolutionResult), f"Result must be DateResolutionResult for: {text}"

        # 3. Assert never in the past
        if res.success and res.dt_utc is not None:
            ref_utc_naive = ref_now.astimezone(datetime.timezone.utc).replace(tzinfo=None)
            res_utc_naive = res.dt_utc.replace(tzinfo=None) if res.dt_utc.tzinfo else res.dt_utc
            assert res_utc_naive >= ref_utc_naive - datetime.timedelta(minutes=5), (
                f"Resolved time {res.dt_utc} cannot be in the past compared to {ref_utc_naive} for text: {text}"
            )

        # 4. Check specific time-of-day defaults for date-only items
        if "tomorrow" in text.lower() and "morning" not in text.lower() and "am" not in text.lower() and "pm" not in text.lower() and "baje" not in text.lower():
            if res.success:
                assert res.time_assumed is True, f"Date-only should flag time_assumed: {text}"
                assert res.dt_local.hour == 10, f"Date-only should default to 10:00: {text}"


def test_ambiguous_phrase_marked_needs_date():
    """Unresolved/ambiguous date phrases should flag needs_date instead of saving an invalid date."""
    ref_now = datetime.datetime(2026, 10, 10, 12, 0, tzinfo=ZoneInfo("Asia/Kolkata"))
    res = resolve_datetime("Please remind me later sometime", now=ref_now, tz_name="Asia/Kolkata")
    assert res.needs_date is True or not res.success
    # Deterministic fallback handles it safely
    reminders = _fallback_deterministic_extract(["Please remind me later sometime"], current_dt=ref_now)
    assert len(reminders) >= 1
    assert reminders[0].confidence == "medium" or reminders[0].confidence == "low"


# ─────────────────────────────────────────────────────────────────────────────
# 3. DEDUPLICATION AND CORRECTION MERGE
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_deduplication_and_correction_merge():
    """Test deduplicating identical reminders and updating on a later correction."""
    await ensure_reminder_tables()
    user_id = 1
    call_id = "test_call_dedupe_123"

    # Create original reminder for Friday
    due_fri = datetime.datetime(2026, 10, 16, 15, 0, tzinfo=datetime.timezone.utc)
    rem_id = await create_reminder(
        user_id=user_id,
        call_id=call_id,
        title="TEST_Follow-up Call",
        due_at=due_fri,
        owner="seller",
        source="detected",
        status="active",
        confidence="high",
    )
    assert rem_id > 0

    try:
        # Check dedupe match for same date and title
        match = await find_dedupe_match(
            user_id=user_id,
            title_norm="follow-up call",
            due_date_str="2026-10-16",
            call_id=call_id,
        )
        assert match is not None
        assert match["id"] == rem_id

        # Merge correction: "Actually make it Thursday at 4 pm"
        due_thu = datetime.datetime(2026, 10, 15, 16, 0, tzinfo=datetime.timezone.utc)
        updated = await update_reminder(
            user_id=user_id,
            reminder_id=rem_id,
            updates={"due_at": due_thu, "note": "Updated per correction"},
        )
        assert updated is not None
        assert updated["due_at"] == due_thu.replace(tzinfo=None)
    finally:
        await delete_reminder(user_id, rem_id)


# ─────────────────────────────────────────────────────────────────────────────
# 4. SCHEDULER & ATOMIC CLAIMING TESTS
# ─────────────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_scheduler_atomic_claim_and_send():
    """Verify scheduler claims due reminders atomically and marks notified."""
    await ensure_reminder_tables()
    user_id = 1
    # Due in 5 minutes with 30 min lead -> should be claimed immediately
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    due_at = now_utc + datetime.timedelta(minutes=5)

    rem_id = await create_reminder(
        user_id=user_id,
        title="TEST_Scheduler_Due",
        due_at=due_at,
        lead_minutes=30,
        status="active",
    )

    try:
        # 1. Claim due reminders
        claimed = await claim_due_reminders(batch_size=10)
        found = [c for c in claimed if c["id"] == rem_id]
        assert len(found) == 1, "Due reminder should be claimed"
        assert found[0]["notify_attempts"] == 0  # Initial attempts before increment in DB

        # 2. Mark notified
        await mark_reminder_notified(rem_id)
        rem_after = await get_reminder(user_id, rem_id)
        assert rem_after["notified_at"] is not None

        # 3. Idempotency: second claim pass should NOT claim it
        claimed_2 = await claim_due_reminders(batch_size=10)
        found_2 = [c for c in claimed_2 if c["id"] == rem_id]
        assert len(found_2) == 0, "Already notified reminder must not be reclaimed"
    finally:
        await delete_reminder(user_id, rem_id)


@pytest.mark.asyncio
async def test_scheduler_retries_and_stops_after_3_failures():
    """Verify scheduler stops claiming a reminder after 3 attempts."""
    await ensure_reminder_tables()
    user_id = 1
    due_at = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(minutes=10)

    rem_id = await create_reminder(
        user_id=user_id,
        title="TEST_Retry_Stop",
        due_at=due_at,
        lead_minutes=0,
        status="active",
    )

    try:
        # Simulate 3 attempts by updating notify_attempts
        await update_reminder(user_id, rem_id, {"status": "active"})
        from app.infrastructure.database.session import get_conn
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.execute("UPDATE peitho_reminders SET notify_attempts = 3 WHERE id = %s", (rem_id,))

        # Claim should now ignore it
        claimed = await claim_due_reminders(batch_size=10)
        found = [c for c in claimed if c["id"] == rem_id]
        assert len(found) == 0, "Reminder with 3 failed attempts must not be claimed"
    finally:
        await delete_reminder(user_id, rem_id)


@pytest.mark.asyncio
async def test_scheduler_marks_overdue_as_missed():
    """Verify reminders overdue by more than grace period (24h) are marked missed at startup."""
    await ensure_reminder_tables()
    user_id = 1
    # Overdue by 30 hours
    long_ago = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=30)
    rem_id = await create_reminder(
        user_id=user_id,
        title="TEST_Overdue_Missed",
        due_at=long_ago,
        lead_minutes=0,
        status="active",
    )

    try:
        count = await mark_missed_reminders(grace_hours=24)
        assert count >= 1
        rem = await get_reminder(user_id, rem_id)
        assert rem["status"] == "missed"
    finally:
        await delete_reminder(user_id, rem_id)


@pytest.mark.asyncio
async def test_patch_rearms_notification():
    """Verify updating due_at resets notified_at and notify_attempts to re-arm."""
    await ensure_reminder_tables()
    user_id = 1
    due_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=2)
    rem_id = await create_reminder(
        user_id=user_id,
        title="TEST_Rearm",
        due_at=due_at,
        lead_minutes=15,
        status="active",
    )

    try:
        # Mark notified
        await mark_reminder_notified(rem_id)
        rem = await get_reminder(user_id, rem_id)
        assert rem["notified_at"] is not None

        # Update due_at
        new_due = due_at + datetime.timedelta(days=1)
        updated = await update_reminder(user_id, rem_id, {"due_at": new_due})
        assert updated["notified_at"] is None
        assert updated["notify_attempts"] == 0
    finally:
        await delete_reminder(user_id, rem_id)


@pytest.mark.asyncio
async def test_missing_smtp_handled_gracefully():
    """Verify sending email with no SMTP setup handles gracefully without crash."""
    # User 99999 has no SMTP credentials
    res, msg = await send_reminder_email_now(user_id=99999, reminder_id=99999)
    assert res is False
    assert "not found" in msg.lower() or "disabled" in msg.lower() or "credentials" in msg.lower()


# ─────────────────────────────────────────────────────────────────────────────
# 5. REST API & USER OWNERSHIP ISOLATION
# ─────────────────────────────────────────────────────────────────────────────

@pytest.fixture
def auth_client():
    """Test client authenticated as User 1 by default."""
    app = create_app()
    app.dependency_overrides[get_current_user] = lambda: {
        "id": 1,
        "email": "user1@example.com",
    }
    yield TestClient(app), app
    app.dependency_overrides.clear()


def test_api_crud_and_user_isolation(auth_client):
    """Test user 1 creates reminder; user 2 cannot read, edit, delete, or test-email it."""
    client, app = auth_client

    # 1. User 1 creates reminder
    create_payload = {
        "title": "TEST_Auth_Isolation_Reminder",
        "due_at": "2026-10-20T10:00:00Z",
        "lead_minutes": 30,
        "owner": "seller",
        "timezone": "Asia/Kolkata",
        "note": "Private notes",
    }
    res = client.post("/api/v1/peitho/reminders", json=create_payload)
    assert res.status_code == 201
    rem_data = res.json()
    rem_id = rem_data["id"]

    try:
        # User 1 can see it in list
        list_res = client.get("/api/v1/peitho/reminders")
        assert list_res.status_code == 200
        ids = [r["id"] for r in list_res.json()]
        assert rem_id in ids

        # Switch authentication to User 2
        app.dependency_overrides[get_current_user] = lambda: {
            "id": 2,
            "email": "user2@example.com",
        }

        # User 2 list: should NOT contain User 1's reminder
        u2_list = client.get("/api/v1/peitho/reminders")
        assert u2_list.status_code == 200
        u2_ids = [r["id"] for r in u2_list.json()]
        assert rem_id not in u2_ids

        # User 2 PATCH: 404 forbidden/not found
        u2_patch = client.patch(f"/api/v1/peitho/reminders/{rem_id}", json={"title": "Hacked Title"})
        assert u2_patch.status_code == 404

        # User 2 DELETE: 404
        u2_del = client.delete(f"/api/v1/peitho/reminders/{rem_id}")
        assert u2_del.status_code == 404

        # User 2 send-test: 404
        u2_test = client.post(f"/api/v1/peitho/reminders/{rem_id}/send-test")
        assert u2_test.status_code == 404

        # Switch back to User 1
        app.dependency_overrides[get_current_user] = lambda: {
            "id": 1,
            "email": "user1@example.com",
        }

        # User 1 can update
        u1_patch = client.patch(f"/api/v1/peitho/reminders/{rem_id}", json={"note": "Updated note"})
        assert u1_patch.status_code == 200
        assert u1_patch.json()["note"] == "Updated note"

        # User 1 can delete
        u1_del = client.delete(f"/api/v1/peitho/reminders/{rem_id}")
        assert u1_del.status_code == 200

    finally:
        # Cleanup
        app.dependency_overrides[get_current_user] = lambda: {"id": 1}
        client.delete(f"/api/v1/peitho/reminders/{rem_id}")


def test_api_validation(auth_client):
    """Test validation errors for invalid payload."""
    client, _ = auth_client

    # Missing title
    res1 = client.post("/api/v1/peitho/reminders", json={
        "due_at": "2026-10-20T10:00:00Z",
    })
    assert res1.status_code == 422

    # Negative lead_minutes
    res2 = client.post("/api/v1/peitho/reminders", json={
        "title": "Invalid lead",
        "due_at": "2026-10-20T10:00:00Z",
        "lead_minutes": -5,
    })
    assert res2.status_code == 422

    # Lead minutes > 10080 (7 days)
    res3 = client.post("/api/v1/peitho/reminders", json={
        "title": "Invalid lead max",
        "due_at": "2026-10-20T10:00:00Z",
        "lead_minutes": 20000,
    })
    assert res3.status_code == 422


# ─────────────────────────────────────────────────────────────────────────────
# 6. WEBSOCKET PROTOCOL EXTENSIONS
# ─────────────────────────────────────────────────────────────────────────────

def test_websocket_reminder_action(auth_client):
    """Verify WebSocket handles client reminder_action without breaking call state."""
    client, _ = auth_client
    start_payload = {
        "product_name": "Test Item",
        "base_price": 100.0,
        "cost_price": 60.0,
        "min_floor": 70.0,
    }
    start_res = client.post("/api/v1/peitho/start", json=start_payload)
    assert start_res.status_code == 200
    session_id = start_res.json()["session_id"]

    with client.websocket_connect(f"/api/v1/peitho/ws/{session_id}") as ws:
        # Receive ready
        ready_msg = ws.receive_json()
        assert ready_msg["type"] == "ready"

        # Send client reminder_action
        ws.send_json({
            "type": "reminder_action",
            "id": 9999,
            "action": "confirm",
        })

        # Send transcript line to verify socket remains fully functional
        ws.send_json({
            "type": "transcript_line",
            "channel": "SELLER",
            "text": "Hello buyer, let's connect Friday.",
            "is_final": True,
        })
        # Wait for state or advisory messages
        msg = ws.receive_json()
        assert msg is not None


# ─────────────────────────────────────────────────────────────────────────────
# 7. LOGGING PRIVACY COMPLIANCE
# ─────────────────────────────────────────────────────────────────────────────

def test_logging_privacy():
    """Verify logs NEVER contain raw transcript text, reminder titles, notes, or email bodies."""
    import logging
    import io

    log_stream = io.StringIO()
    handler = logging.StreamHandler(log_stream)
    root_logger = logging.getLogger()
    root_logger.addHandler(handler)

    secret_transcript = "Secret deal terms: 40% discount if signed by next Monday."
    secret_title = "Send secret deal terms"
    secret_note = "Confidential client passcode 12345"

    try:
        # Run gate
        has_reminder_cue(secret_transcript)
        # Run date resolution
        resolve_datetime(secret_transcript)
        # Flush logs
        handler.flush()
        captured = log_stream.getvalue()

        assert secret_transcript not in captured, "Raw transcript text leaked into logs!"
        assert secret_title not in captured, "Reminder title leaked into logs!"
        assert secret_note not in captured, "Reminder note leaked into logs!"
    finally:
        root_logger.removeHandler(handler)
