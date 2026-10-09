import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Send,
  QrCode,
  Copy,
  Check,
  TrendingUp,
  AlertTriangle,
  Sparkles,
  ExternalLink,
  PhoneOff,
  User,
  ShoppingBag,
  Zap,
  Shield,
  Activity,
  ArrowRight,
  Info,
} from 'lucide-react';
import { generateQRCodeSVG } from '../lib/qrCode';

function getBackendUrls(sessionId) {
  const envApi = import.meta.env.VITE_API_URL || import.meta.env.VITE_BACKEND_URL;
  if (envApi) {
    const http = envApi.replace(/\/+$/, '');
    const ws = http.replace(/^http/, 'ws');
    return {
      http: `${http}/api/v1/peitho/live-chat/${sessionId}?role=seller`,
      ws: `${ws}/api/v1/peitho/live-chat/ws/${sessionId}?role=seller`,
      networkInfo: `${http}/api/v1/peitho/live-chat/network-info`,
    };
  }
  const proto = window.location.protocol;
  const host = window.location.hostname;
  return {
    http: `${proto}//${host}:8000/api/v1/peitho/live-chat/${sessionId}?role=seller`,
    ws: `${proto === 'https:' ? 'wss' : 'ws'}://${host}:8000/api/v1/peitho/live-chat/ws/${sessionId}?role=seller`,
    networkInfo: `${proto}//${host}:8000/api/v1/peitho/live-chat/network-info`,
  };
}

export default function LiveChatSeller({ sessionId: propSessionId, onEndChat, standalone = false }) {
  const routeParams = useParams();
  const sessionId = propSessionId || routeParams.sessionId;
  const navigate = useNavigate();

  const [sessionConfig, setSessionConfig] = useState(null);
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [connected, setConnected] = useState(false);
  const [buyerOnline, setBuyerOnline] = useState(false);
  const [error, setError] = useState(null);

  // Copilot State
  const [profitability, setProfitability] = useState(null);
  const [advisory, setAdvisory] = useState(null);
  const [currentRound, setCurrentRound] = useState(1);
  const [maxRounds, setMaxRounds] = useState(6);

  // Share Modal & Links
  const [showShareModal, setShowShareModal] = useState(false);
  const [buyerUrl, setBuyerUrl] = useState('');
  const [copiedLink, setCopiedLink] = useState(false);
  const [networkIp, setNetworkIp] = useState('');

  const wsRef = useRef(null);
  const chatEndRef = useRef(null);

  // Scroll chat feed
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Determine LAN IP and initial buyer link
  useEffect(() => {
    if (!sessionId) return;

    const urls = getBackendUrls(sessionId);

    // Fetch network info to get LAN IP
    fetch(urls.networkInfo)
      .then((res) => res.json())
      .then((info) => {
        const ip = info.local_ip || window.location.hostname;
        setNetworkIp(ip);
        const port = window.location.port ? `:${window.location.port}` : '';
        const url = `${window.location.protocol}//${ip}${port}/buyer-chat/${sessionId}`;
        setBuyerUrl(url);
      })
      .catch(() => {
        const fallback = `${window.location.origin}/buyer-chat/${sessionId}`;
        setBuyerUrl(fallback);
      });

    // Fetch initial session state
    fetch(urls.http)
      .then((res) => {
        if (!res.ok) throw new Error('Live chat session not found or expired.');
        return res.json();
      })
      .then((data) => {
        setSessionConfig(data.config);
        if (data.messages) setMessages(data.messages);
        if (data.last_profitability) setProfitability(data.last_profitability);
        if (data.last_advisory) setAdvisory(data.last_advisory);
        if (data.current_round) setCurrentRound(data.current_round);
        if (data.config?.max_rounds) setMaxRounds(data.config.max_rounds);
        setBuyerOnline(Boolean(data.buyer_online));
      })
      .catch((err) => {
        setError(err.message);
      });

    // Establish WebSocket connection
    const ws = new WebSocket(urls.ws);
    wsRef.current = ws;

    ws.onopen = () => {
      setConnected(true);
      setError(null);
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);

        if (data.type === 'init') {
          if (data.messages) setMessages(data.messages);
          if (data.last_profitability) setProfitability(data.last_profitability);
          if (data.last_advisory) setAdvisory(data.last_advisory);
          if (data.current_round) setCurrentRound(data.current_round);
          if (data.max_rounds) setMaxRounds(data.max_rounds);
          setBuyerOnline(Boolean(data.buyer_online));
        } else if (data.type === 'presence') {
          if (data.buyer_online !== undefined) {
            setBuyerOnline(data.buyer_online);
          }
        } else if (data.type === 'new_message') {
          setMessages((prev) => {
            if (prev.some((m) => m.id === data.message.id)) return prev;
            return [...prev, data.message];
          });
        } else if (data.type === 'advisory_update') {
          if (data.profitability) setProfitability(data.profitability);
          if (data.advisory) setAdvisory(data.advisory);
          if (data.current_round) setCurrentRound(data.current_round);
        } else if (data.type === 'recommendation_upgrade') {
          if (data.suggested_replies && advisory) {
            setAdvisory((prev) => ({
              ...prev,
              suggested_replies: data.suggested_replies,
              source: 'ai',
            }));
          }
        }
      } catch (e) {
        console.error('Failed to parse seller websocket message:', e);
      }
    };

    ws.onerror = () => {
      setError('Connection to Live Chat room failed.');
    };

    ws.onclose = () => {
      setConnected(false);
    };

    const pingInterval = setInterval(() => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ type: 'ping' }));
      }
    }, 15000);

    return () => {
      clearInterval(pingInterval);
      ws.close();
    };
  }, [sessionId]);

  const handleSendMessage = (e) => {
    if (e) e.preventDefault();
    const text = inputText.trim();
    if (!text || !wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) return;

    wsRef.current.send(
      JSON.stringify({
        type: 'chat_message',
        text: text,
      })
    );
    setInputText('');
  };

  const handleInsertReply = (replyText) => {
    setInputText(replyText);
  };

  const handleSendNowReply = (replyText) => {
    if (!wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) return;
    wsRef.current.send(
      JSON.stringify({
        type: 'chat_message',
        text: replyText,
      })
    );
  };

  const handleCopyLink = () => {
    navigator.clipboard.writeText(buyerUrl);
    setCopiedLink(true);
    setTimeout(() => setCopiedLink(false), 2000);
  };

  const handleOpenTestTab = () => {
    window.open(buyerUrl || `/buyer-chat/${sessionId}`, '_blank');
  };

  const qrData = buyerUrl ? generateQRCodeSVG(buyerUrl, 220) : null;

  return (
    <div className="flex-1 flex flex-col max-w-7xl mx-auto w-full p-2 sm:p-4 gap-3 font-body">
      {/* ── TOP HEADER / TOOLBAR ── */}
      <div className="neo-card p-3 sm:p-4 bg-white flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-sm bg-neo-teal border-2 border-neo-navy flex items-center justify-center text-neo-cream shadow-[2px_2px_0px_#001524]">
            <Zap className="w-5 h-5 text-neo-cream" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="font-heading font-black text-sm sm:text-base leading-tight">
                {sessionConfig?.product_name || 'Live Negotiation Workspace'}
              </h2>
              <span className="text-[10px] font-heading font-bold px-1.5 py-0.5 rounded bg-neo-orange border border-neo-navy uppercase">
                {sessionConfig?.mode || 'MAX_PROFIT'}
              </span>
            </div>
            <div className="flex items-center gap-3 text-xs text-neo-navy/70 mt-0.5">
              <span>
                Asking: <strong>${sessionConfig?.base_price?.toFixed(2)}</strong>
              </span>
              <span>•</span>
              <span>
                Cost: <strong>${sessionConfig?.cost_price?.toFixed(2)}</strong>
              </span>
              <span>•</span>
              <span>
                Floor: <strong>${sessionConfig?.min_floor?.toFixed(2)}</strong>
              </span>
            </div>
          </div>
        </div>

        {/* Presence & Actions */}
        <div className="flex items-center gap-2 sm:gap-3">
          {/* Buyer Presence Chip */}
          <div
            className={`px-3 py-1 rounded border-2 border-neo-navy font-heading font-bold text-xs flex items-center gap-1.5 shadow-[2px_2px_0px_#001524] ${
              buyerOnline ? 'bg-emerald-300 text-neo-navy' : 'bg-amber-200 text-neo-navy'
            }`}
          >
            <span
              className={`w-2.5 h-2.5 rounded-full ${
                buyerOnline ? 'bg-emerald-600 animate-pulse' : 'bg-amber-600'
              }`}
            />
            <span>{buyerOnline ? 'Buyer Connected 🟢' : 'Waiting for Buyer...'}</span>
          </div>

          {/* Invite Buyer Button */}
          <button
            onClick={() => setShowShareModal(true)}
            className="px-3 py-1.5 bg-neo-orange border-2 border-neo-navy font-heading font-bold text-xs flex items-center gap-1.5 shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px]"
            title="Show QR Code and shareable buyer link"
          >
            <QrCode className="w-4 h-4" />
            <span>Invite Buyer</span>
          </button>

          {/* End Chat Button */}
          <button
            onClick={onEndChat || (() => navigate('/meet-assistant'))}
            className="px-3 py-1.5 bg-neo-maroon text-neo-cream border-2 border-neo-navy font-heading font-bold text-xs uppercase shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] flex items-center gap-1"
          >
            <PhoneOff className="w-3.5 h-3.5" />
            <span>Close</span>
          </button>
        </div>
      </div>

      {/* ── ERROR ALERT ── */}
      {error && (
        <div className="bg-neo-maroon text-neo-cream p-2.5 rounded border-2 border-neo-navy text-xs font-semibold flex items-center justify-between">
          <span>⚠️ {error}</span>
          <button onClick={() => setError(null)} className="underline text-[10px]">
            Dismiss
          </button>
        </div>
      )}

      {/* ── 2-COLUMN SPLIT WORKSPACE ── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 flex-1">
        {/* ── COLUMN 1: LIVE CHAT STREAM WITH BUYER (7 COLS) ── */}
        <div className="lg:col-span-7 flex flex-col neo-card bg-white p-3 sm:p-4 h-[580px] sm:h-[640px]">
          {/* Chat Stream Header */}
          <div className="flex items-center justify-between pb-2 border-b-2 border-neo-navy mb-3">
            <span className="font-heading font-black text-xs uppercase tracking-wider flex items-center gap-1.5">
              <ShoppingBag className="w-4 h-4 text-neo-teal" />
              Live Conversation Feed
            </span>
            <span className="text-[10px] font-mono text-neo-navy/60 font-bold">
              Round {currentRound} of {maxRounds}
            </span>
          </div>

          {/* Messages Scroll Area */}
          <div className="flex-1 overflow-y-auto space-y-3 pr-1">
            {messages.length <= 1 && (
              <div className="h-full flex flex-col items-center justify-center text-center p-6 text-neo-navy/50">
                <QrCode className="w-10 h-10 mb-2 opacity-40 text-neo-orange animate-bounce" />
                <p className="font-heading font-bold text-sm">Waiting for buyer to connect...</p>
                <p className="text-xs max-w-xs mt-1">
                  Click <strong>"Invite Buyer"</strong> above to scan the QR code with your phone or open a test buyer tab.
                </p>
                <button
                  onClick={() => setShowShareModal(true)}
                  className="mt-3 px-3 py-1 bg-neo-orange border-2 border-neo-navy text-xs font-heading font-bold shadow-[2px_2px_0px_#001524]"
                >
                  Show QR Code & Link
                </button>
              </div>
            )}

            {messages.map((m) => {
              if (m.sender === 'system') {
                return (
                  <div key={m.id} className="text-center my-2">
                    <span className="text-[10px] bg-neo-cream border border-neo-navy/30 px-2.5 py-0.5 rounded-full text-neo-navy/60 font-mono">
                      {m.text}
                    </span>
                  </div>
                );
              }

              const isSeller = m.sender === 'seller';

              return (
                <div
                  key={m.id}
                  className={`flex flex-col ${isSeller ? 'items-end' : 'items-start'} animate-in fade-in`}
                >
                  <div className="flex items-center gap-1.5 mb-1 px-1">
                    <span
                      className={`text-[9px] font-heading font-black px-1.5 py-0.2 rounded border border-neo-navy ${
                        isSeller
                          ? 'bg-neo-teal text-neo-cream'
                          : 'bg-neo-orange text-neo-navy'
                      }`}
                    >
                      {isSeller ? 'YOU (SELLER)' : 'BUYER'}
                    </span>
                    <span className="text-[9px] text-neo-navy/50 font-mono">
                      {new Date(m.timestamp * 1000).toLocaleTimeString([], {
                        hour: '2-digit',
                        minute: '2-digit',
                        second: '2-digit',
                      })}
                    </span>
                  </div>

                  <div
                    className={`max-w-[85%] p-3 border-2 border-neo-navy font-medium text-xs sm:text-sm leading-relaxed shadow-[2px_2px_0px_#001524] ${
                      isSeller
                        ? 'bg-neo-cream text-neo-navy rounded-tl-lg rounded-bl-lg rounded-tr-xs'
                        : 'bg-white text-neo-navy rounded-tr-lg rounded-br-lg rounded-tl-xs'
                    }`}
                  >
                    {m.text}
                  </div>
                </div>
              );
            })}

            <div ref={chatEndRef} />
          </div>

          {/* Input Form */}
          <form onSubmit={handleSendMessage} className="mt-3 pt-3 border-t-2 border-neo-navy flex gap-2">
            <input
              type="text"
              placeholder="Type message to buyer, or click 'Insert' from AI suggestions..."
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              disabled={!connected}
              className="flex-1 px-3 py-2 border-2 border-neo-navy bg-white text-xs sm:text-sm font-medium focus:outline-hidden focus:ring-2 focus:ring-neo-orange"
            />
            <button
              type="submit"
              disabled={!connected || !inputText.trim()}
              className="px-4 py-2 bg-neo-teal text-neo-cream border-2 border-neo-navy font-heading font-black text-xs uppercase flex items-center gap-1 shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] disabled:opacity-50"
            >
              <Send className="w-3.5 h-3.5" />
              <span>Send</span>
            </button>
          </form>
        </div>

        {/* ── COLUMN 2: AI NEGOTIATION COPILOT & PROFITABILITY RADAR (5 COLS) ── */}
        <div className="lg:col-span-5 flex flex-col gap-3">
          {/* 1. PROFITABILITY & LOSS RADAR BOX */}
          <div className="neo-card p-4 bg-white relative overflow-hidden">
            <div className="flex items-center justify-between mb-2 pb-1.5 border-b-2 border-neo-navy">
              <span className="text-[11px] font-heading font-black text-neo-navy uppercase tracking-wider flex items-center gap-1">
                <TrendingUp className="w-4 h-4 text-neo-teal" />
                Live Profit & Loss Radar
              </span>

              {profitability && (
                <span
                  className={`px-2 py-0.5 rounded text-[10px] font-heading font-black border ${
                    profitability.status === 'PROFITABLE'
                      ? 'bg-emerald-100 text-emerald-900 border-emerald-400'
                      : profitability.status === 'ACCEPTABLE'
                      ? 'bg-blue-100 text-blue-900 border-blue-400'
                      : profitability.status === 'CONTROLLED_LOSS'
                      ? 'bg-amber-100 text-amber-900 border-amber-400'
                      : profitability.status === 'BELOW_FLOOR_VIOLATION'
                      ? 'bg-rose-100 text-rose-900 border-rose-500 animate-pulse'
                      : 'bg-gray-100 text-gray-700 border-gray-300'
                  }`}
                >
                  {profitability.status.replace(/_/g, ' ')}
                </span>
              )}
            </div>

            {/* Metrics Breakdown */}
            {profitability && profitability.detected_offer ? (
              <div className="space-y-2.5 text-xs">
                <div className="grid grid-cols-2 gap-2">
                  <div className="bg-neo-cream/60 p-2 border border-neo-navy/30 rounded">
                    <span className="text-[10px] text-neo-navy/60 font-heading font-bold uppercase block">
                      Buyer Offer
                    </span>
                    <span className="font-heading font-black text-base text-neo-navy">
                      ${profitability.detected_offer.toFixed(2)}
                    </span>
                  </div>

                  <div className="bg-neo-cream/60 p-2 border border-neo-navy/30 rounded">
                    <span className="text-[10px] text-neo-navy/60 font-heading font-bold uppercase block">
                      Net Unit Margin
                    </span>
                    <span
                      className={`font-heading font-black text-base ${
                        profitability.unit_profit >= 0 ? 'text-emerald-700' : 'text-rose-700'
                      }`}
                    >
                      {profitability.unit_profit >= 0 ? '+' : ''}${profitability.unit_profit?.toFixed(2)}{' '}
                      <span className="text-xs font-normal">({profitability.margin_pct}%)</span>
                    </span>
                  </div>
                </div>

                <div className="bg-neo-cream/30 p-2 border border-neo-navy/20 rounded flex justify-between items-center text-xs">
                  <span>
                    Total Deal Profit (Qty {profitability.detected_quantity || sessionConfig?.quantity}):
                  </span>
                  <span
                    className={`font-heading font-black text-sm ${
                      profitability.total_profit >= 0 ? 'text-emerald-700' : 'text-rose-700'
                    }`}
                  >
                    {profitability.total_profit >= 0 ? '+' : ''}${profitability.total_profit?.toFixed(2)}
                  </span>
                </div>

                {/* Explanation Banner */}
                <div
                  className={`p-2.5 rounded border text-xs font-medium ${
                    profitability.severity === 'critical'
                      ? 'bg-rose-50 text-rose-900 border-rose-300'
                      : profitability.severity === 'warning'
                      ? 'bg-amber-50 text-amber-900 border-amber-300'
                      : profitability.severity === 'success'
                      ? 'bg-emerald-50 text-emerald-900 border-emerald-300'
                      : 'bg-blue-50 text-blue-900 border-blue-200'
                  }`}
                >
                  {profitability.explanation}
                </div>
              </div>
            ) : (
              <div className="p-3 text-center text-xs text-neo-navy/60 italic bg-neo-cream/30 rounded border border-dashed border-neo-navy/20">
                Awaiting buyer's first offer or counter in chat to calculate real-time profitability.
              </div>
            )}
          </div>

          {/* 2. PRANE-X STRATEGIC ADVISORY & ACTION CARD */}
          <div className="neo-card p-4 bg-white">
            <div className="flex items-center justify-between mb-2 pb-1.5 border-b-2 border-neo-navy">
              <span className="text-[11px] font-heading font-black text-neo-navy uppercase tracking-wider flex items-center gap-1">
                <Zap className="w-4 h-4 text-neo-orange" />
                Strategic Copilot Action
              </span>

              {advisory && (
                <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-purple-100 text-purple-900 border border-purple-300 font-bold flex items-center gap-1">
                  <Sparkles className="w-3 h-3 text-purple-600" />
                  {advisory.source === 'ai' ? 'AI TACTICAL' : 'TEMPLATE'}
                </span>
              )}
            </div>

            {advisory ? (
              <div className="space-y-3">
                <div className="flex items-center justify-between gap-2">
                  <div
                    className={`px-3 py-1 border-[3px] border-neo-navy shadow-[2px_2px_0px_#001524] text-base font-heading font-black uppercase ${
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

                  <div className="text-right">
                    <span className="text-[10px] font-heading font-bold uppercase text-neo-navy/60 block">
                      Target Counter
                    </span>
                    <span className="font-heading font-black text-xl text-neo-navy">
                      ${advisory.counter_price.toFixed(2)}
                    </span>
                  </div>
                </div>

                <p className="text-xs text-neo-navy/80 bg-neo-cream p-2 border-2 border-neo-navy rounded font-medium">
                  💡 <strong>Strategy:</strong> {advisory.reasoning}
                </p>

                {/* 1-Click Tactical Suggested Replies */}
                <div>
                  <div className="text-[10px] font-heading font-black uppercase text-neo-navy mb-1.5 flex items-center gap-1">
                    <Sparkles className="w-3 h-3 text-neo-orange" />
                    Possible Replies (1-Click Actions):
                  </div>

                  <div className="space-y-2">
                    {advisory.suggested_replies?.map((rep, idx) => (
                      <div
                        key={idx}
                        className="p-2.5 bg-neo-cream/70 border-2 border-neo-navy rounded shadow-[2px_2px_0px_#001524] text-xs"
                      >
                        <p className="font-semibold text-neo-navy mb-2 leading-snug">"{rep}"</p>
                        <div className="flex gap-1.5 justify-end">
                          <button
                            onClick={() => handleInsertReply(rep)}
                            className="px-2 py-0.5 bg-white border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-orange/20 rounded shadow-[1px_1px_0px_#001524]"
                            title="Insert into chat box to edit"
                          >
                            📝 Insert
                          </button>
                          <button
                            onClick={() => handleSendNowReply(rep)}
                            className="px-2 py-0.5 bg-neo-teal text-neo-cream border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-teal/90 rounded shadow-[1px_1px_0px_#001524] flex items-center gap-1"
                            title="Send directly to buyer now"
                          >
                            ⚡ Send Now
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              <div className="p-3 text-center text-xs text-neo-navy/50 italic">
                AI recommendations will appear as soon as the buyer sends a message.
              </div>
            )}
          </div>

          {/* 3. TELEMETRY GAUGES */}
          <div className="neo-card p-3 bg-white text-xs">
            <div className="flex justify-between items-center mb-2 pb-1 border-b border-neo-navy/20 font-heading font-bold text-[10px] text-neo-navy/60 uppercase">
              <span>Negotiation Telemetry</span>
              <span>Round {currentRound} / {maxRounds}</span>
            </div>

            {advisory?.metrics ? (
              <div className="space-y-2">
                <div>
                  <div className="flex justify-between text-[11px] font-bold mb-0.5">
                    <span>Buyer Bargaining Index (BBI)</span>
                    <span>{advisory.metrics.bbi} / 100</span>
                  </div>
                  <div className="h-2 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden">
                    <div
                      className="h-full bg-neo-orange transition-all duration-300"
                      style={{ width: `${Math.min(100, advisory.metrics.bbi)}%` }}
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-[11px] font-bold mb-0.5">
                    <span>High Willingness to Pay</span>
                    <span>{(advisory.metrics.p_high_wtp * 100).toFixed(0)}%</span>
                  </div>
                  <div className="h-2 bg-neo-cream border border-neo-navy rounded-xs overflow-hidden">
                    <div
                      className="h-full bg-neo-teal transition-all duration-300"
                      style={{ width: `${Math.round(advisory.metrics.p_high_wtp * 100)}%` }}
                    />
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-[11px] text-neo-navy/50 italic text-center py-1">
                Telemetry activates on initial buyer utterance.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── SHARE BUYER LINK & QR CODE MODAL ── */}
      {showShareModal && (
        <div className="fixed inset-0 bg-neo-navy/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in">
          <div className="bg-neo-cream border-[3px] border-neo-navy max-w-md w-full p-6 shadow-neo-lg relative">
            <button
              onClick={() => setShowShareModal(false)}
              className="absolute top-4 right-4 w-7 h-7 border-2 border-neo-navy font-bold flex items-center justify-center hover:bg-neo-orange/20"
            >
              ✕
            </button>

            <h3 className="text-xl font-heading font-black text-neo-navy mb-1 flex items-center gap-2">
              <QrCode className="w-5 h-5 text-neo-orange" />
              Invite Buyer to Chat
            </h3>
            <p className="text-xs text-neo-navy/70 mb-4">
              Scan with your smartphone camera or open in another tab to chat as the buyer in real time.
            </p>

            {/* QR Code Display */}
            <div className="flex flex-col items-center justify-center p-4 bg-white border-2 border-neo-navy mb-4 rounded shadow-[2px_2px_0px_#001524]">
              {qrData?.imgUrl ? (
                <img
                  src={qrData.imgUrl}
                  alt="Buyer Chat QR Code"
                  className="w-48 h-48 border border-neo-navy/20"
                />
              ) : (
                <div className="w-48 h-48 flex items-center justify-center text-xs text-neo-navy/60">
                  Generating QR...
                </div>
              )}
              <span className="text-[11px] font-heading font-bold text-neo-navy/70 mt-2">
                Point Phone Camera to Connect Live
              </span>
            </div>

            {/* Shareable Link Box */}
            <div className="mb-4">
              <label className="block text-[10px] font-heading font-bold uppercase mb-1">
                Shareable Buyer URL
              </label>
              <div className="flex gap-2">
                <input
                  type="text"
                  readOnly
                  value={buyerUrl}
                  className="flex-1 px-2.5 py-1.5 border-2 border-neo-navy bg-white text-xs font-mono truncate"
                />
                <button
                  onClick={handleCopyLink}
                  className="px-3 py-1.5 bg-neo-orange border-2 border-neo-navy font-heading font-bold text-xs flex items-center gap-1 shadow-[2px_2px_0px_#001524]"
                >
                  {copiedLink ? <Check className="w-3.5 h-3.5 text-emerald-800" /> : <Copy className="w-3.5 h-3.5" />}
                  <span>{copiedLink ? 'Copied!' : 'Copy'}</span>
                </button>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="flex gap-2">
              <button
                onClick={handleOpenTestTab}
                className="flex-1 neo-btn bg-white hover:bg-neo-cream text-neo-navy text-xs py-2.5 flex items-center justify-center gap-1.5"
              >
                <ExternalLink className="w-3.5 h-3.5" />
                Open Test Tab (Desktop)
              </button>
              <button
                onClick={() => setShowShareModal(false)}
                className="flex-1 neo-btn neo-btn-teal text-xs py-2.5"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
