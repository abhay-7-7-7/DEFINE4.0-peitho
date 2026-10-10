/**
 * useReminders hook.
 * Manages reminders state, optimistic updates with rollback,
 * merging of live WebSocket events (reminder_detected, reminder_updated, reminder_deleted),
 * window focus refresh (no polling), and user timezone conversions.
 */
import { useState, useEffect, useCallback, useRef } from 'react';
import {
  fetchReminders,
  createReminder as apiCreate,
  updateReminder as apiUpdate,
  deleteReminder as apiDelete,
  sendTestReminder as apiSendTest,
  fetchReminderPrefs,
  updateReminderPrefs as apiUpdatePrefs,
  checkEmailSettingsConfigured,
} from './reminderApi';

export function useReminders(filterParams = {}) {
  const [reminders, setReminders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [prefs, setPrefs] = useState({
    timezone: 'Asia/Kolkata',
    default_lead_minutes: 30,
    email_enabled: true,
    call_summary_email_enabled: true,
  });
  const [smtpConfigured, setSmtpConfigured] = useState(true);
  const [highlightedId, setHighlightedId] = useState(null);

  const filterRef = useRef(filterParams);
  filterRef.current = filterParams;

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const [data, userPrefs, smtpOk] = await Promise.all([
        fetchReminders(filterRef.current),
        fetchReminderPrefs(),
        checkEmailSettingsConfigured(),
      ]);
      setReminders(Array.isArray(data) ? data : []);
      if (userPrefs) setPrefs(userPrefs);
      setSmtpConfigured(smtpOk);
    } catch (err) {
      setError(err.message || 'Failed to load reminders');
    } finally {
      setLoading(false);
    }
  }, []);

  // Initial fetch and on-focus refetch (no continuous polling)
  useEffect(() => {
    loadData();

    const onFocus = () => {
      loadData();
    };
    window.addEventListener('focus', onFocus);
    return () => window.removeEventListener('focus', onFocus);
  }, [loadData]);

  // Handle incoming WebSocket messages
  const handleWsEvent = useCallback((event) => {
    if (!event || !event.type) return;

    if (event.type === 'reminder_detected') {
      const r = event.reminder;
      if (!r || !r.id) return;

      setReminders((prev) => {
        const existingIdx = prev.findIndex((item) => item.id === r.id);
        if (existingIdx >= 0) {
          const next = [...prev];
          next[existingIdx] = { ...next[existingIdx], ...r };
          return next;
        }
        return [r, ...prev];
      });

      // Brief highlight without stealing focus
      setHighlightedId(r.id);
      setTimeout(() => {
        setHighlightedId((curr) => (curr === r.id ? null : curr));
      }, 3500);
    } else if (event.type === 'reminder_updated') {
      const r = event.reminder;
      if (!r || !r.id) return;
      setReminders((prev) =>
        prev.map((item) => (item.id === r.id ? { ...item, ...r } : item))
      );
    } else if (event.type === 'reminder_deleted') {
      const delId = event.id;
      if (!delId) return;
      setReminders((prev) => prev.filter((item) => item.id !== delId));
    }
  }, []);

  // Optimistic Create with rollback
  const create = useCallback(async (newReminderData) => {
    const tempId = -Date.now();
    const optimisticItem = {
      id: tempId,
      ...newReminderData,
      status: newReminderData.status || 'active',
      source: newReminderData.source || 'manual',
      created_at: new Date().toISOString(),
    };

    setReminders((prev) => [optimisticItem, ...prev]);

    try {
      const serverItem = await apiCreate(newReminderData);
      setReminders((prev) =>
        prev.map((item) => (item.id === tempId ? serverItem : item))
      );
      return serverItem;
    } catch (err) {
      // Rollback
      setReminders((prev) => prev.filter((item) => item.id !== tempId));
      throw err;
    }
  }, []);

  // Optimistic Update with rollback
  const update = useCallback(async (id, updates) => {
    const previous = reminders.find((item) => item.id === id);
    if (!previous) return;

    // Apply optimistic
    setReminders((prev) =>
      prev.map((item) => (item.id === id ? { ...item, ...updates } : item))
    );

    try {
      const updatedServer = await apiUpdate(id, updates);
      setReminders((prev) =>
        prev.map((item) => (item.id === id ? updatedServer : item))
      );
      return updatedServer;
    } catch (err) {
      // Rollback
      setReminders((prev) =>
        prev.map((item) => (item.id === id ? previous : item))
      );
      throw err;
    }
  }, [reminders]);

  // Optimistic Delete with rollback
  const remove = useCallback(async (id) => {
    const previous = reminders.find((item) => item.id === id);
    if (!previous) return;

    setReminders((prev) => prev.filter((item) => item.id !== id));

    try {
      await apiDelete(id);
    } catch (err) {
      // Rollback
      setReminders((prev) => [...prev, previous]);
      throw err;
    }
  }, [reminders]);

  // Quick Snooze helper
  const snooze = useCallback(async (id, hours = 1) => {
    const item = reminders.find((r) => r.id === id);
    if (!item) return;

    const baseDate = new Date(item.due_at || Date.now());
    baseDate.setHours(baseDate.getHours() + hours);

    return update(id, {
      due_at: baseDate.toISOString(),
      status: 'active',
    });
  }, [reminders, update]);

  // Mark done helper
  const markDone = useCallback(async (id) => {
    return update(id, { status: 'done' });
  }, [update]);

  // Send test email
  const sendTest = useCallback(async (id) => {
    return apiSendTest(id);
  }, []);

  // Update preferences
  const savePrefs = useCallback(async (newPrefs) => {
    const updated = await apiUpdatePrefs(newPrefs);
    setPrefs(updated);
    return updated;
  }, []);

  return {
    reminders,
    loading,
    error,
    prefs,
    smtpConfigured,
    highlightedId,
    refresh: loadData,
    create,
    update,
    remove,
    snooze,
    markDone,
    sendTest,
    savePrefs,
    handleWsEvent,
  };
}
