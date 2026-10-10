/**
 * RemindersCallStrip.jsx
 * Live, compact Reminders component inside PeithoPage during a live sales call.
 * Displays detected and manual reminders with inline controls without interrupting the seller.
 */
import React, { useState } from 'react';
import { Calendar, Clock, Plus, Check, Clock3, Edit2, Trash2, AlertCircle, Info, ShieldAlert } from 'lucide-react';
import ReminderDrawer from './ReminderDrawer';

export default function RemindersCallStrip({
  reminders = [],
  highlightedId = null,
  onUpdate,
  onDelete,
  onSnooze,
  onMarkDone,
  onCreate,
  onSendTest,
  timezone = 'Asia/Kolkata',
  t = (key) => key,
}) {
  const [editingReminder, setEditingReminder] = useState(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  const activeReminders = reminders.filter((r) => r.status === 'active');

  const formatTimeDisplay = (dueStr) => {
    if (!dueStr) return 'Pending Date';
    try {
      const d = new Date(dueStr);
      if (isNaN(d.getTime())) return dueStr;
      return d.toLocaleDateString(undefined, {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return dueStr;
    }
  };

  const handleOpenEdit = (reminder) => {
    setEditingReminder(reminder);
    setIsDrawerOpen(true);
  };

  const handleOpenNew = () => {
    setEditingReminder(null);
    setIsDrawerOpen(true);
  };

  const handleSave = async (payload, id) => {
    if (id) {
      await onUpdate(id, payload);
    } else {
      await onCreate(payload);
    }
  };

  return (
    <div className="neo-card p-3 sm:p-4 bg-white flex flex-col gap-3">
      {/* Section Header */}
      <div className="flex items-center justify-between pb-2 border-b-2 border-neo-navy">
        <div className="flex items-center gap-2">
          <Calendar className="w-4 h-4 text-neo-orange" />
          <span className="font-heading font-black text-xs uppercase tracking-wider text-neo-navy">
            Live Call Reminders & Commitments
          </span>
          <span className="px-1.5 py-0.2 bg-neo-cream border border-neo-navy text-[10px] font-mono font-bold">
            {activeReminders.length}
          </span>
        </div>

        <button
          onClick={handleOpenNew}
          className="px-2 py-1 bg-neo-teal text-neo-cream border-2 border-neo-navy text-[11px] font-heading font-bold uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1 transition-all"
        >
          <Plus className="w-3 h-3" />
          Add Reminder
        </button>
      </div>

      {/* Reminder Cards Feed */}
      {activeReminders.length === 0 ? (
        <div className="p-4 bg-neo-cream/50 border border-dashed border-neo-navy/40 rounded text-center">
          <Clock className="w-6 h-6 text-neo-navy/40 mx-auto mb-1.5" />
          <p className="text-xs font-heading font-bold text-neo-navy/80">
            No commitments detected yet
          </p>
          <p className="text-[11px] text-neo-navy/60 max-w-xs mx-auto mt-0.5">
            Spoken promises like <em>"I'll send the quote tomorrow at 4pm"</em> or <em>"let's talk Friday"</em> appear here automatically.
          </p>
        </div>
      ) : (
        <div className="space-y-2.5 max-h-[300px] overflow-y-auto pr-1">
          {activeReminders.map((rem) => {
            const isHighlighted = rem.id === highlightedId;
            const ownerBadge = rem.owner === 'buyer' ? 'Buyer Action' : (rem.owner === 'both' ? 'Mutual' : 'My Action');
            const ownerColor = rem.owner === 'buyer' ? 'bg-neo-teal/20 text-neo-teal' : 'bg-neo-orange/20 text-neo-navy';

            return (
              <div
                key={rem.id}
                className={`p-3 border-2 border-neo-navy bg-neo-cream/40 rounded transition-all flex flex-col gap-2 ${
                  isHighlighted ? 'ring-2 ring-neo-orange bg-amber-50 shadow-[3px_3px_0px_#FF7D00] animate-pulse' : 'shadow-[2px_2px_0px_#001524]'
                }`}
              >
                {/* Top Row: Title & Badges */}
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1">
                    <div className="flex flex-wrap items-center gap-1.5 mb-1">
                      <span className={`px-1.5 py-0.5 border border-neo-navy text-[9px] font-heading font-black uppercase ${ownerColor}`}>
                        {ownerBadge}
                      </span>
                      {rem.needs_review && (
                        <span className="px-1.5 py-0.5 bg-amber-100 border border-amber-800 text-amber-900 text-[9px] font-bold uppercase flex items-center gap-0.5">
                          <AlertCircle className="w-2.5 h-2.5" /> Needs Review
                        </span>
                      )}
                      {rem.time_assumed && (
                        <span className="px-1.5 py-0.5 bg-blue-50 border border-blue-700 text-blue-900 text-[9px] font-bold uppercase">
                          Time Assumed (10 AM)
                        </span>
                      )}
                    </div>
                    <h4 className="font-heading font-black text-xs text-neo-navy leading-snug">
                      {rem.title}
                    </h4>
                  </div>

                  <span className="text-[10px] font-mono font-bold text-neo-navy/70 whitespace-nowrap bg-white px-2 py-0.5 border border-neo-navy">
                    {formatTimeDisplay(rem.due_at)}
                  </span>
                </div>

                {/* Note (if any) */}
                {rem.note && (
                  <p className="text-[11px] text-neo-navy/70 italic bg-white/70 p-1.5 border border-neo-navy/20 rounded-xs">
                    {rem.note}
                  </p>
                )}

                {/* Inline Action Bar */}
                <div className="flex items-center justify-between pt-1 border-t border-neo-navy/20 text-[10px] font-heading font-bold">
                  {/* Quick Snooze */}
                  <div className="flex items-center gap-1">
                    <span className="text-neo-navy/50 uppercase text-[9px]">Snooze:</span>
                    <button
                      onClick={() => onSnooze(rem.id, 1)}
                      className="px-1.5 py-0.5 bg-white hover:bg-neo-cream border border-neo-navy rounded-xs text-[10px]"
                      title="Postpone by 1 hour"
                    >
                      +1h
                    </button>
                    <button
                      onClick={() => onSnooze(rem.id, 24)}
                      className="px-1.5 py-0.5 bg-white hover:bg-neo-cream border border-neo-navy rounded-xs text-[10px]"
                      title="Postpone by 24 hours"
                    >
                      +1d
                    </button>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => handleOpenEdit(rem)}
                      className="p-1 text-neo-navy hover:bg-white border border-transparent hover:border-neo-navy rounded-xs"
                      title="Edit reminder"
                    >
                      <Edit2 className="w-3 h-3" />
                    </button>
                    <button
                      onClick={() => onMarkDone(rem.id)}
                      className="p-1 text-emerald-800 hover:bg-emerald-100 border border-emerald-800 rounded-xs flex items-center gap-0.5"
                      title="Mark as completed"
                    >
                      <Check className="w-3 h-3" />
                      <span className="text-[9px]">Done</span>
                    </button>
                    <button
                      onClick={() => {
                        if (window.confirm('Delete reminder?')) onDelete(rem.id);
                      }}
                      className="p-1 text-rose-800 hover:bg-rose-100 border border-rose-800 rounded-xs"
                      title="Delete reminder"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Editor Drawer */}
      <ReminderDrawer
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        initialData={editingReminder}
        onSave={handleSave}
        onDelete={onDelete}
        onSendTest={onSendTest}
        timezone={timezone}
        t={t}
      />
    </div>
  );
}
