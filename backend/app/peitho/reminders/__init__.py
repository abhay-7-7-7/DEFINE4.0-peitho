"""
Peitho Reminders Package.
Automatic event & commitment detection, scheduling, calendar management, and email delivery.
"""
from .routes import reminders_router
from .db import ensure_reminder_tables
from .scheduler import start_reminder_scheduler, stop_reminder_scheduler
from .detect import process_line_for_reminders
from .ws_manager import reminder_ws_manager

__all__ = [
    "reminders_router",
    "ensure_reminder_tables",
    "start_reminder_scheduler",
    "stop_reminder_scheduler",
    "process_line_for_reminders",
    "reminder_ws_manager",
]
