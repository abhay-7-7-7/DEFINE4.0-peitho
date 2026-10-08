import 'package:flutter/material.dart';

/// BkTokens — Design token ThemeExtension extracted from BoldKit CSS variables.
///
/// Light mode values match `:root {}` in globals.css
/// Dark mode values match `.dark {}` in globals.css
///
/// HSL → Flutter Color conversion notes:
///   background light:  hsl(60, 9%, 98%)  → #FAFAF7
///   foreground light:  hsl(240, 10%, 10%) → #181820
///   primary:           hsl(0, 84%, 71%)   → #EE7171 (coral red)
///   secondary:         hsl(174, 62%, 56%) → #3DC9B3 (teal)
///   accent:            hsl(49, 100%, 71%) → #FFD849 (yellow)
class BkTokens extends ThemeExtension<BkTokens> {
  const BkTokens({
    required this.isDark,
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.accent,
    required this.accentForeground,
    required this.muted,
    required this.mutedForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.info,
    required this.infoForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.shadowColor,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.neonPink,
    required this.neonGreen,
    required this.neonBlue,
    required this.neonOrange,
    required this.neonPurple,
    required this.clash1,
    required this.clash2,
    required this.clash3,
    required this.clash4,
    required this.borderWidth,
    required this.shadowOffset,
  });

  final bool isDark;

  // Base
  final Color background;
  final Color foreground;

  // Card / Popover (same in BoldKit)
  final Color card;
  final Color cardForeground;

  // Brand palette
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color accent;
  final Color accentForeground;

  // Neutral
  final Color muted;
  final Color mutedForeground;

  // Semantic
  final Color destructive;
  final Color destructiveForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color info;
  final Color infoForeground;

  // Structure
  final Color border;
  final Color input;
  final Color ring;
  final Color shadowColor;

  // Charts
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  // Neon (high-saturation)
  final Color neonPink;
  final Color neonGreen;
  final Color neonBlue;
  final Color neonOrange;
  final Color neonPurple;

  // Clash (unconventional pairings)
  final Color clash1;
  final Color clash2;
  final Color clash3;
  final Color clash4;

  // Neubrutalism metrics
  final double borderWidth;
  final double shadowOffset;

  // ── Light mode (default / :root) ──────────────────────────────────────────
  static const BkTokens light = BkTokens(
    isDark: false,
    background: Color(0xFFFAFAF7),
    foreground: Color(0xFF181820),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF181820),
    primary: Color(0xFFEE7171), // hsl(0,84%,71%) coral red
    primaryForeground: Color(0xFF181820),
    secondary: Color(0xFF3DC9B3), // hsl(174,62%,56%) teal
    secondaryForeground: Color(0xFF181820),
    accent: Color(0xFFFFD849), // hsl(49,100%,71%) yellow
    accentForeground: Color(0xFF181820),
    muted: Color(0xFFE6E6E0),
    mutedForeground: Color(0xFF5C5C6E),
    destructive: Color(0xFFD92B2B),
    destructiveForeground: Color(0xFFFFFFFF),
    success: Color(0xFF5EDBA0),
    successForeground: Color(0xFF181820),
    warning: Color(0xFFFFCC1A),
    warningForeground: Color(0xFF181820),
    info: Color(0xFF75BBFF),
    infoForeground: Color(0xFF181820),
    border: Color(0xFF181820),
    input: Color(0xFF181820),
    ring: Color(0xFF181820),
    shadowColor: Color(0xFF181820),
    chart1: Color(0xFFEE7171),
    chart2: Color(0xFF3DC9B3),
    chart3: Color(0xFFFFD849),
    chart4: Color(0xFF7C3ADB),
    chart5: Color(0xFFE44C8A),
    neonPink: Color(0xFFFF3399),
    neonGreen: Color(0xFF00FF00),
    neonBlue: Color(0xFF00E5FF),
    neonOrange: Color(0xFFFF6B00),
    neonPurple: Color(0xFFCC00FF),
    clash1: Color(0xFFD96633),
    clash2: Color(0xFF6B2DB8),
    clash3: Color(0xFF16A067),
    clash4: Color(0xFFE8C000),
    borderWidth: 3.0,
    shadowOffset: 4.0,
  );

  // ── Dark mode (.dark) ──────────────────────────────────────────────────────
  static const BkTokens dark = BkTokens(
    isDark: true,
    background: Color(0xFF181820),
    foreground: Color(0xFFFAFAF7),
    card: Color(0xFF21212D),
    cardForeground: Color(0xFFFAFAF7),
    primary: Color(0xFFEE7171),
    primaryForeground: Color(0xFF181820),
    secondary: Color(0xFF3DC9B3),
    secondaryForeground: Color(0xFF181820),
    accent: Color(0xFFFFD849),
    accentForeground: Color(0xFF181820),
    muted: Color(0xFF2E2E3D),
    mutedForeground: Color(0xFFA3A39A),
    destructive: Color(0xFFD92B2B),
    destructiveForeground: Color(0xFFFFFFFF),
    success: Color(0xFF5EDBA0),
    successForeground: Color(0xFF181820),
    warning: Color(0xFFFFCC1A),
    warningForeground: Color(0xFF181820),
    info: Color(0xFF75BBFF),
    infoForeground: Color(0xFF181820),
    border: Color(0xFFFAFAF7),
    input: Color(0xFFFAFAF7),
    ring: Color(0xFFFAFAF7),
    shadowColor: Color(0xFF000000),
    chart1: Color(0xFFEE7171),
    chart2: Color(0xFF3DC9B3),
    chart3: Color(0xFFFFD849),
    chart4: Color(0xFF7C3ADB),
    chart5: Color(0xFFE44C8A),
    neonPink: Color(0xFFFF66B3),
    neonGreen: Color(0xFF00FF44),
    neonBlue: Color(0xFF00EEFF),
    neonOrange: Color(0xFFFF8533),
    neonPurple: Color(0xFFDD33FF),
    clash1: Color(0xFFE07344),
    clash2: Color(0xFF7C3DC9),
    clash3: Color(0xFF1AB87A),
    clash4: Color(0xFFEDCC00),
    borderWidth: 3.0,
    shadowOffset: 4.0,
  );

  // ── ThemeExtension implementation ──────────────────────────────────────────
  @override
  BkTokens copyWith({
    bool? isDark,
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? accent,
    Color? accentForeground,
    Color? muted,
    Color? mutedForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? info,
    Color? infoForeground,
    Color? border,
    Color? input,
    Color? ring,
    Color? shadowColor,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? neonPink,
    Color? neonGreen,
    Color? neonBlue,
    Color? neonOrange,
    Color? neonPurple,
    Color? clash1,
    Color? clash2,
    Color? clash3,
    Color? clash4,
    double? borderWidth,
    double? shadowOffset,
  }) {
    return BkTokens(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      info: info ?? this.info,
      infoForeground: infoForeground ?? this.infoForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      shadowColor: shadowColor ?? this.shadowColor,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      neonPink: neonPink ?? this.neonPink,
      neonGreen: neonGreen ?? this.neonGreen,
      neonBlue: neonBlue ?? this.neonBlue,
      neonOrange: neonOrange ?? this.neonOrange,
      neonPurple: neonPurple ?? this.neonPurple,
      clash1: clash1 ?? this.clash1,
      clash2: clash2 ?? this.clash2,
      clash3: clash3 ?? this.clash3,
      clash4: clash4 ?? this.clash4,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  @override
  BkTokens lerp(BkTokens? other, double t) {
    if (other == null) return this;
    return BkTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground:
          Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground:
          Color.lerp(accentForeground, other.accentForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveForeground:
          Color.lerp(destructiveForeground, other.destructiveForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground:
          Color.lerp(successForeground, other.successForeground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningForeground:
          Color.lerp(warningForeground, other.warningForeground, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      neonPink: Color.lerp(neonPink, other.neonPink, t)!,
      neonGreen: Color.lerp(neonGreen, other.neonGreen, t)!,
      neonBlue: Color.lerp(neonBlue, other.neonBlue, t)!,
      neonOrange: Color.lerp(neonOrange, other.neonOrange, t)!,
      neonPurple: Color.lerp(neonPurple, other.neonPurple, t)!,
      clash1: Color.lerp(clash1, other.clash1, t)!,
      clash2: Color.lerp(clash2, other.clash2, t)!,
      clash3: Color.lerp(clash3, other.clash3, t)!,
      clash4: Color.lerp(clash4, other.clash4, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
      shadowOffset: lerpDouble(shadowOffset, other.shadowOffset, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  /// Helper to get tokens from BuildContext
  static BkTokens of(BuildContext context) {
    return Theme.of(context).extension<BkTokens>() ?? BkTokens.light;
  }
}

/// Convenience extension — use [context.bk] anywhere instead of [BkTokens.of(context)].
extension BkContextExtension on BuildContext {
  BkTokens get bk => BkTokens.of(this);
}
