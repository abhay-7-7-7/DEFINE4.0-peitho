import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../features/settings/theme_provider.dart';

/// Settings & About screen — theme toggle, credits, licenses.
class SettingsAboutScreen extends ConsumerWidget {
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: t.foreground,
          ),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme mode section
          _SectionHeader(label: 'APPEARANCE', t: t),
          const SizedBox(height: 12),
          _ThemeModeSelector(
              t: t, mode: themeMode, onChanged: notifier.setMode),
          const SizedBox(height: 32),

          // App info
          _SectionHeader(label: 'APP INFO', t: t),
          const SizedBox(height: 12),
          _InfoRow(label: 'Version', value: '1.0.0', t: t),
          _InfoRow(label: 'Build', value: '1', t: t),
          _InfoRow(label: 'Framework', value: 'Flutter 3.x', t: t),
          const SizedBox(height: 32),

          // Credits
          _SectionHeader(label: 'CREDITS', t: t),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.accent,
              border: Border.all(color: t.border, width: 3),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: const Offset(4, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚡ BOLDKIT',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: t.accentForeground,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Design system ported from BoldKit by Aniruddha Agarwal',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.accentForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Original: https://github.com/ANIBIT14/boldkit',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    color: t.accentForeground.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // MIT License
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.muted,
              border: Border.all(color: t.border, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIT LICENSE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: t.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Copyright (c) 2024 Aniruddha Agarwal\n\n'
                  'Permission is hereby granted, free of charge, to any person obtaining a copy '
                  'of this software and associated documentation files (the "Software"), to deal '
                  'in the Software without restriction, including without limitation the rights '
                  'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                  'copies of the Software, and to permit persons to whom the Software is '
                  'furnished to do so, subject to the following conditions:\n\n'
                  'The above copyright notice and this permission notice shall be included in all '
                  'copies or substantial portions of the Software.',
                  style: GoogleFonts.dmMono(
                    fontSize: 10,
                    color: t.mutedForeground,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About
          _SectionHeader(label: 'ABOUT', t: t),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: 3),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: const Offset(4, 4))
              ],
            ),
            child: Text(
              'BoldKit Flutter is a production-quality port of the BoldKit neubrutalism UI library. '
              'It provides 75+ components with a distinct brutalist aesthetic — bold borders, '
              'hard-offset shadows, flat colors, and satisfying press animations. '
              'Built for Android, iOS, and web.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: t.foreground,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Open licenses
          GestureDetector(
            onTap: () => showLicensePage(context: context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.background,
                border: Border.all(color: t.border, width: 3),
                boxShadow: [
                  BoxShadow(color: t.shadowColor, offset: const Offset(4, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'OPEN SOURCE LICENSES',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: t.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 18, color: t.foreground),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.t});
  final String label;
  final BkTokens t;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: t.mutedForeground,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.t});
  final String label;
  final String value;
  final BkTokens t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: t.border, width: 3),
        color: t.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600, color: t.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, color: t.foreground)),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector(
      {required this.t, required this.mode, required this.onChanged});
  final BkTokens t;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ThemeMode.values.asMap().entries.map((entry) {
        final idx = entry.key;
        final m = entry.value;
        final isSelected = mode == m;
        final labels = {
          ThemeMode.light: 'LIGHT',
          ThemeMode.dark: 'DARK',
          ThemeMode.system: 'SYSTEM'
        };
        final icons = {
          ThemeMode.light: Icons.light_mode,
          ThemeMode.dark: Icons.dark_mode,
          ThemeMode.system: Icons.settings_suggest
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: idx < 2 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? t.primary : t.background,
                  border: Border.all(color: t.border, width: 3),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: t.shadowColor, offset: const Offset(3, 3))
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(icons[m],
                        color: isSelected
                            ? t.primaryForeground
                            : t.mutedForeground,
                        size: 20),
                    const SizedBox(height: 4),
                    Text(
                      labels[m]!,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: isSelected
                            ? t.primaryForeground
                            : t.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
