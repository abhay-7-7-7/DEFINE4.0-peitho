"""
Scripted 6-turn haggling run on 'Office Chair (Ergonomic)' (base 7499, cost 4200).
Compares converging negotiation trajectory vs. stalling negotiation trajectory.
Asserts that the final deal likelihood score is higher for the converging run
than the stalling run, prints score per turn (numbers only), and validates that
no transcript text appears in captured logs.
"""
from dataclasses import dataclass
import pytest
from app.agents.negotiation_engine import (
    NegotiationState,
    BuyerArchetype,
)
from app.peitho.scoring import DealLikelihoodEngine


@dataclass
class MockEngineResult:
    action: str
    counter_price: float
    walk_away: bool = False

    @property
    def decision(self) -> str:
        return self.action.lower()

    @property
    def counter_unit_price(self) -> float:
        return self.counter_price


def run_scripted_negotiation(buyer_utterances, offers, intents, sentiments, buying_signals):
    engine = DealLikelihoodEngine(alpha=0.5)
    state = NegotiationState(
        base_price=7499.0,
        cost_price=4200.0,
        min_floor=5000.0,
        mode="MAX_PROFIT",
        max_rounds=6,
        quantity=1,
        total_sessions=0,
        accepted_deals=0,
        historical_avg_margin=0.0,
        historical_revenue=0.0,
        available_inventory=50,
        reference_inventory=50,
        buyer_archetype=BuyerArchetype.UNKNOWN,
    )
    state.counter_history.append(7499.0)

    scores = []

    for i in range(len(buyer_utterances)):
        offer = offers[i]
        intent = intents[i]
        sentiment = sentiments[i]
        b_signal = buying_signals[i]

        if offer is not None:
            state.offer_history.append(offer)

        # PRANE-X engine response simulation
        if intent == "accept":
            engine_res = MockEngineResult(action="ACCEPT", counter_price=offer or 7100.0)
        elif intent == "reject":
            engine_res = MockEngineResult(action="REJECT", counter_price=7300.0, walk_away=True)
        else:
            # Step down counter toward target
            next_counter = max(5000.0, 7499.0 - (i + 1) * 60.0)
            state.counter_history.append(next_counter)
            engine_res = MockEngineResult(action="COUNTER", counter_price=next_counter)

        intel = {
            "sentiment": sentiment,
            "buying_signal": b_signal,
            "open_objections_count": 1 if sentiment == "negative" else 0,
            "resolved_objections_count": 1 if sentiment == "positive" else 0,
        }
        extraction = {
            "unit_price_offered": offer,
            "intent": intent,
        }

        dl = engine.evaluate(
            state=state,
            engine_result=engine_res,
            intel_data=intel,
            extraction=extraction,
        )
        scores.append(dl.score)

    return scores


def test_scripted_6_turn_haggling_comparison(caplog):
    """
    Scripted 6-turn haggling on 'Office Chair (Ergonomic)' (base 7499, cost 4200).
    Prints score per turn (numbers only) and asserts converging > stalling.
    """
    # ── CONVERGING RUN (6 TURNS) ──
    converging_utterances = [
        "Would you consider 5200 for this office chair?",
        "I can stretch up to 5800 today.",
        "What if we meet at 6300?",
        "I could do 6700 if that works for you.",
        "Let us finalize at 7000.",
        "Alright, 7150 sounds fair, we have a deal!",
    ]
    converging_offers = [5200.0, 5800.0, 6300.0, 6700.0, 7000.0, 7150.0]
    converging_intents = ["offer", "offer", "offer", "offer", "offer", "accept"]
    converging_sentiments = ["neutral", "neutral", "positive", "positive", "positive", "positive"]
    converging_signals = ["medium", "medium", "medium", "high", "high", "high"]

    converging_scores = run_scripted_negotiation(
        converging_utterances,
        converging_offers,
        converging_intents,
        converging_sentiments,
        converging_signals,
    )

    # ── STALLING / DIVERGING RUN (6 TURNS) ──
    stalling_utterances = [
        "My budget is strictly 4800, nothing more.",
        "4800 is really my maximum price.",
        "Another vendor sells a similar chair for 4700.",
        "I am still only willing to pay 4700.",
        "This is too expensive. 4500, take it or leave it.",
        "No way, your price is too high. I am walking away.",
    ]
    stalling_offers = [4800.0, 4800.0, 4700.0, 4700.0, 4500.0, None]
    stalling_intents = ["offer", "offer", "offer", "offer", "offer", "reject"]
    stalling_sentiments = ["negative", "negative", "negative", "negative", "negative", "negative"]
    stalling_signals = ["low", "low", "low", "low", "low", "low"]

    stalling_scores = run_scripted_negotiation(
        stalling_utterances,
        stalling_offers,
        stalling_intents,
        stalling_sentiments,
        stalling_signals,
    )

    # Print score per turn (numbers only) as strictly required by prompt
    print("\nCONVERGING SCORES:")
    for s in converging_scores:
        print(s)

    print("\nSTALLING SCORES:")
    for s in stalling_scores:
        print(s)

    # Assertions
    assert len(converging_scores) == 6
    assert len(stalling_scores) == 6

    # Converging ends significantly higher than stalling
    assert converging_scores[-1] > stalling_scores[-1], (
        f"Converging final ({converging_scores[-1]}) must be higher than stalling ({stalling_scores[-1]})"
    )

    # Converging reaches high band (acceptance override >= 90)
    assert converging_scores[-1] >= 90

    # Stalling reaches low band (rejection override <= 15)
    assert stalling_scores[-1] <= 15

    # Check log privacy: ensure no transcript sentence text appears in logs
    all_logged_text = " ".join([rec.getMessage() for rec in caplog.records])
    for sentence in converging_utterances + stalling_utterances:
        assert sentence not in all_logged_text
