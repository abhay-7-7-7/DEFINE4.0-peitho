import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkChartDataPoint {
  const BkChartDataPoint({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

class BkLineChartSeries {
  const BkLineChartSeries({required this.name, required this.spots, this.color});
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
                              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold),
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
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      getDotPainter: (spot, percent, barData, i) => FlDotSquarePainter(
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
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: t.mutedForeground),
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
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius + strokeWidth / 2), math.pi, math.pi, false, borderPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - strokeWidth / 2), math.pi, math.pi, false, borderPaint);
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

    final spots = List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));

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
