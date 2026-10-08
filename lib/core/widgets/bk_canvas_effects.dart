import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

enum BkCanvasEffectType {
  meshGradient,
  aurora,
  plasma,
  halftone,
  truchet,
  flowField,
  crt,
  metaballs
}

class BkCanvasEffect extends StatefulWidget {
  const BkCanvasEffect({
    super.key,
    required this.type,
    this.child,
    this.speed = 1.0,
    this.colors,
  });

  final BkCanvasEffectType type;
  final Widget? child;
  final double speed;
  final List<Color>? colors;

  @override
  State<BkCanvasEffect> createState() => _BkCanvasEffectState();
}

class _BkCanvasEffectState extends State<BkCanvasEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (3000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(BkCanvasEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration =
          Duration(milliseconds: (3000 / widget.speed).round());
      if (!_controller.isAnimating) _controller.repeat();
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
    final palette = widget.colors ?? [t.primary, t.secondary, t.accent, t.info];
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final time = disableAnimations ? 0.5 : _controller.value;
              return CustomPaint(
                painter: _getPainter(widget.type, time, palette, t),
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  CustomPainter _getPainter(
      BkCanvasEffectType type, double time, List<Color> colors, BkTokens t) {
    switch (type) {
      case BkCanvasEffectType.meshGradient:
        return _MeshGradientPainter(time: time, colors: colors);
      case BkCanvasEffectType.aurora:
        return _AuroraPainter(time: time, colors: colors);
      case BkCanvasEffectType.plasma:
        return _PlasmaPainter(time: time, colors: colors);
      case BkCanvasEffectType.halftone:
        return _HalftonePainter(
            time: time, colors: colors, fgColor: t.foreground);
      case BkCanvasEffectType.truchet:
        return _TruchetPainter(
            time: time, color: colors.first, borderColor: t.border);
      case BkCanvasEffectType.flowField:
        return _FlowFieldPainter(time: time, colors: colors);
      case BkCanvasEffectType.crt:
        return _CrtPainter(time: time, fgColor: t.foreground);
      case BkCanvasEffectType.metaballs:
        return _MetaballsPainter(time: time, colors: colors);
    }
  }
}

// 1. Mesh Gradient
class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({required this.time, required this.colors});
  final double time;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final c1 = colors[0 % colors.length];
    final c2 = colors[1 % colors.length];
    final c3 = colors[2 % colors.length];

    final offset1 = Offset(
        size.width * (0.3 + 0.2 * math.sin(time * 2 * math.pi)),
        size.height * (0.3 + 0.2 * math.cos(time * 2 * math.pi)));
    final offset2 = Offset(
        size.width * (0.7 + 0.2 * math.cos(time * 2 * math.pi)),
        size.height * (0.7 + 0.2 * math.sin(time * 2 * math.pi)));

    paint.shader = RadialGradient(
      center: Alignment(
          offset1.dx / size.width * 2 - 1, offset1.dy / size.height * 2 - 1),
      radius: 0.8,
      colors: [c1, c1.withValues(alpha: 0.0)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    paint.shader = RadialGradient(
      center: Alignment(
          offset2.dx / size.width * 2 - 1, offset2.dy / size.height * 2 - 1),
      radius: 0.8,
      colors: [c2, c2.withValues(alpha: 0.0)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    paint.shader = RadialGradient(
      center: const Alignment(0, 0),
      radius: 0.6,
      colors: [c3.withValues(alpha: 0.4), Colors.transparent],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter old) => old.time != time;
}

// 2. Aurora
class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.time, required this.colors});
  final double time;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final color = colors[i % colors.length].withValues(alpha: 0.35);
      final paint = Paint()..color = color;

      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height * 0.4 +
            math.sin((x / size.width * 4) + (time * 2 * math.pi) + i) * 30 +
            math.cos((x / size.width * 2) - (time * 2 * math.pi)) * 20;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.time != time;
}

// 3. Plasma
class _PlasmaPainter extends CustomPainter {
  _PlasmaPainter({required this.time, required this.colors});
  final double time;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final v1 = math.sin(x * 0.02 + time * 2 * math.pi);
        final v2 = math.sin(y * 0.02 + time * 2 * math.pi);
        final v3 = math.sin((x + y) * 0.02 + time * 2 * math.pi);
        final val = (v1 + v2 + v3 + 3) / 6;

        final colorIndex =
            (val * (colors.length - 1)).floor().clamp(0, colors.length - 1);
        paint.color = colors[colorIndex].withValues(alpha: 0.7);

        canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlasmaPainter old) => old.time != time;
}

// 4. Halftone
class _HalftonePainter extends CustomPainter {
  _HalftonePainter(
      {required this.time, required this.colors, required this.fgColor});
  final double time;
  final List<Color> colors;
  final Color fgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = fgColor;
    const spacing = 16.0;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        final dist = math.sqrt(
            math.pow(x - size.width / 2, 2) + math.pow(y - size.height / 2, 2));
        final radius = (spacing / 2) *
            (0.5 + 0.4 * math.sin(dist * 0.05 - time * 2 * math.pi));
        canvas.drawCircle(Offset(x, y), math.max(1, radius), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter old) => old.time != time;
}

// 5. Truchet
class _TruchetPainter extends CustomPainter {
  _TruchetPainter(
      {required this.time, required this.color, required this.borderColor});
  final double time;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 32.0;
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    int seed = 0;
    for (double x = 0; x < size.width; x += tileSize) {
      for (double y = 0; y < size.height; y += tileSize) {
        final toggle = ((seed++ * 17 + (time * 4).floor()) % 2) == 0;
        if (toggle) {
          canvas.drawArc(
              Rect.fromLTWH(
                  x - tileSize / 2, y - tileSize / 2, tileSize, tileSize),
              0,
              math.pi / 2,
              false,
              paint);
          canvas.drawArc(
              Rect.fromLTWH(
                  x + tileSize / 2, y + tileSize / 2, tileSize, tileSize),
              math.pi,
              math.pi / 2,
              false,
              paint);
        } else {
          canvas.drawArc(
              Rect.fromLTWH(
                  x + tileSize / 2, y - tileSize / 2, tileSize, tileSize),
              math.pi / 2,
              math.pi / 2,
              false,
              paint);
          canvas.drawArc(
              Rect.fromLTWH(
                  x - tileSize / 2, y + tileSize / 2, tileSize, tileSize),
              math.pi * 1.5,
              math.pi / 2,
              false,
              paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TruchetPainter old) => old.time != time;
}

// 6. Flow Field
class _FlowFieldPainter extends CustomPainter {
  _FlowFieldPainter({required this.time, required this.colors});
  final double time;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const step = 20.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        final angle = math.sin(x * 0.01 + time * 2 * math.pi) +
            math.cos(y * 0.01 + time * 2 * math.pi);
        const length = 12.0;
        final dx = length * math.cos(angle);
        final dy = length * math.sin(angle);

        paint.color = colors[((x + y) / step).floor() % colors.length];
        canvas.drawLine(Offset(x, y), Offset(x + dx, y + dy), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowFieldPainter old) => old.time != time;
}

// 7. CRT
class _CrtPainter extends CustomPainter {
  _CrtPainter({required this.time, required this.fgColor});
  final double time;
  final Color fgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fgColor.withValues(alpha: 0.08)
      ..strokeWidth = 1.5;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final sweepY = (time * size.height) % size.height;
    final sweepPaint = Paint()
      ..color = fgColor.withValues(alpha: 0.08)
      ..strokeWidth = 20;
    canvas.drawLine(Offset(0, sweepY), Offset(size.width, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _CrtPainter old) => old.time != time;
}

// 8. Metaballs
class _MetaballsPainter extends CustomPainter {
  _MetaballsPainter({required this.time, required this.colors});
  final double time;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final balls = [
      Offset(size.width * (0.4 + 0.2 * math.sin(time * 2 * math.pi)),
          size.height * (0.5 + 0.2 * math.cos(time * 2 * math.pi))),
      Offset(size.width * (0.6 + 0.2 * math.cos(time * 2 * math.pi)),
          size.height * (0.4 + 0.2 * math.sin(time * 2 * math.pi))),
      Offset(size.width * (0.5 + 0.2 * math.sin(time * 4 * math.pi)),
          size.height * (0.6 + 0.15 * math.cos(time * 4 * math.pi))),
    ];

    for (int i = 0; i < balls.length; i++) {
      final ball = balls[i];
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(ball, 50, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MetaballsPainter old) => old.time != time;
}
