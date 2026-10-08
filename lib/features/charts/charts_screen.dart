import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _selectedTimeRange = '30D';
  String _chartViewType = 'BAR'; // BAR, LINE, AREA
  bool _showSessions = true;
  bool _showConversions = true;
  double _gaugeScore = 78.0;
  int _dataSeed = 0;

  final _timeRanges = ['7D', '30D', '90D', '1Y'];

  void _randomizeData() {
    BkMotion.hapticClick();
    setState(() {
      _dataSeed++;
      _gaugeScore = (math.Random().nextInt(40) + 60).toDouble();
    });
    BkToastManager.show(context, message: 'DATASET RE-CALCULATED');
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final rnd = math.Random(_dataSeed);

    // Compute dynamic datasets based on time range and seed
    final pointCount = switch (_selectedTimeRange) {
      '7D' => 7,
      '30D' => 12,
      '90D' => 18,
      '1Y' => 24,
      _ => 12,
    };

    final barData = List.generate(pointCount.clamp(4, 8), (i) {
      final baseVal = (mockMonthlyData[i % mockMonthlyData.length].value) +
          (rnd.nextInt(20) - 10);
      final label = mockMonthlyData[i % mockMonthlyData.length].month;
      return BkChartDataPoint(label: label, value: baseVal.clamp(10.0, 120.0));
    });

    final lineSpots1 = _showSessions
        ? List.generate(
            pointCount,
            (i) {
              final v = 20.0 + (i * 3.5) + (rnd.nextInt(15) - 7);
              return FlSpot(i.toDouble(), v.clamp(10.0, 100.0));
            },
          )
        : <FlSpot>[];

    final lineSpots2 = _showConversions
        ? List.generate(
            pointCount,
            (i) {
              final v = 15.0 + (i * 2.2) + (rnd.nextInt(10) - 5);
              return FlSpot(i.toDouble(), v.clamp(5.0, 80.0));
            },
          )
        : <FlSpot>[];

    final pieSlices = [
      BkPieSlice(label: 'Direct', value: (40 + rnd.nextInt(10)).toDouble()),
      BkPieSlice(label: 'Social', value: (25 + rnd.nextInt(8)).toDouble()),
      BkPieSlice(label: 'Referral', value: (18 + rnd.nextInt(6)).toDouble()),
      BkPieSlice(label: 'Email', value: (12 + rnd.nextInt(5)).toDouble()),
    ];

    final radialData = [
      BkChartDataPoint(
          label: 'Core',
          value: (0.85 + (rnd.nextDouble() * 0.1 - 0.05)).clamp(0.2, 1.0)),
      BkChartDataPoint(
          label: 'Memory',
          value: (0.64 + (rnd.nextDouble() * 0.1 - 0.05)).clamp(0.2, 1.0)),
      BkChartDataPoint(
          label: 'Network',
          value: (0.42 + (rnd.nextDouble() * 0.1 - 0.05)).clamp(0.2, 1.0)),
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: t.foreground),
            tooltip: 'Randomize Datasets',
            onPressed: _randomizeData,
          ),
          const SizedBox(width: 8),
        ],
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
            // Time Range Tabs
            BkReveal(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _timeRanges.map((range) {
                    final isSelected = _selectedTimeRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          BkMotion.hapticClick();
                          setState(() => _selectedTimeRange = range);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? t.primary : t.card,
                            border: Border.all(
                                color: t.border, width: t.borderWidth),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: t.shadowColor,
                                        offset: const Offset(3, 3))
                                  ]
                                : null,
                          ),
                          child: Text(
                            range,
                            style: GoogleFonts.dmMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? t.primaryForeground
                                  : t.foreground,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Metrics Row
            BkReveal(
              delay: const Duration(milliseconds: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUICK METRICS',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.mutedForeground),
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
                                Text('ACTIVE USERS',
                                    style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                BkSparkline(
                                  values: List.generate(
                                      7, (i) => 20.0 + rnd.nextInt(35)),
                                  color: t.primary,
                                ),
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
                                Text('CONVERSIONS',
                                    style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                BkSparkline(
                                  values: List.generate(
                                      7, (i) => 15.0 + rnd.nextInt(40)),
                                  color: t.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Revenue Metric with View Mode Switcher
            BkReveal(
              delay: const Duration(milliseconds: 100),
              child: BkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        Text(
                          'MONTHLY REVENUE (\$K)',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: t.foreground,
                          ),
                        ),
                        // View Switcher: BAR / LINE / AREA
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ['BAR', 'LINE', 'AREA'].map((mode) {
                            final sel = _chartViewType == mode;
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                onTap: () {
                                  BkMotion.hapticClick();
                                  setState(() => _chartViewType = mode);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sel ? t.accent : t.background,
                                    border:
                                        Border.all(color: t.border, width: 1.5),
                                  ),
                                  child: Text(
                                    mode,
                                    style: GoogleFonts.dmMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: sel
                                          ? t.accentForeground
                                          : t.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: switch (_chartViewType) {
                          'BAR' => BkBarChart(
                              key: ValueKey(
                                  'bar-$_dataSeed-$_selectedTimeRange'),
                              data: barData,
                              height: 220,
                            ),
                          'AREA' => BkAreaChart(
                              key: ValueKey(
                                  'area-$_dataSeed-$_selectedTimeRange'),
                              data: barData,
                              height: 220,
                            ),
                          _ => BkLineChart(
                              key: ValueKey(
                                  'line-$_dataSeed-$_selectedTimeRange'),
                              series: [
                                BkLineChartSeries(
                                  name: 'Revenue',
                                  spots: barData
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(
                                          e.key.toDouble(), e.value.value))
                                      .toList(),
                                  color: t.primary,
                                ),
                              ],
                              height: 220,
                            ),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sessions & Conversions with Interactive Legend Chips
            BkReveal(
              delay: const Duration(milliseconds: 150),
              child: BkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        Text(
                          'SESSIONS & CONVERSIONS',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: t.foreground,
                          ),
                        ),
                        // Interactive Toggle Chips
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                BkMotion.hapticClick();
                                setState(() => _showSessions = !_showSessions);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      _showSessions ? t.primary : t.background,
                                  border:
                                      Border.all(color: t.border, width: 1.5),
                                ),
                                child: Text(
                                  'SESSIONS',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _showSessions
                                        ? t.primaryForeground
                                        : t.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                BkMotion.hapticClick();
                                setState(
                                    () => _showConversions = !_showConversions);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _showConversions
                                      ? t.secondary
                                      : t.background,
                                  border:
                                      Border.all(color: t.border, width: 1.5),
                                ),
                                child: Text(
                                  'CONV',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _showConversions
                                        ? t.secondaryForeground
                                        : t.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BkLineChart(
                        key: ValueKey(
                            'series-$_dataSeed-$_showSessions-$_showConversions'),
                        series: [
                          if (_showSessions)
                            BkLineChartSeries(
                                name: 'Sessions',
                                spots: lineSpots1,
                                color: t.primary),
                          if (_showConversions)
                            BkLineChartSeries(
                                name: 'Conversions',
                                spots: lineSpots2,
                                color: t.secondary),
                        ],
                        height: 220,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Traffic Distribution (Pie / Donut / Radial Bar)
            BkReveal(
              delay: const Duration(milliseconds: 200),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 640;
                  final pie = BkPieChart(
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
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    height: 260,
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: pie),
                        const SizedBox(width: 16),
                        Expanded(child: donut),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      pie,
                      const SizedBox(height: 20),
                      donut,
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Concentric Radial Progress Rings
            BkReveal(
              delay: const Duration(milliseconds: 250),
              child: BkRadialBarChart(
                title: 'SYSTEM RESOURCE UTILIZATION',
                data: radialData,
                height: 240,
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Gauge Score with Slider
            BkReveal(
              delay: const Duration(milliseconds: 300),
              child: BkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BkGaugeChart(
                      value: _gaugeScore,
                      min: 0,
                      max: 100,
                      label: 'System Health Index',
                      height: 190,
                    ),
                    const SizedBox(height: 12),
                    BkSlider(
                      label: 'ADJUST TARGET HEALTH SCORE',
                      value: _gaugeScore,
                      min: 0,
                      max: 100,
                      onChanged: (v) => setState(() => _gaugeScore = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
