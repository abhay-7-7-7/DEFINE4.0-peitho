import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

class BkSkeleton extends StatefulWidget {
  const BkSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20.0,
    this.isRound = false,
  });

  final double width;
  final double height;
  final bool isRound;

  @override
  State<BkSkeleton> createState() => _BkSkeletonState();
}

class _BkSkeletonState extends State<BkSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final factor = disableAnimations ? 0.5 : _controller.value;
        final color =
            Color.lerp(t.muted, t.muted.withValues(alpha: 0.4), factor)!;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: t.border, width: t.borderWidth * 0.75),
          ),
        );
      },
    );
  }
}
