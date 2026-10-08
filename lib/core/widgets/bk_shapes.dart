import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

enum BkShapeType {
  triangle,
  diamond,
  pentagon,
  hexagon,
  octagon,
  cross,
  arrow,
  chevron,
  blob,
  cloud,
  splash,
  leaf,
  flower,
  heart,
  star,
  starSharp,
  moon,
  sun,
  lightning,
  rocket,
  planet,
  cosmicRing,
  infinity,
  spiral,
  fractal,
  mobius,
  wave,
  gear,
  cog,
  circuit,
  target,
  shield,
  bracket,
}

enum BkShapeAnimation {
  none,
  spin,
  pulse,
  float,
  wiggle,
  bounce,
}

enum BkShapeSpeed {
  slow,
  normal,
  fast,
}

class BkShape extends StatefulWidget {
  const BkShape({
    super.key,
    required this.shape,
    this.size = 100.0,
    this.strokeWidth = 3.0,
    this.filled = true,
    this.color,
    this.strokeColor,
    this.animation = BkShapeAnimation.none,
    this.speed = BkShapeSpeed.normal,
  });

  final BkShapeType shape;
  final double size;
  final double strokeWidth;
  final bool filled;
  final Color? color;
  final Color? strokeColor;
  final BkShapeAnimation animation;
  final BkShapeSpeed speed;

  @override
  State<BkShape> createState() => _BkShapeState();
}

class _BkShapeState extends State<BkShape> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final duration = switch (widget.speed) {
      BkShapeSpeed.slow => const Duration(seconds: 4),
      BkShapeSpeed.normal => const Duration(seconds: 2),
      BkShapeSpeed.fast => const Duration(milliseconds: 1000),
    };
    _controller = AnimationController(vsync: this, duration: duration);
    if (widget.animation != BkShapeAnimation.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(BkShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      if (widget.animation == BkShapeAnimation.none) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
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
    final fillCol = widget.color ?? t.primary;
    final strokeCol = widget.strokeColor ?? t.border;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _BkShapePainter(
          shape: widget.shape,
          filled: widget.filled,
          fillColor: fillCol,
          strokeColor: strokeCol,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );

    if (disableAnimations || widget.animation == BkShapeAnimation.none) {
      return child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        switch (widget.animation) {
          case BkShapeAnimation.spin:
            return Transform.rotate(
              angle: val * 2 * math.pi,
              child: child,
            );
          case BkShapeAnimation.pulse:
            final scale = 0.85 + 0.15 * math.sin(val * 2 * math.pi);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          case BkShapeAnimation.float:
            final dy = -8.0 * math.sin(val * 2 * math.pi);
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          case BkShapeAnimation.wiggle:
            final angle = 0.1 * math.sin(val * 4 * math.pi);
            return Transform.rotate(
              angle: angle,
              child: child,
            );
          case BkShapeAnimation.bounce:
            final dy = -12.0 * math.sin(val * math.pi).abs();
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          case BkShapeAnimation.none:
            return child!;
        }
      },
      child: child,
    );
  }
}

class _BkShapePainter extends CustomPainter {
  const _BkShapePainter({
    required this.shape,
    required this.filled,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final BkShapeType shape;
  final bool filled;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final path = _getPath(shape);

    if (filled) {
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  Path _getPath(BkShapeType type) {
    final p = Path();
    switch (type) {
      case BkShapeType.triangle:
        p.moveTo(50, 5);
        p.lineTo(95, 90);
        p.lineTo(5, 90);
        p.close();
      case BkShapeType.diamond:
        p.moveTo(50, 5);
        p.lineTo(95, 50);
        p.lineTo(50, 95);
        p.lineTo(5, 50);
        p.close();
      case BkShapeType.pentagon:
        for (int i = 0; i < 5; i++) {
          final a = -math.pi / 2 + (i * 2 * math.pi / 5);
          final x = 50 + 45 * math.cos(a);
          final y = 50 + 45 * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.hexagon:
        for (int i = 0; i < 6; i++) {
          final a = (i * 2 * math.pi / 6);
          final x = 50 + 45 * math.cos(a);
          final y = 50 + 45 * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.octagon:
        for (int i = 0; i < 8; i++) {
          final a = (i * 2 * math.pi / 8) + (math.pi / 8);
          final x = 50 + 45 * math.cos(a);
          final y = 50 + 45 * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.cross:
        p.moveTo(35, 5);
        p.lineTo(65, 5);
        p.lineTo(65, 35);
        p.lineTo(95, 35);
        p.lineTo(95, 65);
        p.lineTo(65, 65);
        p.lineTo(65, 95);
        p.lineTo(35, 95);
        p.lineTo(35, 65);
        p.lineTo(5, 65);
        p.lineTo(5, 35);
        p.lineTo(35, 35);
        p.close();
      case BkShapeType.arrow:
        p.moveTo(5, 35);
        p.lineTo(55, 35);
        p.lineTo(55, 10);
        p.lineTo(95, 50);
        p.lineTo(55, 90);
        p.lineTo(55, 65);
        p.lineTo(5, 65);
        p.close();
      case BkShapeType.chevron:
        p.moveTo(10, 10);
        p.lineTo(50, 50);
        p.lineTo(10, 90);
        p.lineTo(35, 90);
        p.lineTo(75, 50);
        p.lineTo(35, 10);
        p.close();
      case BkShapeType.blob:
        p.moveTo(50, 10);
        p.cubicTo(80, 5, 95, 35, 90, 65);
        p.cubicTo(85, 90, 55, 95, 35, 90);
        p.cubicTo(10, 85, 5, 55, 15, 35);
        p.cubicTo(20, 20, 30, 12, 50, 10);
        p.close();
      case BkShapeType.cloud:
        p.moveTo(30, 75);
        p.lineTo(75, 75);
        p.arcToPoint(const Offset(85, 55), radius: const Radius.circular(15));
        p.arcToPoint(const Offset(65, 30), radius: const Radius.circular(20));
        p.arcToPoint(const Offset(35, 35), radius: const Radius.circular(20));
        p.arcToPoint(const Offset(15, 55), radius: const Radius.circular(15));
        p.arcToPoint(const Offset(30, 75), radius: const Radius.circular(15));
        p.close();
      case BkShapeType.splash:
        for (int i = 0; i < 16; i++) {
          final a = i * 2 * math.pi / 16;
          final r = i.isEven ? 45.0 : 25.0;
          final x = 50 + r * math.cos(a);
          final y = 50 + r * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.leaf:
        p.moveTo(10, 90);
        p.quadraticBezierTo(10, 10, 90, 10);
        p.quadraticBezierTo(90, 90, 10, 90);
        p.close();
      case BkShapeType.flower:
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final cx = 50 + 25 * math.cos(a);
          final cy = 50 + 25 * math.sin(a);
          p.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: 18));
        }
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 16));
      case BkShapeType.heart:
        p.moveTo(50, 85);
        p.cubicTo(15, 60, 5, 35, 25, 15);
        p.cubicTo(40, 2, 50, 25, 50, 25);
        p.cubicTo(50, 25, 60, 2, 75, 15);
        p.cubicTo(95, 35, 85, 60, 50, 85);
        p.close();
      case BkShapeType.star:
        for (int i = 0; i < 10; i++) {
          final a = -math.pi / 2 + (i * math.pi / 5);
          final r = i.isEven ? 45.0 : 20.0;
          final x = 50 + r * math.cos(a);
          final y = 50 + r * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.starSharp:
        for (int i = 0; i < 12; i++) {
          final a = -math.pi / 2 + (i * math.pi / 6);
          final r = i.isEven ? 46.0 : 14.0;
          final x = 50 + r * math.cos(a);
          final y = 50 + r * math.sin(a);
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
        p.close();
      case BkShapeType.moon:
        p.moveTo(50, 10);
        p.arcToPoint(const Offset(50, 90),
            radius: const Radius.circular(40), clockwise: false);
        p.arcToPoint(const Offset(50, 10),
            radius: const Radius.circular(30), clockwise: true);
        p.close();
      case BkShapeType.sun:
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 24));
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final x1 = 50 + 30 * math.cos(a);
          final y1 = 50 + 30 * math.sin(a);
          final x2 = 50 + 44 * math.cos(a);
          final y2 = 50 + 44 * math.sin(a);
          p.moveTo(x1, y1);
          p.lineTo(x2, y2);
        }
      case BkShapeType.lightning:
        p.moveTo(55, 5);
        p.lineTo(15, 55);
        p.lineTo(45, 55);
        p.lineTo(35, 95);
        p.lineTo(85, 42);
        p.lineTo(55, 42);
        p.close();
      case BkShapeType.rocket:
        p.moveTo(50, 10);
        p.quadraticBezierTo(70, 35, 65, 75);
        p.lineTo(80, 85);
        p.lineTo(65, 80);
        p.lineTo(50, 85);
        p.lineTo(35, 80);
        p.lineTo(20, 85);
        p.lineTo(35, 75);
        p.quadraticBezierTo(30, 35, 50, 10);
        p.close();
      case BkShapeType.planet:
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 26));
        p.addOval(Rect.fromCenter(
            center: const Offset(50, 50), width: 88, height: 24));
      case BkShapeType.cosmicRing:
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 40));
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 24));
      case BkShapeType.infinity:
        p.moveTo(50, 50);
        p.cubicTo(65, 25, 85, 25, 85, 50);
        p.cubicTo(85, 75, 65, 75, 50, 50);
        p.cubicTo(35, 25, 15, 25, 15, 50);
        p.cubicTo(15, 75, 35, 75, 50, 50);
        p.close();
      case BkShapeType.spiral:
        p.moveTo(50, 50);
        for (double t = 0; t < 6 * math.pi; t += 0.2) {
          final r = 2.2 * t;
          final x = 50 + r * math.cos(t);
          final y = 50 + r * math.sin(t);
          p.lineTo(x, y);
        }
      case BkShapeType.fractal:
        p.moveTo(50, 10);
        p.lineTo(80, 35);
        p.lineTo(70, 55);
        p.lineTo(90, 75);
        p.lineTo(50, 85);
        p.lineTo(10, 75);
        p.lineTo(30, 55);
        p.lineTo(20, 35);
        p.close();
      case BkShapeType.mobius:
        p.moveTo(15, 35);
        p.cubicTo(30, 10, 70, 10, 85, 35);
        p.cubicTo(95, 55, 75, 85, 50, 65);
        p.cubicTo(25, 45, 5, 75, 15, 35);
        p.close();
      case BkShapeType.wave:
        p.moveTo(5, 50);
        p.cubicTo(25, 20, 40, 80, 60, 50);
        p.cubicTo(75, 25, 85, 75, 95, 50);
        p.lineTo(95, 75);
        p.lineTo(5, 75);
        p.close();
      case BkShapeType.gear:
        for (int i = 0; i < 8; i++) {
          final a1 = i * math.pi / 4;
          final a2 = a1 + math.pi / 12;
          final a3 = a2 + math.pi / 12;
          final a4 = a3 + math.pi / 12;
          p.lineTo(50 + 44 * math.cos(a1), 50 + 44 * math.sin(a1));
          p.lineTo(50 + 44 * math.cos(a2), 50 + 44 * math.sin(a2));
          p.lineTo(50 + 32 * math.cos(a3), 50 + 32 * math.sin(a3));
          p.lineTo(50 + 32 * math.cos(a4), 50 + 32 * math.sin(a4));
        }
        p.close();
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 14));
      case BkShapeType.cog:
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 36));
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 16));
      case BkShapeType.circuit:
        p.moveTo(10, 50);
        p.lineTo(35, 50);
        p.lineTo(50, 30);
        p.lineTo(75, 30);
        p.lineTo(90, 50);
        p.addOval(Rect.fromCircle(center: const Offset(90, 50), radius: 6));
        p.addOval(Rect.fromCircle(center: const Offset(10, 50), radius: 6));
      case BkShapeType.target:
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 42));
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 28));
        p.addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 14));
        p.moveTo(50, 4);
        p.lineTo(50, 96);
        p.moveTo(4, 50);
        p.lineTo(96, 50);
      case BkShapeType.shield:
        p.moveTo(50, 10);
        p.lineTo(85, 20);
        p.lineTo(85, 55);
        p.cubicTo(85, 75, 50, 92, 50, 92);
        p.cubicTo(50, 92, 15, 75, 15, 55);
        p.lineTo(15, 20);
        p.close();
      case BkShapeType.bracket:
        p.moveTo(35, 10);
        p.lineTo(15, 10);
        p.lineTo(15, 90);
        p.lineTo(35, 90);
        p.moveTo(65, 10);
        p.lineTo(85, 10);
        p.lineTo(85, 90);
        p.lineTo(65, 90);
    }
    return p;
  }

  @override
  bool shouldRepaint(covariant _BkShapePainter old) =>
      old.shape != shape ||
      old.filled != filled ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor ||
      old.strokeWidth != strokeWidth;
}
