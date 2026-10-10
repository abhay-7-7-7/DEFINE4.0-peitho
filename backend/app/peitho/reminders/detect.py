"""
Live Call Reminder Detection Engine.
Fast regex gate → Async LLM with PII scrub → Deterministic dates.py source of truth.
Runs as a non-blocking background task after each final speaker line.
"""
from __future__ import annotations

import asyncio
import json
import re
import datetime
from typing import Dict, List, Optional, Any, Tuple
import structlog
from pydantic import BaseModel, Field

from ...infrastructure.llm.openai_client import OpenRouterClient
from .dates import resolve_datetime, DateResolutionResult
from .db import (
    create_reminder, update_reminder, find_dedupe_match, get_user_prefs
)
from .ws_manager import reminder_ws_manager

logger = structlog.get_logger(__name__)

# ── 1. Fast Keyword / Regex Gate ──
# Matches days, dates, clocks, commitments, and Hindi/Hinglish cues
CUE_PATTERN = re.compile(
    r"\b("
    # Days & Relatives
    r"tomorrow|yesterday|tonight|next week|weekend|end of the week|later today|"
    r"kal|parso|parson|agle hafte|hafta|\d+\s*(?:din|days)(?:\s*baad)?|after\s+\d+\s*days|in\s+\d+\s*(?:days|hours|din)|"
    r"monday|tuesday|wednesday|thursday|friday|saturday|sunday|"
    r"mon|tue|wed|thu|fri|sat|sun|"
    r"somwar|somvaar|mangalwar|mangalvaar|budhwar|budhvaar|guruwar|guruvaar|shukrawar|shukrawaar|shaniwar|shanivaar|ravivar|ravivaar|itwar|"
    # Clock times & Months
    r"\d{1,2}:\d{2}|\d{1,2}\s*(?:am|pm)|at\s+\d{1,2}|"
    r"january|february|march|april|may|june|july|august|september|october|november|december|"
    r"jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|"
    r"\d{1,2}(?:st|nd|rd|th)|"
    # Commitment & action verbs
    r"remind|reminder|follow[\s-]?up|call[\s-]?back|callback|schedule|meeting|meet|"
    r"deadline|deliver|delivery|shipment|dispatch|send (?:the )?(?:quote|invoice|proposal|email|po|details)|"
    r"will send|i\'ll send|i will|let\'s talk|discuss|touch base|catch up|"
    r"bhej dunga|bhej denge|baat karenge|call karta hu|call karunga|milte hai|milenge"
    r")\b",
    re.IGNORECASE,
)

DEVANAGARI_CUE_PATTERN = re.compile(
    r"(?:सोमवार|मंगलवार|बुधवार|गुरुवार|शुक्रवार|शनिवार|रविवार|कल|परसों|बजे|डिलीवरी|भिजवा|भेज)"
)


def has_reminder_cue(text: str) -> bool:
    """Cheap gate: returns True if text contains time or commitment cues."""
    if not text:
        return False
    return bool(CUE_PATTERN.search(text) or DEVANAGARI_CUE_PATTERN.search(text))


# ── 2. PII Scrubber ──
EMAIL_REGEX = re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+")
PHONE_REGEX = re.compile(r"(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}")
CARD_REGEX = re.compile(r"\b(?:\d{4}[-\s]?){3}\d{4}\b")


def scrub_pii(text: str) -> str:
    """Scrub sensitive PII from text before passing to LLM."""
    s = EMAIL_REGEX.sub("[EMAIL]", text)
    s = PHONE_REGEX.sub("[PHONE]", s)
    s = CARD_REGEX.sub("[CARD]", s)
    return s


# ── 3. Structured LLM Response Schema ──
class LLMReminderItem(BaseModel):
    title: str = Field(description="Action-phrased title under 80 chars, e.g. 'Send updated product quote'")
    date_text: Optional[str] = Field(default=None, description="Spoken date/time phrase, e.g. 'tomorrow at 3pm'")
    resolved_date: Optional[str] = Field(default=None, description="YYYY-MM-DD if identifiable")
    time: Optional[str] = Field(default=None, description="HH:MM in 24h clock if identifiable")
    owner: str = Field(default="seller", description="'seller' | 'buyer' | 'both'")
    confidence: str = Field(default="high", description="'low' | 'medium' | 'high'")
    note: Optional[str] = Field(default=None, description="Short context note")


class LLMRemindersResponse(BaseModel):
    reminders: List[LLMReminderItem] = Field(default_factory=list)


DETECTION_SYSTEM_PROMPT = """You are an automated event and commitment extraction engine for sales calls.
Identify any actionable reminder, commitment, callback, meeting, promised quote/delivery, or deadline mentioned in the conversation.
Output STRICT JSON ONLY:
{
  "reminders": [
    {
      "title": "Action-phrased title under 80 chars (e.g. 'Send revised pricing quote')",
      "date_text": "Spoken time cue (e.g. 'Friday 3pm')",
      "resolved_date": "YYYY-MM-DD or null",
      "time": "HH:MM (24-hour) or null",
      "owner": "seller|buyer|both",
      "confidence": "low|medium|high",
      "note": "Short additional detail or null"
    }
  ]
}

RULES:
1. Only return reminders if a speaker committed to a future action, callback, deadline, or delivery.
2. If speaker says "I'll send the quote tomorrow at 4pm", owner is 'seller'.
3. If buyer says "I will check with finance by Monday", owner is 'buyer'.
4. If no commitment or temporal event is present, return {"reminders": []}.
5. Do NOT output markdown code blocks. Output pure JSON."""


async def _extract_reminders_llm(
    context_lines: List[str],
    current_dt: datetime.datetime,
    timezone_name: str,
) -> List[LLMReminderItem]:
    """Call async LLM with 4s timeout to extract reminders."""
    client = OpenRouterClient()
    if not client.enabled:
        return _fallback_deterministic_extract(context_lines, current_dt)

    weekday_str = current_dt.strftime("%A")
    current_date_str = current_dt.strftime("%Y-%m-%d")
    current_time_str = current_dt.strftime("%H:%M")

    # Scrub PII from context
    scrubbed_lines = [scrub_pii(line) for line in context_lines]
    dialogue_context = "\n".join(scrubbed_lines)

    user_prompt = f"""CURRENT REFERENCE TIME:
Date: {current_date_str} ({weekday_str})
Time: {current_time_str}
Timezone: {timezone_name}

RECENT CALL DIALOGUE (last {len(scrubbed_lines)} lines):
{dialogue_context}

Extract all commitments and reminders:"""

    try:
        response = await asyncio.wait_for(
            client.generate(DETECTION_SYSTEM_PROMPT, user_prompt, temperature=0.1),
            timeout=4.0,
        )
        if not response.success or not response.content:
            return _fallback_deterministic_extract(context_lines, current_dt)

        cleaned = response.content.strip()
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
            cleaned = re.sub(r"\s*```$", "", cleaned)

        data = json.loads(cleaned)
        parsed = LLMRemindersResponse(**data)
        return parsed.reminders
    except Exception as exc:
        logger.debug("reminder_llm_detection_failed_or_timeout", error_type=type(exc).__name__)
        return _fallback_deterministic_extract(context_lines, current_dt)


def _fallback_deterministic_extract(
    context_lines: List[str],
    current_dt: datetime.datetime,
) -> List[LLMReminderItem]:
    """Deterministic fallback regex parser if LLM fails or is disabled."""
    results: List[LLMReminderItem] = []
    text = " ".join(context_lines)

    # Detect follow up / callback / quote send
    title = "Follow up with customer"
    owner = "seller"
    if "quote" in text.lower():
        title = "Send pricing quote"
    elif "call" in text.lower() or "callback" in text.lower():
        title = "Scheduled callback"
    elif "delivery" in text.lower() or "shipment" in text.lower():
        title = "Product delivery follow-up"

    results.append(LLMReminderItem(
        title=title,
        date_text=text[:60],
        resolved_date=None,
        time=None,
        owner=owner,
        confidence="medium",
        note="Extracted via fallback parser",
    ))
    return results


# ── 4. Main Detection Hook ──
async def process_line_for_reminders(
    user_id: int,
    session_id: str,
    channel: str,
    text: str,
    transcript_history: List[Any],
    safe_send: Optional[Any] = None,
    ephemeral_mode: bool = False,
) -> None:
    """
    Main hook called after each FINAL line of either speaker.
    Fast gate check (< 0.2ms) → if matched, asynchronously processes in background.
    """
    if not text or not has_reminder_cue(text):
        return

    # User preferences for timezone
    prefs = await get_user_prefs(user_id)
    tz_name = prefs.get("timezone") or "Asia/Kolkata"
    default_lead = prefs.get("default_lead_minutes", 30)

    try:
        from .dates import _safe_tz
        tz = _safe_tz(tz_name)
        ref_now = datetime.datetime.now(tz)
    except Exception:
        ref_now = datetime.datetime.now()
        tz_name = "Asia/Kolkata"

    # Last 4 transcript lines for context
    recent_lines = []
    for item in transcript_history[-4:]:
        t_speaker = getattr(item, "channel", channel)
        if hasattr(t_speaker, "value"):
            t_speaker = t_speaker.value
        t_txt = getattr(item, "text", str(item))
        recent_lines.append(f"{t_speaker}: {t_txt}")

    if not recent_lines:
        recent_lines = [f"{channel}: {text}"]

    # Extract via LLM / parser
    items = await _extract_reminders_llm(recent_lines, ref_now, tz_name)
    if not items:
        return

    for item in items:
        # Deterministic date resolution is the source of truth!
        full_query = f"{item.title} {item.date_text or ''} {text}"
        res: DateResolutionResult = resolve_datetime(
            text=full_query,
            now=ref_now,
            tz_name=tz_name,
            resolved_date_hint=item.resolved_date,
            time_hint=item.time,
        )

        title_clean = item.title[:200].strip()
        confidence = item.confidence if item.confidence in ("low", "medium", "high") else "medium"
        needs_review = (confidence == "low") or res.needs_date
        time_assumed = res.time_assumed

        # Null-safe due_at: if date could not be resolved, default to +1 day 10:00 AM with needs_review=True
        if res.dt_utc is None:
            # Safe placeholder (+1 day at 10 AM)
            placeholder_local = ref_now + datetime.timedelta(days=1)
            placeholder_local = placeholder_local.replace(hour=10, minute=0, second=0, microsecond=0)
            res.dt_utc = placeholder_local.astimezone(datetime.timezone.utc).replace(tzinfo=None)
            res.dt_local = placeholder_local
            needs_review = True

        owner_val = item.owner.lower()
        if owner_val not in ("seller", "buyer", "both"):
            owner_val = "seller"

        # Deduplication and correction merge
        normalized_title = re.sub(r"[^\w\s]", "", title_clean).lower()
        due_date_str = res.date_str or res.dt_local.strftime("%Y-%m-%d")

        match = await find_dedupe_match(
            user_id=user_id,
            title_norm=normalized_title,
            due_date_str=due_date_str,
            call_id=session_id,
        )

        # Correction merge: if seller says "actually make it Thursday", update prior reminder
        is_correction = bool(re.search(r"\b(?:actually|instead|rather|no wait|change to|make it)\b", text, re.IGNORECASE))

        if match and is_correction:
            # Merge correction into existing reminder
            updated = await update_reminder(
                user_id=user_id,
                reminder_id=match["id"],
                updates={
                    "due_at": res.dt_utc,
                    "title": title_clean,
                    "note": item.note or match.get("note"),
                    "confidence": confidence,
                },
            )
            reminder_id = match["id"]
            action_type = "reminder_updated"
            logger.info("reminder_correction_merged", reminder_id=reminder_id, user_id=user_id)
        elif match:
            # Already exists: skip duplicate
            logger.debug("reminder_deduped", reminder_id=match["id"])
            continue
        else:
            # Ephemeral mode: if ephemeral, hold in memory or create with status
            reminder_id = await create_reminder(
                user_id=user_id,
                call_id=session_id,
                title=title_clean,
                note=item.note,
                due_at=res.dt_utc,
                all_day=False,
                timezone=tz_name,
                lead_minutes=default_lead,
                owner=owner_val,
                source="detected",
                status="active",
                confidence=confidence,
            )
            action_type = "reminder_detected"
            logger.info("reminder_detected_and_saved", reminder_id=reminder_id, user_id=user_id)

        # Emitted WebSocket payload
        due_iso = res.dt_local.isoformat() if res.dt_local else res.dt_utc.isoformat()
        payload = {
            "type": action_type,
            "reminder": {
                "id": reminder_id,
                "title": title_clean,
                "note": item.note,
                "due_at": due_iso,
                "all_day": False,
                "owner": owner_val,
                "confidence": confidence,
                "source": "detected",
                "needs_review": needs_review,
                "time_assumed": time_assumed,
            }
        }

        # Safe send directly to call socket
        if safe_send is not None:
            await safe_send(payload)
        # Also broadcast via WS manager
        await reminder_ws_manager.broadcast_session(session_id, payload)
