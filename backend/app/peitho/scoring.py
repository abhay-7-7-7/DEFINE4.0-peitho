"""
Deal Likelihood Scoring Engine — Live, explainable probability of deal closure (0-100).

A deterministic, multi-factor blend incorporating:
1. Price gap and proximity dynamics.
2. Buyer trajectory, concession velocity, and manipulation signals.
3. PRANE-X engine state (BBI, P(High WTP), ZOPA, firmness, round budget).
4. Conversational intel signals (sentiment, buying signals, objections, urgency).
5. Hard overrides for accept, walk-away, and unanchored openings.
6. Exponential moving average (EMA) smoothing and intra-turn provisional nudges.

PII & SECRECY RULES:
- Never log transcript text or audio. Log only scores, timings, counts, and codes.
- Keep all state in memory.
- UI label is "Deal likelihood (estimate)" — deterministic heuristic, not statistical claim.
"""
from __future__ import annotations

import re
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field
import structlog

from ..agents.negotiation_engine import NegotiationState, EngineResult

logger = structlog.get_logger(__name__)

# ═══════════════════════════════════════════════════════════════════════════════
# SCORING CONFIGURATION (Single tunable dictionary — independent of engine TUNING)
# ═══════════════════════════════════════════════════════════════════════════════

SCORING_WEIGHTS: Dict[str, Any] = {
    # ── Master component weights (sum to 1.0) ──
    "w_price_gap": 0.35,
    "w_trajectory": 0.25,
    "w_engine": 0.20,
    "w_intel": 0.20,

    # ── Smoothing ──
    "ema_alpha": 0.50,            # Moving average smoothing factor
    "provisional_nudge": 4.0,     # Intra-turn provisional keyword nudge (+/-)

    # ── Neutral baseline ──
    "neutral_score": 50,

    # ── Hard overrides ──
    "override_accept_score": 94,
    "override_reject_score": 7,

    # ── Price gap breakpoints ──
    # ratio = buyer_offer / counter_price
    "gap_close_threshold": 0.96,   # >= 96% of counter -> high likelihood
    "gap_fair_threshold": 0.88,    # >= 88% of counter -> fair zone
    "gap_wide_threshold": 0.75,    # < 75% of counter -> wide gap

    # ── Trajectory penalties & rewards ──
    "concession_rising_reward": 18.0,
    "concession_flat_penalty": 10.0,
    "concession_falling_penalty": 25.0,
    "stagnant_penalty_per_round": 10.0,
    "grind_penalty_per_round": 8.0,
    "retrograde_penalty_per_event": 16.0,
    "manipulation_penalty_per_event": 12.0,

    # ── Engine telemetry weights ──
    "bbi_weight": 0.40,
    "wtp_weight": 0.35,
    "round_urgency_weight": 0.25,

    # ── Intel conversational weights ──
    "sentiment_positive": 15.0,
    "sentiment_negative": -18.0,
    "buying_signal_high": 20.0,
    "buying_signal_medium": 0.0,
    "buying_signal_low": -16.0,
    "objection_open_penalty": 10.0,
    "objection_resolved_bonus": 8.0,
    "urgency_bonus": 10.0,
    "commitment_bonus": 14.0,
    "competitor_threat_penalty": -12.0,
}


@dataclass
class ScoreDriver:
    """A plain-language driver explaining what influenced the score."""
    text: str
    effect: str  # "positive" | "negative"
    magnitude: float = 0.0


@dataclass
class DealLikelihoodResult:
    """Deterministic Deal Likelihood score result."""
    score: int
    band: str                     # "low" | "medium" | "high"
    trend: str                    # "up" | "flat" | "down"
    delta: int                    # Change since prior turn
    confidence: str               # "low" | "medium" | "high"
    provisional: bool             # True during partial audio/text nudges
    drivers: List[Dict[str, str]] # Top 3 plain-language reasons
    history: List[Dict[str, int]] # Round-by-round history for sparkline
    not_enough_data: bool = False


# Quick provisional signal keywords for intra-turn partial speech
PROVISIONAL_POSITIVE_KEYWORDS = (
    "deal", "agree", "take it", "fair", "close", "works", "ready",
    "done", "lock in", "sounds good", "sold", "let's do it", "lets do it",
    "मंजूर", "हाँ", "deal done", "pakka"
)

PROVISIONAL_NEGATIVE_KEYWORDS = (
    "too high", "expensive", "walk away", "no way", "impossible",
    "pass", "cannot", "can't", "cant", "too much", "no deal", "forget it",
    "बहुत महंगा", "nahi hoga", "nahi ho payega"
)


class DealLikelihoodEngine:
    """
    In-memory Deal Likelihood scoring engine per session.
    Calculates deterministic, smoothed probability of deal closure.
    """

    def __init__(
        self,
        session_id: str = "default",
        weights: Optional[Dict[str, Any]] = None,
        alpha: Optional[float] = None,
    ):
        self.session_id = session_id
        self.weights = dict(weights or SCORING_WEIGHTS)
        if alpha is not None:
            self.weights["ema_alpha"] = float(alpha)
        self.last_score: Optional[int] = None
        self.last_raw_score: float = float(self.weights["neutral_score"])
        self.history: List[Dict[str, int]] = []  # [{"round": r, "score": s}]
        self.turn_count: int = 0

    def compute_provisional_nudge(self, partial_text: str) -> Optional[DealLikelihoodResult]:
        """
        Produce a fast, intra-turn provisional score adjustment from partial speech.
        Marks provisional=True until the final utterance is received.
        """
        if not partial_text or self.last_score is None:
            return None

        text_lower = partial_text.lower()
        nudge = float(self.weights.get("provisional_nudge", 4.0))

        has_positive = any(kw in text_lower for kw in PROVISIONAL_POSITIVE_KEYWORDS)
        has_negative = any(kw in text_lower for kw in PROVISIONAL_NEGATIVE_KEYWORDS)

        if not has_positive and not has_negative:
            return None

        current = self.last_score
        if has_positive and not has_negative:
            prov_score = min(98, current + int(nudge))
            prov_driver = ScoreDriver(text="Positive buying sentiment in speech", effect="positive", magnitude=nudge)
        elif has_negative and not has_positive:
            prov_score = max(5, current - int(nudge))
            prov_driver = ScoreDriver(text="Price resistance voiced in speech", effect="negative", magnitude=nudge)
        else:
            return None

        delta = prov_score - current
        trend = "up" if delta > 0 else ("down" if delta < 0 else "flat")
        band = "high" if prov_score >= 70 else ("medium" if prov_score >= 40 else "low")

        return DealLikelihoodResult(
            score=prov_score,
            band=band,
            trend=trend,
            delta=delta,
            confidence="low",
            provisional=True,
            drivers=[{"text": prov_driver.text, "effect": prov_driver.effect}],
            history=list(self.history),
            not_enough_data=False,
        )

    def evaluate(
        self,
        state: NegotiationState,
        engine_result: Optional[EngineResult] = None,
        intel_data: Optional[Dict[str, Any]] = None,
        extraction: Optional[Dict[str, Any]] = None,
    ) -> DealLikelihoodResult:
        """
        Calculate full, deterministic Deal Likelihood score for a completed turn.
        """
        self.turn_count += 1
        w = self.weights
        drivers: List[ScoreDriver] = []
        signals_available = 0

        # Retrieve offers & counters
        offers = list(state.offer_history)
        counters = list(state.counter_history)
        current_counter = (
            engine_result.counter_unit_price
            if engine_result and getattr(engine_result, "counter_unit_price", None) is not None
            else (counters[-1] if counters else state.base_price)
        )
        current_round = getattr(engine_result, "round_number", state.current_round)
        max_rounds = state.max_rounds

        # Intent detection from extraction/engine
        ext_intent = (extraction or {}).get("intent", "conversational")
        eng_decision = (
            str(getattr(engine_result, "decision", "")).lower()
            if engine_result else ""
        )
        is_terminated = bool(getattr(engine_result, "session_terminated", False))

        # ═════════════════════════════════════════════════════════════════════
        # 1. HARD OVERRIDES (Instant decisive states)
        # ═════════════════════════════════════════════════════════════════════
        if eng_decision == "accept" or ext_intent == "accept":
            final_score = int(w["override_accept_score"])
            drivers.append(ScoreDriver(text="Agreement reached on price and terms", effect="positive", magnitude=50.0))
            return self._finalize_score(final_score, drivers, signals_count=8, current_round=current_round, hard_override=True)

        if is_terminated or eng_decision in ("reject", "session_terminated") or ext_intent == "reject":
            final_score = int(w["override_reject_score"])
            drivers.append(ScoreDriver(text="Negotiation terminated or firmly rejected", effect="negative", magnitude=50.0))
            return self._finalize_score(final_score, drivers, signals_count=8, current_round=current_round, hard_override=True)

        # ═════════════════════════════════════════════════════════════════════
        # 2. NO PRICE ON TABLE YET (Neutral state with not_enough_data)
        # ═════════════════════════════════════════════════════════════════════
        if not offers:
            drivers.append(ScoreDriver(text="No opening price offer from buyer yet", effect="negative", magnitude=10.0))
            final_score = int(w["neutral_score"])
            return self._finalize_score(
                final_score,
                drivers,
                signals_count=1,
                current_round=current_round,
                not_enough_data=True,
                hard_override=True,
            )

        # ═════════════════════════════════════════════════════════════════════
        # 3. COMPONENT A: PRICE GAP SIGNAL (0 - 100)
        # ═════════════════════════════════════════════════════════════════════
        latest_offer = offers[-1]
        price_gap = max(0.0, current_counter - latest_offer)
        price_ratio = latest_offer / max(current_counter, 0.01)
        signals_available += 1

        # Base price gap score from offer/counter ratio
        if price_ratio >= w["gap_close_threshold"]:
            gap_score = 92.0 + min(8.0, (price_ratio - w["gap_close_threshold"]) * 100)
            drivers.append(ScoreDriver(text=f"Offer within {round((1 - price_ratio) * 100)}% of asking quote", effect="positive", magnitude=25.0))
        elif price_ratio >= w["gap_fair_threshold"]:
            gap_score = 68.0 + (price_ratio - w["gap_fair_threshold"]) / (w["gap_close_threshold"] - w["gap_fair_threshold"]) * 24.0
            drivers.append(ScoreDriver(text="Offer is in the reasonable bargaining zone", effect="positive", magnitude=14.0))
        elif price_ratio >= w["gap_wide_threshold"]:
            gap_score = 38.0 + (price_ratio - w["gap_wide_threshold"]) / (w["gap_fair_threshold"] - w["gap_wide_threshold"]) * 30.0
            drivers.append(ScoreDriver(text="Substantial price gap remains to close", effect="negative", magnitude=12.0))
        else:
            gap_score = max(5.0, price_ratio * 45.0)
            drivers.append(ScoreDriver(text="Buyer offer is significantly below floor zone", effect="negative", magnitude=22.0))

        # Gap movement trend (gap shrinking vs widening)
        if len(offers) >= 2 and len(counters) >= 2:
            prev_gap = max(0.0, counters[-2] - offers[-2])
            curr_gap = max(0.0, counters[-1] - offers[-1])
            if curr_gap < prev_gap - 0.5:
                gap_score = min(100.0, gap_score + 10.0)
                drivers.append(ScoreDriver(text="Price gap narrowed since last turn", effect="positive", magnitude=10.0))
            elif curr_gap > prev_gap + 0.5:
                gap_score = max(0.0, gap_score - 10.0)
                drivers.append(ScoreDriver(text="Price gap widened this turn", effect="negative", magnitude=10.0))

        # ═════════════════════════════════════════════════════════════════════
        # 4. COMPONENT B: TRAJECTORY & CONCESSIONS (0 - 100)
        # ═════════════════════════════════════════════════════════════════════
        traj_score = 50.0
        signals_available += 1

        # Last 3 offers movement
        if len(offers) >= 2:
            recent = offers[-3:] if len(offers) >= 3 else offers[-2:]
            is_rising = all(recent[i] < recent[i + 1] for i in range(len(recent) - 1))
            is_falling = any(recent[i] > recent[i + 1] for i in range(len(recent) - 1))
            is_flat = all(recent[i] == recent[i + 1] for i in range(len(recent) - 1))

            if is_rising:
                rising_steps = len(recent) - 1
                traj_score += float(w["concession_rising_reward"]) * (rising_steps / 2.0)
                drivers.append(ScoreDriver(
                    text="Offer rose twice in a row" if rising_steps >= 2 else "Buyer increased their offer",
                    effect="positive",
                    magnitude=18.0,
                ))
            elif is_falling:
                traj_score -= float(w["concession_falling_penalty"])
                drivers.append(ScoreDriver(text="Buyer retracted or lowered their offer", effect="negative", magnitude=22.0))
            elif is_flat:
                traj_score -= float(w["concession_flat_penalty"])
                drivers.append(ScoreDriver(text="Buyer repeated the same offer without conceding", effect="negative", magnitude=12.0))

        # Stagnation and grind penalties from engine state
        stagnant_cnt = getattr(state, "consecutive_stagnant", 0)
        if stagnant_cnt > 0:
            pen = stagnant_cnt * float(w["stagnant_penalty_per_round"])
            traj_score -= pen
            drivers.append(ScoreDriver(text=f"{stagnant_cnt} consecutive stagnant round{'s' if stagnant_cnt > 1 else ''}", effect="negative", magnitude=pen))

        grind_cnt = getattr(state, "consecutive_grind", 0)
        if grind_cnt > 0:
            pen = grind_cnt * float(w["grind_penalty_per_round"])
            traj_score -= pen
            drivers.append(ScoreDriver(text="Buyer is grinding in micro-increments", effect="negative", magnitude=pen))

        retro_cnt = getattr(state, "retrograde_count", 0)
        if retro_cnt > 0:
            pen = min(25.0, retro_cnt * float(w["retrograde_penalty_per_event"]))
            traj_score -= pen

        manip_cnt = getattr(state, "manipulation_events", 0)
        if manip_cnt > 0:
            pen = min(20.0, manip_cnt * float(w["manipulation_penalty_per_event"]))
            traj_score -= pen

        traj_score = max(0.0, min(100.0, traj_score))

        # ═════════════════════════════════════════════════════════════════════
        # 5. COMPONENT C: PRANE-X ENGINE SIGNALS (0 - 100)
        # ═════════════════════════════════════════════════════════════════════
        signals_available += 1
        bbi_val = float(getattr(engine_result, "bbi", state.bbi))
        wtp_val = float(getattr(engine_result, "p_high_wtp", state.p_high_wtp))

        # BBI contribution (0-100)
        bbi_score = bbi_val
        if bbi_val >= 68.0:
            drivers.append(ScoreDriver(text="High buyer bargaining cooperativeness (BBI)", effect="positive", magnitude=14.0))
        elif bbi_val < 35.0:
            drivers.append(ScoreDriver(text="Hostile or adversarial buyer posture detected", effect="negative", magnitude=16.0))

        # WTP contribution (0.05-0.95 -> 5-95)
        wtp_score = max(0.0, min(100.0, wtp_val * 100.0))
        if wtp_val >= 0.70:
            drivers.append(ScoreDriver(text="High estimated willingness to pay", effect="positive", magnitude=12.0))

        # Rounds urgency & budget
        rounds_left = max(0, max_rounds - current_round)
        if rounds_left <= 2:
            if price_ratio >= w["gap_fair_threshold"]:
                # High convergence near final rounds -> pressure aids deal close
                round_score = 75.0
                drivers.append(ScoreDriver(text=f"Closing phase: {rounds_left} round{'s' if rounds_left > 1 else ''} left with tight gap", effect="positive", magnitude=8.0))
            else:
                # Low convergence near final rounds -> risk of running out of time
                round_score = 25.0
                drivers.append(ScoreDriver(text=f"Only {rounds_left} round{'s' if rounds_left > 1 else ''} left with wide price gap", effect="negative", magnitude=15.0))
        else:
            round_score = 55.0

        engine_score = (
            w["bbi_weight"] * bbi_score +
            w["wtp_weight"] * wtp_score +
            w["round_urgency_weight"] * round_score
        )

        # Firmness and ZOPA adjustments
        firmness = getattr(state, "firmness_level", 0)
        if firmness >= 3:
            engine_score = max(0.0, engine_score - 15.0)
            drivers.append(ScoreDriver(text="Final-offer firmness reached (no further drops)", effect="negative", magnitude=15.0))
        elif firmness == 2:
            engine_score = max(0.0, engine_score - 6.0)

        zopa_no = getattr(state, "zopa_no_overlap_count", 0)
        if zopa_no > 0:
            engine_score = max(0.0, engine_score - min(20.0, zopa_no * 8.0))
            drivers.append(ScoreDriver(text="ZOPA overlap constraint strained", effect="negative", magnitude=10.0))

        engine_score = max(0.0, min(100.0, engine_score))

        # ═════════════════════════════════════════════════════════════════════
        # 6. COMPONENT D: CONVERSATION INTEL SIGNALS (0 - 100)
        # ═════════════════════════════════════════════════════════════════════
        intel_score = 50.0
        intel = intel_data or {}
        if intel:
            signals_available += 1
            sentiment = str(intel.get("sentiment", "neutral")).lower()
            buying_signal = str(intel.get("buying_signal", "medium")).lower()
            open_objections = int(intel.get("open_objections_count", 0))
            resolved_objections = int(intel.get("resolved_objections_count", 0))
            urgency_mentioned = bool(intel.get("urgency_signal", False))
            commitment_made = bool(intel.get("commitment_made", False))
            competitor_threat = bool(intel.get("competitor_mention", False))

            if sentiment == "positive":
                intel_score += float(w["sentiment_positive"])
                drivers.append(ScoreDriver(text="Buyer expressed positive sentiment", effect="positive", magnitude=12.0))
            elif sentiment in ("negative", "frustrated"):
                intel_score += float(w["sentiment_negative"])
                drivers.append(ScoreDriver(text="Buyer expressed frustration or resistance", effect="negative", magnitude=14.0))

            if buying_signal == "high":
                intel_score += float(w["buying_signal_high"])
                drivers.append(ScoreDriver(text="Strong buyer intent signals detected", effect="positive", magnitude=16.0))
            elif buying_signal == "low":
                intel_score += float(w["buying_signal_low"])
                drivers.append(ScoreDriver(text="Weak commercial interest from buyer", effect="negative", magnitude=12.0))

            if open_objections > 0:
                pen = open_objections * float(w["objection_open_penalty"])
                intel_score -= pen
                drivers.append(ScoreDriver(
                    text=f"{open_objections} price/term objection{'s' if open_objections > 1 else ''} unresolved",
                    effect="negative",
                    magnitude=pen,
                ))

            if resolved_objections > 0:
                bon = resolved_objections * float(w["objection_resolved_bonus"])
                intel_score += bon
                drivers.append(ScoreDriver(text="Key buyer objection successfully addressed", effect="positive", magnitude=bon))

            if urgency_mentioned:
                intel_score += float(w["urgency_bonus"])
                drivers.append(ScoreDriver(text="Buyer indicated delivery/time urgency", effect="positive", magnitude=10.0))

            if commitment_made:
                intel_score += float(w["commitment_bonus"])
                drivers.append(ScoreDriver(text="Buyer made verbal buying commitment", effect="positive", magnitude=14.0))

            if competitor_threat:
                intel_score += float(w["competitor_threat_penalty"])
                drivers.append(ScoreDriver(text="Competitor pricing leverage cited by buyer", effect="negative", magnitude=12.0))

        intel_score = max(0.0, min(100.0, intel_score))

        # ═════════════════════════════════════════════════════════════════════
        # 7. WEIGHTED BLEND & EMA SMOOTHING
        # ═════════════════════════════════════════════════════════════════════
        raw_score = (
            w["w_price_gap"] * gap_score +
            w["w_trajectory"] * traj_score +
            w["w_engine"] * engine_score +
            w["w_intel"] * intel_score
        )

        alpha = float(w["ema_alpha"])
        if self.last_score is None:
            smoothed = round(raw_score)
        else:
            smoothed = round(alpha * raw_score + (1.0 - alpha) * float(self.last_score))

        final_score = max(0, min(100, int(smoothed)))
        self.last_raw_score = raw_score

        return self._finalize_score(
            final_score,
            drivers,
            signals_count=signals_available,
            current_round=current_round,
            hard_override=False,
        )

    def _finalize_score(
        self,
        score: int,
        drivers: List[ScoreDriver],
        signals_count: int,
        current_round: int,
        hard_override: bool = False,
        not_enough_data: bool = False,
    ) -> DealLikelihoodResult:
        """Helper to format delta, trend, band, history, and top 3 drivers."""
        delta = 0 if self.last_score is None else (score - self.last_score)
        self.last_score = score

        # Record history per round
        round_entry = {"round": max(1, current_round + 1), "score": score}
        if not self.history or self.history[-1]["round"] != round_entry["round"]:
            self.history.append(round_entry)
        else:
            self.history[-1]["score"] = score

        # Trend & band
        trend = "up" if delta > 1 else ("down" if delta < -1 else "flat")
        if score >= 70:
            band = "high"
        elif score >= 40:
            band = "medium"
        else:
            band = "low"

        # Confidence label
        if not_enough_data:
            confidence = "low"
        elif signals_count >= 3 or hard_override:
            confidence = "high"
        elif signals_count >= 2:
            confidence = "medium"
        else:
            confidence = "low"

        # Top 3 drivers sorted by magnitude (largest impact first)
        drivers.sort(key=lambda d: d.magnitude, reverse=True)
        top_drivers: List[Dict[str, str]] = []
        seen_texts = set()
        for d in drivers:
            if d.text not in seen_texts:
                top_drivers.append({"text": d.text, "effect": d.effect})
                seen_texts.add(d.text)
            if len(top_drivers) >= 3:
                break

        # Fallback driver if list is empty
        if not top_drivers:
            top_drivers.append({"text": "Market positioning aligned with quote", "effect": "positive" if score >= 50 else "negative"})

        # Structured content-free log
        logger.info(
            "peitho_deal_likelihood_evaluated",
            turn=self.turn_count,
            round=current_round,
            score=score,
            delta=delta,
            band=band,
            trend=trend,
            confidence=confidence,
            provisional=False,
        )

        return DealLikelihoodResult(
            score=score,
            band=band,
            trend=trend,
            delta=delta,
            confidence=confidence,
            provisional=False,
            drivers=top_drivers,
            history=list(self.history),
            not_enough_data=not_enough_data,
        )
