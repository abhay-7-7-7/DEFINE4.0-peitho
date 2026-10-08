import 'package:flutter/material.dart';
import '../theme/bk_motion.dart';

/// Neubrutalist staggered entrance reveal animation.
/// Fades, slides up, and settles with a subtle brutalist rotational twist.
class BkReveal extends StatefulWidget {
  const BkReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = BkMotion.reveal,
    this.curve = BkMotion.revealCurve,
    this.slideOffset = const Offset(0, 24),
    this.initialRotation = 0.02, // ~1.1 degrees settle
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final double initialRotation;

  @override
  State<BkReveal> createState() => _BkRevealState();
}

class _BkRevealState extends State<BkReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = CurvedAnimation(parent: _controller, curve: widget.curve);
    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _rotate = Tween<double>(
      begin: widget.initialRotation,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!BkMotion.shouldAnimate(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: _slide.value,
            child: Transform.rotate(
              angle: _rotate.value,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
