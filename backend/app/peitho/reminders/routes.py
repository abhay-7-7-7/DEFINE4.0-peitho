"""
REST API routes for Peitho Reminders.
Prefix: /api/v1/peitho/reminders
All endpoints enforce JWT authentication and user ownership isolation.
"""
from __future__ import annotations

import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import JSONResponse
import structlog

from ...api.v1.auth_routes import get_current_user
from ...api.middleware import limiter
from .schemas import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    ReminderPrefsUpdate,
    ReminderPrefsResponse,
)
from .db import (
    list_reminders,
    get_reminder,
    create_reminder,
    update_reminder,
    delete_reminder,
    get_user_prefs,
    upsert_user_prefs,
    get_conn,
)
from .scheduler import send_reminder_email_now
from .ws_manager import reminder_ws_manager

logger = structlog.get_logger(__name__)

reminders_router = APIRouter(prefix="/api/v1/peitho/reminders", tags=["Peitho Reminders"])


@reminders_router.get("/health")
async def check_reminders_health():
    """Verify MySQL database connectivity and peitho_reminders table availability."""
    try:
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.execute("SELECT 1")
                await cur.execute("SELECT COUNT(*) FROM peitho_reminders")
                count = (await cur.fetchone())[0]
        return {"status": "healthy", "database": "mysql_connected", "reminders_stored": count}
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "message": str(e)})


@reminders_router.get("", response_model=List[ReminderResponse])
@limiter.limit("60/minute")
async def get_reminders(
    request: Request,
    from_date: Optional[str] = Query(default=None, alias="from"),
    to_date: Optional[str] = Query(default=None, alias="to"),
    status_filter: Optional[str] = Query(default=None, alias="status"),
    call_id: Optional[str] = Query(default=None),
    user: dict = Depends(get_current_user),
):
    """List reminders owned by the authenticated user with optional date range and status filters."""
    from_dt = None
    to_dt = None
    if from_date:
        try:
            from_dt = datetime.datetime.fromisoformat(from_date.replace("Z", "+00:00"))
        except Exception:
            pass
    if to_date:
        try:
            to_dt = datetime.datetime.fromisoformat(to_date.replace("Z", "+00:00"))
        except Exception:
            pass

    rows = await list_reminders(
        user_id=user["id"],
        from_dt=from_dt,
        to_dt=to_dt,
        status=status_filter,
        call_id=call_id,
    )
    return rows


@reminders_router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("30/minute")
async def create_new_reminder(
    request: Request,
    body: ReminderCreate,
    user: dict = Depends(get_current_user),
):
    """Create a manual reminder for the authenticated user."""
    # Convert due_at to UTC naive datetime if aware
    due_utc = body.due_at
    if due_utc.tzinfo is not None:
        due_utc = due_utc.astimezone(datetime.timezone.utc).replace(tzinfo=None)

    reminder_id = await create_reminder(
        user_id=user["id"],
        title=body.title.strip(),
        due_at=due_utc,
        note=body.note,
        call_id=body.call_id,
        all_day=body.all_day,
        timezone=body.timezone,
        lead_minutes=body.lead_minutes,
        owner=body.owner,
        source=body.source,
        status=body.status,
        confidence=body.confidence,
    )

    created = await get_reminder(user["id"], reminder_id)
    if not created:
        raise HTTPException(status_code=500, detail="Failed to retrieve created reminder")

    # Broadcast to user's active call sockets if any
    ws_payload = {
        "type": "reminder_detected" if body.source == "detected" else "reminder_updated",
        "reminder": {
            "id": created["id"],
            "title": created["title"],
            "note": created["note"],
            "due_at": created["due_at"].isoformat() if created["due_at"] else None,
            "all_day": bool(created["all_day"]),
            "owner": created["owner"],
            "confidence": created["confidence"],
            "source": created["source"],
            "needs_review": created["confidence"] == "low",
            "time_assumed": False,
        }
    }
    if body.call_id:
        await reminder_ws_manager.broadcast_session(body.call_id, ws_payload)
    await reminder_ws_manager.broadcast_user(user["id"], ws_payload)

    return created


@reminders_router.patch("/{reminder_id}", response_model=ReminderResponse)
@limiter.limit("60/minute")
async def update_existing_reminder(
    request: Request,
    reminder_id: int,
    body: ReminderUpdate,
    user: dict = Depends(get_current_user),
):
    """Update fields on a reminder owned by current user. Re-arms notifications if due date changed."""
    existing = await get_reminder(user["id"], reminder_id)
    if not existing:
        return JSONResponse(status_code=404, content={"detail": "Reminder not found"})

    dumped = body.model_dump(exclude_unset=True)
    if "due_at" in dumped and dumped["due_at"] is not None:
        due_utc = dumped["due_at"]
        if hasattr(due_utc, "tzinfo") and due_utc.tzinfo is not None:
            dumped["due_at"] = due_utc.astimezone(datetime.timezone.utc).replace(tzinfo=None)

    updated = await update_reminder(user["id"], reminder_id, dumped)
    if not updated:
        return JSONResponse(status_code=404, content={"detail": "Reminder not found or update failed"})

    # Broadcast update to user's open call sockets
    ws_payload = {
        "type": "reminder_updated",
        "reminder": {
            "id": updated["id"],
            "title": updated["title"],
            "note": updated["note"],
            "due_at": updated["due_at"].isoformat() if updated["due_at"] else None,
            "all_day": bool(updated["all_day"]),
            "owner": updated["owner"],
            "confidence": updated["confidence"],
            "source": updated["source"],
            "status": updated["status"],
            "needs_review": updated["confidence"] == "low",
            "time_assumed": False,
        }
    }
    if updated.get("call_id"):
        await reminder_ws_manager.broadcast_session(updated["call_id"], ws_payload)
    await reminder_ws_manager.broadcast_user(user["id"], ws_payload)

    return updated


@reminders_router.delete("/{reminder_id}")
@limiter.limit("60/minute")
async def delete_existing_reminder(
    request: Request,
    reminder_id: int,
    user: dict = Depends(get_current_user),
):
    """Delete a reminder owned by current user."""
    existing = await get_reminder(user["id"], reminder_id)
    if not existing:
        return JSONResponse(status_code=404, content={"detail": "Reminder not found"})

    deleted = await delete_reminder(user["id"], reminder_id)
    if not deleted:
        return JSONResponse(status_code=404, content={"detail": "Reminder not found"})

    # Broadcast deletion to active call sockets
    ws_payload = {"type": "reminder_deleted", "id": reminder_id}
    if existing.get("call_id"):
        await reminder_ws_manager.broadcast_session(existing["call_id"], ws_payload)
    await reminder_ws_manager.broadcast_user(user["id"], ws_payload)

    return {"ok": True, "id": reminder_id}


@reminders_router.post("/{reminder_id}/send-test")
@limiter.limit("10/minute")
async def send_test_email(
    request: Request,
    reminder_id: int,
    user: dict = Depends(get_current_user),
):
    """Trigger immediate email delivery of this reminder for demo / verification."""
    existing = await get_reminder(user["id"], reminder_id)
    if not existing:
        return JSONResponse(status_code=404, content={"detail": "Reminder not found"})

    success, message = await send_reminder_email_now(user["id"], reminder_id)
    if not success:
        return JSONResponse(status_code=400, content={"detail": message})

    return {"success": True, "message": message}


@reminders_router.get("/prefs", response_model=ReminderPrefsResponse)
@limiter.limit("60/minute")
async def get_reminder_preferences(
    request: Request,
    user: dict = Depends(get_current_user),
):
    """Get reminder preferences for current user."""
    return await get_user_prefs(user["id"])


@reminders_router.put("/prefs", response_model=ReminderPrefsResponse)
@limiter.limit("30/minute")
async def update_reminder_preferences(
    request: Request,
    body: ReminderPrefsUpdate,
    user: dict = Depends(get_current_user),
):
    """Update reminder preferences for current user."""
    return await upsert_user_prefs(
        user_id=user["id"],
        timezone=body.timezone or "Asia/Kolkata",
        default_lead_minutes=body.default_lead_minutes if body.default_lead_minutes is not None else 30,
        email_enabled=body.email_enabled if body.email_enabled is not None else True,
        call_summary_email_enabled=body.call_summary_email_enabled if body.call_summary_email_enabled is not None else True,
    )
