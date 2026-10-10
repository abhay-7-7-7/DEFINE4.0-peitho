import React, { useState, useEffect, useRef, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Mic,
  MicOff,
  Radio,
  PhoneOff,
  Copy,
  Check,
  TrendingUp,
  TrendingDown,
  Minus,
  Shield,
  Volume2,
  VolumeX,
  Sparkles,
  Layers,
  ArrowLeft,
  ExternalLink,
  Info,
  HelpCircle,
  Activity,
  Send,
  Zap,
  CheckCircle2,
  Lock,
} from 'lucide-react';
import { usePeithoCall } from './usePeithoCall';
import { useI18n } from '../context/I18nContext';
import { RemindersCallStrip, CallSummaryReminders, useReminders } from './reminders';

const TranscriptItem = React.memo(function TranscriptItem({ t }) {
  const isSeller = t.channel === 'SELLER';
  return (
    <div className={`flex flex-col ${isSeller ? 'items-end' : 'items-start'}`}>
      <div className="flex items-center gap-1.5 mb-1 px-1">
        <span
          className={`text-[10px] font-heading font-black px-1.5 py-0.2 rounded border border-neo-navy ${
            isSeller
              ? 'bg-neo-teal text-neo-cream'
              : 'bg-neo-orange text-neo-navy'
          }`}
        >
          {isSeller ? 'YOU (SELLER)' : 'BUYER'}
        </span>
        <span className="text-[10px] text-neo-navy/50 font-mono">
          {new Date(t.timestamp * 1000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
        </span>
      </div>

      <div
        className={`max-w-[85%] p-3 border-2 border-neo-navy font-medium text-sm leading-relaxed shadow-[2px_2px_0px_#001524] ${
          isSeller
            ? 'bg-neo-cream text-neo-navy rounded-tl-lg rounded-bl-lg rounded-tr-xs'
            : 'bg-white text-neo-navy rounded-tr-lg rounded-br-lg rounded-tl-xs'
        }`}
      >
        {t.text}
      </div>
    </div>
  );
});

const TranscriptFeed = React.memo(function TranscriptFeed({
  transcripts,
  partialSellerText,
  partialBuyerText,
  transcriptEndRef,
}) {
  return (
    <div className="flex-1 overflow-y-auto space-y-3 pr-1">
      {transcripts.length === 0 && !partialSellerText && !partialBuyerText && (
        <div className="h-full flex flex-col items-center justify-center text-center p-6 text-neo-navy/50">
          <Activity className="w-8 h-8 mb-2 animate-bounce opacity-40" />
          <p className="font-heading font-bold text-sm">Listening for conversation...</p>
          <p className="text-xs max-w-xs mt-1">
            Speak into your microphone or let the buyer speak in Google Meet. Speech appears here automatically.
          </p>
        </div>
      )}

      {transcripts.map((t) => (
        <TranscriptItem key={t.id} t={t} />
      ))}

      {partialSellerText && (
        <div className="flex flex-col items-end opacity-75 animate-pulse">
          <span className="text-[10px] font-mono font-medium text-gray-500 mb-0.5">YOU (speaking...):</span>
          <div className="max-w-[85%] p-2.5 border-2 border-dashed border-gray-400 bg-gray-100 text-gray-700 text-xs italic rounded">
            "{partialSellerText}"
          </div>
        </div>
      )}

      {partialBuyerText && (
        <div className="flex flex-col items-start opacity-75 animate-pulse">
          <span className="text-[10px] font-mono font-medium text-gray-500 mb-0.5">BUYER (speaking...):</span>
          <div className="max-w-[85%] p-2.5 border-2 border-dashed border-gray-400 bg-gray-100 text-gray-700 text-xs italic rounded">
            "{partialBuyerText}"
          </div>
        </div>
      )}

      <div ref={transcriptEndRef} />
    </div>
  );
});

function ScoreSparkline({ history, currentScore }) {
  const points = useMemo(() => {
    if (!history || history.length === 0) {
      return [{ round: 0, score: currentScore }];
    }
    return history;
  }, [history, currentScore]);

  const width = 90;
  const height = 26;
  const pad = 3;

  if (points.length < 2) {
    const clamped = Math.max(0, Math.min(100, currentScore));
    const y = height - pad - (clamped / 100) * (height - 2 * pad);
    return (
      <svg width={width} height={height} className="overflow-visible">
        <line x1={pad} y1={height / 2} x2={width - pad} y2={height / 2} stroke="#CBD5E1" strokeWidth="1" strokeDasharray="2,2" />
        <circle cx={width / 2} cy={y} r="3" fill="#0EA5E9" stroke="#001524" strokeWidth="1.5" />
      </svg>
    );
  }

  const coords = points.map((p, i) => {
    const x = pad + (i / (points.length - 1)) * (width - 2 * pad);
    const scoreVal = Math.max(0, Math.min(100, p.score));
    const y = height - pad - (scoreVal / 100) * (height - 2 * pad);
    return { x, y };
  });

  const polylineStr = coords.map((c) => `${c.x.toFixed(1)},${c.y.toFixed(1)}`).join(' ');

  return (
    <svg width={width} height={height} className="overflow-visible" title="Score history per round">
      <polyline
        fill="none"
        stroke="#001524"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        points={polylineStr}
      />
      {coords.map((c, i) => (
        <circle
          key={i}
          cx={c.x}
          cy={c.y}
          r={i === coords.length - 1 ? 3.5 : 2}
          fill={i === coords.length - 1 ? "#F97316" : "#0284C7"}
          stroke="#001524"
          strokeWidth="1.5"
        />
      ))}
    </svg>
  );
}

const DealLikelihoodCard = React.memo(function DealLikelihoodCard({ buyerScore, t }) {
  const targetScore = buyerScore.score ?? 50;
  const [displayScore, setDisplayScore] = useState(targetScore);

  useEffect(() => {
    if (displayScore === targetScore) return;
    const diff = targetScore - displayScore;
    const step = diff > 0 ? 1 : -1;
    const timer = setInterval(() => {
      setDisplayScore((curr) => {
        if (curr === targetScore) {
          clearInterval(timer);
          return curr;
        }
        return curr + step;
      });
    }, 20);
    return () => clearInterval(timer);
  }, [targetScore, displayScore]);

  const band = (buyerScore.band || 'medium').toLowerCase();
  const bandBadge =
    band === 'high'
      ? 'bg-emerald-500 text-neo-cream border-neo-navy'
      : band === 'low'
      ? 'bg-rose-500 text-neo-cream border-neo-navy'
      : 'bg-amber-400 text-neo-navy border-neo-navy';

  const barColor =
    band === 'high' ? 'bg-emerald-500' : band === 'low' ? 'bg-rose-500' : 'bg-amber-400';

  const trend = buyerScore.trend || 'flat';
  const delta = buyerScore.delta || 0;
  const isProvisional = Boolean(buyerScore.provisional);

  return (
    <div className={`neo-card p-4 bg-white relative transition-all duration-200 ${isProvisional ? 'opacity-85 border-dashed' : ''}`}>
      {/* Header */}
      <div className="flex items-center justify-between gap-2 mb-2">
        <div className="flex items-center gap-1.5">
          <Activity className="w-4 h-4 text-neo-orange" />
          <span className="font-heading font-black text-xs uppercase tracking-wider text-neo-navy">
            {t ? t('peitho.dealLikelihoodEstimate', 'Deal likelihood (estimate)') : 'Deal likelihood (estimate)'}
          </span>
        </div>
        <div className="flex items-center gap-1.5">
          {isProvisional && (
            <span className="text-[10px] font-heading font-bold px-1.5 py-0.2 bg-amber-100 text-amber-900 border border-amber-300 rounded animate-pulse">
              {t ? t('peitho.provisional', 'Provisional') : 'Provisional'}
            </span>
          )}
          <span className="text-[10px] font-mono font-medium text-neo-navy/60 capitalize">
            {t ? t('peitho.confidence', 'Confidence') : 'Confidence'}: {buyerScore.confidence || 'medium'}
          </span>
        </div>
      </div>

      {/* Main Metric Row: Big score, delta arrow, sparkline */}
      <div className="flex items-center justify-between gap-3 my-2">
        {/* Score & Band */}
        <div className="flex items-baseline gap-2">
          <span className={`text-4xl font-heading font-black tracking-tight ${isProvisional ? 'text-neo-navy/70' : 'text-neo-navy'}`}>
            {displayScore}
          </span>
          <span className="text-sm font-heading font-bold text-neo-navy/40">/100</span>

          <span className={`text-[11px] font-heading font-black uppercase px-2 py-0.5 border-2 rounded shadow-[1px_1px_0px_#001524] ${bandBadge}`}>
            {band}
          </span>
        </div>

        {/* Delta & Trend */}
        <div className="flex items-center gap-1 font-heading font-black text-xs">
          {trend === 'up' && (
            <span className="text-emerald-700 flex items-center bg-emerald-50 px-1.5 py-0.5 border border-emerald-300 rounded">
              <TrendingUp className="w-3.5 h-3.5 mr-0.5 text-emerald-600" />
              +{delta}
            </span>
          )}
          {trend === 'down' && (
            <span className="text-rose-700 flex items-center bg-rose-50 px-1.5 py-0.5 border border-rose-300 rounded">
              <TrendingDown className="w-3.5 h-3.5 mr-0.5 text-rose-600" />
              {delta}
            </span>
          )}
          {trend === 'flat' && (
            <span className="text-neo-navy/60 flex items-center bg-gray-50 px-1.5 py-0.5 border border-gray-300 rounded">
              <Minus className="w-3 h-3 mr-0.5" />
              0
            </span>
          )}
        </div>

        {/* Sparkline per round */}
        <div className="bg-neo-cream/40 px-2 py-1 border border-neo-navy/20 rounded flex flex-col items-center">
          <div className="text-[9px] font-mono text-neo-navy/50 uppercase mb-0.5">Round Trend</div>
          <ScoreSparkline history={buyerScore.history} currentScore={displayScore} />
        </div>
      </div>

      {/* Gauge Progress Bar */}
      <div className="w-full h-2.5 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden mb-2.5">
        <div
          className={`h-full ${barColor} transition-all duration-300 ease-out`}
          style={{ width: `${Math.max(3, Math.min(100, displayScore))}%` }}
        />
      </div>

      {/* Top 3 Drivers Chips */}
      {buyerScore.drivers && buyerScore.drivers.length > 0 && (
        <div className="space-y-1">
          <div className="text-[10px] font-heading font-black uppercase text-neo-navy/60">
            Top Drivers
          </div>
          <div className="flex flex-wrap gap-1.5">
            {buyerScore.drivers.slice(0, 3).map((d, i) => {
              const isPos = d.effect === 'positive';
              return (
                <span
                  key={i}
                  className={`text-[10px] font-medium px-2 py-0.5 rounded border flex items-center gap-1 ${
                    isPos
                      ? 'bg-emerald-50 text-emerald-900 border-emerald-300'
                      : 'bg-rose-50 text-rose-900 border-rose-300'
                  }`}
                >
                  <span className="font-bold">{isPos ? '+' : '–'}</span>
                  {d.text}
                </span>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
});

const BuyerStateStrip = React.memo(function BuyerStateStrip({ buyerState, t }) {
  const sentiment = buyerState?.sentiment || 'neutral';
  const buyingSignal = buyerState?.buying_signal || 'medium';
  const objections = buyerState?.open_objections ?? 0;

  return (
    <div className="bg-neo-cream/90 border-2 border-neo-navy px-3 py-1.5 rounded flex items-center justify-between text-xs font-heading">
      <div className="text-[10px] font-black uppercase tracking-wider text-neo-navy/70 flex items-center gap-1">
        <span>BUYER STATE:</span>
      </div>

      <div className="flex items-center gap-2 text-[11px]">
        {/* Sentiment */}
        <span className="bg-white px-2 py-0.5 border border-neo-navy/30 rounded font-semibold text-neo-navy">
          Sentiment: <strong className="capitalize">{sentiment}</strong>
        </span>

        {/* Buying signal */}
        <span
          className={`px-2 py-0.5 border rounded font-black capitalize ${
            buyingSignal === 'high'
              ? 'bg-emerald-100 text-emerald-800 border-emerald-400'
              : buyingSignal === 'low'
              ? 'bg-rose-100 text-rose-800 border-rose-400'
              : 'bg-amber-100 text-amber-900 border-amber-400'
          }`}
        >
          Signal: {buyingSignal}
        </span>

        {/* Open objections */}
        <span className="bg-white px-2 py-0.5 border border-neo-navy/30 rounded font-semibold text-neo-navy">
          {objections} Open Objections
        </span>
      </div>
    </div>
  );
});

function LockDealModal({
  isOpen,
  onClose,
  deal,
  config,
  onLock,
  t,
}) {
  const [copied, setCopied] = useState(false);
  if (!isOpen || !deal) return null;

  const price = Number(deal.price) || 0;
  const qty = Number(config?.quantity) || 1;
  const cost = Number(config?.cost_price) || 0;
  const minFloor = Number(config?.min_floor) || 0;
  const totalValue = price * qty;
  const unitProfit = price - cost;
  const totalProfit = unitProfit * qty;
  const marginPercent = price > 0 ? ((unitProfit / price) * 100).toFixed(1) : '0.0';
  const floorBuffer = price - minFloor;

  const scriptText = `Excellent, we have an agreement at $${price.toFixed(2)}. I am locking in our terms right now and will prepare the confirmation.`;

  const handleCopyScript = () => {
    navigator.clipboard.writeText(scriptText);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 bg-neo-navy/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in">
      <div className="bg-neo-cream border-[3.5px] border-neo-navy max-w-lg w-full p-6 shadow-neo-lg relative rounded-none animate-in zoom-in-95">
        {/* Top Header */}
        <div className="flex items-start justify-between pb-3 border-b-2 border-neo-navy mb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-emerald-400 border-2 border-neo-navy flex items-center justify-center shadow-[2px_2px_0px_#001524]">
              <Lock className="w-5 h-5 text-neo-navy" />
            </div>
            <div>
              <span className="text-[10px] font-heading font-black tracking-widest text-emerald-800 uppercase bg-emerald-100 px-2 py-0.5 border border-emerald-400 rounded">
                Agreement Reached
              </span>
              <h2 className="text-xl sm:text-2xl font-heading font-black text-neo-navy uppercase tracking-tight mt-0.5">
                Lock the Deal
              </h2>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 border-2 border-neo-navy font-bold flex items-center justify-center hover:bg-rose-100 transition-colors cursor-pointer"
            title="Dismiss / Keep Haggling"
          >
            ✕
          </button>
        </div>

        {/* Reason pill */}
        {deal.reason && (
          <div className="mb-4 px-3 py-1.5 bg-emerald-50 border-2 border-emerald-600/40 rounded text-xs font-semibold text-emerald-950 flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-emerald-600 shrink-0" />
            <span>{deal.reason}</span>
          </div>
        )}

        {/* Main Price Highlight */}
        <div className="bg-white border-2 border-neo-navy p-4 mb-4 rounded shadow-[2px_2px_0px_#001524] text-center">
          <div className="text-[11px] font-heading font-black uppercase text-neo-navy/60">
            Agreed Unit Price
          </div>
          <div className="text-3xl sm:text-4xl font-heading font-black text-neo-navy my-1">
            ${price.toFixed(2)}
            <span className="text-sm font-normal text-neo-navy/60 font-body ml-1">/ unit</span>
          </div>
          <div className="text-xs font-mono font-bold text-neo-teal">
            Total Contract Value: <span className="text-sm text-neo-navy">${totalValue.toFixed(2)}</span> ({qty} {qty === 1 ? 'unit' : 'units'})
          </div>
        </div>

        {/* Confidential Profitability Breakdown (Seller Eyes Only) */}
        <div className="bg-neo-teal/10 border-2 border-neo-teal p-3.5 mb-4 rounded text-xs">
          <div className="text-[10px] font-heading font-black uppercase tracking-wider text-neo-teal flex items-center gap-1 mb-2">
            <Shield className="w-3.5 h-3.5" />
            <span>Confidential Seller Margin Breakdown</span>
          </div>
          <div className="grid grid-cols-3 gap-2 text-center">
            <div className="bg-white p-2 border border-neo-navy/20 rounded">
              <span className="text-[10px] text-neo-navy/60 block font-heading font-bold uppercase">Margin %</span>
              <span className="font-heading font-black text-sm text-emerald-700">{marginPercent}%</span>
            </div>
            <div className="bg-white p-2 border border-neo-navy/20 rounded">
              <span className="text-[10px] text-neo-navy/60 block font-heading font-bold uppercase">Total Profit</span>
              <span className="font-heading font-black text-sm text-neo-navy">${totalProfit.toFixed(2)}</span>
            </div>
            <div className="bg-white p-2 border border-neo-navy/20 rounded">
              <span className="text-[10px] text-neo-navy/60 block font-heading font-bold uppercase">Above Floor</span>
              <span className="font-heading font-black text-sm text-neo-teal">+${floorBuffer.toFixed(2)}</span>
            </div>
          </div>
        </div>

        {/* Spoken Closing Script */}
        <div className="bg-white border-2 border-neo-navy p-3 mb-5 rounded">
          <div className="flex items-center justify-between mb-1.5">
            <span className="text-[10px] font-heading font-black uppercase text-neo-navy/70 flex items-center gap-1">
              <span>🗣️ Recommended Spoken Confirmation</span>
            </span>
            <button
              onClick={handleCopyScript}
              className="px-2 py-0.5 bg-neo-cream hover:bg-neo-orange/20 border border-neo-navy rounded text-[10px] font-heading font-bold flex items-center gap-1 transition-all cursor-pointer"
            >
              {copied ? (
                <>
                  <Check className="w-3 h-3 text-emerald-600" />
                  <span className="text-emerald-700">Copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-3 h-3 text-neo-navy" />
                  <span>Copy</span>
                </>
              )}
            </button>
          </div>
          <p className="text-xs sm:text-sm font-semibold text-neo-navy italic">
            "{scriptText}"
          </p>
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row gap-3">
          <button
            onClick={() => onLock(price)}
            className="flex-1 py-3 px-4 bg-emerald-500 hover:bg-emerald-400 text-neo-navy border-[2.5px] border-neo-navy font-heading font-black text-sm uppercase shadow-[3px_3px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center justify-center gap-2 transition-all cursor-pointer"
          >
            <Lock className="w-4 h-4" />
            <span>Lock Deal Now (${totalValue.toFixed(2)})</span>
          </button>
          <button
            onClick={onClose}
            className="py-3 px-4 bg-white hover:bg-neo-cream text-neo-navy border-[2.5px] border-neo-navy font-heading font-bold text-xs uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] transition-all cursor-pointer"
          >
            Keep Haggling
          </button>
        </div>
      </div>
    </div>
  );
}

const NowZone = React.memo(function NowZone({
  advisory,
  currentRound,
  maxRounds,
  sellerIsSpeaking,
  hasQueuedSuggestion,
  candidateLockDeal,
  isDealLocked,
  lockedDealData,
  onOpenLockModal,
  t,
}) {
  const [dismissedIndices, setDismissedIndices] = useState(new Set());
  const [usedIndices, setUsedIndices] = useState(new Set());
  const [copiedIndex, setCopiedIndex] = useState(null);

  useEffect(() => {
    setDismissedIndices(new Set());
    setUsedIndices(new Set());
  }, [advisory?.recommendation_id, advisory?.turn]);

  const handleCopy = (text, idx) => {
    navigator.clipboard.writeText(text);
    setCopiedIndex(idx);
    setTimeout(() => setCopiedIndex(null), 2000);
  };

  const handleUsed = (idx) => {
    setUsedIndices((prev) => {
      const next = new Set(prev);
      if (next.has(idx)) next.delete(idx);
      else next.add(idx);
      return next;
    });
  };

  const handleDismiss = (idx) => {
    setDismissedIndices((prev) => new Set(prev).add(idx));
  };

  if (!advisory) {
    return (
      <div className="neo-card p-5 bg-white text-center text-xs text-neo-navy/60">
        Waiting for buyer's initial statement to compute advisory guidance...
      </div>
    );
  }

  const rawOptions =
    advisory.options && advisory.options.length > 0
      ? advisory.options
      : (advisory.suggested_replies || []).map((txt, idx) => ({
          text: txt,
          intent: idx === 0 ? 'hold' : 'bridge',
          why: '',
          followup: null,
        }));

  const visibleOptions = rawOptions.filter((_, idx) => !dismissedIndices.has(idx));

  const intentBadges = {
    hold: { bg: 'bg-neo-navy text-neo-cream border-neo-navy', label: 'HOLD' },
    bridge: { bg: 'bg-neo-teal text-neo-cream border-neo-navy', label: 'BRIDGE' },
    close: { bg: 'bg-emerald-600 text-neo-cream border-neo-navy', label: 'CLOSE' },
    probe: { bg: 'bg-purple-600 text-neo-cream border-neo-navy', label: 'PROBE' },
  };

  return (
    <div className="neo-card p-5 bg-white relative overflow-hidden transition-opacity duration-200">
      {/* Top Header */}
      <div className="flex items-center justify-between gap-2 mb-2 pb-2 border-b-2 border-neo-navy/15">
        <div className="flex items-center gap-2">
          {/* Action Badge */}
          <div
            className={`text-base sm:text-lg font-heading font-black px-3 py-0.5 border-[2.5px] border-neo-navy shadow-[2px_2px_0px_#001524] uppercase ${
              advisory.action === 'ACCEPT'
                ? 'bg-emerald-400 text-neo-navy'
                : advisory.action === 'COUNTER'
                ? 'bg-neo-orange text-neo-navy'
                : advisory.action === 'FINAL_OFFER'
                ? 'bg-purple-400 text-neo-navy'
                : 'bg-neo-maroon text-neo-cream'
            }`}
          >
            {advisory.action}
          </div>

          <span className="font-mono text-xs font-bold text-neo-navy/70">
            Round {currentRound} / {maxRounds}
          </span>
        </div>

        <div className="flex items-center gap-2">
          {/* Source Badge */}
          <span
            className={`px-2 py-0.5 text-[10px] font-heading font-black border rounded flex items-center gap-1 ${
              advisory.source === 'ai'
                ? 'bg-purple-100 text-purple-900 border-purple-300'
                : 'bg-amber-100 text-amber-900 border-amber-300'
            }`}
          >
            {advisory.source === 'ai' ? (
              <>
                <Sparkles className="w-3 h-3 text-purple-600" />
                {t ? t('peitho.aiIntel', 'AI INTEL') : 'AI INTEL'}
              </>
            ) : (
              <>
                <Zap className="w-3 h-3 text-amber-600" />
                {t ? t('peitho.instantTemplate', 'INSTANT TEMPLATE') : 'INSTANT TEMPLATE'}
              </>
            )}
          </span>

          {/* Counter Price */}
          <div className="text-right">
            <span className="text-[10px] font-heading font-bold uppercase text-neo-navy/60 block leading-tight">Quote</span>
            <span className="text-xl font-heading font-black text-neo-navy">
              ${Number(advisory.counter_price).toFixed(2)}
            </span>
          </div>
        </div>
      </div>

      {/* Deal Officially Locked Banner */}
      {isDealLocked && (
        <div className="mb-3 p-3 bg-emerald-400 border-[2.5px] border-neo-navy rounded shadow-[2px_2px_0px_#001524] text-center">
          <div className="flex items-center justify-center gap-1.5 font-heading font-black text-sm text-neo-navy uppercase">
            <CheckCircle2 className="w-4 h-4 text-neo-navy" />
            <span>Deal Officially Locked!</span>
          </div>
          <p className="text-[11px] font-bold text-neo-navy/90 mt-0.5">
            Agreed Price: ${lockedDealData?.agreed_price ? Number(lockedDealData.agreed_price).toFixed(2) : '—'} / unit
            {lockedDealData?.total_value ? ` • Total: $${Number(lockedDealData.total_value).toFixed(2)}` : ''}
          </p>
        </div>
      )}

      {/* Lock Deal Opportunity Banner */}
      {candidateLockDeal && !isDealLocked && (
        <div className="mb-3 p-3 bg-emerald-100 border-[2.5px] border-emerald-800 rounded flex items-center justify-between gap-3 shadow-[2px_2px_0px_#001524] animate-pulse">
          <div className="flex items-center gap-2 text-xs font-heading font-black text-emerald-950">
            <Sparkles className="w-4 h-4 text-emerald-700 shrink-0" />
            <span>Deal Opportunity at ${candidateLockDeal.price.toFixed(2)} / unit!</span>
          </div>
          <button
            onClick={onOpenLockModal}
            className="px-3 py-1 bg-emerald-500 hover:bg-emerald-400 text-neo-navy border-2 border-neo-navy font-heading font-black text-xs uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1 cursor-pointer transition-all"
          >
            <Lock className="w-3.5 h-3.5" />
            <span>Lock Deal</span>
          </button>
        </div>
      )}

      {/* Seller Speaking / Queued Suggestion Dot */}
      {(sellerIsSpeaking || hasQueuedSuggestion) && (
        <div className="mb-2 px-2.5 py-1 bg-amber-50 border-2 border-amber-400 rounded flex items-center gap-2 text-xs text-amber-900 font-semibold animate-pulse">
          <span className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-ping" />
          <span>
            {t ? t('peitho.suggestionReady', 'Suggestion ready (seller speaking...)') : 'Suggestion ready (seller speaking...)'}
          </span>
        </div>
      )}

      {/* Strategy Rationale */}
      {advisory.reasoning && (
        <p className="text-xs text-neo-navy/80 bg-neo-cream/60 p-2 border border-neo-navy/30 rounded font-medium mb-3">
          💡 <strong>{t ? t('peitho.strategyRationale', 'Strategy Rationale') : 'Strategy Rationale'}:</strong> {advisory.reasoning}
        </p>
      )}

      {/* Options Cards */}
      <div className="space-y-2.5 transition-opacity duration-200">
        <div className="text-[11px] font-heading font-black text-neo-navy uppercase tracking-wider flex items-center justify-between">
          <span className="flex items-center gap-1.5">
            <Sparkles className="w-3.5 h-3.5 text-neo-orange" />
            Tactical Spoken Options:
          </span>
          <span className="text-[10px] font-mono text-neo-navy/50">{visibleOptions.length} available</span>
        </div>

        {visibleOptions.length === 0 ? (
          <div className="p-3 bg-neo-cream/40 border border-neo-navy/20 rounded text-xs text-neo-navy/50 italic text-center">
            All options dismissed for this turn.
          </div>
        ) : (
          visibleOptions.map((opt, idx) => {
            const intentKey = (opt.intent || 'hold').toLowerCase();
            const badge = intentBadges[intentKey] || intentBadges.hold;
            const isUsed = usedIndices.has(idx);
            const isCopied = copiedIndex === idx;

            return (
              <div
                key={idx}
                className={`p-3 border-2 border-neo-navy rounded shadow-[2px_2px_0px_#001524] relative group transition-all duration-150 ${
                  isUsed ? 'bg-emerald-50/80 border-emerald-700' : 'bg-neo-cream/70 hover:bg-neo-cream'
                }`}
              >
                {/* Header row: Intent badge & Action buttons */}
                <div className="flex items-center justify-between gap-2 mb-1.5">
                  <span
                    className={`text-[10px] font-heading font-black px-2 py-0.5 border rounded uppercase ${badge.bg}`}
                  >
                    {badge.label}
                  </span>

                  <div className="flex items-center gap-1">
                    {/* Copy Button */}
                    <button
                      onClick={() => handleCopy(opt.text, idx)}
                      className="px-1.5 py-0.5 bg-white border border-neo-navy hover:bg-neo-orange/20 rounded text-[10px] font-heading font-bold flex items-center gap-0.5 transition-all"
                      title="Copy text"
                    >
                      {isCopied ? (
                        <>
                          <Check className="w-3 h-3 text-emerald-600" />
                          <span className="text-emerald-700">Copied!</span>
                        </>
                      ) : (
                        <>
                          <Copy className="w-3 h-3 text-neo-navy" />
                          <span>Copy</span>
                        </>
                      )}
                    </button>

                    {/* Used Button */}
                    <button
                      onClick={() => handleUsed(idx)}
                      className={`px-1.5 py-0.5 border rounded text-[10px] font-heading font-bold flex items-center gap-0.5 transition-all ${
                        isUsed
                          ? 'bg-emerald-500 text-white border-emerald-700'
                          : 'bg-white text-neo-navy border-neo-navy hover:bg-emerald-50'
                      }`}
                      title="Mark as used in call"
                    >
                      <CheckCircle2 className="w-3 h-3" />
                      <span>{isUsed ? 'Used' : 'Use'}</span>
                    </button>

                    {/* Dismiss Button */}
                    <button
                      onClick={() => handleDismiss(idx)}
                      className="px-1 py-0.5 bg-white border border-neo-navy hover:bg-rose-100 text-neo-navy/60 hover:text-rose-700 rounded text-[10px] transition-all"
                      title="Dismiss option"
                    >
                      ✕
                    </button>
                  </div>
                </div>

                {/* Spoken Text */}
                <p className="text-xs sm:text-sm font-semibold text-neo-navy leading-snug">
                  "{opt.text}"
                </p>

                {/* Why line */}
                {opt.why && (
                  <p className="text-[11px] text-neo-navy/60 font-medium mt-1">
                    ↳ <em>{opt.why}</em>
                  </p>
                )}

                {/* Follow-up Hint (Top option) */}
                {idx === 0 && opt.followup && (
                  <div className="mt-2 p-2 bg-purple-50/90 border border-purple-300 rounded text-[11px] text-purple-950 font-medium flex items-start gap-1.5">
                    <span className="font-heading font-black text-purple-800 text-[10px] uppercase shrink-0">
                      If buyer says...:
                    </span>
                    <span>{opt.followup}</span>
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
});

export default function PeithoPage() {
  const navigate = useNavigate();
  const {
    status,
    sessionId,
    error,
    sttProvider,
    sellerStatus,
    sellerReason,
    buyerStatus,
    buyerReason,
    sellerEnergy,
    buyerEnergy,
    isMicMuted,
    toggleMicMute,
    transcripts,
    partialSellerText,
    partialBuyerText,
    advisory,
    currentCounter,
    currentRound,
    language,
    setLanguage,
    startCall,
    endCall,
    sendTypedLine,
    buyerScore,
    sellerIsSpeaking,
    hasQueuedSuggestion,
    isDealLocked,
    lockedDealData,
    lockDeal,
    sendReminderAction,
  } = usePeithoCall({ initialLanguage: 'en', onReminderEvent: (msg) => handleReminderWsEvent(msg) });

  const {
    reminders,
    highlightedId,
    create: createReminder,
    update: updateReminder,
    remove: deleteReminder,
    snooze: snoozeReminder,
    markDone: markDoneReminder,
    sendTest: sendTestReminder,
    handleWsEvent: handleReminderWsEvent,
    prefs: reminderPrefs,
  } = useReminders();

  const i18n = useI18n ? useI18n() : null;
  const t = useCallback((key, fallback) => (i18n?.t ? i18n.t(key) : fallback || key), [i18n]);

  // Pre-call form parameters
  const [config, setConfig] = useState({
    product_name: 'High-Performance Cloud Compute Cluster',
    base_price: 500,
    cost_price: 250,
    min_floor: 320,
    mode: 'MAX_PROFIT',
    max_rounds: 6,
    quantity: 1,
    available_inventory: 50,
    reference_inventory: 50,
    buyer_archetype: 'UNKNOWN',
  });

  // Typed manual input state
  const [typedSpeaker, setTypedSpeaker] = useState('BUYER');
  const [typedText, setTypedText] = useState('');
  const [copiedIndex, setCopiedIndex] = useState(null);
  const [showMeetHelp, setShowMeetHelp] = useState(false);

  const [showLockDealModal, setShowLockDealModal] = useState(false);
  const [dismissedDealPrice, setDismissedDealPrice] = useState(null);

  // Detect when buyer price comes near target and agreement is reached (and >= min_floor)
  const candidateLockDeal = useMemo(() => {
    if (isDealLocked) return null;
    const minFloor = Number(config.min_floor) || 0;
    const targetCounter = Number(currentCounter) || Number(config.base_price) || 0;

    // 1. Explicit backend advisory signal
    if (advisory?.deal_lockable && advisory?.lockable_price) {
      if (advisory.lockable_price >= minFloor) {
        return {
          price: Number(advisory.lockable_price),
          reason: advisory.lock_reason || 'Buyer agreed to price within target range',
          source: 'advisory',
        };
      }
    }

    if (advisory?.action === 'ACCEPT') {
      const p = advisory.extracted_buyer_offer || advisory.counter_price || targetCounter;
      if (p >= minFloor) {
        return {
          price: Number(p),
          reason: 'Engine recommends accepting favorable buyer terms',
          source: 'engine_accept',
        };
      }
    }

    // 2. Transcript & intent evaluation on latest buyer utterance
    if (transcripts.length > 0) {
      const buyerLines = transcripts.filter((t) => t.channel === 'BUYER');
      if (buyerLines.length > 0) {
        const lastBuyer = buyerLines[buyerLines.length - 1];
        const textLower = lastBuyer.text.toLowerCase();
        const agreementWords = [
          'deal',
          'agree',
          'agreed',
          'done',
          'sounds good',
          'take it',
          'accept',
          'lock',
          'fair',
          'fine',
          'ok',
          'okay',
          "let's do it",
          'we have a deal',
          "i'll take",
        ];
        const hasAgreement = agreementWords.some((w) => textLower.includes(w));

        const numMatches = textLower.match(/\$?\s*([0-9]+(?:\.[0-9]+)?)/g);
        let detectedPrice = null;
        if (numMatches) {
          for (const m of numMatches) {
            const val = parseFloat(m.replace('$', '').trim());
            if (!isNaN(val) && val >= minFloor && val <= config.base_price * 1.5) {
              detectedPrice = val;
              break;
            }
          }
        }

        const effectivePrice = detectedPrice ?? targetCounter;
        const isNear =
          effectivePrice >= targetCounter ||
          (targetCounter - effectivePrice) / Math.max(targetCounter, 1) <= 0.08;

        if (hasAgreement && effectivePrice >= minFloor && (isNear || (buyerScore?.score ?? 0) >= 70)) {
          return {
            price: Number(effectivePrice),
            reason: detectedPrice
              ? `Buyer agreed to $${effectivePrice.toFixed(2)} (near target $${targetCounter.toFixed(2)})`
              : `Buyer accepted target quote of $${targetCounter.toFixed(2)}`,
            source: 'transcript_agreement',
          };
        }
      }
    }

    return null;
  }, [isDealLocked, advisory, config.min_floor, config.base_price, currentCounter, transcripts, buyerScore]);

  // Automatically trigger popup modal when deal agreement is detected
  useEffect(() => {
    if (candidateLockDeal && !isDealLocked && dismissedDealPrice !== candidateLockDeal.price) {
      setShowLockDealModal(true);
    }
  }, [candidateLockDeal, isDealLocked, dismissedDealPrice]);

  const handleLockDeal = (price) => {
    lockDeal(price);
    setShowLockDealModal(false);
  };

  const handleCloseModal = () => {
    setShowLockDealModal(false);
    if (candidateLockDeal) {
      setDismissedDealPrice(candidateLockDeal.price);
    }
  };

  const transcriptEndRef = useRef(null);

  // Auto-scroll transcript feed
  useEffect(() => {
    if (transcriptEndRef.current) {
      transcriptEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [transcripts, partialSellerText, partialBuyerText]);

  const handleCopyReply = (text, index) => {
    navigator.clipboard.writeText(text);
    setCopiedIndex(index);
    setTimeout(() => setCopiedIndex(null), 2000);
  };

  const handleSendManual = (e) => {
    e.preventDefault();
    if (!typedText.trim()) return;
    sendTypedLine(typedSpeaker, typedText.trim());
    setTypedText('');
  };

  const isCallActive = status === 'active';

  return (
    <div className="min-h-screen bg-neo-cream text-neo-navy flex flex-col font-body">
      {/* ── TOP HEADER ── */}
      <header className="border-b-[3px] border-neo-navy bg-neo-cream sticky top-0 z-40 px-4 sm:px-8 py-3.5 flex items-center justify-between shadow-sm">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/')}
            className="p-1.5 border-2 border-neo-navy hover:bg-neo-orange/20 transition-all rounded-sm flex items-center gap-1 text-xs font-bold font-heading uppercase"
            title="Return to Home"
          >
            <ArrowLeft className="w-4 h-4" />
            <span className="hidden sm:inline">Home</span>
          </button>

          <div className="flex items-center gap-2">
            <span className="w-3 h-3 rounded-full bg-neo-orange border-2 border-neo-navy animate-pulse" />
            <h1 className="text-xl sm:text-2xl font-heading font-black tracking-tight flex items-center gap-1.5">
              PEITHO <span className="text-neo-teal text-sm font-semibold tracking-normal hidden md:inline">Meet Assistant</span>
            </h1>
          </div>
        </div>

        {/* Live Status Indicators */}
        <div className="flex items-center gap-3">
          {isDealLocked && (
            <div className="flex items-center gap-1.5 px-3 py-1 bg-emerald-400 text-neo-navy border-2 border-neo-navy rounded text-xs font-heading font-black shadow-[2px_2px_0px_#001524]">
              <Lock className="w-3.5 h-3.5 text-neo-navy" />
              <span>DEAL LOCKED</span>
            </div>
          )}

          {candidateLockDeal && !isDealLocked && (
            <button
              onClick={() => setShowLockDealModal(true)}
              className="hidden sm:flex items-center gap-1.5 px-3 py-1 bg-emerald-400 hover:bg-emerald-300 text-neo-navy border-2 border-neo-navy rounded text-xs font-heading font-black shadow-[2px_2px_0px_#001524] cursor-pointer animate-pulse transition-all"
              title="Open Lock Deal Modal"
            >
              <Lock className="w-3.5 h-3.5 text-neo-navy" />
              <span>LOCK DEAL (${candidateLockDeal.price.toFixed(2)})</span>
            </button>
          )}

          <div className="hidden sm:flex items-center gap-2 px-3 py-1 bg-neo-cream border-2 border-neo-navy rounded text-xs font-heading font-bold shadow-[2px_2px_0px_#001524]">
            <Radio className={`w-3.5 h-3.5 ${isCallActive ? 'text-neo-orange animate-pulse' : 'text-neo-navy/40'}`} />
            <span>{isCallActive ? 'LIVE SESSION' : 'OFFLINE'}</span>
          </div>

          <button
            onClick={() => setShowMeetHelp(true)}
            className="p-1.5 border-2 border-neo-navy bg-neo-teal text-neo-cream hover:bg-neo-teal/90 transition-all rounded text-xs font-heading font-bold flex items-center gap-1 shadow-[2px_2px_0px_#001524]"
            title="Google Meet Audio Instructions"
          >
            <HelpCircle className="w-4 h-4" />
            <span className="hidden md:inline">Meet Audio Setup</span>
          </button>
        </div>
      </header>

      {/* ── GOOGLE MEET SETUP MODAL ── */}
      {showMeetHelp && (
        <div className="fixed inset-0 bg-neo-navy/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-neo-cream border-[3px] border-neo-navy max-w-lg w-full p-6 shadow-neo-lg animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between pb-3 border-b-2 border-neo-navy mb-4">
              <h2 className="text-xl font-heading font-black text-neo-navy flex items-center gap-2">
                <ExternalLink className="w-5 h-5 text-neo-orange" />
                Google Meet Setup Guide
              </h2>
              <button
                onClick={() => setShowMeetHelp(false)}
                className="w-7 h-7 border-2 border-neo-navy font-bold flex items-center justify-center hover:bg-neo-orange/20"
              >
                ✕
              </button>
            </div>

            <div className="space-y-3.5 text-sm text-neo-navy/90 mb-6">
              <div className="flex gap-3 items-start">
                <span className="w-6 h-6 rounded-full bg-neo-orange border-2 border-neo-navy text-neo-navy font-black flex items-center justify-center text-xs shrink-0">1</span>
                <p>Open your <strong>Google Meet call</strong> in a Chrome browser tab.</p>
              </div>
              <div className="flex gap-3 items-start">
                <span className="w-6 h-6 rounded-full bg-neo-orange border-2 border-neo-navy text-neo-navy font-black flex items-center justify-center text-xs shrink-0">2</span>
                <p>Click <strong>"Start Peitho Live"</strong> below. Your browser will prompt for permissions.</p>
              </div>
              <div className="flex gap-3 items-start">
                <span className="w-6 h-6 rounded-full bg-neo-orange border-2 border-neo-navy text-neo-navy font-black flex items-center justify-center text-xs shrink-0">3</span>
                <div>
                  <p>When the screen share prompt appears:</p>
                  <ul className="list-disc pl-5 mt-1 space-y-1 font-medium text-xs bg-neo-teal/10 p-2.5 border-2 border-neo-teal/40 rounded">
                    <li>Select the <strong>"Chrome Tab"</strong> tab.</li>
                    <li>Select your <strong>Google Meet tab</strong>.</li>
                    <li><strong>Crucial:</strong> Ensure <strong>"Also share tab audio"</strong> toggle is checked at the bottom!</li>
                  </ul>
                </div>
              </div>
              <div className="flex gap-3 items-start">
                <span className="w-6 h-6 rounded-full bg-neo-orange border-2 border-neo-navy text-neo-navy font-black flex items-center justify-center text-xs shrink-0">4</span>
                <p>Peitho will automatically isolate the buyer's voice from the tab and your voice from your microphone!</p>
              </div>
            </div>

            <button
              onClick={() => setShowMeetHelp(false)}
              className="w-full neo-btn neo-btn-orange py-2.5 text-sm"
            >
              Got It, Let's Go
            </button>
          </div>
        </div>
      )}

      {/* ── ERROR BANNER ── */}
      {error && (
        <div className="bg-neo-maroon text-neo-cream px-4 py-2 text-sm font-semibold flex items-center justify-between border-b-2 border-neo-navy">
          <span>⚠️ {error}</span>
          <button onClick={() => {}} className="text-xs uppercase underline">Dismiss</button>
        </div>
      )}

      {/* ── PRE-CALL SETUP / LAUNCH SCREEN ── */}
      {!isCallActive && (
        <main className="flex-1 max-w-4xl mx-auto w-full p-4 sm:p-8 flex flex-col justify-center space-y-6">
          {/* Post-Call Reminders Summary if call just ended */}
          {status === 'ended' && (
            <CallSummaryReminders
              reminders={reminders}
              callId={sessionId}
              onUpdate={updateReminder}
              onDelete={deleteReminder}
              onCreate={createReminder}
              onSendTest={sendTestReminder}
              timezone={reminderPrefs?.timezone || 'Asia/Kolkata'}
              t={t}
            />
          )}

          <div className="neo-card p-6 sm:p-8 relative overflow-hidden">
            <div className="absolute top-0 right-0 bg-neo-teal text-neo-cream text-xs font-heading font-black px-4 py-1 border-b-2 border-l-2 border-neo-navy uppercase tracking-wider">
              PRANE-X Advisory Engine
            </div>

            <div className="mb-6">
              <h2 className="text-2xl sm:text-3xl font-heading font-black text-neo-navy mb-2">
                Configure Meet Assistant
              </h2>
              <p className="text-sm text-neo-navy/70">
                Set your product parameters and margin targets. Peitho runs the PRANE-X negotiation engine in advisory mode to calculate counter-offers and prompt tactical responses in real time.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Product Name</label>
                <input
                  type="text"
                  value={config.product_name}
                  onChange={(e) => setConfig({ ...config, product_name: e.target.value })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden focus:ring-2 focus:ring-neo-orange"
                />
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Negotiation Mode</label>
                <select
                  value={config.mode}
                  onChange={(e) => setConfig({ ...config, mode: e.target.value })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm focus:outline-hidden"
                >
                  <option value="MAX_PROFIT">MAX_PROFIT (Conservative Concessions)</option>
                  <option value="MIN_LOSS">MIN_LOSS (Volume / Inventory Liquidation)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Asking / Base Price ($)</label>
                <input
                  type="number"
                  value={config.base_price}
                  onChange={(e) => setConfig({ ...config, base_price: parseFloat(e.target.value) || 0 })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Cost Price ($)</label>
                <input
                  type="number"
                  value={config.cost_price}
                  onChange={(e) => setConfig({ ...config, cost_price: parseFloat(e.target.value) || 0 })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Absolute Minimum Floor ($)</label>
                <input
                  type="number"
                  value={config.min_floor}
                  onChange={(e) => setConfig({ ...config, min_floor: parseFloat(e.target.value) || 0 })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">Deal Quantity</label>
                <input
                  type="number"
                  min="1"
                  value={config.quantity}
                  onChange={(e) => setConfig({ ...config, quantity: parseInt(e.target.value, 10) || 1 })}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm"
                />
              </div>

              <div>
                <label className="block text-xs font-heading font-bold uppercase mb-1">STT Language & Code-Switching</label>
                <select
                  value={language}
                  onChange={(e) => setLanguage(e.target.value)}
                  className="w-full px-3 py-2 border-2 border-neo-navy bg-white font-medium text-sm"
                >
                  <option value="en">English (Default)</option>
                  <option value="hi">Hindi (हिन्दी)</option>
                  <option value="auto">Multilingual / Auto (Code-Switching)</option>
                </select>
              </div>
            </div>

            {/* Quick Info Box */}
            <div className="bg-neo-teal/10 border-2 border-neo-teal p-3.5 mb-6 rounded text-xs flex items-center gap-2.5">
              <Info className="w-5 h-5 text-neo-teal shrink-0" />
              <span>
                <strong>Privacy Guaranteed:</strong> Neither customer audio nor customer transcripts are ever stored in external logs. Calculations run server-side and suggestions are displayed exclusively to you.
              </span>
            </div>

            {/* Launch Buttons */}
            <div className="flex flex-col sm:flex-row gap-3">
              <button
                onClick={() => startCall(config, true)}
                disabled={status === 'starting'}
                className="flex-1 neo-btn neo-btn-orange text-base py-3.5 flex items-center justify-center gap-2"
              >
                <Zap className="w-5 h-5" />
                {status === 'starting' ? 'Connecting Audio Streams...' : 'Start Meet Assistant (With Meet Audio)'}
              </button>

              <button
                onClick={() => startCall(config, false)}
                disabled={status === 'starting'}
                className="neo-btn bg-white hover:bg-neo-cream text-neo-navy text-xs py-3 px-4 flex items-center justify-center gap-1.5"
                title="Start with mic only and type buyer utterances manually"
              >
                <Mic className="w-4 h-4" />
                Mic-Only / Manual Mode
              </button>
            </div>
          </div>
        </main>
      )}

      {/* ── ACTIVE COPILOT DASHBOARD ── */}
      {isCallActive && (
        <main className="flex-1 p-3 sm:p-6 grid grid-cols-1 lg:grid-cols-12 gap-4 max-w-7xl mx-auto w-full">
          {/* ── COLUMN 1: LIVE CALL CONTROL & AUDIO TRANSCRIPT STREAM (7 Cols) ── */}
          <section className="lg:col-span-7 flex flex-col gap-4">
            {/* Call Control Strip */}
            <div className="neo-card p-3 sm:p-4 flex flex-wrap items-center justify-between gap-3 bg-white">
              <div className="flex items-center gap-4">
                <div>
                  <div className="text-[10px] font-heading font-black uppercase text-neo-navy/60">Product</div>
                  <div className="font-heading font-bold text-sm truncate max-w-[160px] sm:max-w-xs">{config.product_name}</div>
                </div>

                <div className="h-6 w-[2px] bg-neo-navy/20" />

                <div>
                  <div className="text-[10px] font-heading font-black uppercase text-neo-navy/60">Target Counter</div>
                  <div className="font-heading font-bold text-base text-neo-teal">
                    ${currentCounter ? currentCounter.toFixed(2) : config.base_price.toFixed(2)}
                  </div>
                </div>
              </div>

              {/* Live VU Energy Meters */}
              <div className="flex items-center gap-3">
                {/* Seller Mic VU */}
                <div className="flex items-center gap-1.5 bg-neo-cream px-2 py-1 border-2 border-neo-navy rounded">
                  <button
                    onClick={toggleMicMute}
                    className="p-1 hover:bg-neo-orange/20 rounded"
                    title={isMicMuted ? 'Unmute Mic' : 'Mute Mic'}
                  >
                    {isMicMuted ? <MicOff className="w-3.5 h-3.5 text-neo-maroon" /> : <Mic className="w-3.5 h-3.5 text-neo-navy" />}
                  </button>
                  <div className="w-12 h-2.5 bg-white border border-neo-navy rounded-xs overflow-hidden">
                    <div
                      className="h-full bg-neo-teal transition-all duration-75"
                      style={{ width: `${Math.round(sellerEnergy * 100)}%` }}
                    />
                  </div>
                  <span className="text-[10px] font-heading font-black">MIC</span>
                </div>

                {/* Buyer Tab Audio VU */}
                <div className="flex items-center gap-1.5 bg-neo-cream px-2 py-1 border-2 border-neo-navy rounded">
                  <Volume2 className="w-3.5 h-3.5 text-neo-navy" />
                  <div className="w-12 h-2.5 bg-white border border-neo-navy rounded-xs overflow-hidden">
                    <div
                      className="h-full bg-neo-orange transition-all duration-75"
                      style={{ width: `${Math.round(buyerEnergy * 100)}%` }}
                    />
                  </div>
                  <span className="text-[10px] font-heading font-black">TAB</span>
                </div>

              {/* End Call */}
              <button
                onClick={endCall}
                className="px-3 py-1 bg-neo-maroon text-neo-cream border-2 border-neo-navy font-heading font-bold text-xs uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1"
              >
                <PhoneOff className="w-3 h-3" />
                End
              </button>
            </div>
          </div>

          {/* ── AUDIO CHANNELS & PROVIDER HEALTH STRIP ── */}
          <div className="bg-neo-cream border-2 border-neo-navy p-2.5 rounded flex flex-wrap items-center justify-between gap-2 text-xs">
            <div className="flex flex-wrap items-center gap-2">
              {/* SELLER Status */}
              <div
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded border-2 border-neo-navy font-bold text-[11px] ${
                  sellerStatus === 'live'
                    ? 'bg-emerald-100 text-emerald-900 border-emerald-800'
                    : sellerStatus === 'error'
                    ? 'bg-rose-100 text-rose-900 border-rose-800'
                    : 'bg-amber-100 text-amber-900 border-amber-800'
                }`}
                title={sellerReason}
              >
                <span
                  className={`w-2 h-2 rounded-full ${
                    sellerStatus === 'live'
                      ? 'bg-emerald-600 animate-pulse'
                      : sellerStatus === 'error'
                      ? 'bg-rose-600'
                      : 'bg-amber-500 animate-ping'
                  }`}
                />
                <span>SELLER audio: {sellerStatus}</span>
                {sellerStatus !== 'live' && (
                  <span className="text-[10px] font-normal opacity-90 hidden sm:inline">({sellerReason})</span>
                )}
              </div>

              {/* BUYER Status */}
              <div
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded border-2 border-neo-navy font-bold text-[11px] ${
                  buyerStatus === 'live'
                    ? 'bg-emerald-100 text-emerald-900 border-emerald-800'
                    : buyerStatus === 'error'
                    ? 'bg-rose-100 text-rose-900 border-rose-800'
                    : buyerStatus === 'inactive'
                    ? 'bg-gray-100 text-gray-700 border-gray-600'
                    : 'bg-amber-100 text-amber-900 border-amber-800'
                }`}
                title={buyerReason}
              >
                <span
                  className={`w-2 h-2 rounded-full ${
                    buyerStatus === 'live'
                      ? 'bg-emerald-600 animate-pulse'
                      : buyerStatus === 'error'
                      ? 'bg-rose-600'
                      : buyerStatus === 'inactive'
                      ? 'bg-gray-400'
                      : 'bg-amber-500 animate-ping'
                  }`}
                />
                <span>BUYER audio: {buyerStatus}</span>
                {buyerStatus !== 'live' && (
                  <span className="text-[10px] font-normal opacity-90 hidden sm:inline">({buyerReason})</span>
                )}
              </div>
            </div>

            {/* STT Provider Badge */}
            <div className="flex items-center gap-1.5 text-[11px] font-heading font-black text-neo-navy/80 bg-white px-2.5 py-1 border border-neo-navy rounded">
              <Zap className="w-3 h-3 text-neo-orange" />
              <span>STT: {sttProvider}</span>
            </div>
          </div>

          {/* ── HEADPHONES ECHO NOTICE ── */}
          <div className="bg-amber-50 border-2 border-amber-400/80 p-2 rounded text-xs flex items-center gap-2 text-amber-900 font-medium">
            <span className="text-sm">🎧</span>
            <span>
              <strong>Echo Prevention Tip:</strong> Wear headphones during your Google Meet call so your microphone does not pick up the buyer's voice from your speakers.
            </span>
          </div>

          {/* Transcript Stream Feed */}
          <div className="neo-card p-4 flex-1 flex flex-col h-[500px] sm:h-[560px] bg-white">
            <div className="flex items-center justify-between pb-2 border-b-2 border-neo-navy mb-3">
              <span className="font-heading font-black text-xs uppercase tracking-wider flex items-center gap-1.5">
                <Radio className="w-3.5 h-3.5 text-neo-orange animate-pulse" />
                Dual-Channel Live Conversation Feed
              </span>
              <span className="text-[10px] font-bold text-neo-navy/60 font-mono">
                {transcripts.length} utterances
              </span>
            </div>

            {/* Scrollable Transcript List (Memoized) */}
            <TranscriptFeed
              transcripts={transcripts}
              partialSellerText={partialSellerText}
              partialBuyerText={partialBuyerText}
              transcriptEndRef={transcriptEndRef}
            />

            {/* Manual Speech Injection Form */}
              <form onSubmit={handleSendManual} className="mt-3 pt-3 border-t-2 border-neo-navy flex gap-2">
                <select
                  value={typedSpeaker}
                  onChange={(e) => setTypedSpeaker(e.target.value)}
                  className="px-2 py-1.5 border-2 border-neo-navy bg-neo-cream font-heading font-bold text-xs uppercase"
                >
                  <option value="BUYER">Buyer Said</option>
                  <option value="SELLER">I Said</option>
                </select>

                <input
                  type="text"
                  placeholder="Type utterance (for testing or manual sync)..."
                  value={typedText}
                  onChange={(e) => setTypedText(e.target.value)}
                  className="flex-1 px-3 py-1.5 border-2 border-neo-navy bg-white text-xs font-medium focus:outline-hidden"
                />

                <button
                  type="submit"
                  className="px-3 py-1.5 bg-neo-orange border-2 border-neo-navy font-heading font-bold text-xs flex items-center gap-1 shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px]"
                >
                  <Send className="w-3 h-3" />
                  Inject
                </button>
              </form>
            </div>
          </section>

          {/* ── COLUMN 2: STRATEGIC ADVISORY & TACTICAL REPLIES (5 Cols) ── */}
          <section className="lg:col-span-5 flex flex-col gap-4">
            {/* Deal Likelihood Live Score Card */}
            <DealLikelihoodCard buyerScore={buyerScore} t={t} />

            {/* Live Buyer State Strip */}
            <BuyerStateStrip buyerState={buyerScore?.buyerState} t={t} />

            {/* NOW Zone: Engine Recommendation & Tactical Options */}
            <NowZone
              advisory={advisory}
              currentRound={currentRound}
              maxRounds={config.max_rounds}
              sellerIsSpeaking={sellerIsSpeaking}
              hasQueuedSuggestion={hasQueuedSuggestion}
              candidateLockDeal={candidateLockDeal}
              isDealLocked={isDealLocked}
              lockedDealData={lockedDealData}
              onOpenLockModal={() => setShowLockDealModal(true)}
              t={t}
            />

            {/* Live Reminders & Commitments Feed */}
            <RemindersCallStrip
              reminders={reminders}
              highlightedId={highlightedId}
              onUpdate={updateReminder}
              onDelete={deleteReminder}
              onSnooze={snoozeReminder}
              onMarkDone={markDoneReminder}
              onCreate={createReminder}
              onSendTest={sendTestReminder}
              timezone={reminderPrefs?.timezone || 'Asia/Kolkata'}
              t={t}
            />

            {/* PRANE-X Telemetry Gauges */}
            <div className="neo-card p-4 bg-white">
              <div className="text-[11px] font-heading font-black text-neo-navy/70 uppercase tracking-wider mb-3 flex items-center justify-between">
                <span>PRANE-X Engine Telemetry</span>
                <span className="font-mono text-[10px]">Round {currentRound} / {config.max_rounds}</span>
              </div>

              {advisory && advisory.metrics ? (
                <div className="space-y-3 text-xs">
                  {/* BBI (Buyer Bargaining Index) */}
                  <div>
                    <div className="flex justify-between font-heading font-bold mb-1">
                      <span>Buyer Bargaining Index (BBI)</span>
                      <span className="font-mono">{advisory.metrics.bbi} / 100</span>
                    </div>
                    <div className="w-full h-2.5 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden">
                      <div
                        className="h-full bg-neo-orange transition-all duration-300"
                        style={{ width: `${Math.min(100, advisory.metrics.bbi)}%` }}
                      />
                    </div>
                  </div>

                  {/* High WTP Probability */}
                  <div>
                    <div className="flex justify-between font-heading font-bold mb-1">
                      <span>P(High Willingness to Pay)</span>
                      <span className="font-mono">{(advisory.metrics.p_high_wtp * 100).toFixed(0)}%</span>
                    </div>
                    <div className="w-full h-2.5 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden">
                      <div
                        className="h-full bg-neo-teal transition-all duration-300"
                        style={{ width: `${Math.round(advisory.metrics.p_high_wtp * 100)}%` }}
                      />
                    </div>
                  </div>

                  {/* Surplus Budget Share */}
                  <div>
                    <div className="flex justify-between font-heading font-bold mb-1">
                      <span>Remaining Concession Budget</span>
                      <span className="font-mono">{(advisory.metrics.surplus_share * 100).toFixed(0)}%</span>
                    </div>
                    <div className="w-full h-2.5 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden">
                      <div
                        className="h-full bg-emerald-500 transition-all duration-300"
                        style={{ width: `${Math.round(advisory.metrics.surplus_share * 100)}%` }}
                      />
                    </div>
                  </div>

                  {/* Firmness / Stagnant indicators */}
                  <div className="grid grid-cols-2 gap-2 pt-1 border-t border-neo-navy/10">
                    <div className="bg-neo-cream/50 p-2 border border-neo-navy/30 rounded text-center">
                      <div className="text-[10px] text-neo-navy/60 font-heading font-bold uppercase">Firmness Level</div>
                      <div className="font-heading font-black text-sm text-neo-teal">
                        Level {advisory.metrics.firmness_level}
                      </div>
                    </div>
                    <div className="bg-neo-cream/50 p-2 border border-neo-navy/30 rounded text-center">
                      <div className="text-[10px] text-neo-navy/60 font-heading font-bold uppercase">Stagnant Rounds</div>
                      <div className="font-heading font-black text-sm text-neo-orange">
                        {advisory.metrics.consecutive_stagnant}
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-xs text-neo-navy/50 italic text-center py-4">
                  Metrics activate upon receiving the first buyer offer.
                </div>
              )}
            </div>
          </section>
        </main>
      )}

      {/* ── LOCK DEAL CONFIRMATION POPUP MODAL ── */}
      <LockDealModal
        isOpen={showLockDealModal}
        onClose={handleCloseModal}
        deal={candidateLockDeal}
        config={config}
        onLock={handleLockDeal}
        t={t}
      />
    </div>
  );
}
