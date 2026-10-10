# Peitho Live Assistant — Real-Time WebSocket Protocol Specification

This document specifies the bidirectional WebSocket communication protocol between the Peitho frontend copilot and the TradeMind backend server at `/api/v1/peitho/ws/{session_id}`.

---

## 1. Connection & Lifecycle

- **Endpoint**: `/api/v1/peitho/ws/{session_id}`
- **Handshake**: Initiated by client after initializing a session via `POST /api/v1/peitho/start`.
- **Audio Format**: Mono PCM 16kHz, 16-bit little-endian, Base64-encoded, streamed in ~100ms chunks (3,200 bytes).

---

## 2. Inbound Messages (Client → Server)

### 2.1 Audio Chunk Stream (`audio`)
Streams raw voice audio from either the seller microphone or the buyer Google Meet browser tab.
```json
{
  "type": "audio",
  "channel": "SELLER", // "SELLER" (or "MIC") | "BUYER" (or "TAB")
  "data": "<base64_encoded_pcm16_16khz>"
}
```

### 2.2 Typed Transcript Line (`transcript_line`)
Direct textual injection for testing, manual synchronization, or zero-mic environments.
```json
{
  "type": "transcript_line",
  "channel": "BUYER", // "BUYER" | "SELLER"
  "text": "Could you do $400 for 2 units?",
  "is_final": true    // boolean: true for committed utterance, false for partial
}
```

### 2.3 Ping Keepalive (`ping`)
Synchronizes connection state and prevents reverse-proxy idle disconnects.
```json
{
  "type": "ping"
}
```

### 2.4 Lock Deal (`lock_deal`)
**Additive Event**. Sent by the seller to commit and finalize an agreed transaction when buyer terms are acceptable.
```json
{
  "type": "lock_deal",
  "agreed_price": 475.0
}
```

### 2.5 End Call (`end_call`)
Signals clean session termination by the human sales representative.
```json
{
  "type": "end_call"
}
```

---

## 3. Outbound Messages (Server → Client)

### 3.1 Initial Ready Ack (`ready`)
Sent immediately upon successful WebSocket handshake.
```json
{
  "type": "ready",
  "session_id": "36c3cb37-8081-40be-8976-7ee7cba3d438",
  "product_name": "High-Performance Cloud Compute Cluster",
  "base_price": 500.0,
  "current_counter": 500.0,
  "stt_provider": "ElevenLabsSTTAdapter",
  "language": "en",
  "message": "Connected to Peitho copilot. Audio capture active."
}
```

### 3.2 Dual-Channel Status (`state`)
Broadcasts channel state and connection health.
```json
{
  "type": "state",
  "stt_provider": "elevenlabs",
  "seller_status": "live",
  "seller_reason": "Connected to ElevenLabs Scribe",
  "buyer_status": "live",
  "buyer_reason": "Connected to ElevenLabs Scribe"
}
```

### 3.3 Partial Transcript (`partial_transcript`)
Real-time interim transcription hypothesis for live speech visualization.
```json
{
  "type": "partial_transcript",
  "channel": "BUYER", // "BUYER" | "SELLER"
  "text": "Can you offer"
}
```

### 3.4 Final Transcript (`final_transcript`)
VAD-committed speech segment. Subject to VAD merge guard (unpunctuated rapid fragments merged).
```json
{
  "type": "final_transcript",
  "id": "c869c025-a136-4767-8fd2-901b089c97b8",
  "channel": "BUYER",
  "text": "Can you offer 450 dollars?",
  "timestamp": 1728475200.123,
  "is_merged": false // true if combined with immediately preceding unpunctuated fragment
}
```

### 3.5 Live Deal Likelihood Score (`buyer_score`)
**Additive Event**. Emitted for every committed buyer final utterance, as well as provisional nudges during partial hypothesis recognition. Computes a deterministic, explainable probability of deal closure (0–100) combining price gap, concession velocity, engine telemetry, and conversational sentiment.
```json
{
  "type": "buyer_score",
  "call_id": "36c3cb37-8081-40be-8976-7ee7cba3d438",
  "turn": 1,
  "score": 68,
  "band": "medium",
  "trend": "up",
  "delta": 6,
  "confidence": "high",
  "provisional": false,
  "drivers": [
    {
      "text": "Offer rose twice in a row",
      "effect": "positive"
    },
    {
      "text": "Offer within 8% of asking quote",
      "effect": "positive"
    },
    {
      "text": "1 price objection unresolved",
      "effect": "negative"
    }
  ],
  "history": [
    {
      "round": 1,
      "score": 62
    },
    {
      "round": 2,
      "score": 68
    }
  ]
}
```

### 3.6 Stage 1 Immediate Advisory (`advisory`)
**Ultra-low-latency strategic recommendation (< 10ms from commit)**. Evaluates PRANE-X engine rules and produces instant deterministic template replies and structured options (`HOLD`, `BRIDGE`, `CLOSE`, `PROBE`) so the rep is never left waiting for an LLM.
```json
{
  "type": "advisory",
  "recommendation_id": "d981240a-5b12-4f81-9b7e-908b1a37c891",
  "source": "template",
  "seller_speaking": false,
  "timing": {
    "t0": 1728475199423.0,
    "t2": 1728475200123.0,
    "t5": 1728475200127.2,
    "t0_to_t2_ms": 700.0,
    "t2_to_t5_ms": 4.2
  },
  "data": {
    "action": "COUNTER",
    "counter_price": 475.0,
    "walk_away": false,
    "reasoning": "COMPROMISE_STEP (EXPLORATION Phase)",
    "extracted_buyer_offer": 450.0,
    "extracted_buyer_intent": "offer",
    "extracted_quantity": 1,
    "suggested_replies": [
      "I can meet you partway at $475.00 per unit if we can confirm the order today.",
      "How about we split the difference at $475.00? That keeps it workable on our end."
    ],
    "options": [
      {
        "text": "I can meet you partway at $475.00 per unit if we can confirm the order today.",
        "intent": "bridge",
        "why": "Offers reciprocal concession tied to rapid commitment.",
        "followup": "If buyer accepts, transition immediately to contract sign-off."
      },
      {
        "text": "At $475.00, you get our complete support package and guaranteed stock allocation.",
        "intent": "hold",
        "why": "Reinforces tangible product value to justify current position.",
        "followup": null
      },
      {
        "text": "What overall budget ceiling are you working with for this purchase?",
        "intent": "probe",
        "why": "Uncovers true financial parameters to guide subsequent rounds.",
        "followup": "If buyer specifies a realistic range, bridge with value-add options."
      }
    ],
    "buyer_score": 68,
    "buyer_score_band": "medium",
    "deal_lockable": true,
    "lockable_price": 475.0,
    "lock_reason": "Buyer offer meets or exceeds target quote",
    "metrics": {
      "bbi": 42.5,
      "p_high_wtp": 0.65,
      "surplus_share": 0.58,
      "buyer_concession_velocity": 0.0,
      "consecutive_stagnant": 0,
      "firmness_level": 1,
      "current_round": 1,
      "max_rounds": 6
    },
    "timestamp": 1728475200.127
  }
}
```

### 3.7 Stage 2 Asynchronous AI Upgrade (`recommendation_update`)
**Additive Event**. Pushed concurrently when OpenRouter / Gemini tactical generation completes. Upgrades spoken replies seamlessly without causing price card flicker. Features tactical intent classification and follow-up guidance.
```json
{
  "type": "recommendation_update",
  "recommendation_id": "d981240a-5b12-4f81-9b7e-908b1a37c891",
  "source": "ai",
  "suggested_replies": [
    "I can meet you at $475 if we can lock in shipment this afternoon.",
    "At $475 per cluster, our full enterprise support package is included."
  ],
  "options": [
    {
      "text": "I can meet you at $475 if we can lock in shipment this afternoon.",
      "intent": "bridge",
      "why": "Pairs price concession with same-day order commitment.",
      "followup": "If buyer requests net-60 payment terms, counter with net-30."
    },
    {
      "text": "At $475 per cluster, our full enterprise support package is included.",
      "intent": "hold",
      "why": "Defends quote by highlighting bundled services.",
      "followup": null
    },
    {
      "text": "What specific deployment timeline are you aiming for on your side?",
      "intent": "probe",
      "why": "Shifts conversation to delivery urgency.",
      "followup": null
    }
  ],
  "timing": {
    "t0": 1728475199423.0,
    "t2": 1728475200123.0,
    "t5": 1728475200127.2,
    "t7": 1728475200895.0,
    "t2_to_t7_ms": 772.0,
    "t0_to_t7_ms": 1472.0
  }
}
```

### 3.8 Seller Quote Synchronized (`seller_update`)
Emitted when the human rep verbalizes an explicit counter-offer, keeping PRANE-X master state in exact lockstep.
```json
{
  "type": "seller_update",
  "detected_price": 475.0,
  "current_counter": 475.0,
  "round": 1
}
```

### 3.8 Pong Keepalive (`pong`)
```json
{
  "type": "pong",
  "ts": 1728475201.554
}
```

### 3.9 Call Ended (`call_ended`)
```json
{
  "type": "call_ended",
  "session_id": "36c3cb37-8081-40be-8976-7ee7cba3d438"
}
```

### 3.10 Error Notification (`error`)
```json
{
  "type": "error",
  "message": "Session not found or expired"
}
```

### 3.11 Deal Locked Confirmation (`deal_locked`)
**Additive Event**. Broadcast when the seller locks the deal, terminating the session with committed transaction terms.
```json
{
  "type": "deal_locked",
  "call_id": "36c3cb37-8081-40be-8976-7ee7cba3d438",
  "agreed_price": 475.0,
  "quantity": 1,
  "total_value": 475.0,
  "timestamp": 1728475205.891
}
```

---

## 4. Live Reminders & Commitment Protocol (Additive)

### 4.1 Inbound: Client Reminder Action (`reminder_action`)
Sent by the seller from the live call copilot interface to confirm or dismiss a detected reminder.
```json
{
  "type": "reminder_action",
  "id": 42,
  "action": "confirm" // "confirm" | "dismiss"
}
```

### 4.2 Outbound: Reminder Detected (`reminder_detected`)
Pushed to the seller in real-time when the detection engine identifies a future commitment, callback, delivery, or meeting.
```json
{
  "type": "reminder_detected",
  "reminder": {
    "id": 42,
    "title": "Send revised pricing quote with volume tier",
    "note": "Mentioned palletized freight discount",
    "due_at": "2026-10-17T15:00:00+05:30",
    "all_day": false,
    "owner": "seller",
    "confidence": "high",
    "source": "detected",
    "needs_review": false,
    "time_assumed": false
  }
}
```

### 4.3 Outbound: Reminder Updated (`reminder_updated`)
Pushed whenever a reminder's time, title, or status is modified during or outside the call.
```json
{
  "type": "reminder_updated",
  "reminder": {
    "id": 42,
    "title": "Send revised pricing quote with volume tier",
    "due_at": "2026-10-17T16:00:00+05:30",
    "status": "active"
  }
}
```

### 4.4 Outbound: Reminder Deleted (`reminder_deleted`)
```json
{
  "type": "reminder_deleted",
  "id": 42
}
```

