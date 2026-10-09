"""
Unit tests for Peitho Deal Likelihood Scoring Engine (scoring.py).
Tests monotonic sanity, hard overrides, EMA smoothing bounds, neutral band,
and driver extraction.
"""
from dataclasses import dataclass
import pytest
from app.agents.negotiation_engine import (
    NegotiationState,
    BuyerArchetype,
)
from app.peitho.scoring import DealLikelihoodEngine, SCORING_WEIGHTS


@dataclass
class MockEngineResult:
    action: str
    counter_price: float
    walk_away: bool = False
    strategy_reasoning: str = ""

    @property
    def decision(self) -> str:
        return self.action.lower()

    @property
    def counter_unit_price(self) -> float:
        return self.counter_price


def make_state(
    base: float = 7499.0,
    cost: float = 4200.0,
    floor: float = 5000.0,
    rounds: int = 6,
) -> NegotiationState:
    st = NegotiationState(
        base_price=base,
        cost_price=cost,
        min_floor=floor,
        mode="MAX_PROFIT",
        max_rounds=rounds,
        quantity=1,
        total_sessions=0,
        accepted_deals=0,
        historical_avg_margin=0.0,
        historical_revenue=0.0,
        available_inventory=50,
        reference_inventory=50,
        buyer_archetype=BuyerArchetype.UNKNOWN,
    )
    st.counter_history.append(base)
    return st


def test_neutral_when_no_price_on_table():
    """When no price is on the table, score is in neutral band (50) with low confidence."""
    engine = DealLikelihoodEngine()
    state = make_state()
    res = MockEngineResult(
        action="COUNTER",
        counter_price=7200.0,
        strategy_reasoning="Initial counter",
    )
    result = engine.evaluate(
        state=state,
        engine_result=res,
        intel_data={"sentiment": "neutral", "buying_signal": "medium"},
        extraction={"unit_price_offered": None, "intent": "inquiry"},
    )
    assert 40 <= result.score <= 60
    assert result.confidence == "low"
    assert result.band == "medium"
    assert any("No opening price offer" in d["text"] for d in result.drivers)


def test_monotonic_sanity_rising_offers():
    """Rising buyer offers moving toward the counter raise the score."""
    engine = DealLikelihoodEngine()
    state = make_state()

    # Turn 1: Low offer 5200 against counter 7200
    state.offer_history.append(5200.0)
    res1 = MockEngineResult(action="COUNTER", counter_price=7200.0)
    score1 = engine.evaluate(
        state=state,
        engine_result=res1,
        intel_data={"sentiment": "neutral", "buying_signal": "medium", "open_objections_count": 1},
        extraction={"unit_price_offered": 5200.0, "intent": "offer"},
    ).score

    # Turn 2: Higher offer 6000 against counter 7000
    state.offer_history.append(6000.0)
    res2 = MockEngineResult(action="COUNTER", counter_price=7000.0)
    score2 = engine.evaluate(
        state=state,
        engine_result=res2,
        intel_data={"sentiment": "positive", "buying_signal": "medium", "open_objections_count": 0},
        extraction={"unit_price_offered": 6000.0, "intent": "offer"},
    ).score

    # Turn 3: Higher offer 6700 against counter 6850
    state.offer_history.append(6700.0)
    res3 = MockEngineResult(action="COUNTER", counter_price=6850.0)
    score3 = engine.evaluate(
        state=state,
        engine_result=res3,
        intel_data={"sentiment": "positive", "buying_signal": "high", "open_objections_count": 0},
        extraction={"unit_price_offered": 6700.0, "intent": "offer"},
    ).score

    assert score2 > score1, f"Expected score2 ({score2}) > score1 ({score1})"
    assert score3 > score2, f"Expected score3 ({score3}) > score2 ({score2})"


def test_stagnation_and_retrograde_lower_score():
    """Stagnation counters, retrograde offers, and unresolved objections lower the score."""
    engine = DealLikelihoodEngine()
    state = make_state()

    # Initial decent offer
    state.offer_history.append(6000.0)
    res1 = MockEngineResult(action="COUNTER", counter_price=7000.0)
    score1 = engine.evaluate(
        state=state,
        engine_result=res1,
        intel_data={"sentiment": "neutral", "buying_signal": "medium"},
        extraction={"unit_price_offered": 6000.0, "intent": "offer"},
    ).score

    # Stagnant offer + high objections + retrograde counter
    state.offer_history.append(5800.0)  # retrograde lower offer
    state.consecutive_stagnant = 2
    state.retrograde_count = 1
    res2 = MockEngineResult(action="COUNTER", counter_price=7000.0)
    score2 = engine.evaluate(
        state=state,
        engine_result=res2,
        intel_data={
            "sentiment": "negative",
            "buying_signal": "low",
            "open_objections_count": 3,
        },
        extraction={"unit_price_offered": 5800.0, "intent": "offer"},
    ).score

    assert score2 < score1, f"Expected score2 ({score2}) < score1 ({score1})"


def test_hard_override_accept():
    """Explicit acceptance language or ACCEPT action produces a score >= 90."""
    engine = DealLikelihoodEngine()
    state = make_state()
    res = MockEngineResult(action="ACCEPT", counter_price=6800.0)
    eval_res = engine.evaluate(
        state=state,
        engine_result=res,
        intel_data={"sentiment": "positive", "buying_signal": "high"},
        extraction={"unit_price_offered": 6800.0, "intent": "accept"},
    )
    assert eval_res.score >= 90
    assert eval_res.band == "high"
    assert any(d["effect"] == "positive" and ("agreement" in d["text"].lower() or "accepted" in d["text"].lower()) for d in eval_res.drivers)


def test_hard_override_walkaway_or_rejection():
    """Firm rejection or walk-away action produces a score <= 10."""
    engine = DealLikelihoodEngine()
    state = make_state()
    res = MockEngineResult(action="REJECT", counter_price=7000.0, walk_away=True)
    eval_res = engine.evaluate(
        state=state,
        engine_result=res,
        intel_data={"sentiment": "negative", "buying_signal": "low"},
        extraction={"unit_price_offered": 4000.0, "intent": "reject"},
    )
    assert eval_res.score <= 10
    assert eval_res.band == "low"
    assert any(d["effect"] == "negative" for d in eval_res.drivers)


def test_ema_smoothing_bounds():
    """EMA smoothing keeps score continuous and responsive without jitter."""
    engine = DealLikelihoodEngine(alpha=0.5)
    state = make_state()

    # Step 1: Raw score starts around 45
    state.offer_history.append(5000.0)
    res1 = MockEngineResult(action="COUNTER", counter_price=7000.0)
    s1 = engine.evaluate(
        state=state,
        engine_result=res1,
        intel_data={"sentiment": "neutral", "buying_signal": "medium"},
        extraction={"unit_price_offered": 5000.0, "intent": "offer"},
    ).score

    # Step 2: Jump offer to 6500. EMA with alpha 0.5 blends s1 and raw2
    state.offer_history.append(6500.0)
    res2 = MockEngineResult(action="COUNTER", counter_price=6800.0)
    s2 = engine.evaluate(
        state=state,
        engine_result=res2,
        intel_data={"sentiment": "positive", "buying_signal": "high"},
        extraction={"unit_price_offered": 6500.0, "intent": "offer"},
    ).score

    # Score increases smoothly, within valid [0, 100] range
    assert 0 <= s1 <= 100
    assert 0 <= s2 <= 100
    assert s2 > s1


def test_provisional_speech_nudges():
    """Provisional nudges slightly shift current score without corrupting EMA history."""
    engine = DealLikelihoodEngine()
    engine.last_score = 55

    # Positive nudge
    nudged_pos = engine.compute_provisional_nudge("deal sounds great we agree")
    assert nudged_pos is not None
    assert nudged_pos.score > 55
    assert nudged_pos.provisional is True

    # Negative nudge
    engine.last_score = 55
    nudged_neg = engine.compute_provisional_nudge("too high expensive cannot afford walk away")
    assert nudged_neg is not None
    assert nudged_neg.score < 55
    assert nudged_neg.provisional is True


def test_drivers_non_empty_and_match_signals():
    """Drivers list must contain up to 3 non-empty explanations with positive or negative effect."""
    engine = DealLikelihoodEngine()
    state = make_state()
    state.offer_history.extend([5500.0, 6000.0, 6400.0])
    res = MockEngineResult(action="COUNTER", counter_price=6800.0)
    result = engine.evaluate(
        state=state,
        engine_result=res,
        intel_data={"sentiment": "positive", "buying_signal": "high", "open_objections_count": 0},
        extraction={"unit_price_offered": 6400.0, "intent": "offer"},
    )
    assert 1 <= len(result.drivers) <= 3
    for driver in result.drivers:
        assert "text" in driver and len(driver["text"]) > 0
        assert driver["effect"] in ("positive", "negative")
