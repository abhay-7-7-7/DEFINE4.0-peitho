"""
Pydantic schemas for Peitho Reminders API and WebSocket messages.
"""
from __future__ import annotations

import datetime
from typing import Optional, Literal
from pydantic import BaseModel, Field, field_validator


class ReminderCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    note: Optional[str] = None
    due_at: datetime.datetime
    all_day: bool = False
    timezone: str = "Asia/Kolkata"
    lead_minutes: int = Field(default=30, ge=0, le=10080)  # max 7 days
    owner: Literal["seller", "buyer", "both"] = "seller"
    source: Literal["detected", "manual"] = "manual"
    status: Literal["active", "done", "cancelled"] = "active"
    confidence: Optional[Literal["low", "medium", "high"]] = None
    call_id: Optional[str] = None


class ReminderUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    note: Optional[str] = None
    due_at: Optional[datetime.datetime] = None
    all_day: Optional[bool] = None
    timezone: Optional[str] = None
    lead_minutes: Optional[int] = Field(default=None, ge=0, le=10080)
    owner: Optional[Literal["seller", "buyer", "both"]] = None
    status: Optional[Literal["active", "done", "cancelled", "missed"]] = None
    confidence: Optional[Literal["low", "medium", "high"]] = None


class ReminderResponse(BaseModel):
    id: int
    user_id: int
    call_id: Optional[str] = None
    title: str
    note: Optional[str] = None
    due_at: datetime.datetime
    all_day: bool
    timezone: str
    lead_minutes: int
    owner: str
    source: str
    status: str
    confidence: Optional[str] = None
    notified_at: Optional[datetime.datetime] = None
    notify_attempts: int = 0
    created_at: Optional[datetime.datetime] = None
    updated_at: Optional[datetime.datetime] = None


class ReminderPrefsUpdate(BaseModel):
    timezone: Optional[str] = "Asia/Kolkata"
    default_lead_minutes: Optional[int] = Field(default=30, ge=0, le=10080)
    email_enabled: Optional[bool] = True
    call_summary_email_enabled: Optional[bool] = True


class ReminderPrefsResponse(BaseModel):
    user_id: int
    timezone: str
    default_lead_minutes: int
    email_enabled: bool
    call_summary_email_enabled: bool


class DetectedReminderPayload(BaseModel):
    """Shape emitted over WebSocket when reminder detected."""
    id: int
    title: str
    note: Optional[str] = None
    due_at: str
    all_day: bool
    owner: str
    confidence: Optional[str]
    source: str
    needs_review: bool
    time_assumed: bool
