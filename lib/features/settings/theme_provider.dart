import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/bk_tokens.dart';

// ── Pre-load helper ──────────────────────────────────────────────────────────

/// Call this BEFORE runApp; returns the persisted [ThemeMode] so there is no
/// flash of the wrong theme on startup.
Future<ThemeMode> loadPersistedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return switch (prefs.getString(ThemeModeNotifier._key)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

// ── ThemeMode Provider ─────────────────────────────────────────────────────────

/// Single source of truth for the current [ThemeMode].
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier([super.initial = ThemeMode.system]);

  static const _key = 'bk_theme_mode';

  /// Switch to the given [mode] and persist it.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
  }

  /// Toggle between light and dark (skips system).
  void toggle() {
    setMode(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  /// Cycle through light → dark → system.
  void cycle() {
    setMode(switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    });
  }
}

// ── Custom Tokens & Builder Provider ──────────────────────────────────────────

class CustomTokensState {
  const CustomTokensState({
    this.primary,
    this.secondary,
    this.accent,
    this.borderWidth,
    this.shadowOffset,
    this.fontScale = 1.0,
    this.rounded = false,
    this.presetName = 'default',
  });

  final Color? primary;
  final Color? secondary;
  final Color? accent;
  final double? borderWidth;
  final double? shadowOffset;
  final double fontScale;
  final bool rounded;
  final String presetName;

  bool get isCustomized =>
      primary != null ||
      secondary != null ||
      accent != null ||
      borderWidth != null ||
      shadowOffset != null ||
      fontScale != 1.0 ||
      rounded != false;

  CustomTokensState copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    double? borderWidth,
    double? shadowOffset,
    double? fontScale,
    bool? rounded,
    String? presetName,
  }) {
    return CustomTokensState(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      fontScale: fontScale ?? this.fontScale,
      rounded: rounded ?? this.rounded,
      presetName: presetName ?? this.presetName,
    );
  }

  BkTokens applyTo(BkTokens base) {
    return base.copyWith(
      primary: primary ?? base.primary,
      secondary: secondary ?? base.secondary,
      accent: accent ?? base.accent,
      borderWidth: borderWidth ?? base.borderWidth,
      shadowOffset: shadowOffset ?? base.shadowOffset,
    );
  }
}

final customThemeTokensProvider =
    StateNotifierProvider<CustomTokensNotifier, CustomTokensState>(
  (ref) => CustomTokensNotifier(),
);

class CustomTokensNotifier extends StateNotifier<CustomTokensState> {
  CustomTokensNotifier() : super(const CustomTokensState());

  void setCustomTokens({
    Color? primary,
    Color? secondary,
    Color? accent,
    double? borderWidth,
    double? shadowOffset,
    double? fontScale,
    bool? rounded,
  }) {
    state = state.copyWith(
      primary: primary,
      secondary: secondary,
      accent: accent,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
      fontScale: fontScale,
      rounded: rounded,
      presetName: 'custom',
    );
  }

  void setPrimary(Color color) {
    state = state.copyWith(primary: color, presetName: 'custom');
  }

  void setSecondary(Color color) {
    state = state.copyWith(secondary: color, presetName: 'custom');
  }

  void setAccent(Color color) {
    state = state.copyWith(accent: color, presetName: 'custom');
  }

  void setBorderWidth(double width) {
    state = state.copyWith(borderWidth: width);
  }

  void setShadowOffset(double offset) {
    state = state.copyWith(shadowOffset: offset);
  }

  void setFontScale(double scale) {
    state = state.copyWith(fontScale: scale);
  }

  void setRounded(bool rounded) {
    state = state.copyWith(rounded: rounded);
  }

  void setPreset(String preset) {
    switch (preset) {
      case 'coral':
        state = state.copyWith(
          primary: const Color(0xFFEE7171),
          secondary: const Color(0xFF3DC9B3),
          accent: const Color(0xFFFFD849),
          presetName: 'coral',
        );
      case 'teal':
        state = state.copyWith(
          primary: const Color(0xFF3DC9B3),
          secondary: const Color(0xFFEE7171),
          accent: const Color(0xFFFFD849),
          presetName: 'teal',
        );
      case 'yellow':
        state = state.copyWith(
          primary: const Color(0xFFFFD849),
          secondary: const Color(0xFF3DC9B3),
          accent: const Color(0xFFEE7171),
          presetName: 'yellow',
        );
      case 'purple':
        state = state.copyWith(
          primary: const Color(0xFFA855F7),
          secondary: const Color(0xFF06B6D4),
          accent: const Color(0xFFFACC15),
          presetName: 'purple',
        );
      case 'cyber':
        state = state.copyWith(
          primary: const Color(0xFFFF007A),
          secondary: const Color(0xFF00F0FF),
          accent: const Color(0xFFFFE600),
          presetName: 'cyber',
        );
      default:
        reset();
    }
  }

  void reset() {
    state = const CustomTokensState();
  }
}
