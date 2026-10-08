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

// ── BkRadioGroup + BkRadioOption ─────────────────────────────────────────────

/// Manages a group of [BkRadioOption] widgets with a shared selected value.
class BkRadioGroup<T> extends StatelessWidget {
  const BkRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
    this.direction = Axis.vertical,
    this.spacing = 12.0,
  });

  final T? value;
  final ValueChanged<T?> onChanged;
  final List<BkRadioOption<T>> children;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = children
        .map((option) => _BkRadioOptionInherited<T>(
              groupValue: value,
              onChanged: onChanged,
              child: option,
            ))
        .toList();

    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .expand((w) => [w, SizedBox(height: spacing)])
            .toList()
          ..removeLast(),
      );
    } else {
      return Row(
        children: items
            .expand((w) => [w, SizedBox(width: spacing)])
            .toList()
          ..removeLast(),
      );
    }
  }
}

/// A single radio option. Must be a descendant of [BkRadioGroup].
class BkRadioOption<T> extends StatelessWidget {
  const BkRadioOption({
    super.key,
    required this.value,
    required this.label,
    this.enabled = true,
    this.size = 22.0,
  });

  final T value;
  final String label;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final inherited = _BkRadioOptionInherited.of<T>(context);
    final BkTokens t = BkTokens.of(context);

    final bool selected = inherited?.groupValue == value;

    return GestureDetector(
      onTap: enabled ? () => inherited?.onChanged(value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: selected
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
            child: selected
                ? CustomPaint(painter: _RadioDotPainter(color: t.primaryForeground))
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
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

class _RadioDotPainter extends CustomPainter {
  const _RadioDotPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.45,
        height: size.height * 0.45,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RadioDotPainter old) => old.color != color;
}

// ── InheritedWidget helper ────────────────────────────────────────────────────

class _BkRadioOptionInherited<T> extends InheritedWidget {
  const _BkRadioOptionInherited({
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  final T? groupValue;
  final ValueChanged<T?> onChanged;

  static _BkRadioOptionInherited<T>? of<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_BkRadioOptionInherited<T>>();
  }

  @override
  bool updateShouldNotify(_BkRadioOptionInherited<T> old) =>
      groupValue != old.groupValue;
}
