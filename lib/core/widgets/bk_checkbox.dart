import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

// ── BkCheckbox ────────────────────────────────────────────────────────────────

/// Neubrutalist square checkbox with 3 px border.
///
/// Supports [indeterminate] state (dash mark instead of checkmark).
class BkCheckbox extends StatelessWidget {
  const BkCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.indeterminate = false,
    this.enabled = true,
    this.size = 24.0,
  });

  /// Current checked state. `null` is treated as indeterminate if
  /// [indeterminate] is also true; otherwise false.
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool indeterminate;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final bool isChecked = value == true;
    final bool isIndet = indeterminate && value == null;

    Widget box = GestureDetector(
      onTap: enabled
          ? () {
              if (indeterminate && value == null) {
                onChanged?.call(true);
              } else {
                onChanged?.call(!(value ?? false));
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (isChecked || isIndet)
              ? t.primary
              : (enabled ? t.background : t.muted),
          border: Border.all(
            color: enabled ? t.border : t.mutedForeground,
            width: t.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: (isChecked || isIndet)
            ? CustomPaint(
                painter: _CheckmarkPainter(
                  color: t.primaryForeground,
                  indeterminate: isIndet,
                ),
              )
            : null,
      ),
    );

    if (label == null) return box;

    return GestureDetector(
      onTap: enabled
          ? () {
              if (indeterminate && value == null) {
                onChanged?.call(true);
              } else {
                onChanged?.call(!(value ?? false));
              }
            }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 10),
          Text(
            label!,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? t.foreground : t.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.color, this.indeterminate = false});

  final Color color;
  final bool indeterminate;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    if (indeterminate) {
      // Horizontal dash
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.5),
        Offset(size.width * 0.8, size.height * 0.5),
        paint,
      );
    } else {
      // Checkmark: down-stroke then up-stroke
      final Path path = Path()
        ..moveTo(size.width * 0.18, size.height * 0.5)
        ..lineTo(size.width * 0.4, size.height * 0.72)
        ..lineTo(size.width * 0.82, size.height * 0.26);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) =>
      old.color != color || old.indeterminate != indeterminate;
}
