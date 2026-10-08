import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';
import 'bk_card.dart';
import 'bk_progress.dart';

enum BkTrend { up, down, neutral }

class BkStatCard extends StatelessWidget {
  const BkStatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.trend = BkTrend.neutral,
    this.icon,
    this.progressValue,
    this.progressLabel,
    this.comparison = 'vs last month',
    this.colorScheme = 'primary',
  });

  final String title;
  final String value;
  final String? change;
  final BkTrend trend;
  final Widget? icon;
  final double? progressValue;
  final String? progressLabel;
  final String comparison;
  final String colorScheme;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final schemeColor = switch (colorScheme) {
      'secondary' => t.secondary,
      'accent' => t.accent,
      'success' => t.success,
      'warning' => t.warning,
      'info' => t.info,
      'destructive' => t.destructive,
      _ => t.primary,
    };

    final (trendColor, trendIcon) = switch (trend) {
      BkTrend.up => (t.success, Icons.arrow_upward),
      BkTrend.down => (t.destructive, Icons.arrow_downward),
      BkTrend.neutral => (t.mutedForeground, Icons.remove),
    };

    return Stack(
      children: [
        BkCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: t.mutedForeground,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            value,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: t.foreground,
                              height: 1.1,
                            ),
                          ),
                          if (change != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(trendIcon, size: 16, color: trendColor),
                                const SizedBox(width: 4),
                                Text(
                                  change!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: trendColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    comparison,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: t.mutedForeground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (icon != null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: schemeColor,
                          border:
                              Border.all(color: t.border, width: t.borderWidth),
                          boxShadow: [
                            BoxShadow(
                              color: t.shadowColor,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(child: icon),
                      ),
                  ],
                ),
                if (progressValue != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: t.border.withValues(alpha: 0.2),
                              width: 2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              progressLabel ?? 'Progress',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: t.mutedForeground),
                            ),
                            Text(
                              '${(progressValue! * 100).round()}%',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.foreground),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        BkProgress(
                            value: progressValue,
                            height: 10,
                            color: schemeColor),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Decorative corner color stripe
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 6,
            color: schemeColor,
          ),
        ),
      ],
    );
  }
}
