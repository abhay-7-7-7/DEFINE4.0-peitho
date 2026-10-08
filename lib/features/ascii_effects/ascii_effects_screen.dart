import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';

class AsciiEffectsScreen extends StatefulWidget {
  const AsciiEffectsScreen({super.key});

  @override
  State<AsciiEffectsScreen> createState() => _AsciiEffectsScreenState();
}

class _AsciiEffectsScreenState extends State<AsciiEffectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ASCII state
  BkAsciiShapeType _selectedAsciiShape = BkAsciiShapeType.torus;
  BkAsciiSize _asciiSize = BkAsciiSize.md;
  BkAsciiCharset _asciiCharset = BkAsciiCharset.blocks;
  BkAsciiSpeed _asciiSpeed = BkAsciiSpeed.normal;
  bool _asciiMulticolor = false;
  bool _asciiPlaying = true;

  // Math Curve state
  BkCurveType _selectedCurve = BkCurveType.rose;
  double _curveProgressValue = 0.65;

  // Canvas Effect state
  BkCanvasEffectType _selectedCanvasEffect = BkCanvasEffectType.meshGradient;
  double _effectSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFullscreenAscii(BuildContext context, BkTokens t) {
    BkMotion.hapticClick();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: const Offset(6, 6)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedAsciiShape.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 320,
                  width: double.infinity,
                  color: t.foreground,
                  child: Center(
                    child: BkAsciiShape(
                      shape: _selectedAsciiShape,
                      size: BkAsciiSize.lg,
                      charset: _asciiCharset,
                      speed: _asciiSpeed,
                      multicolor: _asciiMulticolor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BkButton(
                  label: 'CLOSE PREVIEW',
                  variant: BkButtonVariant.primary,
                  size: BkButtonSize.md,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'ASCII & EFFECTS',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: t.border, width: 2),
                bottom: BorderSide(color: t.border, width: 3),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: t.primaryForeground,
              unselectedLabelColor: t.mutedForeground,
              indicatorColor: t.primary,
              indicatorWeight: 4,
              labelStyle:
                  GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
              tabs: const [
                Tab(text: 'ASCII SHAPES'),
                Tab(text: 'MATH CURVES'),
                Tab(text: 'CANVAS SHADERS'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAsciiTab(t),
          _buildMathCurvesTab(t),
          _buildCanvasEffectsTab(t),
        ],
      ),
    );
  }

  Widget _buildAsciiTab(BkTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Featured Ascii Canvas wrapped in RepaintBoundary for 60fps performance
          BkReveal(
            child: RepaintBoundary(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: t.foreground,
                  border: Border.all(color: t.border, width: t.borderWidth),
                  boxShadow: [
                    BoxShadow(
                        color: t.shadowColor,
                        offset: Offset(t.shadowOffset, t.shadowOffset)),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _asciiPlaying
                          ? BkAsciiShape(
                              shape: _selectedAsciiShape,
                              size: _asciiSize,
                              charset: _asciiCharset,
                              speed: _asciiSpeed,
                              multicolor: _asciiMulticolor,
                            )
                          : Text(
                              'ANIMATION PAUSED',
                              style: GoogleFonts.dmMono(
                                color: t.background,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _asciiPlaying
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: t.background,
                            ),
                            tooltip: _asciiPlaying
                                ? 'Pause Animation'
                                : 'Play Animation',
                            onPressed: () {
                              BkMotion.hapticClick();
                              setState(() => _asciiPlaying = !_asciiPlaying);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.fullscreen, color: t.background),
                            tooltip: 'Fullscreen Preview',
                            onPressed: () => _showFullscreenAscii(context, t),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Shape picker
          BkReveal(
            delay: const Duration(milliseconds: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT ASCII SHAPE',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: t.card,
                      border:
                          Border.all(color: t.border, width: t.borderWidth)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BkAsciiShapeType>(
                      value: _selectedAsciiShape,
                      isExpanded: true,
                      dropdownColor: t.card,
                      items: BkAsciiShapeType.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        BkMotion.hapticClick();
                        setState(() => _selectedAsciiShape = v!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Size Selector
          BkReveal(
            delay: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASCII RESOLUTION / SIZE',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground),
                ),
                const SizedBox(height: 8),
                Row(
                  children: BkAsciiSize.values.map((s) {
                    final sel = _asciiSize == s;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            BkMotion.hapticClick();
                            setState(() => _asciiSize = s);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? t.primary : t.card,
                              border: Border.all(
                                  color: t.border, width: t.borderWidth),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                          color: t.shadowColor,
                                          offset: const Offset(3, 3))
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                s.name.toUpperCase(),
                                style: GoogleFonts.dmMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color:
                                      sel ? t.primaryForeground : t.foreground,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Charset selector
          BkReveal(
            delay: const Duration(milliseconds: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHARSET',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.mutedForeground)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BkAsciiCharset.values.map((c) {
                    final isSelected = _asciiCharset == c;
                    return GestureDetector(
                      onTap: () {
                        BkMotion.hapticClick();
                        setState(() => _asciiCharset = c);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? t.secondary : t.card,
                          border:
                              Border.all(color: t.border, width: t.borderWidth),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: t.shadowColor,
                                      offset: const Offset(3, 3))
                                ]
                              : null,
                        ),
                        child: Text(
                          c.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isSelected
                                ? t.secondaryForeground
                                : t.foreground,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Multicolor & Speed
          BkReveal(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Row(
                  children: [
                    BkCheckbox(
                      value: _asciiMulticolor,
                      onChanged: (v) {
                        BkMotion.hapticClick();
                        setState(() => _asciiMulticolor = v ?? false);
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'MULTICOLOR PALETTE',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('SPEED: ',
                        style: GoogleFonts.dmMono(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    ...BkAsciiSpeed.values.map((spd) {
                      final sel = _asciiSpeed == spd;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(spd.name.toUpperCase()),
                          selected: sel,
                          onSelected: (_) {
                            BkMotion.hapticClick();
                            setState(() => _asciiSpeed = spd);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMathCurvesTab(BkTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live MathCurveLoader
          BkReveal(
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: t.card,
                border: Border.all(color: t.border, width: t.borderWidth),
                boxShadow: [
                  BoxShadow(
                      color: t.shadowColor,
                      offset: Offset(t.shadowOffset, t.shadowOffset)),
                ],
              ),
              child: Center(
                child: BkMathCurveLoader(
                  curve: _selectedCurve,
                  size: 160,
                  trackColor: t.muted,
                  headColor: t.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          BkReveal(
            delay: const Duration(milliseconds: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT PARAMETRIC CURVE',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BkCurveType.values.map((curve) {
                    final isSelected = _selectedCurve == curve;
                    return GestureDetector(
                      onTap: () {
                        BkMotion.hapticClick();
                        setState(() => _selectedCurve = curve);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? t.secondary : t.card,
                          border:
                              Border.all(color: t.border, width: t.borderWidth),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: t.shadowColor,
                                      offset: const Offset(3, 3))
                                ]
                              : null,
                        ),
                        child: Text(
                          curve.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? t.secondaryForeground
                                : t.foreground,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Math curve progress sample with live interactive slider
          BkReveal(
            delay: const Duration(milliseconds: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PARAMETRIC PROGRESS BAR',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground),
                ),
                const SizedBox(height: 8),
                BkCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        BkMathCurveProgress(
                          curve: _selectedCurve,
                          value: _curveProgressValue,
                          size: 110,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_curveProgressValue * 100).toInt()}% COMPLETION',
                          style: GoogleFonts.dmMono(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        BkSlider(
                          label: 'DRAG PROGRESS VALUE',
                          value: _curveProgressValue * 100,
                          min: 0,
                          max: 100,
                          onChanged: (v) =>
                              setState(() => _curveProgressValue = v / 100.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCanvasEffectsTab(BkTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live canvas shader view
          BkReveal(
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: t.border, width: t.borderWidth),
                boxShadow: [
                  BoxShadow(
                      color: t.shadowColor,
                      offset: Offset(t.shadowOffset, t.shadowOffset)),
                ],
              ),
              child: BkCanvasEffect(
                type: _selectedCanvasEffect,
                speed: _effectSpeed,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: t.card.withValues(alpha: 0.85),
                    child: Text(
                      _selectedCanvasEffect.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          BkReveal(
            delay: const Duration(milliseconds: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT CANVAS SHADER',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BkCanvasEffectType.values.map((eff) {
                    final isSelected = _selectedCanvasEffect == eff;
                    return GestureDetector(
                      onTap: () {
                        BkMotion.hapticClick();
                        setState(() => _selectedCanvasEffect = eff);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? t.accent : t.card,
                          border:
                              Border.all(color: t.border, width: t.borderWidth),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: t.shadowColor,
                                      offset: const Offset(3, 3))
                                ]
                              : null,
                        ),
                        child: Text(
                          eff.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            color:
                                isSelected ? t.accentForeground : t.foreground,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Speed slider using BkSlider
          BkReveal(
            delay: const Duration(milliseconds: 120),
            child: BkSlider(
              label: 'ANIMATION SPEED (${_effectSpeed.toStringAsFixed(1)}x)',
              value: _effectSpeed,
              min: 0.2,
              max: 3.0,
              divisions: 28,
              onChanged: (v) => setState(() => _effectSpeed = v),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
