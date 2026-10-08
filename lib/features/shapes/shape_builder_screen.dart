import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';

class ShapeBuilderScreen extends StatefulWidget {
  const ShapeBuilderScreen({super.key});

  @override
  State<ShapeBuilderScreen> createState() => _ShapeBuilderScreenState();
}

class _ShapeBuilderScreenState extends State<ShapeBuilderScreen> {
  BkShapeType _shape = BkShapeType.star;
  double _size = 140.0;
  double _strokeWidth = 3.0;
  bool _filled = true;
  Color? _color;
  BkShapeAnimation _animation = BkShapeAnimation.none;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final activeColor = _color ?? t.primary;

    final colorOptions = [
      t.primary,
      t.secondary,
      t.accent,
      t.destructive,
      t.info,
      t.success,
      t.foreground,
    ];

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'SHAPE BUILDER',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Canvas
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset, t.shadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: BkShape(
                shape: _shape,
                size: _size,
                strokeWidth: _strokeWidth,
                filled: _filled,
                color: activeColor,
                animation: _animation,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Shape selector
          Text('SELECT SHAPE', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BkShapeType>(
                value: _shape,
                isExpanded: true,
                dropdownColor: t.card,
                items: BkShapeType.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _shape = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Size slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SIZE: ${_size.round()}px', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _size,
            min: 50,
            max: 220,
            onChanged: (v) => setState(() => _size = v),
          ),
          const SizedBox(height: 8),

          // Stroke width slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STROKE WIDTH: ${_strokeWidth.toStringAsFixed(1)}px', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _strokeWidth,
            min: 1,
            max: 10,
            onChanged: (v) => setState(() => _strokeWidth = v),
          ),
          const SizedBox(height: 12),

          // Filled toggle
          Row(
            children: [
              BkCheckbox(
                value: _filled,
                onChanged: (v) => setState(() => _filled = v ?? false),
              ),
              const SizedBox(width: 8),
              Text('FILLED SHAPE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          // Color Palette selector
          Text('COLOR', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          Row(
            children: colorOptions.map((c) {
              final isSelected = activeColor == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      border: Border.all(color: t.border, width: isSelected ? 4 : 2),
                      boxShadow: isSelected
                          ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Animation selector
          Text('ANIMATION', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BkShapeAnimation.values.map((anim) {
                final isSelected = _animation == anim;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _animation = anim),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? t.primary : t.card,
                        border: Border.all(color: t.border, width: t.borderWidth),
                        boxShadow: isSelected
                            ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
                            : null,
                      ),
                      child: Text(
                        anim.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? t.primaryForeground : t.foreground,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // Export code button
          BkButton(
            label: 'EXPORT DART CODE',
            variant: BkButtonVariant.primary,
            size: BkButtonSize.lg,
            onPressed: () => _showExportCode(context, t),
          ),
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showExportCode(BuildContext context, BkTokens t) {
    final code = '''BkShape(
  shape: BkShapeType.${_shape.name},
  size: ${_size.round()}.0,
  strokeWidth: ${_strokeWidth.toStringAsFixed(1)},
  filled: $_filled,
  animation: BkShapeAnimation.${_animation.name},
)''';

    showBkBottomSheet(
      context: context,
      title: 'EXPORT CODE',
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
              style: GoogleFonts.dmMono(color: t.background, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          BkButton(
            label: 'CLOSE',
            variant: BkButtonVariant.primary,
            size: BkButtonSize.defaultSize,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
