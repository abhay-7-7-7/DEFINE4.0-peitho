import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkMenuItem {
  const BkMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.isDestructive = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? shortcut;
  final bool isDestructive;
  final VoidCallback? onTap;
}

/// A neubrutalist dropdown menu triggered from an anchor widget.
class BkDropdownMenu extends StatelessWidget {
  const BkDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
  });

  final Widget trigger;
  final List<BkMenuItem> items;

  void _showMenu(BuildContext context) {
    BkMotion.hapticLight();
    final t = BkTokens.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dropdown',
      barrierColor: Colors.black26,
      transitionDuration: BkMotion.press,
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx.clamp(16.0, MediaQuery.of(ctx).size.width - 240),
              top: offset.dy + size.height + 6,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((item) {
                      final itemColor =
                          item.isDestructive ? t.destructive : t.foreground;

                      return ListTile(
                        dense: true,
                        leading: item.icon != null
                            ? Icon(item.icon, size: 18, color: itemColor)
                            : null,
                        title: Text(
                          item.label.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: itemColor,
                          ),
                        ),
                        trailing: item.shortcut != null
                            ? Text(
                                item.shortcut!,
                                style: GoogleFonts.dmMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: t.mutedForeground,
                                ),
                              )
                            : null,
                        onTap: () {
                          BkMotion.hapticClick();
                          Navigator.of(ctx).pop();
                          item.onTap?.call();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: trigger,
    );
  }
}
