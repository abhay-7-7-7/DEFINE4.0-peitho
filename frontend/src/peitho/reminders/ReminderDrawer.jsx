/**
 * ReminderDrawer.jsx
 * Non-blocking slide-out editor and creator for reminders.
 * Can be used mid-call or inside the calendar view without disrupting workflow.
 */
import React, { useState, useEffect } from 'react';
import { X, Calendar, Clock, Bell, User, Check, Trash2, Send, AlertTriangle } from 'lucide-react';

export default function ReminderDrawer({
  isOpen,
  onClose,
  initialData = null,
  onSave,
  onDelete,
  onSendTest,
  timezone = 'Asia/Kolkata',
  t = (key) => key,
}) {
  const [title, setTitle] = useState('');
  const [date, setDate] = useState('');
  const [time, setTime] = useState('10:00');
  const [allDay, setAllDay] = useState(false);
  const [leadMinutes, setLeadMinutes] = useState(30);
  const [owner, setOwner] = useState('seller');
  const [status, setStatus] = useState('active');
  const [note, setNote] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [testSent, setTestSent] = useState(false);
  const [testError, setTestError] = useState(null);

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || '');
      setNote(initialData.note || '');
      setAllDay(Boolean(initialData.all_day));
      setLeadMinutes(initialData.lead_minutes !== undefined ? initialData.lead_minutes : 30);
      setOwner(initialData.owner || 'seller');
      setStatus(initialData.status || 'active');

      if (initialData.due_at) {
        const d = new Date(initialData.due_at);
        if (!isNaN(d.getTime())) {
          // Format local date YYYY-MM-DD
          const year = d.getFullYear();
          const month = String(d.getMonth() + 1).padStart(2, '0');
          const day = String(d.getDate()).padStart(2, '0');
          setDate(`${year}-${month}-${day}`);

          const hours = String(d.getHours()).padStart(2, '0');
          const mins = String(d.getMinutes()).padStart(2, '0');
          setTime(`${hours}:${mins}`);
        }
      }
    } else {
      // Default to tomorrow 10:00 AM
      const tmrw = new Date();
      tmrw.setDate(tmrw.getDate() + 1);
      const year = tmrw.getFullYear();
      const month = String(tmrw.getMonth() + 1).padStart(2, '0');
      const day = String(tmrw.getDate()).padStart(2, '0');
      setDate(`${year}-${month}-${day}`);
      setTime('10:00');
      setTitle('');
      setNote('');
      setAllDay(false);
      setLeadMinutes(30);
      setOwner('seller');
      setStatus('active');
    }
    setTestSent(false);
    setTestError(null);
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!title.trim() || !date) return;

    setIsSubmitting(true);
    try {
      // Construct ISO timestamp from date + time
      const [year, month, day] = date.split('-').map(Number);
      const [hours, mins] = allDay ? [10, 0] : time.split(':').map(Number);
      const localDateObj = new Date(year, month - 1, day, hours, mins, 0);

      const payload = {
        title: title.trim(),
        note: note.trim() || null,
        due_at: localDateObj.toISOString(),
        all_day: allDay,
        timezone: timezone,
        lead_minutes: Number(leadMinutes),
        owner: owner,
        status: status,
      };

      await onSave(payload, initialData?.id);
      onClose();
    } catch (err) {
      alert(err.message || 'Failed to save reminder');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleTestEmail = async () => {
    if (!initialData?.id || !onSendTest) return;
    setTestSent(false);
    setTestError(null);
    try {
      await onSendTest(initialData.id);
      setTestSent(true);
      setTimeout(() => setTestSent(false), 4000);
    } catch (err) {
      setTestError(err.message || 'Failed to send test email');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-neo-navy/40 backdrop-blur-xs animate-fade-in">
      <div 
        className="w-full max-w-md bg-neo-cream border-l-[4px] border-neo-navy h-full shadow-[-6px_0px_0px_#001524] flex flex-col justify-between overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 border-b-[3px] border-neo-navy flex items-center justify-between bg-white">
          <div>
            <h3 className="font-heading font-black text-lg sm:text-xl text-neo-navy uppercase tracking-tight">
              {initialData?.id ? 'Edit Reminder' : 'Add New Reminder'}
            </h3>
            <span className="text-[11px] font-mono text-neo-navy/60">
              Timezone: {timezone}
            </span>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 border-2 border-neo-navy hover:bg-neo-orange/20 rounded transition-all"
          >
            <X className="w-5 h-5 text-neo-navy" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-4 sm:p-6 space-y-4 flex-1">
          {/* Title */}
          <div>
            <label className="block text-xs font-heading font-bold uppercase mb-1">
              Title / Action Required *
            </label>
            <input
              type="text"
              required
              maxLength={200}
              placeholder="e.g. Send updated pricing proposal"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden"
            />
          </div>

          {/* Date & Time */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-heading font-bold uppercase mb-1 flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5" /> Date *
              </label>
              <input
                type="date"
                required
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-heading font-bold uppercase mb-1 flex items-center gap-1">
                <Clock className="w-3.5 h-3.5" /> Time
              </label>
              <input
                type="time"
                disabled={allDay}
                value={time}
                onChange={(e) => setTime(e.target.value)}
                className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden disabled:bg-neo-cream/50"
              />
            </div>
          </div>

          {/* All Day Toggle */}
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="allDayCheckbox"
              checked={allDay}
              onChange={(e) => setAllDay(e.target.checked)}
              className="w-4 h-4 border-2 border-neo-navy text-neo-orange"
            />
            <label htmlFor="allDayCheckbox" className="text-xs font-heading font-bold uppercase cursor-pointer">
              All-Day Event (Default 10:00 AM)
            </label>
          </div>

          {/* Lead Time & Owner */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-heading font-bold uppercase mb-1 flex items-center gap-1">
                <Bell className="w-3.5 h-3.5" /> Notification Lead
              </label>
              <select
                value={leadMinutes}
                onChange={(e) => setLeadMinutes(Number(e.target.value))}
                className="w-full px-2 py-2 border-2 border-neo-navy bg-white font-medium text-xs focus:outline-hidden"
              >
                <option value={0}>At exact time (0m)</option>
                <option value={15}>15 minutes before</option>
                <option value={30}>30 minutes before</option>
                <option value={60}>1 hour before</option>
                <option value={1440}>1 day before</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-heading font-bold uppercase mb-1 flex items-center gap-1">
                <User className="w-3.5 h-3.5" /> Responsibility
              </label>
              <select
                value={owner}
                onChange={(e) => setOwner(e.target.value)}
                className="w-full px-2 py-2 border-2 border-neo-navy bg-white font-medium text-xs focus:outline-hidden"
              >
                <option value="seller">Seller (My Action)</option>
                <option value="buyer">Buyer Action</option>
                <option value="both">Mutual Commitment</option>
              </select>
            </div>
          </div>

          {/* Status (if editing) */}
          {initialData?.id && (
            <div>
              <label className="block text-xs font-heading font-bold uppercase mb-1">
                Status
              </label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="w-full px-2 py-2 border-2 border-neo-navy bg-white font-medium text-xs focus:outline-hidden"
              >
                <option value="active">Active (Pending)</option>
                <option value="done">Completed (Done)</option>
                <option value="cancelled">Cancelled</option>
                <option value="missed">Missed</option>
              </select>
            </div>
          )}

          {/* Note / Context */}
          <div>
            <label className="block text-xs font-heading font-bold uppercase mb-1">
              Additional Notes / Commitment Context
            </label>
            <textarea
              rows={3}
              placeholder="e.g. Buyer requested palletized shipping discount included"
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden"
            />
          </div>

          {/* Test Email Button for Demo */}
          {initialData?.id && onSendTest && (
            <div className="pt-2 border-t-2 border-neo-navy/20">
              <button
                type="button"
                onClick={handleTestEmail}
                className="w-full py-2 bg-neo-teal text-neo-cream font-heading font-bold text-xs uppercase border-2 border-neo-navy shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center justify-center gap-1.5 transition-all"
              >
                <Send className="w-3.5 h-3.5" />
                Send Test Email Now (Demo)
              </button>
              {testSent && (
                <div className="mt-1.5 p-1.5 bg-emerald-100 border border-emerald-800 text-emerald-900 text-xs font-bold flex items-center gap-1">
                  <Check className="w-3.5 h-3.5" /> Reminder email sent via your SMTP!
                </div>
              )}
              {testError && (
                <div className="mt-1.5 p-1.5 bg-rose-100 border border-rose-800 text-rose-900 text-xs font-bold flex items-center gap-1">
                  <AlertTriangle className="w-3.5 h-3.5" /> {testError}
                </div>
              )}
            </div>
          )}
        </form>

        {/* Footer Actions */}
        <div className="p-4 sm:p-5 border-t-[3px] border-neo-navy bg-white flex items-center justify-between gap-3">
          {initialData?.id && onDelete ? (
            <button
              type="button"
              onClick={() => {
                if (window.confirm('Delete this reminder?')) {
                  onDelete(initialData.id);
                  onClose();
                }
              }}
              className="px-3 py-2 bg-rose-50 text-rose-700 hover:bg-rose-100 border-2 border-neo-navy font-heading font-bold text-xs uppercase flex items-center gap-1"
            >
              <Trash2 className="w-3.5 h-3.5" /> Delete
            </button>
          ) : (
            <div />
          )}

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 border-2 border-neo-navy font-heading font-bold text-xs uppercase hover:bg-neo-cream"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleSubmit}
              disabled={isSubmitting || !title.trim()}
              className="px-5 py-2 bg-neo-orange border-2 border-neo-navy font-heading font-black text-xs uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : 'Save Reminder'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
