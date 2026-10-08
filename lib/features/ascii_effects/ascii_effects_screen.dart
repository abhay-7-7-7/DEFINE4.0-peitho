import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';

class AsciiEffectsScreen extends StatefulWidget {
  const AsciiEffectsScreen({super.key});

  @override
  State<AsciiEffectsScreen> createState() => _AsciiEffectsScreenState();
}

class _AsciiEffectsScreenState extends State<AsciiEffectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ASCII state
  BkAsciiShapeType _selectedAsciiShape = BkAsciiShapeType.torus;
  final BkAsciiSize _asciiSize = BkAsciiSize.md;
  BkAsciiCharset _asciiCharset = BkAsciiCharset.blocks;
  final BkAsciiSpeed _asciiSpeed = BkAsciiSpeed.normal;
  bool _asciiMulticolor = false;

  // Math Curve state
  BkCurveType _selectedCurve = BkCurveType.rose;

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

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'ASCII & EFFECTS',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.0),
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
              labelColor: t.primaryForeground,
              unselectedLabelColor: t.mutedForeground,
              indicatorColor: t.primary,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
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
          // Featured Ascii Canvas
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: t.foreground,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: Offset(t.shadowOffset, t.shadowOffset)),
              ],
            ),
            child: Center(
              child: BkAsciiShape(
                shape: _selectedAsciiShape,
                size: _asciiSize,
                charset: _asciiCharset,
                speed: _asciiSpeed,
                multicolor: _asciiMulticolor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Shape picker
          Text('SELECT ASCII SHAPE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: t.card, border: Border.all(color: t.border, width: t.borderWidth)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BkAsciiShapeType>(
                value: _selectedAsciiShape,
                isExpanded: true,
                dropdownColor: t.card,
                items: BkAsciiShapeType.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)));
                }).toList(),
                onChanged: (v) => setState(() => _selectedAsciiShape = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Charset selector
          Text('CHARSET', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BkAsciiCharset.values.map((c) {
              final isSelected = _asciiCharset == c;
              return GestureDetector(
                onTap: () => setState(() => _asciiCharset = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? t.primary : t.card,
                    border: Border.all(color: t.border, width: t.borderWidth),
                    boxShadow: isSelected ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))] : null,
                  ),
                  child: Text(c.name.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Multicolor & Speed
          Row(
            children: [
              BkCheckbox(
                value: _asciiMulticolor,
                onChanged: (v) => setState(() => _asciiMulticolor = v ?? false),
              ),
              const SizedBox(width: 8),
              Text('MULTICOLOR PALETTE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
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
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: Offset(t.shadowOffset, t.shadowOffset)),
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
          const SizedBox(height: 24),

          Text('SELECT PARAMETRIC CURVE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BkCurveType.values.map((curve) {
              final isSelected = _selectedCurve == curve;
              return GestureDetector(
                onTap: () => setState(() => _selectedCurve = curve),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? t.secondary : t.card,
                    border: Border.all(color: t.border, width: t.borderWidth),
                    boxShadow: isSelected ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))] : null,
                  ),
                  child: Text(
                    curve.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? t.secondaryForeground : t.foreground,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Math curve progress sample
          Text('PARAMETRIC PROGRESS BAR', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          const BkCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  BkMathCurveProgress(curve: BkCurveType.butterfly, value: 0.65, size: 100),
                  SizedBox(height: 8),
                  Text('65% COMPLETION', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
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
          Container(
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(color: t.shadowColor, offset: Offset(t.shadowOffset, t.shadowOffset)),
              ],
            ),
            child: BkCanvasEffect(
              type: _selectedCanvasEffect,
              speed: _effectSpeed,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: t.card.withValues(alpha: 0.85),
                  child: Text(
                    _selectedCanvasEffect.name.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('SELECT CANVAS SHADER', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BkCanvasEffectType.values.map((eff) {
              final isSelected = _selectedCanvasEffect == eff;
              return GestureDetector(
                onTap: () => setState(() => _selectedCanvasEffect = eff),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? t.accent : t.card,
                    border: Border.all(color: t.border, width: t.borderWidth),
                    boxShadow: isSelected ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))] : null,
                  ),
                  child: Text(
                    eff.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? t.accentForeground : t.foreground,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Speed slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ANIMATION SPEED: ${_effectSpeed.toStringAsFixed(1)}x', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Slider(
            value: _effectSpeed,
            min: 0.2,
            max: 3.0,
            onChanged: (v) => setState(() => _effectSpeed = v),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
