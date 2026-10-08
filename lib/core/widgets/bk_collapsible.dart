import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

/// Neubrutalist collapsible section with animated expand/collapse transition.
class BkCollapsible extends StatefulWidget {
  const BkCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.badge,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? badge;

  @override
  State<BkCollapsible> createState() => _BkCollapsibleState();
}

class _BkCollapsibleState extends State<BkCollapsible>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _controller;
  late final Animation<double> _chevronTurns;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _chevronTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_expanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    BkMotion.hapticClick();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: _expanded
                  ? t.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: t.foreground,
                      ),
                    ),
                  ),
                  if (widget.badge != null) ...[
                    widget.badge!,
                    const SizedBox(width: 8),
                  ],
                  RotationTransition(
                    turns: _chevronTurns,
                    child: Icon(Icons.keyboard_arrow_down,
                        size: 22, color: t.foreground),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: t.border, width: 2)),
              ),
              child: widget.child,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
