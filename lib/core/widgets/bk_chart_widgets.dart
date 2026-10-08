import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkChartDataPoint {
  const BkChartDataPoint(
      {required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

class BkLineChartSeries {
  const BkLineChartSeries(
      {required this.name, required this.spots, this.color});
  final String name;
  final List<FlSpot> spots;
  final Color? color;
}

class BkPieSlice {
  const BkPieSlice({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

class BkRadarSeries {
  const BkRadarSeries({required this.name, required this.values, this.color});
  final String name;
  final List<double> values;
  final Color? color;
}

/// 1. BkBarChart — styled brutalist bar chart
class BkBarChart extends StatelessWidget {
  const BkBarChart({
    super.key,
    required this.data,
    this.title,
    this.height = 240,
  });

  final List<BkChartDataPoint> data;
  final String? title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final palette = [t.chart1, t.chart2, t.chart3, t.chart4, t.chart5];

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              data[idx].label,
                              style: GoogleFonts.outfit(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: GoogleFonts.dmMono(fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: t.border.withValues(alpha: 0.15),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: t.border, width: 2),
                ),
                barGroups: List.generate(data.length, (idx) {
                  final pt = data[idx];
                  final col = pt.color ?? palette[idx % palette.length];
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: pt.value,
                        color: col,
                        width: 18,
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: t.border, width: 2),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. BkLineChart — brutalist line & area chart
class BkLineChart extends StatelessWidget {
  const BkLineChart({
    super.key,
    required this.series,
    this.title,
    this.showArea = true,
    this.height = 240,
  });

  final List<BkLineChartSeries> series;
  final String? title;
  final bool showArea;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final palette = [t.chart1, t.chart2, t.chart3, t.chart4, t.chart5];

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: t.border.withValues(alpha: 0.15),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (val) => FlLine(
                    color: t.border.withValues(alpha: 0.15),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(
                        'P${val.toInt()}',
                        style: GoogleFonts.dmMono(fontSize: 9),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: GoogleFonts.dmMono(fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: t.border, width: 2),
                ),
                lineBarsData: List.generate(series.length, (idx) {
                  final s = series[idx];
                  final col = s.color ?? palette[idx % palette.length];
                  return LineChartBarData(
                    spots: s.spots,
                    isCurved: false,
                    color: col,
                    barWidth: 3,
                    isStrokeCapRound: false,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, i) =>
                          FlDotSquarePainter(
                        size: 7,
                        color: col,
                        strokeColor: t.border,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: showArea,
                      color: col.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. BkPieChart & BkDonutChart
class BkPieChart extends StatelessWidget {
  const BkPieChart({
    super.key,
    required this.slices,
    this.title,
    this.isDonut = false,
    this.centerWidget,
    this.height = 240,
  });

  final List<BkPieSlice> slices;
  final String? title;
  final bool isDonut;
  final Widget? centerWidget;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final palette = [t.chart1, t.chart2, t.chart3, t.chart4, t.chart5];

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: isDonut ? 40 : 0,
                    sections: List.generate(slices.length, (idx) {
                      final slice = slices[idx];
                      final col = slice.color ?? palette[idx % palette.length];
                      return PieChartSectionData(
                        value: slice.value,
                        title: slice.label,
                        color: col,
                        radius: 54,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: t.foreground,
                        ),
                        borderSide: BorderSide(color: t.border, width: 2),
                      );
                    }),
                  ),
                ),
                if (isDonut && centerWidget != null) centerWidget!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. BkGaugeChart — brutalist gauge meter
class BkGaugeChart extends StatelessWidget {
  const BkGaugeChart({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.label = 'Score',
    this.height = 180,
  });

  final double value;
  final double min;
  final double max;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final ratio = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Container(
      height: height,
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
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _GaugePainter(
                ratio: ratio,
                trackColor: t.muted,
                fillColor: t.primary,
                borderColor: t.border,
              ),
            ),
          ),
          Text(
            '${value.round()}',
            style:
                GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: t.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.ratio,
    required this.trackColor,
    required this.fillColor,
    required this.borderColor,
  });

  final double ratio;
  final Color trackColor;
  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2 - 16, size.height - 8);
    const strokeWidth = 24.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    // Fill
    canvas.drawArc(rect, math.pi, math.pi * ratio, false, fillPaint);
    // Outline
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + strokeWidth / 2),
        math.pi,
        math.pi,
        false,
        borderPaint);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        math.pi,
        math.pi,
        false,
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.ratio != ratio;
}

/// 5. BkSparkline — mini sparkline
class BkSparkline extends StatelessWidget {
  const BkSparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 36.0,
    this.width = 100.0,
  });

  final List<double> values;
  final Color? color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final lineColor = color ?? t.primary;

    if (values.isEmpty) return SizedBox(width: width, height: height);

    final spots =
        List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 6. BkAreaChart — filled brutalist area chart ──────────────────────────────
class BkAreaChart extends StatelessWidget {
  const BkAreaChart({
    super.key,
    required this.data,
    this.title,
    this.height = 240,
    this.color,
  });

  final List<BkChartDataPoint> data;
  final String? title;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final primaryColor = color ?? t.primary;

    if (data.isEmpty) return SizedBox(height: height);

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].value),
    );

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: t.border.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: GoogleFonts.dmMono(
                            fontSize: 10, color: t.mutedForeground),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              data[idx].label,
                              style: GoogleFonts.dmMono(
                                  fontSize: 9, color: t.mutedForeground),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: t.border, width: 2),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withValues(alpha: 0.35),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotSquarePainter(
                        size: 8,
                        color: t.background,
                        strokeColor: t.border,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 7. BkRadarChart — custom painter polygonal spider chart ───────────────────
class BkRadarChart extends StatelessWidget {
  const BkRadarChart({
    super.key,
    required this.categories,
    required this.series,
    this.title,
    this.height = 260,
  });

  final List<String> categories;
  final List<BkRadarSeries> series;
  final String? title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: CustomPaint(
              painter: _BkRadarPainter(
                categories: categories,
                series: series,
                borderColor: t.border,
                mutedColor: t.muted,
                textColor: t.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BkRadarPainter extends CustomPainter {
  const _BkRadarPainter({
    required this.categories,
    required this.series,
    required this.borderColor,
    required this.mutedColor,
    required this.textColor,
  });

  final List<String> categories;
  final List<BkRadarSeries> series;
  final Color borderColor;
  final Color mutedColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 24;
    final count = categories.length;
    final angleStep = (2 * math.pi) / count;

    final gridPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw grid webs
    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * (ring / 4);
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Spokes and labels
    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);

      // Label
      final lx = center.dx + (radius + 14) * math.cos(angle);
      final ly = center.dy + (radius + 14) * math.sin(angle);
      final textSpan = TextSpan(
        text: categories[i].toUpperCase(),
        style: GoogleFonts.dmMono(
            fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }

    // Draw data series polygons
    for (final s in series) {
      final sColor = s.color ?? borderColor;
      final polyPath = Path();
      for (int i = 0; i < count; i++) {
        final val = (i < s.values.length ? s.values[i] : 0.0).clamp(0.0, 1.0);
        final r = radius * val;
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          polyPath.moveTo(x, y);
        } else {
          polyPath.lineTo(x, y);
        }
      }
      polyPath.close();

      final fillPaint = Paint()
        ..color = sColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = sColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawPath(polyPath, fillPaint);
      canvas.drawPath(polyPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BkRadarPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.series != series ||
        oldDelegate.borderColor != borderColor;
  }
}

// ── 8. BkRadialBarChart — concentric radial progress rings ────────────────────
class BkRadialBarChart extends StatelessWidget {
  const BkRadialBarChart({
    super.key,
    required this.data,
    this.title,
    this.height = 240,
  });

  final List<BkChartDataPoint> data;
  final String? title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final palette = [t.primary, t.secondary, t.accent, t.chart4, t.chart5];

    return Container(
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _BkRadialBarPainter(
                      data: data,
                      palette: palette,
                      trackColor: t.muted,
                      borderColor: t.border,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(data.length, (i) {
                    final item = data[i];
                    final color = item.color ?? palette[i % palette.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(color: t.border, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.label}: ${(item.value * 100).toInt()}%',
                            style: GoogleFonts.dmMono(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: t.foreground,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BkRadialBarPainter extends CustomPainter {
  const _BkRadialBarPainter({
    required this.data,
    required this.palette,
    required this.trackColor,
    required this.borderColor,
  });

  final List<BkChartDataPoint> data;
  final List<Color> palette;
  final Color trackColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 10.0;
    const spacing = 4.0;

    for (int i = 0; i < data.length; i++) {
      final r = maxRadius - i * (strokeWidth + spacing);
      if (r <= 0) break;
      final color = data[i].color ?? palette[i % palette.length];
      final sweep = (data[i].value.clamp(0.0, 1.0)) * 2 * math.pi;

      // Track
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, r, trackPaint);

      // Value Arc
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.square;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweep,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BkRadialBarPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.trackColor != trackColor;
  }
}
