import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

/// BkSwitch — Neubrutalism rectangular toggle switch with square thumb.
class BkSwitch extends StatefulWidget {
  const BkSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size = 28.0,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  @override
  State<BkSwitch> createState() => _BkSwitchState();
}

class _BkSwitchState extends State<BkSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(BkSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final width = widget.size * 2.1;
    final height = widget.size;
    final thumbSize = height - (t.borderWidth * 2) - 4;

    final activeTrack = widget.activeColor ?? t.primary;
    final inactiveTrack = widget.inactiveColor ?? t.muted;

    return Semantics(
      toggled: widget.value,
      enabled: widget.onChanged != null,
      child: GestureDetector(
        onTap: widget.onChanged != null
            ? () => widget.onChanged!(!widget.value)
            : null,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final trackColor =
                Color.lerp(inactiveTrack, activeTrack, _animation.value)!;
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: trackColor,
                border: Border.all(color: t.border, width: t.borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: t.shadowColor,
                    offset:
                        Offset(t.shadowOffset * 0.75, t.shadowOffset * 0.75),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 2 +
                        ((width - thumbSize - (t.borderWidth * 2) - 4) *
                            _animation.value),
                    top: 2,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: t.card,
                        border: Border.all(
                            color: t.border, width: t.borderWidth * 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
