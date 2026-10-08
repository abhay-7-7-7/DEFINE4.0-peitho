import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized motion design tokens and animation helpers for BoldKit Neubrutalism.
class BkMotion {
  BkMotion._();

  // ── Durations ─────────────────────────────────────────────────────────────
  /// Tactile press push duration (80-120ms).
  static const Duration press = Duration(milliseconds: 90);

  /// Desktop / Web hover lift duration.
  static const Duration hover = Duration(milliseconds: 140);

  /// Staggered entrance reveal duration.
  static const Duration reveal = Duration(milliseconds: 380);

  /// Stagger delay between sequential items.
  static const Duration staggerDelay = Duration(milliseconds: 55);

  /// Route / Page transition duration.
  static const Duration pageTransition = Duration(milliseconds: 260);

  /// Tab content switch duration.
  static const Duration tabSwitch = Duration(milliseconds: 200);

  /// Numeric count-up duration for stat counters.
  static const Duration counter = Duration(milliseconds: 1100);

  /// Pulsing badge cycle duration.
  static const Duration badgePulse = Duration(milliseconds: 1400);

  /// Carousel slide transition duration.
  static const Duration carouselSlide = Duration(milliseconds: 350);

  /// Shake feedback on input validation error.
  static const Duration errorShake = Duration(milliseconds: 400);

  // ── Curves ───────────────────────────────────────────────────────────────
  /// Snappy deceleration for brutalist push and release.
  static const Curve pressCurve = Curves.easeOut;

  /// Smooth ease-out for element reveals.
  static const Curve revealCurve = Curves.easeOutCubic;

  /// Tactile bounce for celebrations, favorites, and popover appearances.
  static const Curve bounce = Curves.elasticOut;

  /// High-velocity spring-like cubic.
  static const Curve snappy = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Smooth linear for continuous rotations or tickers.
  static const Curve linear = Curves.linear;

  // ── Haptic feedback helpers ──────────────────────────────────────────────
  /// Subtle tactile click for standard buttons, chips, and toggles.
  static void hapticClick() {
    HapticFeedback.selectionClick();
  }

  /// Light impact for cards, modals, and list selections.
  static void hapticLight() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for destructive actions, errors, and celebrations.
  static void hapticMedium() {
    HapticFeedback.mediumImpact();
  }

  /// Checks whether animations are disabled in the environment.
  static bool shouldAnimate(BuildContext context) {
    return !MediaQuery.disableAnimationsOf(context);
  }
}
