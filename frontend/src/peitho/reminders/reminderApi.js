/**
 * Peitho Reminders REST API Client
 */
import { getAuthToken } from '../../lib/api';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:8000';

function getHeaders() {
  const token = getAuthToken();
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}

export async function fetchReminders(params = {}) {
  const url = new URL(`${API_BASE}/api/v1/peitho/reminders`);
  if (params.from) url.searchParams.set('from', params.from);
  if (params.to) url.searchParams.set('to', params.to);
  if (params.status) url.searchParams.set('status', params.status);
  if (params.call_id) url.searchParams.set('call_id', params.call_id);

  const res = await fetch(url.toString(), {
    headers: getHeaders(),
  });
  if (!res.ok) {
    if (res.status === 401) {
      throw new Error('Authentication required: please log in at /login.');
    }
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to fetch reminders');
  }
  return res.json();
}

export async function createReminder(data) {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders`, {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(data),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to create reminder');
  }
  return res.json();
}

export async function updateReminder(id, updates) {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders/${id}`, {
    method: 'PATCH',
    headers: getHeaders(),
    body: JSON.stringify(updates),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to update reminder');
  }
  return res.json();
}

export async function deleteReminder(id) {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders/${id}`, {
    method: 'DELETE',
    headers: getHeaders(),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to delete reminder');
  }
  return res.json();
}

export async function sendTestReminder(id) {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders/${id}/send-test`, {
    method: 'POST',
    headers: getHeaders(),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to send test email');
  }
  return res.json();
}

export async function fetchReminderPrefs() {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders/prefs`, {
    headers: getHeaders(),
  });
  if (!res.ok) {
    return {
      timezone: 'Asia/Kolkata',
      default_lead_minutes: 30,
      email_enabled: true,
      call_summary_email_enabled: true,
    };
  }
  return res.json();
}

export async function updateReminderPrefs(prefs) {
  const res = await fetch(`${API_BASE}/api/v1/peitho/reminders/prefs`, {
    method: 'PUT',
    headers: getHeaders(),
    body: JSON.stringify(prefs),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || 'Failed to update reminder preferences');
  }
  return res.json();
}

export async function checkEmailSettingsConfigured() {
  try {
    const res = await fetch(`${API_BASE}/api/v1/email/settings`, {
      headers: getHeaders(),
    });
    if (!res.ok) return false;
    const data = await res.json();
    return Boolean(data && data.smtp_user && data.smtp_password);
  } catch {
    return false;
  }
}
