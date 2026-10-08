import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final barData = mockMonthlyData.take(6).map((m) {
      return BkChartDataPoint(label: m.month, value: m.value);
    }).toList();

    final lineSpots1 = List.generate(
      mockMonthlyData.length,
      (i) => FlSpot(i.toDouble(), mockMonthlyData[i].value),
    );
    final lineSpots2 = List.generate(
      mockMonthlyData.length,
      (i) => FlSpot(i.toDouble(), mockMonthlyData[i].value2),
    );

    const pieSlices = [
      BkPieSlice(label: 'Direct', value: 42),
      BkPieSlice(label: 'Social', value: 28),
      BkPieSlice(label: 'Referral', value: 18),
      BkPieSlice(label: 'Email', value: 12),
    ];

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'CHARTS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: t.foreground,
          ),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sparklines KPI banner
          Text(
            'QUICK METRICS',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: t.mutedForeground),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: BkCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('USERS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const BkSparkline(values: [10, 25, 18, 30, 42, 38, 55]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BkCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SALES', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        BkSparkline(values: const [40, 32, 45, 28, 50, 62, 70], color: t.secondary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart
          BkBarChart(
            title: 'MONTHLY REVENUE (\$K)',
            data: barData,
            height: 260,
          ),
          const SizedBox(height: 24),

          // Line & Area Chart
          BkLineChart(
            title: 'SESSIONS & CONVERSIONS',
            series: [
              BkLineChartSeries(name: 'Sessions', spots: lineSpots1, color: t.primary),
              BkLineChartSeries(name: 'Conversions', spots: lineSpots2, color: t.secondary),
            ],
            height: 260,
          ),
          const SizedBox(height: 24),

          // Pie & Donut Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              const pie = BkPieChart(
                title: 'TRAFFIC SOURCES',
                slices: pieSlices,
                height: 260,
              );
              final donut = BkPieChart(
                title: 'CONVERSION SPLIT',
                slices: pieSlices,
                isDonut: true,
                centerWidget: Text(
                  '100%',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                height: 260,
              );

              if (isWide) {
                return Row(
                  children: [
                    const Expanded(child: pie),
                    const SizedBox(width: 16),
                    Expanded(child: donut),
                  ],
                );
              }
              return Column(
                children: [
                  pie,
                  const SizedBox(height: 24),
                  donut,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Gauge Chart
          const BkGaugeChart(
            value: 78,
            min: 0,
            max: 100,
            label: 'System Performance Score',
            height: 220,
          ),
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
