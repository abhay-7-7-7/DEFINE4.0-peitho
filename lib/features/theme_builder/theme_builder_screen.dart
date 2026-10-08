import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../settings/theme_provider.dart';

class ThemeBuilderScreen extends ConsumerStatefulWidget {
  const ThemeBuilderScreen({super.key});

  @override
  ConsumerState<ThemeBuilderScreen> createState() => _ThemeBuilderScreenState();
}

class _ThemeBuilderScreenState extends ConsumerState<ThemeBuilderScreen> {
  Color _primary = const Color(0xFFEE7171); // Coral default
  Color _secondary = const Color(0xFF3DC9B3); // Teal default
  Color _accent = const Color(0xFFFFD849); // Yellow default
  double _borderWidth = 3.0;
  double _shadowOffset = 4.0;

  static const _presets = [
    _Preset('Coral', Color(0xFFEE7171), Color(0xFF3DC9B3), Color(0xFFFFD849)),
    _Preset('Ocean', Color(0xFF00B4D8), Color(0xFF90E0EF), Color(0xFFFFB703)),
    _Preset('Neon', Color(0xFFFF3399), Color(0xFF00FF00), Color(0xFF00E5FF)),
    _Preset('Sunset', Color(0xFFFF5E5B), Color(0xFFD8D8F6), Color(0xFFFFFFEA)),
    _Preset('Cyber', Color(0xFF7C3ADB), Color(0xFF00FFCC), Color(0xFFFF007F)),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    // Dynamic preview tokens
    final previewTokens = t.copyWith(
      primary: _primary,
      secondary: _secondary,
      accent: _accent,
      borderWidth: _borderWidth,
      shadowOffset: _shadowOffset,
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'THEME BUILDER',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt, color: t.foreground),
            tooltip: 'Reset App Theme',
            onPressed: () {
              BkMotion.hapticClick();
              ref.read(customThemeTokensProvider.notifier).reset();
              setState(() {
                _primary = const Color(0xFFEE7171);
                _secondary = const Color(0xFF3DC9B3);
                _accent = const Color(0xFFFFD849);
                _borderWidth = 3.0;
                _shadowOffset = 4.0;
              });
              BkToastManager.show(context,
                  message: 'RESTORED DEFAULT THEME TOKENS');
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BkReveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE DESIGN TOKEN STUDIO',
                    style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tune primary, secondary, and accent palettes with live global application.',
                    style: GoogleFonts.outfit(
                        fontSize: 15, color: t.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Presets row
            BkReveal(
              delay: const Duration(milliseconds: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRESET THEMES',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: t.mutedForeground)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presets.map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              BkMotion.hapticClick();
                              setState(() {
                                _primary = preset.primary;
                                _secondary = preset.secondary;
                                _accent = preset.accent;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: t.card,
                                border: Border.all(
                                    color: t.border, width: t.borderWidth),
                                boxShadow: [
                                  BoxShadow(
                                      color: t.shadowColor,
                                      offset: const Offset(3, 3)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                      width: 12,
                                      height: 12,
                                      color: preset.primary),
                                  const SizedBox(width: 4),
                                  Container(
                                      width: 12,
                                      height: 12,
                                      color: preset.secondary),
                                  const SizedBox(width: 4),
                                  Container(
                                      width: 12,
                                      height: 12,
                                      color: preset.accent),
                                  const SizedBox(width: 8),
                                  Text(preset.name.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Border width slider
            BkReveal(
              delay: const Duration(milliseconds: 100),
              child: Column(
                children: [
                  BkSlider(
                    label:
                        'BORDER WIDTH (${_borderWidth.toStringAsFixed(1)}px)',
                    value: _borderWidth,
                    min: 1,
                    max: 6,
                    divisions: 10,
                    onChanged: (v) => setState(() => _borderWidth = v),
                  ),
                  const SizedBox(height: 16),
                  BkSlider(
                    label:
                        'SHADOW OFFSET (${_shadowOffset.toStringAsFixed(1)}px)',
                    value: _shadowOffset,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (v) => setState(() => _shadowOffset = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Live Preview Container
            BkReveal(
              delay: const Duration(milliseconds: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIVE COMPONENT PREVIEW',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: t.mutedForeground)),
                  const SizedBox(height: 12),
                  Theme(
                    data: Theme.of(context).copyWith(
                      extensions: [previewTokens],
                    ),
                    child: Builder(
                      builder: (context) {
                        final activeT = BkTokens.of(context);
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: activeT.card,
                            border: Border.all(
                                color: activeT.border,
                                width: activeT.borderWidth),
                            boxShadow: [
                              BoxShadow(
                                color: activeT.shadowColor,
                                offset: Offset(
                                    activeT.shadowOffset, activeT.shadowOffset),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  BkButton(
                                    label: 'PRIMARY BUTTON',
                                    variant: BkButtonVariant.primary,
                                    onPressed: () {},
                                  ),
                                  BkButton(
                                    label: 'SECONDARY',
                                    variant: BkButtonVariant.secondary,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  BkBadge(
                                      label: 'ACCENT TAG',
                                      variant: BkBadgeVariant.accent),
                                  BkBadge(
                                      label: 'PRIMARY TAG',
                                      variant: BkBadgeVariant.primary),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const BkProgress(value: 0.65, height: 14),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Apply to App & Export Buttons
            BkReveal(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Expanded(
                    child: BkButton(
                      label: 'APPLY TO APP',
                      variant: BkButtonVariant.accent,
                      size: BkButtonSize.lg,
                      onPressed: () {
                        BkMotion.hapticClick();
                        ref
                            .read(customThemeTokensProvider.notifier)
                            .setCustomTokens(
                              primary: _primary,
                              secondary: _secondary,
                              accent: _accent,
                              borderWidth: _borderWidth,
                              shadowOffset: _shadowOffset,
                            );
                        BkToastManager.show(context,
                            message: 'APPLIED THEME ACROSS THE ENTIRE APP!');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BkButton(
                      label: 'EXPORT CODE',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.lg,
                      onPressed: () => _showTokenCode(context, t),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showTokenCode(BuildContext context, BkTokens t) {
    BkMotion.hapticClick();
    final code = '''// Custom BkTokens configuration
final customTokens = BkTokens.light.copyWith(
  primary: Color(0x${_primary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}),
  secondary: Color(0x${_secondary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}),
  accent: Color(0x${_accent.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}),
  borderWidth: ${_borderWidth.toStringAsFixed(1)},
  shadowOffset: ${_shadowOffset.toStringAsFixed(1)},
);''';

    showBkBottomSheet(
      context: context,
      title: 'TOKEN OVERRIDES',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.foreground,
              border: Border.all(color: t.border, width: 2),
            ),
            child: Text(
              code,
              style: GoogleFonts.dmMono(
                  color: t.background, fontSize: 12, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BkButton(
                  label: 'COPY CODE',
                  variant: BkButtonVariant.accent,
                  size: BkButtonSize.defaultSize,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Navigator.of(context).pop();
                    BkToastManager.show(context,
                        message: 'COPIED TO CLIPBOARD!');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BkButton(
                  label: 'CLOSE',
                  variant: BkButtonVariant.outline,
                  size: BkButtonSize.defaultSize,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preset {
  const _Preset(this.name, this.primary, this.secondary, this.accent);
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
}
