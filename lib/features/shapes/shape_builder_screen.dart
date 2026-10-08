import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';

class ShapeBuilderScreen extends StatefulWidget {
  const ShapeBuilderScreen({super.key, this.initialShape});

  final BkShapeType? initialShape;

  @override
  State<ShapeBuilderScreen> createState() => _ShapeBuilderScreenState();
}

class _ShapeBuilderScreenState extends State<ShapeBuilderScreen> {
  late BkShapeType _shape;
  double _size = 130.0;
  double _strokeWidth = 3.0;
  double _rotation = 0.0;
  bool _filled = true;
  Color? _color;
  BkShapeAnimation _animation = BkShapeAnimation.none;

  // Draggable physics canvas offset
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _shape = widget.initialShape ?? BkShapeType.star;
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: t.foreground),
            tooltip: 'Reset Canvas',
            onPressed: () {
              BkMotion.hapticClick();
              setState(() {
                _panOffset = Offset.zero;
                _rotation = 0;
                _size = 130.0;
                _strokeWidth = 3.0;
                _filled = true;
                _animation = BkShapeAnimation.none;
              });
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Interactive Drag Preview Canvas
            BkReveal(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() => _panOffset += details.delta);
                },
                child: Container(
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
                  child: Stack(
                    children: [
                      // Subtle grid lines indicator
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Text(
                          'DRAG TO PAN',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: t.mutedForeground,
                          ),
                        ),
                      ),
                      Center(
                        child: Transform.translate(
                          offset: _panOffset,
                          child: Transform.rotate(
                            angle: _rotation * 3.14159 / 180,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Shape Selector
            BkReveal(
              delay: const Duration(milliseconds: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT SHAPE',
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
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: [
                        BoxShadow(
                            color: t.shadowColor,
                            offset: const Offset(3, 3),
                            blurRadius: 0),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BkShapeType>(
                        value: _shape,
                        isExpanded: true,
                        dropdownColor: t.card,
                        items: BkShapeType.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            BkMotion.hapticClick();
                            setState(() => _shape = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sliders: Size, Stroke, Rotation
            BkReveal(
              delay: const Duration(milliseconds: 100),
              child: Column(
                children: [
                  BkSlider(
                    label: 'SIZE (${_size.round()}px)',
                    value: _size,
                    min: 50,
                    max: 220,
                    onChanged: (v) => setState(() => _size = v),
                  ),
                  const SizedBox(height: 16),
                  BkSlider(
                    label:
                        'STROKE WIDTH (${_strokeWidth.toStringAsFixed(1)}px)',
                    value: _strokeWidth,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    onChanged: (v) => setState(() => _strokeWidth = v),
                  ),
                  const SizedBox(height: 16),
                  BkSlider(
                    label: 'ROTATION (${_rotation.round()}°)',
                    value: _rotation,
                    min: 0,
                    max: 360,
                    onChanged: (v) => setState(() => _rotation = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filled toggle
            BkReveal(
              delay: const Duration(milliseconds: 140),
              child: Row(
                children: [
                  BkCheckbox(
                    value: _filled,
                    onChanged: (v) {
                      BkMotion.hapticClick();
                      setState(() => _filled = v ?? false);
                    },
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'FILLED SHAPE (SOLID INTERIOR)',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Color Palette Selector
            BkReveal(
              delay: const Duration(milliseconds: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHAPE COLOR',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.mutedForeground),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colorOptions.map((c) {
                      final isSelected = activeColor == c;
                      return GestureDetector(
                        onTap: () {
                          BkMotion.hapticClick();
                          setState(() => _color = c);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(
                                color: t.border, width: isSelected ? 4 : 2),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: t.shadowColor,
                                        offset: const Offset(3, 3))
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Animation Selector
            BkReveal(
              delay: const Duration(milliseconds: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ANIMATION EFFECT',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.mutedForeground),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: BkShapeAnimation.values.map((anim) {
                        final isSelected = _animation == anim;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              BkMotion.hapticClick();
                              setState(() => _animation = anim);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? t.primary : t.card,
                                border: Border.all(
                                    color: t.border, width: t.borderWidth),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                            color: t.shadowColor,
                                            offset: const Offset(3, 3))
                                      ]
                                    : null,
                              ),
                              child: Text(
                                anim.name.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? t.primaryForeground
                                      : t.foreground,
                                ),
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
            const SizedBox(height: 32),

            // Action Buttons: Copy Code & Export
            BkReveal(
              delay: const Duration(milliseconds: 260),
              child: Row(
                children: [
                  Expanded(
                    child: BkButton(
                      label: 'COPY CODE',
                      variant: BkButtonVariant.secondary,
                      size: BkButtonSize.lg,
                      onPressed: () => _copyCode(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BkButton(
                      label: 'EXPORT CODE',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.lg,
                      onPressed: () => _showExportCode(context, t),
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

  String _generateCode() {
    return '''BkShape(
  shape: BkShapeType.${_shape.name},
  size: ${_size.round()}.0,
  strokeWidth: ${_strokeWidth.toStringAsFixed(1)},
  filled: $_filled,
  animation: BkShapeAnimation.${_animation.name},
)''';
  }

  void _copyCode(BuildContext context) {
    BkMotion.hapticClick();
    Clipboard.setData(ClipboardData(text: _generateCode()));
    BkToastManager.show(context, message: 'DART CODE COPIED TO CLIPBOARD!');
  }

  void _showExportCode(BuildContext context, BkTokens t) {
    final code = _generateCode();

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
              style: GoogleFonts.dmMono(
                  color: t.background, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BkButton(
                  label: 'COPY',
                  variant: BkButtonVariant.accent,
                  size: BkButtonSize.md,
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
                  size: BkButtonSize.md,
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
