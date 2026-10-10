class SummaryMetrics {
  final double grossRevenue;
  final double netRevenue;
  final double productCost;
  final double totalCost;
  final double profitOrLoss;
  final String profitStatus; // PROFIT, LOSS, BREAK_EVEN
  final double profitMarginPercent;
  final double conversionRate;
  final double returnRate;
  final double profitPerUnit;
  final double effectiveSellingPrice;
  final int remainingStock;
  final int netUnitsSold;

  SummaryMetrics({
    required this.grossRevenue,
    required this.netRevenue,
    required this.productCost,
    required this.totalCost,
    required this.profitOrLoss,
    required this.profitStatus,
    required this.profitMarginPercent,
    required this.conversionRate,
    required this.returnRate,
    required this.profitPerUnit,
    required this.effectiveSellingPrice,
    required this.remainingStock,
    required this.netUnitsSold,
  });

  factory SummaryMetrics.fromJson(Map<String, dynamic> json) {
    return SummaryMetrics(
      grossRevenue: (json['gross_revenue'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0.0,
      productCost: (json['product_cost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      profitOrLoss: (json['profit_or_loss'] as num?)?.toDouble() ?? 0.0,
      profitStatus: json['profit_status']?.toString() ?? 'PROFIT',
      profitMarginPercent: (json['profit_margin_percent'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      returnRate: (json['return_rate'] as num?)?.toDouble() ?? 0.0,
      profitPerUnit: (json['profit_per_unit'] as num?)?.toDouble() ?? 0.0,
      effectiveSellingPrice: (json['effective_selling_price'] as num?)?.toDouble() ?? 0.0,
      remainingStock: (json['remaining_stock'] as num?)?.toInt() ?? 0,
      netUnitsSold: (json['net_units_sold'] as num?)?.toInt() ?? 0,
    );
  }
}

class BusinessInsightItem {
  final String title;
  final String message;
  final String severity; // info, warning, critical, success
  final String? metric;

  BusinessInsightItem({
    required this.title,
    required this.message,
    required this.severity,
    this.metric,
  });

  factory BusinessInsightItem.fromJson(Map<String, dynamic> json) {
    return BusinessInsightItem(
      title: json['title']?.toString() ?? 'Insight',
      message: json['message']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'info',
      metric: json['metric']?.toString(),
    );
  }
}

class AnalyticsCalculationResult {
  final SummaryMetrics summary;
  final List<BusinessInsightItem> insights;
  final Map<String, dynamic>? charts;

  AnalyticsCalculationResult({
    required this.summary,
    required this.insights,
    this.charts,
  });

  factory AnalyticsCalculationResult.fromJson(Map<String, dynamic> json) {
    final sumMap = json['summary'] as Map<String, dynamic>? ?? {};
    final insightsList = (json['insights'] as List?)
            ?.map((i) => BusinessInsightItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    return AnalyticsCalculationResult(
      summary: SummaryMetrics.fromJson(sumMap),
      insights: insightsList,
      charts: json['charts'] as Map<String, dynamic>?,
    );
  }
}
