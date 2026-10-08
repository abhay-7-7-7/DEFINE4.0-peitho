import 'package:flutter/material.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

/// A neubrutalist popover floating card anchored to a trigger widget.
class BkPopover extends StatelessWidget {
  const BkPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.width = 240,
  });

  final Widget trigger;
  final Widget content;
  final double width;

  void _show(BuildContext context) {
    BkMotion.hapticLight();
    final t = BkTokens.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final left = (offset.dx + size.width / 2 - width / 2)
        .clamp(16.0, screenSize.width - width - 16);
    final top = offset.dy + size.height + 8;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Popover',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
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
                  child: content,
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
      onTap: () => _show(context),
      child: trigger,
    );
  }
}
