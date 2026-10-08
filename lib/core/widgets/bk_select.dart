import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkSelectItem<T> {
  const BkSelectItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Neubrutalist dropdown select input with 3px border and 4px offset shadow.
class BkSelect<T> extends StatefulWidget {
  const BkSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder = 'SELECT OPTION',
    this.enabled = true,
  });

  final List<BkSelectItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;

  @override
  State<BkSelect<T>> createState() => _BkSelectState<T>();
}

class _BkSelectState<T> extends State<BkSelect<T>> {
  bool _pressed = false;

  void _showOptions(BuildContext context) {
    if (!widget.enabled) return;
    BkMotion.hapticLight();
    final t = BkTokens.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: t.background,
            border:
                Border(top: BorderSide(color: t.border, width: t.borderWidth)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.label != null) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.label!.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: t.foreground,
                      ),
                    ),
                  ),
                ),
                Divider(height: 16, thickness: t.borderWidth, color: t.border),
              ],
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item.value == widget.value;

                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: item.icon != null
                            ? Icon(item.icon,
                                color: isSelected ? t.primary : t.foreground)
                            : null,
                        title: Text(
                          item.label.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected ? t.primary : t.foreground,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_box, color: t.primary, size: 24)
                            : Icon(Icons.check_box_outline_blank,
                                color: t.mutedForeground, size: 24),
                        tileColor: isSelected
                            ? t.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        onTap: () {
                          BkMotion.hapticClick();
                          widget.onChanged(item.value);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final selectedItem = widget.items.cast<BkSelectItem<T>?>().firstWhere(
          (item) => item?.value == widget.value,
          orElse: () => null,
        );

    final offset = _pressed ? 0.0 : t.shadowOffset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            _showOptions(context);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: BkMotion.press,
            curve: BkMotion.pressCurve,
            transform: Matrix4.translationValues(
              _pressed ? 2 : 0,
              _pressed ? 2 : 0,
              0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.enabled ? t.card : t.muted,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: offset > 0
                  ? [
                      BoxShadow(
                        color: t.shadowColor,
                        offset: Offset(offset, offset),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (selectedItem?.icon != null) ...[
                  Icon(selectedItem!.icon, size: 18, color: t.foreground),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    (selectedItem?.label ?? widget.placeholder).toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: selectedItem != null
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: selectedItem != null
                          ? t.foreground
                          : t.mutedForeground,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: t.foreground, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
