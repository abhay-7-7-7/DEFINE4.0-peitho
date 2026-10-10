"""
Deterministic Date and Time Resolver for Peitho Reminders.
Supports English, Hindi, and Hinglish temporal expressions.
"""
from __future__ import annotations

import re
import datetime
from zoneinfo import ZoneInfo
from typing import Optional, Tuple
from dataclasses import dataclass


@dataclass
class DateResolutionResult:
    success: bool
    dt_local: Optional[datetime.datetime]
    dt_utc: Optional[datetime.datetime]
    time_assumed: bool
    needs_date: bool
    date_str: Optional[str]  # "YYYY-MM-DD"
    time_str: Optional[str]  # "HH:MM"


# Weekday index (0 = Monday, 6 = Sunday)
WEEKDAY_MAP = {
    "monday": 0, "mon": 0, "somwar": 0, "somvaar": 0, "सोमवार": 0,
    "tuesday": 1, "tue": 1, "mangalwar": 1, "mangalvaar": 1, "मंगलवार": 1,
    "wednesday": 2, "wed": 2, "budhwar": 2, "budhvaar": 2, "बुधवार": 2,
    "thursday": 3, "thu": 3, "guruwar": 3, "guruvaar": 3, "brihaspativar": 3, "गुरुवार": 3,
    "friday": 4, "fri": 4, "shukrawar": 4, "shukrawaar": 4, "शुक्रवार": 4,
    "saturday": 5, "sat": 5, "shaniwar": 5, "shanivaar": 5, "शनिवार": 5,
    "sunday": 6, "sun": 6, "ravivar": 6, "ravivaar": 6, "itwar": 6, "रविवार": 6,
}

MONTH_MAP = {
    "january": 1, "jan": 1, "february": 2, "feb": 2, "march": 3, "mar": 3,
    "april": 4, "apr": 4, "may": 5, "june": 6, "jun": 6,
    "july": 7, "jul": 7, "august": 8, "aug": 8, "september": 9, "sep": 9, "sept": 9,
    "october": 10, "oct": 10, "november": 11, "nov": 11, "december": 12, "dec": 12,
}


def _safe_tz(tz_name: str) -> datetime.tzinfo:
    try:
        return ZoneInfo(tz_name)
    except Exception:
        pass
    try:
        return ZoneInfo("Asia/Kolkata")
    except Exception:
        pass
    if "kolkata" in (tz_name or "").lower() or "ist" in (tz_name or "").lower() or "india" in (tz_name or "").lower():
        return datetime.timezone(datetime.timedelta(hours=5, minutes=30), name="Asia/Kolkata")
    return datetime.timezone.utc


def resolve_datetime(
    text: str,
    now: Optional[datetime.datetime] = None,
    tz_name: str = "Asia/Kolkata",
    resolved_date_hint: Optional[str] = None,  # From LLM if any YYYY-MM-DD
    time_hint: Optional[str] = None,           # From LLM if any HH:MM
) -> DateResolutionResult:
    """
    Deterministically resolves a date and time from text (or hints) relative to reference now.
    """
    tz = _safe_tz(tz_name)
    if now is None:
        ref_local = datetime.datetime.now(tz)
    else:
        if now.tzinfo is None:
            ref_local = now.replace(tzinfo=tz)
        else:
            ref_local = now.astimezone(tz)

    lower_text = (text or "").lower().strip()
    target_date: Optional[datetime.date] = None
    target_hour: Optional[int] = None
    target_minute: Optional[int] = None
    time_assumed = False

    # ── 1. Date Hints from LLM ──
    if resolved_date_hint:
        try:
            parts = [int(p) for p in resolved_date_hint.split("-")]
            if len(parts) == 3:
                target_date = datetime.date(parts[0], parts[1], parts[2])
        except Exception:
            target_date = None

    # ── 2. Time Hints from LLM ──
    if time_hint:
        try:
            t_parts = [int(p) for p in time_hint.split(":")]
            if len(t_parts) >= 2:
                target_hour = t_parts[0]
                target_minute = t_parts[1]
        except Exception:
            pass

    # ── 3. Deterministic Date Extraction from text ──
    if target_date is None:
        # Check "day after tomorrow" / "parso"
        if re.search(r"\b(?:day after tomorrow|parso|parson|परसों)\b", lower_text):
            target_date = ref_local.date() + datetime.timedelta(days=2)
        # Check "tomorrow" / "kal"
        elif re.search(r"\b(?:tomorrow|kal|कल)\b", lower_text):
            target_date = ref_local.date() + datetime.timedelta(days=1)
        # Check "today" / "aaj" / "this afternoon" / "tonight"
        elif re.search(r"\b(?:today|aaj|tonight|आज)\b", lower_text):
            target_date = ref_local.date()
        # Check "after X days" / "in X days" / "X din baad"
        elif m := re.search(r"\b(?:after|in)\s+(\d+)\s+days?\b", lower_text):
            target_date = ref_local.date() + datetime.timedelta(days=int(m.group(1)))
        elif m := re.search(r"\b(\d+)\s+(?:din|days?)\s+(?:baad|later)\b", lower_text):
            target_date = ref_local.date() + datetime.timedelta(days=int(m.group(1)))
        # Check "next week" / "agle hafte"
        elif re.search(r"\b(?:next week|agle hafte|अगले हफ्ते)\b", lower_text):
            days_until_next_mon = (7 - ref_local.weekday()) % 7
            if days_until_next_mon == 0:
                days_until_next_mon = 7
            target_date = ref_local.date() + datetime.timedelta(days=days_until_next_mon)
        # Check "end of the week" / "by the weekend"
        elif re.search(r"\b(?:end of (?:the )?week|weekend|hafta aakhir)\b", lower_text):
            days_to_fri = (4 - ref_local.weekday())
            if days_to_fri <= 0:
                days_to_fri += 7
            target_date = ref_local.date() + datetime.timedelta(days=days_to_fri)
        else:
            # Check Weekday mentions ("Friday", "next Monday", "somwar", "शुक्रवार")
            for w_name, w_idx in WEEKDAY_MAP.items():
                pattern = rf"\b(?:next\s+|coming\s+)?{re.escape(w_name)}\b"
                if re.search(pattern, lower_text):
                    is_explicit_next = bool(re.search(rf"\bnext\s+{re.escape(w_name)}\b", lower_text))
                    days_ahead = (w_idx - ref_local.weekday()) % 7
                    if days_ahead == 0:
                        days_ahead = 7
                    elif is_explicit_next and days_ahead < 7:
                        days_ahead += 7
                    target_date = ref_local.date() + datetime.timedelta(days=days_ahead)
                    break

            # Check explicit calendar date e.g. "15th", "15th March", "March 15", "15 April"
            if target_date is None:
                # "March 15" or "15 March"
                for m_name, m_num in MONTH_MAP.items():
                    m_pat = rf"\b(?:{re.escape(m_name)}\s+(\d{{1,2}})(?:st|nd|rd|th)?|(\d{{1,2}})(?:st|nd|rd|th)?\s+{re.escape(m_name)})\b"
                    if match := re.search(m_pat, lower_text):
                        day_val = int(match.group(1) or match.group(2))
                        year_val = ref_local.year
                        try:
                            cand = datetime.date(year_val, m_num, day_val)
                            if cand < ref_local.date():
                                cand = datetime.date(year_val + 1, m_num, day_val)
                            target_date = cand
                        except ValueError:
                            pass
                        break

            # Fallback "15th" (assumes current or next month)
            if target_date is None:
                if match := re.search(r"\b(\d{1,2})(?:st|nd|rd|th)\b", lower_text):
                    day_val = int(match.group(1))
                    if 1 <= day_val <= 31:
                        try:
                            cand = datetime.date(ref_local.year, ref_local.month, day_val)
                            if cand < ref_local.date():
                                # roll to next month
                                m = ref_local.month + 1
                                y = ref_local.year
                                if m > 12:
                                    m = 1
                                    y += 1
                                cand = datetime.date(y, m, day_val)
                            target_date = cand
                        except ValueError:
                            pass

    # ── 4. Deterministic Time Extraction from text ──
    if target_hour is None:
        # Check standard 12h / 24h patterns e.g. "3pm", "3:30 pm", "15:00", "at 4", "10 am"
        # 3:30 pm / 3:30pm
        if match := re.search(r"\b(\d{1,2}):(\d{2})\s*(am|pm)\b", lower_text):
            h = int(match.group(1))
            m = int(match.group(2))
            meridiem = match.group(3)
            if meridiem == "pm" and h < 12:
                h += 12
            elif meridiem == "am" and h == 12:
                h = 0
            target_hour, target_minute = h, m
        # 3pm / 3 pm
        elif match := re.search(r"\b(\d{1,2})\s*(am|pm)\b", lower_text):
            h = int(match.group(1))
            meridiem = match.group(2)
            if meridiem == "pm" and h < 12:
                h += 12
            elif meridiem == "am" and h == 12:
                h = 0
            target_hour, target_minute = h, 0
        # 15:00
        elif match := re.search(r"\b([01]?\d|2[0-3]):([0-5]\d)\b", lower_text):
            target_hour = int(match.group(1))
            target_minute = int(match.group(2))
        # "at 4" / "at 5" (usually afternoon if ambiguous between 1-6, else morning)
        elif match := re.search(r"\bat\s+(\d{1,2})\b", lower_text):
            h = int(match.group(1))
            if 1 <= h <= 6:
                h += 12  # assume 4pm
            target_hour, target_minute = h, 0
        # Broad time-of-day slots
        elif re.search(r"\b(?:morning|subah|sawere|सुबह)\b", lower_text):
            target_hour, target_minute = 10, 0
        elif re.search(r"\b(?:afternoon|dophar|dopahar|दोपहर)\b", lower_text):
            target_hour, target_minute = 14, 0
        elif re.search(r"\b(?:evening|shaam|शाम)\b", lower_text):
            target_hour, target_minute = 17, 0
        elif re.search(r"\b(?:night|raat|रात)\b", lower_text):
            target_hour, target_minute = 20, 0
        else:
            # Default time: 10:00 AM
            target_hour, target_minute = 10, 0
            time_assumed = True

    if target_minute is None:
        target_minute = 0

    # ── 5. Unresolved Date Handling ──
    if target_date is None:
        return DateResolutionResult(
            success=False,
            dt_local=None,
            dt_utc=None,
            time_assumed=time_assumed,
            needs_date=True,
            date_str=None,
            time_str=f"{target_hour:02d}:{target_minute:02d}",
        )

    # Combine date and time
    resolved_dt = datetime.datetime(
        target_date.year,
        target_date.month,
        target_date.day,
        target_hour,
        target_minute,
        0,
        tzinfo=tz,
    )

    # ── 6. Never Produce a Time in the Past ──
    if resolved_dt <= ref_local:
        # If date was today or assumed without day, roll forward to tomorrow or next week
        if target_date == ref_local.date():
            resolved_dt = resolved_dt + datetime.timedelta(days=1)
        else:
            # Roll forward by 7 days if weekday matched in past
            resolved_dt = resolved_dt + datetime.timedelta(days=7)

    # Compute UTC representation
    dt_utc = resolved_dt.astimezone(datetime.timezone.utc)
    # Store UTC naive or formatted
    dt_utc_naive = dt_utc.replace(tzinfo=None)

    date_str = resolved_dt.strftime("%Y-%m-%d")
    time_str = resolved_dt.strftime("%H:%M")

    return DateResolutionResult(
        success=True,
        dt_local=resolved_dt,
        dt_utc=dt_utc_naive,
        time_assumed=time_assumed,
        needs_date=False,
        date_str=date_str,
        time_str=time_str,
    )
