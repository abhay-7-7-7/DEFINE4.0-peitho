import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bk_tokens.dart';

/// BoldKit ThemeData factory.
/// Material 3 is disabled in style; all theming is done via BkTokens + ThemeExtension.
class BkTheme {
  BkTheme._();

  static ThemeData light([BkTokens? custom]) =>
      _build(custom ?? BkTokens.light);
  static ThemeData dark([BkTokens? custom]) => _build(custom ?? BkTokens.dark);
  static ThemeData build(BkTokens tokens) => _build(tokens);

  static TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.dmMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static ThemeData _build(BkTokens t) {
    final base = t.isDark ? ThemeData.dark() : ThemeData.light();
    final textTheme = _buildTextTheme(t);

    return base.copyWith(
      scaffoldBackgroundColor: t.background,
      colorScheme: ColorScheme(
        brightness: t.isDark ? Brightness.dark : Brightness.light,
        primary: t.primary,
        onPrimary: t.primaryForeground,
        secondary: t.secondary,
        onSecondary: t.secondaryForeground,
        error: t.destructive,
        onError: t.destructiveForeground,
        surface: t.card,
        onSurface: t.foreground,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: t.foreground,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: t.foreground),
        shape: Border(bottom: BorderSide(color: t.border, width: 3)),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 3),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.border, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.border, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.foreground, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.destructive, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.destructive, width: 3),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.outfit(
          color: t.mutedForeground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        hintStyle: GoogleFonts.outfit(color: t.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.primary,
          foregroundColor: t.primaryForeground,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: BorderSide(color: t.border, width: 3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: t.border, width: 2),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return t.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(t.primaryForeground),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return t.primaryForeground;
          return t.mutedForeground;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return t.primary;
          return t.muted;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.primary,
        inactiveTrackColor: t.muted,
        thumbColor: t.primary,
        overlayColor: t.primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: t.muted,
        color: t.primary,
      ),
      extensions: [t],
    );
  }

  static TextTheme _buildTextTheme(BkTokens t) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57,
        fontWeight: FontWeight.w900,
        color: t.foreground,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 45,
        fontWeight: FontWeight.w900,
        color: t.foreground,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: t.foreground,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: t.foreground,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: t.foreground,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: t.foreground,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 0.5,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 0.5,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 0.5,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: t.foreground,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: t.foreground,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: t.mutedForeground,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 1.0,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: t.foreground,
        letterSpacing: 1.5,
      ),
    );
  }
}
