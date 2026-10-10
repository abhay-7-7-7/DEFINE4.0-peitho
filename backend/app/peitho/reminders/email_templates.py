"""
Email templates for Peitho Reminders and Call Summaries.
Built in the same Neubrutalist plain string style as email_service.py.
"""
from __future__ import annotations

import urllib.parse
import datetime
from typing import List, Dict, Optional, Tuple


def _build_google_cal_link(
    title: str,
    dt_utc: datetime.datetime,
    duration_minutes: int = 30,
    details: str = "",
) -> str:
    """Builds standard Google Calendar render template URL."""
    start_str = dt_utc.strftime("%Y%m%dT%H%M%SZ")
    end_dt = dt_utc + datetime.timedelta(minutes=duration_minutes)
    end_str = end_dt.strftime("%Y%m%dT%H%M%SZ")

    params = {
        "action": "TEMPLATE",
        "text": title,
        "dates": f"{start_str}/{end_str}",
        "details": details or f"Peitho Sales Reminder: {title}",
    }
    return f"https://calendar.google.com/calendar/render?{urllib.parse.urlencode(params)}"


_BASE_STYLE = """
<style>
  body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; background: #f5f5f5; }
  .container { max-width: 600px; margin: 20px auto; background: #fff; border: 3px solid #001524; }
  .header { background: #001524; color: #FFECD1; padding: 24px 32px; border-bottom: 3px solid #001524; }
  .header h1 { margin: 0; font-size: 22px; letter-spacing: 1px; }
  .header .accent { color: #FF7D00; }
  .body { padding: 32px; color: #001524; line-height: 1.6; }
  .stat-row { display: flex; gap: 16px; margin: 16px 0; }
  .stat-box { flex: 1; background: #FFECD1; border: 2px solid #001524; padding: 12px 16px; text-align: center; }
  .stat-box .label { font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: #555; }
  .stat-box .value { font-size: 20px; font-weight: 700; color: #001524; }
  .btn { display: inline-block; background: #FF7D00; color: #001524; padding: 12px 24px; text-decoration: none; font-weight: 700; border: 2px solid #001524; margin-top: 16px; font-size: 14px; text-transform: uppercase; }
  .btn-cal { background: #15616D; color: #fff; }
  .chip { display: inline-block; padding: 4px 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; border: 1px solid #001524; background: #FFECD1; margin-bottom: 12px; }
  .footer { background: #f9f9f9; border-top: 2px solid #001524; padding: 16px 32px; font-size: 12px; color: #888; text-align: center; }
  .teal { color: #15616D; font-weight: 700; }
  .orange { color: #FF7D00; font-weight: 700; }
</style>
"""


def template_reminder_notification(
    title: str,
    dt_local: datetime.datetime,
    timezone_name: str,
    note: Optional[str] = None,
    product_name: Optional[str] = None,
    owner: str = "seller",
    dt_utc: Optional[datetime.datetime] = None,
) -> Tuple[str, str]:
    """
    Build HTML email for a single firing reminder.
    Returns (subject, html_body).
    """
    formatted_date = dt_local.strftime("%A, %d %B %Y")
    formatted_time = dt_local.strftime("%I:%M %p")
    time_display = f"{formatted_time} ({timezone_name})"

    subject = f"Reminder: {title} at {formatted_time}"

    # UTC for google calendar
    cal_utc = dt_utc if dt_utc is not None else dt_local.astimezone(datetime.timezone.utc)
    gcal_url = _build_google_cal_link(title, cal_utc, details=note or "")

    product_html = ""
    if product_name:
        product_html = f"<p><strong>Associated Product / Call:</strong> <span class='teal'>{product_name}</span></p>"

    note_html = ""
    if note:
        note_html = f"<div style='background:#f9f9f9; border-left: 4px solid #15616D; padding: 10px 14px; margin: 16px 0; font-style: italic;'>{note}</div>"

    owner_label = "Seller Action" if owner == "seller" else ("Buyer Action" if owner == "buyer" else "Mutual Commitment")

    html = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>{subject}</title>
  {_BASE_STYLE}
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>PEI<span class="accent">THO</span> LIVE REMINDERS</h1>
    </div>
    <div class="body">
      <span class="chip">{owner_label}</span>
      <h2 style="margin-top:0; font-size: 20px; color:#001524;">{title}</h2>

      <div class="stat-row">
        <div class="stat-box">
          <div class="label">Due Date</div>
          <div class="value">{formatted_date}</div>
        </div>
        <div class="stat-box">
          <div class="label">Time</div>
          <div class="value">{time_display}</div>
        </div>
      </div>

      {product_html}
      {note_html}

      <div style="margin-top: 24px;">
        <a href="{gcal_url}" class="btn btn-cal" target="_blank">📅 Add to Google Calendar</a>
      </div>
    </div>
    <div class="footer">
      <p>Peitho Autonomous Negotiation Engine • Deterministic Profit & Schedule Protection</p>
    </div>
  </div>
</body>
</html>
"""
    return subject, html


def template_call_summary_reminders(
    product_name: str,
    reminders: List[dict],
    timezone_name: str = "Asia/Kolkata",
) -> Tuple[str, str]:
    """
    Build HTML email summarizing reminders detected during a finished call.
    Returns (subject, html_body).
    """
    subject = f"Peitho Call Summary: {len(reminders)} Reminder(s) Detected for {product_name}"

    items_html = ""
    for r in reminders:
        r_title = r.get("title", "Follow up")
        r_due = r.get("due_at")
        if isinstance(r_due, datetime.datetime):
            due_str = r_due.strftime("%d %b %Y, %I:%M %p")
        else:
            due_str = str(r_due)
        r_owner = (r.get("owner") or "seller").capitalize()
        items_html += f"""
        <li style="margin-bottom: 12px; padding-bottom: 8px; border-bottom: 1px solid #ddd;">
          <strong style="color:#001524;">{r_title}</strong><br>
          <span style="font-size:12px; color:#555;">Due: {due_str} ({timezone_name}) • Owner: {r_owner}</span>
        </li>
        """

    html = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>{subject}</title>
  {_BASE_STYLE}
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>PEI<span class="accent">THO</span> CALL SUMMARY</h1>
    </div>
    <div class="body">
      <h2 style="margin-top:0; font-size: 18px;">Meeting Follow-Ups & Commitments</h2>
      <p>The following action items were detected during your live call for <strong>{product_name}</strong>:</p>

      <ul style="padding-left: 20px; line-height: 1.6;">
        {items_html}
      </ul>

      <div style="margin-top: 24px;">
        <p style="font-size: 13px; color: #555;">Review and manage all reminders in your Peitho Calendar.</p>
      </div>
    </div>
    <div class="footer">
      <p>Peitho Autonomous Negotiation Engine</p>
    </div>
  </div>
</body>
</html>
"""
    return subject, html
