"""
Background Async Scheduler for Peitho Reminders Delivery.
Runs every 30s, claims due reminders atomically, dispatches emails asynchronously,
and gracefully handles retries and missing SMTP configurations.
"""
from __future__ import annotations

import asyncio
import datetime
from zoneinfo import ZoneInfo
from typing import Optional, Tuple
import structlog

from ...core.config import get_settings
from ...services.email_service import EmailService
from ...api.v1.email_routes import get_user_email_settings, _build_service
from .db import (
    claim_due_reminders,
    mark_reminder_notified,
    mark_missed_reminders,
    get_reminder,
    list_reminders,
    get_user_prefs,
)
from .email_templates import template_reminder_notification, template_call_summary_reminders
from .dates import _safe_tz

logger = structlog.get_logger(__name__)

_scheduler_task: Optional[asyncio.Task] = None
_stop_event = asyncio.Event()


async def send_reminder_email_now(user_id: int, reminder_id: int) -> Tuple[bool, str]:
    """
    Send a reminder email immediately (e.g. for test or scheduled trigger).
    Runs SMTP in asyncio.to_thread to avoid blocking event loop.
    Returns (success: bool, message: str).
    """
    reminder = await get_reminder(user_id, reminder_id)
    if not reminder:
        return False, "Reminder not found"

    settings_dict = await get_user_email_settings(user_id)
    if not settings_dict or not settings_dict.get("notifications_enabled"):
        return False, "Email notifications are disabled or not configured"
    if not settings_dict.get("smtp_user") or not settings_dict.get("smtp_password"):
        return False, "SMTP credentials not configured"

    # Build local time for formatting
    tz_name = reminder.get("timezone") or "Asia/Kolkata"
    tz = _safe_tz(tz_name)

    due_utc = reminder["due_at"]
    if due_utc.tzinfo is None:
        due_utc_aware = due_utc.replace(tzinfo=datetime.timezone.utc)
    else:
        due_utc_aware = due_utc.astimezone(datetime.timezone.utc)

    dt_local = due_utc_aware.astimezone(tz)

    subject, html_body = template_reminder_notification(
        title=reminder["title"],
        dt_local=dt_local,
        timezone_name=tz_name,
        note=reminder.get("note"),
        owner=reminder.get("owner", "seller"),
        dt_utc=due_utc_aware,
    )

    to_email = settings_dict.get("from_email") or settings_dict.get("smtp_user")
    service = _build_service(settings_dict)

    # Run blocking SMTP in thread
    success = await asyncio.to_thread(service.send, to_email, subject, html_body)
    if success:
        await mark_reminder_notified(reminder_id)
        logger.info("reminder_email_sent_successfully", reminder_id=reminder_id, user_id=user_id)
        return True, "Email sent successfully"
    else:
        logger.error("reminder_email_send_failed", reminder_id=reminder_id, user_id=user_id)
        return False, "SMTP delivery failed. Check your email credentials."


async def send_call_summary_email(user_id: int, session_id: str, product_name: str) -> bool:
    """Send summary email of detected reminders at end of call."""
    prefs = await get_user_prefs(user_id)
    if not prefs.get("call_summary_email_enabled", True):
        return False

    reminders = await list_reminders(user_id, call_id=session_id)
    if not reminders:
        return False

    settings_dict = await get_user_email_settings(user_id)
    if not settings_dict or not settings_dict.get("smtp_user") or not settings_dict.get("smtp_password"):
        return False

    subject, html_body = template_call_summary_reminders(
        product_name=product_name or "Sales Call",
        reminders=reminders,
        timezone_name=prefs.get("timezone", "Asia/Kolkata"),
    )

    to_email = settings_dict.get("from_email") or settings_dict.get("smtp_user")
    service = _build_service(settings_dict)

    success = await asyncio.to_thread(service.send, to_email, subject, html_body)
    if success:
        logger.info("call_summary_email_sent", user_id=user_id, reminder_count=len(reminders))
    return success


async def _scheduler_loop() -> None:
    """Main scheduler loop running every 30s."""
    settings = get_settings()
    grace_hours = getattr(settings, "peitho_reminder_grace_hours", 24)

    # Startup grace cleanup: mark long-overdue (> 24h) reminders as missed
    try:
        missed_count = await mark_missed_reminders(grace_hours=grace_hours)
        if missed_count > 0:
            logger.info("peitho_reminders_marked_missed_at_startup", count=missed_count)
    except Exception as e:
        logger.error("peitho_missed_reminders_check_error", error_type=type(e).__name__)

    logger.info("peitho_reminder_scheduler_started")

    while not _stop_event.is_set():
        try:
            # Claim batch of due reminders
            due_batch = await claim_due_reminders(batch_size=10)
            for item in due_batch:
                reminder_id = item["id"]
                user_id = item["user_id"]
                try:
                    await send_reminder_email_now(user_id, reminder_id)
                except Exception as ex:
                    logger.error("reminder_delivery_exception", reminder_id=reminder_id, error_type=type(ex).__name__)
        except Exception as loop_ex:
            logger.error("peitho_scheduler_loop_error", error_type=type(loop_ex).__name__)

        try:
            await asyncio.wait_for(_stop_event.wait(), timeout=30.0)
        except asyncio.TimeoutError:
            pass

    logger.info("peitho_reminder_scheduler_stopped")


def start_reminder_scheduler() -> None:
    """Start the background reminder scheduler task."""
    global _scheduler_task, _stop_event
    _stop_event.clear()
    if _scheduler_task is None or _scheduler_task.done():
        _scheduler_task = asyncio.create_task(_scheduler_loop())


async def stop_reminder_scheduler() -> None:
    """Stop the background reminder scheduler task."""
    global _scheduler_task, _stop_event
    _stop_event.set()
    if _scheduler_task and not _scheduler_task.done():
        _scheduler_task.cancel()
        try:
            await _scheduler_task
        except asyncio.CancelledError:
            pass
    _scheduler_task = None
