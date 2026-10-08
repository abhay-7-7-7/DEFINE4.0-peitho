import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkRadioOption<T> {
  const BkRadioOption({
    required this.value,
    required this.label,
    this.description,
  });

  final T value;
  final String label;
  final String? description;
}

/// A neubrutalist Radio Group with square geometry, 3px border, and hard shadow.
class BkRadioGroup<T> extends StatelessWidget {
  const BkRadioGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.label,
    this.direction = Axis.vertical,
  });

  final List<BkRadioOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onChanged;
  final String? label;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (direction == Axis.vertical)
          Column(
            children: options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BkRadio<T>(
                  value: opt.value,
                  groupValue: selectedValue,
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                  label: opt.label,
                  description: opt.description,
                ),
              );
            }).toList(),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options.map((opt) {
              return BkRadio<T>(
                value: opt.value,
                groupValue: selectedValue,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                label: opt.label,
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Individual neubrutalist radio item with tactile feedback.
class BkRadio<T> extends StatefulWidget {
  const BkRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.description,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String label;
  final String? description;

  @override
  State<BkRadio<T>> createState() => _BkRadioState<T>();
}

class _BkRadioState<T> extends State<BkRadio<T>> {
  bool _pressed = false;

  bool get _isSelected => widget.value == widget.groupValue;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        BkMotion.hapticClick();
        widget.onChanged(widget.value);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Row(
        crossAxisAlignment: widget.description != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: BkMotion.press,
            curve: BkMotion.pressCurve,
            width: 22,
            height: 22,
            transform: Matrix4.translationValues(
              _pressed ? 1 : 0,
              _pressed ? 1 : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: _pressed
                  ? null
                  : [
                      BoxShadow(
                        color: t.shadowColor,
                        offset: Offset(t.shadowOffset - 2, t.shadowOffset - 2),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: _isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      color: t.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: _isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: t.foreground,
                  ),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.description!,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: t.mutedForeground),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
