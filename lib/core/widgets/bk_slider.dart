import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

/// A custom neubrutalist slider with thick rectangular track, square thumb,
/// 3px borders, and tactile hard-shadow styling.
class BkSlider extends StatefulWidget {
  const BkSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.showValue = true,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final bool showValue;

  @override
  State<BkSlider> createState() => _BkSliderState();
}

class _BkSliderState extends State<BkSlider> {
  bool _isDragging = false;

  void _updateValueFromPosition(double localX, double width) {
    if (width <= 0) return;
    final clampedX = localX.clamp(0.0, width);
    final ratio = clampedX / width;
    double rawValue = widget.min + ratio * (widget.max - widget.min);

    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      rawValue = (rawValue / step).round() * step;
    }

    final newValue = rawValue.clamp(widget.min, widget.max);
    if ((newValue - widget.value).abs() > 0.001) {
      BkMotion.hapticClick();
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final active = widget.activeColor ?? t.primary;

    final progress = ((widget.value - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Expanded(
                  child: Text(
                    widget.label!.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: t.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (widget.label != null && widget.showValue)
                const SizedBox(width: 8),
              if (widget.showValue)
                Text(
                  widget.divisions != null
                      ? widget.value.toStringAsFixed(0)
                      : widget.value.toStringAsFixed(1),
                  style: GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: t.foreground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            const trackHeight = 16.0;
            const thumbSize = 24.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                setState(() => _isDragging = true);
                _updateValueFromPosition(details.localPosition.dx, trackWidth);
              },
              onHorizontalDragUpdate: (details) {
                _updateValueFromPosition(details.localPosition.dx, trackWidth);
              },
              onHorizontalDragEnd: (_) {
                setState(() => _isDragging = false);
              },
              onTapDown: (details) {
                _updateValueFromPosition(details.localPosition.dx, trackWidth);
              },
              child: SizedBox(
                height: 44, // Generous touch target
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer track
                    Container(
                      height: trackHeight,
                      width: trackWidth,
                      decoration: BoxDecoration(
                        color: t.muted,
                        border:
                            Border.all(color: t.border, width: t.borderWidth),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          color: active,
                        ),
                      ),
                    ),
                    // Square Brutalist Thumb
                    Positioned(
                      left: (progress * (trackWidth - thumbSize))
                          .clamp(0.0, trackWidth - thumbSize),
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: t.background,
                          border:
                              Border.all(color: t.border, width: t.borderWidth),
                          boxShadow: _isDragging
                              ? null
                              : [
                                  BoxShadow(
                                    color: t.shadowColor,
                                    offset: Offset(
                                        t.shadowOffset - 1, t.shadowOffset - 1),
                                    blurRadius: 0,
                                  ),
                                ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            color: active,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
