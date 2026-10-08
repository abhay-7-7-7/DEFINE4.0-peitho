import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

enum BkSpinnerVariant { defaultRing, dots, bars, blocks, brutal }

class BkSpinner extends StatefulWidget {
  const BkSpinner({
    super.key,
    this.variant = BkSpinnerVariant.defaultRing,
    this.size = 32.0,
    this.color,
  });

  final BkSpinnerVariant variant;
  final double size;
  final Color? color;

  @override
  State<BkSpinner> createState() => _BkSpinnerState();
}

class _BkSpinnerState extends State<BkSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final color = widget.color ?? t.foreground;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            switch (widget.variant) {
              case BkSpinnerVariant.dots:
                return _buildDots(color);
              case BkSpinnerVariant.bars:
                return _buildBars(color);
              case BkSpinnerVariant.blocks:
                return _buildBlocks(color);
              case BkSpinnerVariant.brutal:
                return _buildBrutal(t, color);
              case BkSpinnerVariant.defaultRing:
                return _buildRing(t, color);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRing(BkTokens t, Color color) {
    return Transform.rotate(
      angle: _controller.value * 2 * math.pi,
      child: CustomPaint(
        painter: _RingPainter(color: color, strokeWidth: t.borderWidth),
      ),
    );
  }

  Widget _buildDots(Color color) {
    final dotSize = widget.size * 0.22;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final phase = (_controller.value + (index * 0.2)) % 1.0;
        final bounce = math.sin(phase * math.pi);
        return Transform.translate(
          offset: Offset(0, -bounce * (widget.size * 0.25)),
          child: Container(
            width: dotSize,
            height: dotSize,
            color: color,
          ),
        );
      }),
    );
  }

  Widget _buildBars(Color color) {
    final barWidth = widget.size * 0.18;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        final phase = (_controller.value + (index * 0.25)) % 1.0;
        final scale = 0.3 + (0.7 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi)));
        return Container(
          width: barWidth,
          height: widget.size * scale,
          color: color,
        );
      }),
    );
  }

  Widget _buildBlocks(Color color) {
    final blockSize = widget.size * 0.35;
    final angle = _controller.value * 2 * math.pi;
    final r = widget.size * 0.25;
    return Stack(
      children: List.generate(4, (index) {
        final a = angle + (index * (math.pi / 2));
        final x = (widget.size / 2 - blockSize / 2) + r * math.cos(a);
        final y = (widget.size / 2 - blockSize / 2) + r * math.sin(a);
        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: blockSize,
            height: blockSize,
            color: color,
          ),
        );
      }),
    );
  }

  Widget _buildBrutal(BkTokens t, Color color) {
    final angle = _controller.value * 2 * math.pi;
    const offset = 4.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(offset, offset),
          child: Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            color: t.primary,
          ),
        ),
        Transform.rotate(
          angle: angle,
          child: Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: t.border, width: t.borderWidth),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
