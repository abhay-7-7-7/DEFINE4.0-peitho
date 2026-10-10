/**
 * RemindersCalendarPage.jsx
 * Full Calendar & Agenda page at /peitho/reminders.
 * Built with plain React and Neubrutalist design principles.
 */
import React, { useState, useMemo } from 'react';
import {
  Calendar as CalendarIcon,
  ChevronLeft,
  ChevronRight,
  Plus,
  Filter,
  AlertTriangle,
  Clock,
  CheckCircle2,
  AlertCircle,
  Mail,
  ExternalLink,
} from 'lucide-react';
import { Link } from 'react-router-dom';
import Layout from '../../components/Layout';
import { useReminders } from './useReminders';
import ReminderDrawer from './ReminderDrawer';
import { useI18n } from '../../context/I18nContext';

export default function RemindersCalendarPage() {
  const { t } = useI18n();
  const {
    reminders,
    loading,
    error,
    prefs,
    smtpConfigured,
    create,
    update,
    remove,
    sendTest,
  } = useReminders();

  const [currentDate, setCurrentDate] = useState(new Date());
  const [viewMode, setViewMode] = useState('month'); // 'month' | 'week' | 'agenda'
  const [statusFilter, setStatusFilter] = useState('all');
  const [ownerFilter, setOwnerFilter] = useState('all');

  // Drawer state
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [selectedReminder, setSelectedReminder] = useState(null);
  const [prefilledDate, setPrefilledDate] = useState(null);

  // Drag and drop state
  const [draggedReminderId, setDraggedReminderId] = useState(null);

  // Filtered reminders
  const filteredReminders = useMemo(() => {
    return reminders.filter((r) => {
      if (statusFilter !== 'all' && r.status !== statusFilter) return false;
      if (ownerFilter !== 'all' && r.owner !== ownerFilter) return false;
      return true;
    });
  }, [reminders, statusFilter, ownerFilter]);

  // Missed and Needs Review sets
  const missedReminders = useMemo(() => {
    return reminders.filter((r) => r.status === 'missed');
  }, [reminders]);

  const needsReviewReminders = useMemo(() => {
    return reminders.filter((r) => r.confidence === 'low' || r.needs_review);
  }, [reminders]);

  // Calendar Math
  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();

  const monthName = currentDate.toLocaleString('default', { month: 'long', year: 'numeric' });

  // Navigation handlers
  const handlePrev = () => {
    if (viewMode === 'month') {
      setCurrentDate(new Date(year, month - 1, 1));
    } else if (viewMode === 'week') {
      const d = new Date(currentDate);
      d.setDate(d.getDate() - 7);
      setCurrentDate(d);
    } else {
      const d = new Date(currentDate);
      d.setMonth(d.getMonth() - 1);
      setCurrentDate(d);
    }
  };

  const handleNext = () => {
    if (viewMode === 'month') {
      setCurrentDate(new Date(year, month + 1, 1));
    } else if (viewMode === 'week') {
      const d = new Date(currentDate);
      d.setDate(d.getDate() + 7);
      setCurrentDate(d);
    } else {
      const d = new Date(currentDate);
      d.setMonth(d.getMonth() + 1);
      setCurrentDate(d);
    }
  };

  const handleToday = () => {
    setCurrentDate(new Date());
  };

  // Click on a date cell to add reminder
  const handleDayClick = (dateObj) => {
    const y = dateObj.getFullYear();
    const m = String(dateObj.getMonth() + 1).padStart(2, '0');
    const d = String(dateObj.getDate()).padStart(2, '0');
    setPrefilledDate(`${y}-${m}-${d}`);
    setSelectedReminder(null);
    setIsDrawerOpen(true);
  };

  const handleChipClick = (e, reminder) => {
    e.stopPropagation();
    setSelectedReminder(reminder);
    setPrefilledDate(null);
    setIsDrawerOpen(true);
  };

  // Drag and drop handlers
  const handleDragStart = (e, reminderId) => {
    e.stopPropagation();
    setDraggedReminderId(reminderId);
  };

  const handleDropOnDate = async (e, targetDate) => {
    e.preventDefault();
    if (!draggedReminderId) return;

    const r = reminders.find((item) => item.id === draggedReminderId);
    if (!r) return;

    // Retain original time-of-day, change date
    const origDate = new Date(r.due_at || Date.now());
    const newDate = new Date(targetDate);
    newDate.setHours(origDate.getHours(), origDate.getMinutes(), 0, 0);

    try {
      await update(draggedReminderId, {
        due_at: newDate.toISOString(),
      });
    } catch (err) {
      alert('Failed to reschedule reminder: ' + err.message);
    } finally {
      setDraggedReminderId(null);
    }
  };

  // Month grid generator
  const monthDays = useMemo(() => {
    const firstDayIndex = new Date(year, month, 1).getDay(); // 0 is Sunday
    const totalDays = new Date(year, month + 1, 0).getDate();
    const prevMonthDays = new Date(year, month, 0).getDate();

    const days = [];

    // Leading days from previous month
    for (let i = firstDayIndex - 1; i >= 0; i--) {
      const d = new Date(year, month - 1, prevMonthDays - i);
      days.push({ date: d, isCurrentMonth: false });
    }

    // Days of current month
    for (let i = 1; i <= totalDays; i++) {
      const d = new Date(year, month, i);
      days.push({ date: d, isCurrentMonth: true });
    }

    // Trailing days from next month
    const remaining = (7 - (days.length % 7)) % 7;
    for (let i = 1; i <= remaining; i++) {
      const d = new Date(year, month + 1, i);
      days.push({ date: d, isCurrentMonth: false });
    }

    return days;
  }, [year, month]);

  // Week days generator
  const weekDays = useMemo(() => {
    const start = new Date(currentDate);
    const dayOfWeek = start.getDay();
    start.setDate(start.getDate() - dayOfWeek);

    const days = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(start);
      d.setDate(start.getDate() + i);
      days.push(d);
    }
    return days;
  }, [currentDate]);

  // Reminders for a specific date
  const getRemindersForDate = (dateObj) => {
    const targetY = dateObj.getFullYear();
    const targetM = dateObj.getMonth();
    const targetD = dateObj.getDate();

    return filteredReminders.filter((r) => {
      if (!r.due_at) return false;
      const rDate = new Date(r.due_at);
      return (
        rDate.getFullYear() === targetY &&
        rDate.getMonth() === targetM &&
        rDate.getDate() === targetD
      );
    });
  };

  const getStatusColor = (rem) => {
    if (rem.status === 'done') return 'bg-emerald-100 text-emerald-900 border-emerald-700';
    if (rem.status === 'missed') return 'bg-rose-100 text-rose-900 border-rose-700';
    if (rem.confidence === 'low' || rem.needs_review) return 'bg-amber-100 text-amber-900 border-amber-800';
    if (rem.owner === 'buyer') return 'bg-neo-teal/20 text-neo-teal border-neo-navy';
    return 'bg-neo-orange/20 text-neo-navy border-neo-navy';
  };

  const isToday = (d) => {
    const today = new Date();
    return (
      d.getDate() === today.getDate() &&
      d.getMonth() === today.getMonth() &&
      d.getFullYear() === today.getFullYear()
    );
  };

  return (
    <Layout>
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Header Strip */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="px-2.5 py-0.5 bg-neo-orange text-neo-navy border-2 border-neo-navy font-heading font-black text-xs uppercase shadow-[2px_2px_0px_#001524]">
                Calendar & Tasks
              </span>
              <span className="text-xs font-mono text-neo-navy/60">
                Timezone: {prefs?.timezone || 'Asia/Kolkata'}
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-heading font-black text-neo-navy uppercase tracking-tight">
              Peitho Reminders
            </h1>
          </div>

          {/* Action buttons */}
          <div className="flex flex-wrap items-center gap-2">
            <button
              onClick={() => {
                setSelectedReminder(null);
                setPrefilledDate(null);
                setIsDrawerOpen(true);
              }}
              className="px-4 py-2 bg-neo-orange text-neo-navy font-heading font-black text-xs uppercase border-[3px] border-neo-navy shadow-[3px_3px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1.5 transition-all"
            >
              <Plus className="w-4 h-4" />
              Add Reminder
            </button>
            <Link
              to="/meet-assistant"
              className="px-4 py-2 bg-neo-cream text-neo-navy font-heading font-bold text-xs uppercase border-2 border-neo-navy hover:bg-white shadow-[2px_2px_0px_#001524] flex items-center gap-1 transition-all"
            >
              Launch Meet Copilot
            </Link>
          </div>
        </div>

        {/* Error Banner */}
        {error && (
          <div className="mb-6 p-4 bg-rose-50 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] flex items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
              <div>
                <h4 className="font-heading font-black text-xs uppercase text-rose-900">
                  {error.includes('login') ? 'Authentication Required' : 'Sync Error'}
                </h4>
                <p className="text-xs text-rose-800 mt-0.5">{error}</p>
              </div>
            </div>
            {error.includes('login') && (
              <Link
                to="/login"
                className="px-3 py-1.5 bg-neo-orange text-neo-navy font-heading font-bold text-xs uppercase border-2 border-neo-navy shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] shrink-0"
              >
                Go to Login
              </Link>
            )}
          </div>
        )}

        {/* SMTP Warning Banner if not configured */}
        {!smtpConfigured && (
          <div className="mb-6 p-4 bg-amber-50 border-[3px] border-neo-navy shadow-[4px_4px_0px_#001524] flex items-start justify-between gap-3">
            <div className="flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-neo-orange shrink-0 mt-0.5" />
              <div>
                <h4 className="font-heading font-black text-xs uppercase text-neo-navy">
                  Email Notifications Not Active
                </h4>
                <p className="text-xs text-neo-navy/80 mt-0.5">
                  Your SMTP credentials are not configured. Reminders will be recorded in this calendar, but notification emails cannot be dispatched.
                </p>
              </div>
            </div>
            <Link
              to="/email-settings"
              className="px-3 py-1.5 bg-neo-teal text-neo-cream font-heading font-bold text-xs uppercase border-2 border-neo-navy shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] shrink-0"
            >
              Configure SMTP
            </Link>
          </div>
        )}

        {/* Quick Highlights (Missed or Needs Review) */}
        {(missedReminders.length > 0 || needsReviewReminders.length > 0) && (
          <div className="grid sm:grid-cols-2 gap-4 mb-6">
            {missedReminders.length > 0 && (
              <div className="p-3.5 bg-rose-50 border-2 border-neo-navy shadow-[3px_3px_0px_#001524] flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-rose-700" />
                  <span className="font-heading font-black text-xs uppercase text-rose-900">
                    {missedReminders.length} Missed Reminder(s)
                  </span>
                </div>
                <button
                  onClick={() => setStatusFilter('missed')}
                  className="text-[11px] font-heading font-bold underline hover:text-rose-700"
                >
                  View Missed
                </button>
              </div>
            )}

            {needsReviewReminders.length > 0 && (
              <div className="p-3.5 bg-amber-50 border-2 border-neo-navy shadow-[3px_3px_0px_#001524] flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4 text-amber-800" />
                  <span className="font-heading font-black text-xs uppercase text-amber-950">
                    {needsReviewReminders.length} Unconfirmed AI Detection(s)
                  </span>
                </div>
                <button
                  onClick={() => {
                    const first = needsReviewReminders[0];
                    setSelectedReminder(first);
                    setIsDrawerOpen(true);
                  }}
                  className="text-[11px] font-heading font-bold underline hover:text-amber-800"
                >
                  Review Now
                </button>
              </div>
            )}
          </div>
        )}

        {/* Controls Toolbar: Nav, View Toggle, Filters */}
        <div className="neo-card p-4 bg-white mb-6 flex flex-wrap items-center justify-between gap-4">
          {/* Month / Week Navigation */}
          <div className="flex items-center gap-2">
            <button
              onClick={handlePrev}
              className="p-1.5 border-2 border-neo-navy bg-neo-cream hover:bg-white rounded transition-all"
              title="Previous"
            >
              <ChevronLeft className="w-4 h-4 text-neo-navy" />
            </button>
            <button
              onClick={handleToday}
              className="px-3 py-1 border-2 border-neo-navy bg-neo-cream hover:bg-white font-heading font-bold text-xs uppercase rounded transition-all"
            >
              Today
            </button>
            <button
              onClick={handleNext}
              className="p-1.5 border-2 border-neo-navy bg-neo-cream hover:bg-white rounded transition-all"
              title="Next"
            >
              <ChevronRight className="w-4 h-4 text-neo-navy" />
            </button>
            <h2 className="font-heading font-black text-base sm:text-lg text-neo-navy ml-2">
              {monthName}
            </h2>
          </div>

          {/* View Mode Toggle */}
          <div className="flex items-center border-2 border-neo-navy bg-neo-cream rounded overflow-hidden">
            <button
              onClick={() => setViewMode('month')}
              className={`px-3 py-1 font-heading font-bold text-xs uppercase transition-all ${
                viewMode === 'month' ? 'bg-neo-navy text-neo-cream' : 'text-neo-navy hover:bg-white'
              }`}
            >
              Month
            </button>
            <button
              onClick={() => setViewMode('week')}
              className={`px-3 py-1 font-heading font-bold text-xs uppercase border-x-2 border-neo-navy transition-all ${
                viewMode === 'week' ? 'bg-neo-navy text-neo-cream' : 'text-neo-navy hover:bg-white'
              }`}
            >
              Week
            </button>
            <button
              onClick={() => setViewMode('agenda')}
              className={`px-3 py-1 font-heading font-bold text-xs uppercase transition-all ${
                viewMode === 'agenda' ? 'bg-neo-navy text-neo-cream' : 'text-neo-navy hover:bg-white'
              }`}
            >
              Agenda
            </button>
          </div>

          {/* Filters */}
          <div className="flex flex-wrap items-center gap-2">
            <div className="flex items-center gap-1.5 text-xs font-heading font-bold">
              <Filter className="w-3.5 h-3.5 text-neo-navy/60" />
              <span>Status:</span>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="px-2 py-1 border-2 border-neo-navy bg-white text-xs font-medium"
              >
                <option value="all">All</option>
                <option value="active">Active</option>
                <option value="done">Done</option>
                <option value="missed">Missed</option>
                <option value="cancelled">Cancelled</option>
              </select>
            </div>

            <div className="flex items-center gap-1.5 text-xs font-heading font-bold">
              <span>Owner:</span>
              <select
                value={ownerFilter}
                onChange={(e) => setOwnerFilter(e.target.value)}
                className="px-2 py-1 border-2 border-neo-navy bg-white text-xs font-medium"
              >
                <option value="all">All</option>
                <option value="seller">Seller</option>
                <option value="buyer">Buyer</option>
                <option value="both">Mutual</option>
              </select>
            </div>
          </div>
        </div>

        {/* ── VIEW 1: MONTH VIEW ── */}
        {viewMode === 'month' && (
          <div className="neo-card p-0 bg-white overflow-hidden">
            {/* Weekday Labels Header */}
            <div className="grid grid-cols-7 border-b-[3px] border-neo-navy bg-neo-cream text-center text-xs font-heading font-black uppercase text-neo-navy py-2">
              <div>Sun</div>
              <div>Mon</div>
              <div>Tue</div>
              <div>Wed</div>
              <div>Thu</div>
              <div>Fri</div>
              <div>Sat</div>
            </div>

            {/* Grid Days */}
            <div className="grid grid-cols-7 auto-rows-fr divide-x-2 divide-y-2 divide-neo-navy/20">
              {monthDays.map((item, idx) => {
                const dayReminders = getRemindersForDate(item.date);
                const isTodayDate = isToday(item.date);

                return (
                  <div
                    key={idx}
                    onClick={() => handleDayClick(item.date)}
                    onDragOver={(e) => e.preventDefault()}
                    onDrop={(e) => handleDropOnDate(e, item.date)}
                    className={`min-h-[90px] sm:min-h-[110px] p-1.5 sm:p-2 flex flex-col justify-between transition-colors cursor-pointer hover:bg-neo-cream/40 ${
                      item.isCurrentMonth ? 'bg-white' : 'bg-neo-cream/20 text-neo-navy/40'
                    } ${isTodayDate ? 'bg-neo-orange/10 ring-2 ring-inset ring-neo-orange' : ''}`}
                  >
                    {/* Day Number */}
                    <div className="flex items-center justify-between mb-1">
                      <span
                        className={`text-xs font-heading font-black ${
                          isTodayDate
                            ? 'px-1.5 py-0.5 bg-neo-orange text-neo-navy border border-neo-navy rounded-xs'
                            : ''
                        }`}
                      >
                        {item.date.getDate()}
                      </span>
                      {dayReminders.length > 0 && (
                        <span className="text-[10px] font-mono text-neo-navy/50 font-bold">
                          {dayReminders.length}
                        </span>
                      )}
                    </div>

                    {/* Events Chips */}
                    <div className="space-y-1 overflow-y-auto max-h-[70px]">
                      {dayReminders.map((rem) => (
                        <div
                          key={rem.id}
                          draggable
                          onDragStart={(e) => handleDragStart(e, rem.id)}
                          onClick={(e) => handleChipClick(e, rem)}
                          className={`px-1.5 py-0.5 border text-[10px] font-heading font-bold truncate rounded-xs cursor-pointer shadow-[1px_1px_0px_#001524] hover:translate-x-[1px] ${getStatusColor(
                            rem
                          )}`}
                          title={`${rem.title} (${rem.status})`}
                        >
                          {rem.title}
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ── VIEW 2: WEEK VIEW ── */}
        {viewMode === 'week' && (
          <div className="neo-card p-0 bg-white overflow-hidden">
            <div className="grid grid-cols-7 border-b-[3px] border-neo-navy bg-neo-cream text-center text-xs font-heading font-black uppercase text-neo-navy py-2">
              {weekDays.map((d, idx) => (
                <div key={idx} className={isToday(d) ? 'text-neo-orange font-black' : ''}>
                  {d.toLocaleDateString(undefined, { weekday: 'short', month: 'numeric', day: 'numeric' })}
                </div>
              ))}
            </div>

            <div className="grid grid-cols-7 min-h-[350px] divide-x-2 divide-neo-navy/20">
              {weekDays.map((d, idx) => {
                const dayReminders = getRemindersForDate(d);
                return (
                  <div
                    key={idx}
                    onClick={() => handleDayClick(d)}
                    onDragOver={(e) => e.preventDefault()}
                    onDrop={(e) => handleDropOnDate(e, d)}
                    className="p-2 space-y-1.5 hover:bg-neo-cream/40 cursor-pointer"
                  >
                    {dayReminders.map((rem) => (
                      <div
                        key={rem.id}
                        draggable
                        onDragStart={(e) => handleDragStart(e, rem.id)}
                        onClick={(e) => handleChipClick(e, rem)}
                        className={`p-1.5 border-2 border-neo-navy text-xs font-heading font-bold rounded shadow-[2px_2px_0px_#001524] ${getStatusColor(
                          rem
                        )}`}
                      >
                        <div className="font-black truncate">{rem.title}</div>
                        <div className="text-[10px] font-mono opacity-80">
                          {rem.due_at ? new Date(rem.due_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                        </div>
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ── VIEW 3: AGENDA VIEW ── */}
        {viewMode === 'agenda' && (
          <div className="neo-card p-6 bg-white space-y-4">
            <h3 className="font-heading font-black text-lg text-neo-navy uppercase border-b-2 border-neo-navy pb-2">
              Upcoming Agenda & Commitments
            </h3>

            {filteredReminders.length === 0 ? (
              <p className="text-xs text-neo-navy/60 italic py-4">
                No reminders found matching the selected filters.
              </p>
            ) : (
              <div className="divide-y-2 divide-neo-navy/15">
                {filteredReminders.map((rem) => {
                  const d = new Date(rem.due_at || Date.now());
                  const formattedDue = isNaN(d.getTime())
                    ? rem.due_at
                    : d.toLocaleDateString(undefined, {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      });

                  return (
                    <div
                      key={rem.id}
                      onClick={() => {
                        setSelectedReminder(rem);
                        setIsDrawerOpen(true);
                      }}
                      className="py-3 flex flex-wrap items-center justify-between gap-3 hover:bg-neo-cream/30 px-2 cursor-pointer transition-colors"
                    >
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span
                            className={`px-2 py-0.5 border border-neo-navy text-[10px] font-heading font-bold uppercase ${getStatusColor(
                              rem
                            )}`}
                          >
                            {rem.status}
                          </span>
                          <span className="text-[10px] font-mono text-neo-navy/60 uppercase">
                            {rem.owner === 'buyer' ? 'Buyer Action' : 'Seller Action'}
                          </span>
                        </div>
                        <h4 className="font-heading font-black text-sm text-neo-navy">
                          {rem.title}
                        </h4>
                        {rem.note && (
                          <p className="text-xs text-neo-navy/70 italic mt-0.5">{rem.note}</p>
                        )}
                      </div>

                      <div className="text-right">
                        <div className="text-xs font-mono font-bold text-neo-navy">
                          {formattedDue}
                        </div>
                        <div className="text-[10px] font-mono text-neo-navy/50">
                          Lead: {rem.lead_minutes}m before
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {/* Reminder Drawer Modal */}
        <ReminderDrawer
          isOpen={isDrawerOpen}
          onClose={() => setIsDrawerOpen(false)}
          initialData={
            selectedReminder ||
            (prefilledDate ? { due_at: `${prefilledDate}T10:00:00.000Z` } : null)
          }
          onSave={async (payload, id) => {
            if (id) {
              await update(id, payload);
            } else {
              await create(payload);
            }
          }}
          onDelete={remove}
          onSendTest={sendTest}
          timezone={prefs?.timezone || 'Asia/Kolkata'}
          t={t}
        />
      </div>
    </Layout>
  );
}
