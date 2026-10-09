import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Send,
  ShoppingBag,
  Sparkles,
  CheckCircle,
  AlertCircle,
  ArrowLeft,
  MessageSquare,
  ShieldCheck,
  Zap,
} from 'lucide-react';

function getBackendWsUrl(sessionId) {
  const envApi = import.meta.env.VITE_API_URL || import.meta.env.VITE_BACKEND_URL;
  if (envApi) {
    const http = envApi.replace(/\/+$/, '');
    const ws = http.replace(/^http/, 'ws');
    return `${ws}/api/v1/peitho/live-chat/ws/${sessionId}?role=buyer`;
  }
  // Connect via relative path through Vite proxy (works on any tunnel, LAN IP, or local host)
  const proto = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  return `${proto}//${window.location.host}/api/v1/peitho/live-chat/ws/${sessionId}?role=buyer`;
}

function getBackendHttpUrl(sessionId) {
  const envApi = import.meta.env.VITE_API_URL || import.meta.env.VITE_BACKEND_URL;
  if (envApi) {
    const http = envApi.replace(/\/+$/, '');
    return `${http}/api/v1/peitho/live-chat/${sessionId}?role=buyer`;
  }
  // Connect via relative path through Vite proxy
  return `/api/v1/peitho/live-chat/${sessionId}?role=buyer`;
}

export default function BuyerChatPage() {
  const { sessionId } = useParams();
  const navigate = useNavigate();

  const [sessionData, setSessionData] = useState(null);
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [connected, setConnected] = useState(false);
  const [sellerOnline, setSellerOnline] = useState(false);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const wsRef = useRef(null);
  const messagesEndRef = useRef(null);

  // Auto-scroll chat feed
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Initial HTTP fetch & WebSocket setup
  useEffect(() => {
    if (!sessionId) {
      setError('Invalid or missing session ID');
      setLoading(false);
      return;
    }

    // 1. Initial REST fetch
    fetch(getBackendHttpUrl(sessionId))
      .then((res) => {
        if (!res.ok) throw new Error('Live negotiation session not found or expired.');
        return res.json();
      })
      .then((data) => {
        setSessionData(data);
        if (data.messages) setMessages(data.messages);
        setSellerOnline(Boolean(data.seller_online));
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });

    // 2. Connect WebSocket
    const wsUrl = getBackendWsUrl(sessionId);
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      setConnected(true);
      setError(null);
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);

        if (data.type === 'init') {
          setSessionData({
            product_name: data.product_name,
            base_price: data.base_price,
            quantity: data.quantity,
          });
          if (data.messages) setMessages(data.messages);
          setSellerOnline(Boolean(data.seller_online));
        } else if (data.type === 'presence') {
          if (data.seller_online !== undefined) {
            setSellerOnline(data.seller_online);
          }
        } else if (data.type === 'new_message') {
          setMessages((prev) => {
            if (prev.some((m) => m.id === data.message.id)) return prev;
            return [...prev, data.message];
          });
        }
      } catch (e) {
        console.error('Failed to parse buyer message:', e);
      }
    };

    ws.onerror = () => {
      setError('Connection to negotiation room failed. Check server status.');
    };

    ws.onclose = () => {
      setConnected(false);
    };

    // Ping keepalive every 15s
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

  const handleQuickOffer = (offerText) => {
    setInputText(offerText);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-neo-cream flex items-center justify-center p-4 font-body">
        <div className="neo-card p-6 text-center max-w-sm w-full bg-white animate-pulse">
          <div className="w-10 h-10 border-4 border-neo-navy border-t-neo-orange rounded-full animate-spin mx-auto mb-3" />
          <h2 className="text-lg font-heading font-black text-neo-navy">Connecting to Seller...</h2>
          <p className="text-xs text-neo-navy/60 mt-1">Establishing direct negotiation channel</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-neo-cream flex items-center justify-center p-4 font-body">
        <div className="neo-card p-6 text-center max-w-sm w-full bg-white">
          <AlertCircle className="w-10 h-10 text-neo-maroon mx-auto mb-3" />
          <h2 className="text-lg font-heading font-black text-neo-navy">Unable to Connect</h2>
          <p className="text-xs text-neo-navy/70 mt-1 mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="w-full neo-btn neo-btn-orange text-xs py-2"
          >
            Retry Connection
          </button>
        </div>
      </div>
    );
  }

  const productName = sessionData?.product_name || 'Item in Negotiation';
  const basePrice = sessionData?.base_price || 0;
  const quantity = sessionData?.quantity || 1;

  return (
    <div className="min-h-screen bg-neo-cream text-neo-navy flex flex-col font-body max-w-md mx-auto sm:border-x-[3px] border-neo-navy shadow-2xl">
      {/* ── MOBILE HEADER ── */}
      <header className="sticky top-0 z-30 bg-neo-cream border-b-[3px] border-neo-navy px-4 py-3 shadow-xs">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-sm bg-neo-orange border-2 border-neo-navy flex items-center justify-center shadow-[1px_1px_0px_#001524]">
              <ShoppingBag className="w-4 h-4 text-neo-navy" />
            </div>
            <div>
              <h1 className="text-sm font-heading font-black leading-tight truncate max-w-[200px]">
                {productName}
              </h1>
              <span className="text-[10px] text-neo-navy/60 font-mono font-semibold">
                Qty: {quantity} unit{quantity > 1 ? 's' : ''}
              </span>
            </div>
          </div>

          {/* Seller Presence Chip */}
          <div
            className={`px-2 py-0.5 rounded-full border-2 border-neo-navy text-[10px] font-heading font-bold flex items-center gap-1 shadow-[1px_1px_0px_#001524] ${
              sellerOnline ? 'bg-emerald-300 text-neo-navy' : 'bg-amber-200 text-neo-navy'
            }`}
          >
            <span
              className={`w-2 h-2 rounded-full ${
                sellerOnline ? 'bg-emerald-600 animate-pulse' : 'bg-amber-600'
              }`}
            />
            {sellerOnline ? 'Seller Online' : 'Seller Away'}
          </div>
        </div>

        {/* Listed Price Strip */}
        <div className="bg-white border-2 border-neo-navy rounded p-2 flex items-center justify-between text-xs shadow-[2px_2px_0px_#001524]">
          <span className="text-neo-navy/70 font-heading font-bold text-[11px] uppercase">
            Official Listed Price
          </span>
          <span className="font-heading font-black text-sm text-neo-teal">
            ${basePrice.toFixed(2)}
          </span>
        </div>
      </header>

      {/* ── CHAT MESSAGE STREAM ── */}
      <main className="flex-1 p-3 overflow-y-auto space-y-3 bg-neo-cream/40">
        <div className="bg-neo-teal/10 border-2 border-neo-teal/50 p-2.5 rounded text-[11px] text-neo-navy/80 flex items-start gap-2 shadow-[1px_1px_0px_#001524]">
          <ShieldCheck className="w-4 h-4 text-neo-teal shrink-0 mt-0.5" />
          <span>
            You are in a live, direct negotiation with the verified seller. State your offer or ask questions below.
          </span>
        </div>

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

          const isBuyer = m.sender === 'buyer';

          return (
            <div
              key={m.id}
              className={`flex flex-col ${isBuyer ? 'items-end' : 'items-start'} animate-in fade-in`}
            >
              <div className="flex items-center gap-1 mb-0.5 px-1">
                <span
                  className={`text-[9px] font-heading font-black uppercase px-1 rounded border border-neo-navy ${
                    isBuyer ? 'bg-neo-orange text-neo-navy' : 'bg-neo-teal text-white'
                  }`}
                >
                  {isBuyer ? 'You' : 'Seller'}
                </span>
                <span className="text-[9px] text-neo-navy/50 font-mono">
                  {new Date(m.timestamp * 1000).toLocaleTimeString([], {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </span>
              </div>

              <div
                className={`max-w-[85%] p-3 border-2 border-neo-navy font-medium text-xs sm:text-sm leading-relaxed shadow-[2px_2px_0px_#001524] ${
                  isBuyer
                    ? 'bg-neo-orange/20 text-neo-navy rounded-tl-lg rounded-bl-lg rounded-tr-xs'
                    : 'bg-white text-neo-navy rounded-tr-lg rounded-br-lg rounded-tl-xs'
                }`}
              >
                {m.text}
              </div>
            </div>
          );
        })}

        <div ref={messagesEndRef} />
      </main>

      {/* ── QUICK OFFER PROMPTS ── */}
      <div className="bg-neo-cream px-3 py-1.5 border-t-2 border-neo-navy flex gap-1.5 overflow-x-auto no-scrollbar">
        <button
          onClick={() => handleQuickOffer(`Can you do $${(basePrice * 0.85).toFixed(0)}?`)}
          className="whitespace-nowrap px-2 py-1 bg-white border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-orange/20 rounded shadow-[1px_1px_0px_#001524]"
        >
          💡 Offer ${(basePrice * 0.85).toFixed(0)}
        </button>
        <button
          onClick={() => handleQuickOffer(`Can you do $${(basePrice * 0.9).toFixed(0)}?`)}
          className="whitespace-nowrap px-2 py-1 bg-white border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-orange/20 rounded shadow-[1px_1px_0px_#001524]"
        >
          💡 Offer ${(basePrice * 0.9).toFixed(0)}
        </button>
        <button
          onClick={() => handleQuickOffer("What's your best final price if I buy today?")}
          className="whitespace-nowrap px-2 py-1 bg-white border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-orange/20 rounded shadow-[1px_1px_0px_#001524]"
        >
          🏷️ Best Final Price?
        </button>
        <button
          onClick={() => handleQuickOffer('Can you offer free expedited shipping?')}
          className="whitespace-nowrap px-2 py-1 bg-white border border-neo-navy text-[10px] font-heading font-bold hover:bg-neo-orange/20 rounded shadow-[1px_1px_0px_#001524]"
        >
          📦 Shipping Discount?
        </button>
      </div>

      {/* ── INPUT BAR ── */}
      <footer className="sticky bottom-0 bg-white border-t-[3px] border-neo-navy p-3 shadow-lg">
        <form onSubmit={handleSendMessage} className="flex gap-2">
          <input
            type="text"
            placeholder="Type your message or offer..."
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            disabled={!connected}
            className="flex-1 px-3 py-2 border-2 border-neo-navy bg-neo-cream/50 text-xs sm:text-sm font-medium focus:outline-hidden focus:ring-2 focus:ring-neo-orange"
          />
          <button
            type="submit"
            disabled={!connected || !inputText.trim()}
            className="px-4 py-2 bg-neo-orange border-2 border-neo-navy font-heading font-black text-xs uppercase flex items-center justify-center gap-1 shadow-[2px_2px_0px_#001524] hover:translate-x-[1px] hover:translate-y-[1px] disabled:opacity-50"
          >
            <Send className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Send</span>
          </button>
        </form>
      </footer>
    </div>
  );
}
