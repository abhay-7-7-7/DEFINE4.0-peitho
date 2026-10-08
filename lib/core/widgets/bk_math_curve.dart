// lib/core/widgets/bk_math_curve.dart
// BoldKit Math Curve widgets:
//   - BkMathCurveLoader  : parametric curve with animated square head
//   - BkMathCurveProgress: curve filling to a progress value
//   - BkMathCurveBackground: full-widget animated curve background

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum BkMathCurveType {
  rose,
  lissajous,
  spirograph,
  hypotrochoid,
  epitrochoid,
  butterfly,
  fermat,
  maclaurin,
  cardioid,
  deltoid,
}

typedef BkCurveType = BkMathCurveType;

enum BkMathCurveSpeed {
  slow,
  normal,
  fast,
}

extension _SpeedExt on BkMathCurveSpeed {
  double get multiplier {
    switch (this) {
      case BkMathCurveSpeed.slow:   return 0.4;
      case BkMathCurveSpeed.normal: return 1.0;
      case BkMathCurveSpeed.fast:   return 2.5;
    }
  }
}

// ---------------------------------------------------------------------------
// Curve sampling
// ---------------------------------------------------------------------------

/// Samples 200 (x, y) points in [−1, 1] for the requested curve.
/// The output is normalized so the bounding box fits inside [−1, 1].
List<Offset> sampleCurve(BkMathCurveType curve, {int samples = 200}) {
  final raw = <Offset>[];
  final tMax = _tMax(curve);

  for (int i = 0; i <= samples; i++) {
    final t = i / samples * tMax;
    raw.add(_evalCurve(curve, t));
  }

  // Normalize to [-1, 1]
  double minX = raw[0].dx, maxX = raw[0].dx;
  double minY = raw[0].dy, maxY = raw[0].dy;
  for (final p in raw) {
    if (p.dx < minX) minX = p.dx;
    if (p.dx > maxX) maxX = p.dx;
    if (p.dy < minY) minY = p.dy;
    if (p.dy > maxY) maxY = p.dy;
  }
  final rangeX = maxX - minX;
  final rangeY = maxY - minY;
  final range = math.max(rangeX, rangeY);
  if (range == 0) return raw;
  return raw
      .map((p) => Offset(
            (p.dx - (minX + maxX) / 2) / (range / 2),
            (p.dy - (minY + maxY) / 2) / (range / 2),
          ))
      .toList();
}

double _tMax(BkMathCurveType curve) {
  switch (curve) {
    case BkMathCurveType.rose:        return 2 * math.pi;
    case BkMathCurveType.lissajous:   return 2 * math.pi;
    case BkMathCurveType.spirograph:  return 6 * math.pi;
    case BkMathCurveType.hypotrochoid: return 6 * math.pi;
    case BkMathCurveType.epitrochoid: return 6 * math.pi;
    case BkMathCurveType.butterfly:   return 4 * math.pi;
    case BkMathCurveType.fermat:      return 2 * math.pi;
    case BkMathCurveType.maclaurin:   return 2 * math.pi;
    case BkMathCurveType.cardioid:    return 2 * math.pi;
    case BkMathCurveType.deltoid:     return 2 * math.pi;
  }
}

Offset _evalCurve(BkMathCurveType curve, double t) {
  switch (curve) {
    case BkMathCurveType.rose: {
      const k = 3.0;
      final r = math.cos(k * t);
      return Offset(r * math.cos(t), r * math.sin(t));
    }
    case BkMathCurveType.lissajous: {
      const a = 3.0, b = 2.0, delta = math.pi / 2;
      return Offset(math.sin(a * t + delta), math.sin(b * t));
    }
    case BkMathCurveType.spirograph:
    case BkMathCurveType.hypotrochoid: {
      const R = 5.0, r = 3.0, d = 5.0;
      final x = (R - r) * math.cos(t) + d * math.cos((R - r) / r * t);
      final y = (R - r) * math.sin(t) - d * math.sin((R - r) / r * t);
      return Offset(x, y);
    }
    case BkMathCurveType.epitrochoid: {
      const R = 3.0, r = 1.0, d = 2.5;
      final x = (R + r) * math.cos(t) - d * math.cos((R + r) / r * t);
      final y = (R + r) * math.sin(t) - d * math.sin((R + r) / r * t);
      return Offset(x, y);
    }
    case BkMathCurveType.butterfly: {
      final expSin = math.exp(math.sin(t));
      final cos4 = 2 * math.cos(4 * t);
      final s = math.sin((2 * t - math.pi) / 24);
      final rVal = expSin - cos4 + s * s * s * s * s;
      return Offset(rVal * math.cos(t), rVal * math.sin(t));
    }
    case BkMathCurveType.fermat: {
      final rVal = math.sqrt(t.abs()) * (t >= 0 ? 1 : -1);
      return Offset(rVal * math.cos(t), rVal * math.sin(t));
    }
    case BkMathCurveType.maclaurin: {
      // Maclaurin trisectrix: x = a*(t^2-3)/(t^2+1), y = a*t*(t^2-3)/(t^2+1)
      // parametric via angle
      const a = 1.0;
      final cosT = math.cos(t);
      final sinT = math.sin(t);
      // r = a * (4*cos(t) - sec(t)) in polar, but use Cartesian form
      if (cosT.abs() < 0.01) return Offset.zero;
      final rVal = a * (4 * cosT - 1 / cosT);
      return Offset(rVal * cosT, rVal * sinT);
    }
    case BkMathCurveType.cardioid: {
      const r = 0.5;
      final rVal = 2 * r * (1 - math.cos(t));
      return Offset(rVal * math.cos(t), rVal * math.sin(t));
    }
    case BkMathCurveType.deltoid: {
      const R = 1.0, r = 1 / 3;
      final x = (R - r) * math.cos(t) + r * math.cos((R - r) / r * t);
      final y = (R - r) * math.sin(t) - r * math.sin((R - r) / r * t);
      return Offset(x, y);
    }
  }
}

// ---------------------------------------------------------------------------
// Helper: build a Flutter Path from normalized curve points
// ---------------------------------------------------------------------------

Path _buildPath(List<Offset> pts, Size size) {
  final path = Path();
  if (pts.isEmpty) return path;
  final cx = size.width / 2;
  final cy = size.height / 2;
  final sc = math.min(cx, cy) * 0.9;
  final first = pts.first;
  path.moveTo(cx + first.dx * sc, cy + first.dy * sc);
  for (int i = 1; i < pts.length; i++) {
    path.lineTo(cx + pts[i].dx * sc, cy + pts[i].dy * sc);
  }
  return path;
}

// Get tangent angle at a fractional position along the point list
double _tangentAngle(List<Offset> pts, double frac) {
  final idx = (frac * (pts.length - 1)).clamp(0, pts.length - 2).toInt();
  final a = pts[idx];
  final b = pts[idx + 1];
  return math.atan2(b.dy - a.dy, b.dx - a.dx);
}

Offset _pointAt(List<Offset> pts, double frac, Size size) {
  final idx = (frac * (pts.length - 1)).clamp(0.0, (pts.length - 1).toDouble());
  final lo = idx.floor();
  final hi = idx.ceil().clamp(0, pts.length - 1);
  final t = idx - lo;
  final p = Offset.lerp(pts[lo], pts[hi], t)!;
  final cx = size.width / 2;
  final cy = size.height / 2;
  final sc = math.min(cx, cy) * 0.9;
  return Offset(cx + p.dx * sc, cy + p.dy * sc);
}

// ---------------------------------------------------------------------------
// BkMathCurveLoader — animated square head travelling the curve
// ---------------------------------------------------------------------------

class BkMathCurveLoader extends StatefulWidget {
  const BkMathCurveLoader({
    super.key,
    this.curve = BkMathCurveType.lissajous,
    this.speed = BkMathCurveSpeed.normal,
    this.strokeWidth = 1.5,
    this.headSize = 8.0,
    this.trackColor,
    this.headColor,
    this.size = 120.0,
  });

  final BkMathCurveType curve;
  final BkMathCurveSpeed speed;
  final double strokeWidth;
  final double headSize;
  final Color? trackColor;
  final Color? headColor;
  final double size;

  @override
  State<BkMathCurveLoader> createState() => _BkMathCurveLoaderState();
}

class _BkMathCurveLoaderState extends State<BkMathCurveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Offset> _pts;

  @override
  void initState() {
    super.initState();
    _pts = sampleCurve(widget.curve);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (3000 / widget.speed.multiplier).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(BkMathCurveLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) {
      _pts = sampleCurve(widget.curve);
    }
    if (oldWidget.speed != widget.speed) {
      _ctrl.duration =
          Duration(milliseconds: (3000 / widget.speed.multiplier).round());
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnims = MediaQuery.of(context).disableAnimations;
    if (disableAnims && _ctrl.isAnimating) _ctrl.stop();

    final cs = Theme.of(context).colorScheme;
    final trackColor = widget.trackColor ?? cs.primary.withValues(alpha: 0.25);
    final headColor = widget.headColor ?? cs.primary;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CurveLoaderPainter(
              pts: _pts,
              progress: _ctrl.value,
              trackColor: trackColor,
              headColor: headColor,
              strokeWidth: widget.strokeWidth,
              headSize: widget.headSize,
            ),
          );
        },
      ),
    );
  }
}

class _CurveLoaderPainter extends CustomPainter {
  const _CurveLoaderPainter({
    required this.pts,
    required this.progress,
    required this.trackColor,
    required this.headColor,
    required this.strokeWidth,
    required this.headSize,
  });

  final List<Offset> pts;
  final double progress;
  final Color trackColor;
  final Color headColor;
  final double strokeWidth;
  final double headSize;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw full track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _buildPath(pts, size);
    canvas.drawPath(path, trackPaint);

    // Draw square head at current position
    final headPos = _pointAt(pts, progress, size);
    final angle = _tangentAngle(pts, progress);

    final headPaint = Paint()
      ..color = headColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(headPos.dx, headPos.dy);
    canvas.rotate(angle);
    final half = headSize / 2;
    canvas.drawRect(Rect.fromLTWH(-half, -half, headSize, headSize), headPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CurveLoaderPainter old) =>
      old.progress != progress ||
      old.pts != pts ||
      old.trackColor != trackColor ||
      old.headColor != headColor;
}

// ---------------------------------------------------------------------------
// BkMathCurveProgress — curve filled to a progress value
// ---------------------------------------------------------------------------

class BkMathCurveProgress extends StatelessWidget {
  const BkMathCurveProgress({
    super.key,
    required this.value,
    this.curve = BkMathCurveType.cardioid,
    this.strokeWidth = 2.0,
    this.activeColor,
    this.trackColor,
    this.size = 120.0,
  }) : assert(value >= 0.0 && value <= 1.0);

  final double value;
  final BkMathCurveType curve;
  final double strokeWidth;
  final Color? activeColor;
  final Color? trackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pts = sampleCurve(curve);
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _CurveProgressPainter(
          pts: pts,
          value: value,
          strokeWidth: strokeWidth,
          activeColor: activeColor ?? cs.primary,
          trackColor: trackColor ?? cs.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _CurveProgressPainter extends CustomPainter {
  const _CurveProgressPainter({
    required this.pts,
    required this.value,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
  });

  final List<Offset> pts;
  final double value;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sc = math.min(cx, cy) * 0.9;

    Offset toCanvas(Offset p) => Offset(cx + p.dx * sc, cy + p.dy * sc);

    final cutIdx = (value * (pts.length - 1)).round().clamp(0, pts.length - 1);

    // Track (full path dimmed)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trackPath = Path()..moveTo(toCanvas(pts[0]).dx, toCanvas(pts[0]).dy);
    for (int i = 1; i < pts.length; i++) {
      final p = toCanvas(pts[i]);
      trackPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(trackPath, trackPaint);

    if (cutIdx <= 0) return;

    // Active portion
    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final activePath = Path()..moveTo(toCanvas(pts[0]).dx, toCanvas(pts[0]).dy);
    for (int i = 1; i <= cutIdx; i++) {
      final p = toCanvas(pts[i]);
      activePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(_CurveProgressPainter old) =>
      old.value != value || old.pts != pts;
}

// ---------------------------------------------------------------------------
// BkMathCurveBackground — full-widget animated curve background
// ---------------------------------------------------------------------------

class BkMathCurveBackground extends StatefulWidget {
  const BkMathCurveBackground({
    super.key,
    this.curve = BkMathCurveType.butterfly,
    this.speed = BkMathCurveSpeed.normal,
    this.strokeWidth = 1.0,
    this.color,
    this.child,
  });

  final BkMathCurveType curve;
  final BkMathCurveSpeed speed;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  @override
  State<BkMathCurveBackground> createState() => _BkMathCurveBackgroundState();
}

class _BkMathCurveBackgroundState extends State<BkMathCurveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Offset> _pts;

  @override
  void initState() {
    super.initState();
    _pts = sampleCurve(widget.curve);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (6000 / widget.speed.multiplier).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(BkMathCurveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) {
      _pts = sampleCurve(widget.curve);
    }
    if (oldWidget.speed != widget.speed) {
      _ctrl.duration =
          Duration(milliseconds: (6000 / widget.speed.multiplier).round());
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnims = MediaQuery.of(context).disableAnimations;
    if (disableAnims && _ctrl.isAnimating) _ctrl.stop();

    final color =
        widget.color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => CustomPaint(
          painter: _CurveBgPainter(
            pts: _pts,
            progress: _ctrl.value,
            color: color,
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _CurveBgPainter extends CustomPainter {
  const _CurveBgPainter({
    required this.pts,
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> pts;
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw entire path, with a glowing head at progress position
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _buildPath(pts, size);
    canvas.drawPath(path, paint);

    // Draw glowing head
    final headPos = _pointAt(pts, progress, size);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(headPos, strokeWidth * 2.5, glowPaint);

    final solidPaint = Paint()..color = color;
    canvas.drawCircle(headPos, strokeWidth * 1.5, solidPaint);
  }

  @override
  bool shouldRepaint(_CurveBgPainter old) =>
      old.progress != progress || old.pts != pts || old.color != color;
}
