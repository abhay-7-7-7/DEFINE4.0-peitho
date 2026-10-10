/**
 * CallSummaryReminders.jsx
 * End-of-call summary section listing all reminders captured during the completed session.
 */
import React, { useState } from 'react';
import { Calendar, Plus, Check, Edit2, Trash2, Mail, ExternalLink } from 'lucide-react';
import { Link } from 'react-router-dom';
import ReminderDrawer from './ReminderDrawer';

export default function CallSummaryReminders({
  reminders = [],
  callId,
  onUpdate,
  onDelete,
  onCreate,
  onSendTest,
  timezone = 'Asia/Kolkata',
  t = (key) => key,
}) {
  const [editingReminder, setEditingReminder] = useState(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  const callReminders = reminders.filter((r) => !callId || r.call_id === callId);

  const formatTime = (iso) => {
    if (!iso) return 'Pending Date';
    try {
      const d = new Date(iso);
      return d.toLocaleDateString(undefined, {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return iso;
    }
  };

  const handleSave = async (payload, id) => {
    if (id) {
      await onUpdate(id, payload);
    } else {
      await onCreate({ ...payload, call_id: callId });
    }
  };

  return (
    <div className="neo-card p-5 bg-white space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-2 border-b-2 border-neo-navy pb-3">
        <div className="flex items-center gap-2">
          <Calendar className="w-5 h-5 text-neo-teal" />
          <h3 className="font-heading font-black text-base uppercase text-neo-navy">
            Commitments & Follow-Ups ({callReminders.length})
          </h3>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              setEditingReminder(null);
              setIsDrawerOpen(true);
            }}
            className="px-2.5 py-1 bg-neo-teal text-neo-cream border-2 border-neo-navy text-xs font-heading font-bold uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1"
          >
            <Plus className="w-3.5 h-3.5" />
            Add Reminder
          </button>
          <Link
            to="/peitho/reminders"
            className="px-2.5 py-1 bg-neo-cream text-neo-navy border-2 border-neo-navy text-xs font-heading font-bold uppercase hover:bg-white flex items-center gap-1"
          >
            Open Calendar <ExternalLink className="w-3 h-3" />
          </Link>
        </div>
      </div>

      {callReminders.length === 0 ? (
        <p className="text-xs text-neo-navy/60 italic py-2">
          No action items or commitments were recorded during this call.
        </p>
      ) : (
        <div className="divide-y-2 divide-neo-navy/15">
          {callReminders.map((r) => (
            <div key={r.id} className="py-2.5 flex items-center justify-between gap-3">
              <div>
                <span className={`text-[10px] font-heading font-bold uppercase px-1.5 py-0.5 border border-neo-navy mr-2 ${
                  r.owner === 'buyer' ? 'bg-neo-teal/20 text-neo-teal' : 'bg-neo-orange/20 text-neo-navy'
                }`}>
                  {r.owner === 'buyer' ? 'Buyer Action' : 'Seller Action'}
                </span>
                <span className="font-heading font-black text-sm text-neo-navy">
                  {r.title}
                </span>
                <div className="text-[11px] font-mono text-neo-navy/60 mt-0.5">
                  Due: {formatTime(r.due_at)} • Status: {r.status}
                </div>
              </div>

              <div className="flex items-center gap-1.5">
                <button
                  onClick={() => {
                    setEditingReminder(r);
                    setIsDrawerOpen(true);
                  }}
                  className="p-1.5 border border-neo-navy hover:bg-neo-cream text-neo-navy rounded"
                  title="Edit"
                >
                  <Edit2 className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={() => onUpdate(r.id, { status: r.status === 'done' ? 'active' : 'done' })}
                  className={`p-1.5 border border-neo-navy rounded ${
                    r.status === 'done' ? 'bg-emerald-200 text-emerald-900' : 'hover:bg-neo-cream'
                  }`}
                  title={r.status === 'done' ? 'Mark Active' : 'Mark Done'}
                >
                  <Check className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={() => onDelete(r.id)}
                  className="p-1.5 border border-neo-navy hover:bg-rose-100 text-rose-700 rounded"
                  title="Delete"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Reminder Drawer */}
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
