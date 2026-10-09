"""
Unit tests for Peitho tactical suggestions, anti-repetition memory,
and seller-speaking queueing mechanics.
"""
import pytest
from app.peitho.fallbacks import get_fallback_options
from app.peitho.intel import (
    SuggestedOption,
    SuggestionHistoryTracker,
    _validate_option_security,
)


def test_no_discounts_on_reject_or_final_offer():
    """For REJECT or FINAL_OFFER, suggestions defend price without offering further discounts."""
    # Test REJECT
    reject_opts = get_fallback_options(
        action="REJECT",
        counter_price=7000.0,
        quantity=1,
        firmness=3,
        buyer_offer=4500.0,
    )
    assert len(reject_opts) >= 1
    intents = [opt.intent.lower() for opt in reject_opts]
    # No concessions/bridge
    assert "bridge" not in intents
    assert all(i in ("hold", "close", "probe") for i in intents)
    for opt in reject_opts:
        lower_txt = opt.text.lower()
        assert "discount" not in lower_txt
        assert "lower" not in lower_txt

    # Test FINAL_OFFER
    final_opts = get_fallback_options(
        action="FINAL_OFFER",
        counter_price=6800.0,
        quantity=1,
        firmness=3,
        buyer_offer=6000.0,
    )
    assert len(final_opts) >= 1
    final_intents = [opt.intent.lower() for opt in final_opts]
    assert "bridge" not in final_intents


def test_only_facts_numbers_allowed():
    """Suggestions only include numbers present in FACTS (counter, buyer offer, quantity)."""
    counter_price = 7000.0
    buyer_offer = 6200.0
    quantity = 2

    # Valid options using only FACTS numbers
    opt_valid1 = SuggestedOption(
        text="We can provide 2 units at $7000 each.",
        intent="hold",
        why="Defending current counter",
    )
    opt_valid2 = SuggestedOption(
        text="Your offer of $6200 is noted, but our best is $7000.",
        intent="probe",
        why="Checking budget flexibility",
    )

    assert _validate_option_security(opt_valid1, counter_price, quantity, buyer_offer) is True
    assert _validate_option_security(opt_valid2, counter_price, quantity, buyer_offer) is True

    # Hallucinated numbers (e.g. 5500, 350) that are NOT in facts must be rejected
    opt_hallucinated1 = SuggestedOption(
        text="How about $5500 instead?",
        intent="bridge",
        why="Unauthorized discount",
    )
    opt_hallucinated2 = SuggestedOption(
        text="We can take off $350 today.",
        intent="bridge",
        why="Unauthorized discount",
    )

    assert _validate_option_security(opt_hallucinated1, counter_price, quantity, buyer_offer) is False
    assert _validate_option_security(opt_hallucinated2, counter_price, quantity, buyer_offer) is False


def test_anti_repetition_tracker_window():
    """Suggestions shown in the last 3 turns are recognized as repeated and excluded."""
    tracker = SuggestionHistoryTracker(window_turns=3)

    turn1_text1 = "Our price of $7000 reflects top tier build quality."
    turn1_text2 = "Could we include free warranty instead?"
    tracker.record_turn_options([turn1_text1, turn1_text2])

    # Repeated text must be flagged
    assert tracker.is_repeated(turn1_text1) is True
    assert tracker.is_repeated(turn1_text2) is True

    # Fresh novel text must not be flagged
    novel_text = "If we wrap this up today, $7000 secures priority dispatch."
    assert tracker.is_repeated(novel_text) is False

    # Simulate turns passing beyond window of 3 turns
    tracker.record_turn_options(["Turn 2 option A", "Turn 2 option B"])
    tracker.record_turn_options(["Turn 3 option A", "Turn 3 option B"])
    tracker.record_turn_options(["Turn 4 option A", "Turn 4 option B"])

    # Turn 1 text should now have aged out of the 3-turn window
    assert tracker.is_repeated(turn1_text1) is False


def test_seller_speaking_queueing_and_release():
    """Verify that when seller is speaking, suggestion is queued, and released when speaking finishes."""
    class MockCallContext:
        def __init__(self):
            self.seller_is_speaking = False
            self.active_advisory = None
            self.queued_advisory = None

        def receive_advisory(self, adv):
            if self.seller_is_speaking:
                self.queued_advisory = adv
            else:
                self.active_advisory = adv
                self.queued_advisory = None

        def seller_speech_ended(self):
            self.seller_is_speaking = False
            if self.queued_advisory:
                self.active_advisory = self.queued_advisory
                self.queued_advisory = None

    ctx = MockCallContext()
    # Turn 1: Seller not speaking
    adv1 = {"id": "rec-1", "action": "COUNTER", "counter_price": 7200.0}
    ctx.receive_advisory(adv1)
    assert ctx.active_advisory["id"] == "rec-1"
    assert ctx.queued_advisory is None

    # Turn 2: Seller speaks into mic
    ctx.seller_is_speaking = True
    adv2 = {"id": "rec-2", "action": "COUNTER", "counter_price": 6900.0}
    ctx.receive_advisory(adv2)
    # Active advisory unchanged to prevent card swap mid-sentence
    assert ctx.active_advisory["id"] == "rec-1"
    assert ctx.queued_advisory["id"] == "rec-2"

    # Seller pauses speech
    ctx.seller_speech_ended()
    assert ctx.active_advisory["id"] == "rec-2"
    assert ctx.queued_advisory is None
