"""
Database access and schema management for Peitho Reminders.
"""
from __future__ import annotations

import datetime
from typing import Dict, List, Optional, Any, Tuple
import aiomysql
import structlog

import asyncio
from contextlib import asynccontextmanager
from ...infrastructure.database import session as db_session

logger = structlog.get_logger(__name__)


@asynccontextmanager
async def get_conn():
    """Yield an aiomysql connection, resetting pool if running loop has changed or closed."""
    try:
        loop = asyncio.get_running_loop()
        if db_session._pool is not None and (db_session._pool._loop.is_closed() or db_session._pool._loop != loop):
            db_session._pool = None
    except Exception:
        pass
    async with db_session.get_conn() as conn:
        yield conn


async def ensure_reminder_tables() -> None:
    """Create peitho_reminders and peitho_reminder_prefs tables if they do not exist."""
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
                CREATE TABLE IF NOT EXISTS peitho_reminders (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT NOT NULL,
                    call_id VARCHAR(64) NULL,
                    title VARCHAR(200) NOT NULL,
                    note TEXT NULL,
                    due_at DATETIME NOT NULL,
                    all_day TINYINT(1) DEFAULT 0,
                    timezone VARCHAR(64) NOT NULL,
                    lead_minutes INT DEFAULT 30,
                    owner ENUM('seller','buyer','both') DEFAULT 'seller',
                    source ENUM('detected','manual') NOT NULL,
                    status ENUM('active','done','cancelled','missed') DEFAULT 'active',
                    confidence ENUM('low','medium','high') NULL,
                    notified_at DATETIME NULL,
                    notify_attempts INT DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                    INDEX idx_status_due_at (status, due_at),
                    INDEX idx_user_due_at (user_id, due_at)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)

            await cur.execute("""
                CREATE TABLE IF NOT EXISTS peitho_reminder_prefs (
                    user_id INT NOT NULL PRIMARY KEY,
                    timezone VARCHAR(64) DEFAULT 'Asia/Kolkata',
                    default_lead_minutes INT DEFAULT 30,
                    email_enabled TINYINT(1) DEFAULT 1,
                    call_summary_email_enabled TINYINT(1) DEFAULT 1,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """)
    logger.info("peitho_reminder_tables_ensured")


# ── Prefs Helpers ─────────────────────────────────────────────────────────────

async def get_user_prefs(user_id: int) -> dict:
    """Fetch reminder preferences for a user, or default."""
    async with get_conn() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM peitho_reminder_prefs WHERE user_id = %s", (user_id,))
            row = await cur.fetchone()
            if row:
                return row
    return {
        "user_id": user_id,
        "timezone": "Asia/Kolkata",
        "default_lead_minutes": 30,
        "email_enabled": True,
        "call_summary_email_enabled": True,
    }


async def upsert_user_prefs(
    user_id: int,
    timezone: str = "Asia/Kolkata",
    default_lead_minutes: int = 30,
    email_enabled: bool = True,
    call_summary_email_enabled: bool = True,
) -> dict:
    """Update or insert user reminder preferences."""
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
                INSERT INTO peitho_reminder_prefs (
                    user_id, timezone, default_lead_minutes, email_enabled, call_summary_email_enabled
                ) VALUES (%s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                    timezone = VALUES(timezone),
                    default_lead_minutes = VALUES(default_lead_minutes),
                    email_enabled = VALUES(email_enabled),
                    call_summary_email_enabled = VALUES(call_summary_email_enabled)
            """, (user_id, timezone, default_lead_minutes, int(email_enabled), int(call_summary_email_enabled)))
    return await get_user_prefs(user_id)


# ── Reminder CRUD Helpers ─────────────────────────────────────────────────────

async def list_reminders(
    user_id: int,
    from_dt: Optional[datetime.datetime] = None,
    to_dt: Optional[datetime.datetime] = None,
    status: Optional[str] = None,
    call_id: Optional[str] = None,
) -> List[dict]:
    """List reminders owned by user_id with optional filters."""
    query = "SELECT * FROM peitho_reminders WHERE user_id = %s"
    params: List[Any] = [user_id]

    if from_dt is not None:
        query += " AND due_at >= %s"
        params.append(from_dt)
    if to_dt is not None:
        query += " AND due_at <= %s"
        params.append(to_dt)
    if status is not None:
        query += " AND status = %s"
        params.append(status)
    if call_id is not None:
        query += " AND call_id = %s"
        params.append(call_id)

    query += " ORDER BY due_at ASC"

    async with get_conn() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(query, tuple(params))
            return await cur.fetchall()


async def get_reminder(user_id: int, reminder_id: int) -> Optional[dict]:
    """Get single reminder by id owned by user_id."""
    async with get_conn() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT * FROM peitho_reminders WHERE id = %s AND user_id = %s",
                (reminder_id, user_id),
            )
            return await cur.fetchone()


async def create_reminder(
    user_id: int,
    title: str,
    due_at: datetime.datetime,
    note: Optional[str] = None,
    call_id: Optional[str] = None,
    all_day: bool = False,
    timezone: str = "Asia/Kolkata",
    lead_minutes: int = 30,
    owner: str = "seller",
    source: str = "manual",
    status: str = "active",
    confidence: Optional[str] = None,
) -> int:
    """Insert a new reminder for user_id."""
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
                INSERT INTO peitho_reminders (
                    user_id, call_id, title, note, due_at, all_day, timezone,
                    lead_minutes, owner, source, status, confidence
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                user_id, call_id, title, note, due_at, int(all_day), timezone,
                lead_minutes, owner, source, status, confidence
            ))
            return cur.lastrowid


async def update_reminder(
    user_id: int,
    reminder_id: int,
    updates: Dict[str, Any],
) -> Optional[dict]:
    """
    Update reminder fields. If due_at or lead_minutes changed, reset notified_at and notify_attempts.
    """
    allowed_fields = {
        "title", "note", "due_at", "all_day", "timezone",
        "lead_minutes", "owner", "status", "confidence",
    }
    filtered = {k: v for k, v in updates.items() if k in allowed_fields}
    if not filtered:
        return await get_reminder(user_id, reminder_id)

    # Check if due_at or lead_minutes changed to re-arm
    rearm = "due_at" in filtered or "lead_minutes" in filtered or filtered.get("status") == "active"

    set_clauses = [f"{k} = %s" for k in filtered.keys()]
    values = list(filtered.values())

    if rearm:
        set_clauses.append("notified_at = NULL")
        set_clauses.append("notify_attempts = 0")

    query = f"UPDATE peitho_reminders SET {', '.join(set_clauses)} WHERE id = %s AND user_id = %s"
    values.extend([reminder_id, user_id])

    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute(query, tuple(values))
            if cur.rowcount == 0:
                # Check if reminder exists
                existing = await get_reminder(user_id, reminder_id)
                if not existing:
                    return None

    return await get_reminder(user_id, reminder_id)


async def delete_reminder(user_id: int, reminder_id: int) -> bool:
    """Delete a reminder owned by user_id."""
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute(
                "DELETE FROM peitho_reminders WHERE id = %s AND user_id = %s",
                (reminder_id, user_id),
            )
            return cur.rowcount > 0


async def find_dedupe_match(
    user_id: int,
    title_norm: str,
    due_date_str: str,
    call_id: Optional[str] = None,
) -> Optional[dict]:
    """
    Find matching reminder in the call or within last 24h for user_id to deduplicate.
    """
    query = """
        SELECT * FROM peitho_reminders
        WHERE user_id = %s
          AND (call_id = %s OR created_at >= NOW() - INTERVAL 24 HOUR)
          AND status IN ('active', 'done')
        ORDER BY id DESC LIMIT 10
    """
    async with get_conn() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(query, (user_id, call_id))
            rows = await cur.fetchall()

    for r in rows:
        r_title = (r["title"] or "").lower().strip()
        r_due = r["due_at"].strftime("%Y-%m-%d") if r["due_at"] else ""
        if r_due == due_date_str and (title_norm in r_title or r_title in title_norm):
            return r
    return None


# ── Scheduler DB Helpers ──────────────────────────────────────────────────────

async def claim_due_reminders(batch_size: int = 10) -> List[dict]:
    """
    Select active reminders where notified_at IS NULL and due_at - lead_minutes <= NOW(),
    and atomically increment notify_attempts to prevent duplicate execution across workers.
    """
    async with get_conn() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            # Select batch of candidate IDs
            await cur.execute("""
                SELECT id, user_id, title, note, due_at, timezone, lead_minutes, owner, notify_attempts
                FROM peitho_reminders
                WHERE status = 'active'
                  AND notified_at IS NULL
                  AND notify_attempts < 3
                  AND DATE_SUB(due_at, INTERVAL lead_minutes MINUTE) <= UTC_TIMESTAMP()
                ORDER BY due_at ASC
                LIMIT %s
            """, (batch_size,))
            candidates = await cur.fetchall()

            if not candidates:
                return []

            candidate_ids = [c["id"] for c in candidates]
            format_strings = ','.join(['%s'] * len(candidate_ids))
            # Claim atomically
            await cur.execute(f"""
                UPDATE peitho_reminders
                SET notify_attempts = notify_attempts + 1
                WHERE id IN ({format_strings}) AND notified_at IS NULL
            """, tuple(candidate_ids))

            return candidates


async def mark_reminder_notified(reminder_id: int) -> None:
    """Mark reminder as successfully notified."""
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
                UPDATE peitho_reminders
                SET notified_at = UTC_TIMESTAMP()
                WHERE id = %s
            """, (reminder_id,))


async def mark_missed_reminders(grace_hours: int = 24) -> int:
    """
    At startup or periodic check, mark long-overdue reminders as 'missed'
    instead of spamming sellers late.
    """
    async with get_conn() as conn:
        async with conn.cursor() as cur:
            await cur.execute("""
                UPDATE peitho_reminders
                SET status = 'missed'
                WHERE status = 'active'
                  AND notified_at IS NULL
                  AND due_at < DATE_SUB(UTC_TIMESTAMP(), INTERVAL %s HOUR)
            """, (grace_hours,))
            return cur.rowcount
