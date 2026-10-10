class ProductStatsSummary {
  final int totalSessions;
  final int acceptedDeals;
  final double avgMargin;
  final double revenue;

  const ProductStatsSummary({
    this.totalSessions = 0,
    this.acceptedDeals = 0,
    this.avgMargin = 0.0,
    this.revenue = 0.0,
  });

  factory ProductStatsSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProductStatsSummary();
    return ProductStatsSummary(
      totalSessions: json['totalSessions'] is int
          ? json['totalSessions']
          : int.tryParse('${json['totalSessions']}') ?? 0,
      acceptedDeals: json['acceptedDeals'] is int
          ? json['acceptedDeals']
          : int.tryParse('${json['acceptedDeals']}') ?? 0,
      avgMargin: json['avgMargin'] != null
          ? (num.tryParse('${json['avgMargin']}') ?? 0.0).toDouble()
          : 0.0,
      revenue: json['revenue'] != null
          ? (num.tryParse('${json['revenue']}') ?? 0.0).toDouble()
          : 0.0,
    );
  }
}

class Product {
  final int id;
  final int userId;
  final String name;
  final double basePrice;
  final double costPrice;
  final double minAcceptablePrice;
  final double maxLossPercent;
  final String mode;
  final int maxRounds;
  final String category;
  final String status;
  final String createdAt;
  final ProductStatsSummary stats;

  const Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.basePrice,
    required this.costPrice,
    required this.minAcceptablePrice,
    this.maxLossPercent = 0.0,
    this.mode = 'MAX_PROFIT',
    this.maxRounds = 10,
    this.category = 'General',
    this.status = 'active',
    required this.createdAt,
    this.stats = const ProductStatsSummary(),
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}') ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Product',
      basePrice: (num.tryParse('${json['base_price']}') ?? 0.0).toDouble(),
      costPrice: (num.tryParse('${json['cost_price']}') ?? 0.0).toDouble(),
      minAcceptablePrice:
          (num.tryParse('${json['min_acceptable_price']}') ?? 0.0).toDouble(),
      maxLossPercent:
          (num.tryParse('${json['max_loss_percent']}') ?? 0.0).toDouble(),
      mode: json['mode']?.toString() ?? 'MAX_PROFIT',
      maxRounds: json['max_rounds'] is int
          ? json['max_rounds']
          : int.tryParse('${json['max_rounds']}') ?? 10,
      category: json['category']?.toString() ?? 'General',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString() ?? '',
      stats: ProductStatsSummary.fromJson(json['stats'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'base_price': basePrice,
        'cost_price': costPrice,
        'min_acceptable_price': minAcceptablePrice,
        'max_loss_percent': maxLossPercent,
        'mode': mode,
        'max_rounds': maxRounds,
        'category': category,
      };
}

class ProductDetailedStats {
  final int productId;
  final String productName;
  final int totalSessions;
  final int acceptedDeals;
  final int rejectedDeals;
  final int activeSessions;
  final double acceptRate;
  final double avgRounds;
  final double avgFinalPrice;
  final double minDealPrice;
  final double maxDealPrice;
  final double totalRevenue;
  final double avgMargin;
  final List<dynamic> recentSessions;

  const ProductDetailedStats({
    required this.productId,
    required this.productName,
    required this.totalSessions,
    required this.acceptedDeals,
    required this.rejectedDeals,
    required this.activeSessions,
    required this.acceptRate,
    required this.avgRounds,
    required this.avgFinalPrice,
    required this.minDealPrice,
    required this.maxDealPrice,
    required this.totalRevenue,
    required this.avgMargin,
    required this.recentSessions,
  });

  factory ProductDetailedStats.fromJson(Map<String, dynamic> json) {
    return ProductDetailedStats(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse('${json['product_id']}') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      totalSessions: json['total_sessions'] is int
          ? json['total_sessions']
          : int.tryParse('${json['total_sessions']}') ?? 0,
      acceptedDeals: json['accepted_deals'] is int
          ? json['accepted_deals']
          : int.tryParse('${json['accepted_deals']}') ?? 0,
      rejectedDeals: json['rejected_deals'] is int
          ? json['rejected_deals']
          : int.tryParse('${json['rejected_deals']}') ?? 0,
      activeSessions: json['active_sessions'] is int
          ? json['active_sessions']
          : int.tryParse('${json['active_sessions']}') ?? 0,
      acceptRate: (num.tryParse('${json['accept_rate']}') ?? 0.0).toDouble(),
      avgRounds: (num.tryParse('${json['avg_rounds']}') ?? 0.0).toDouble(),
      avgFinalPrice:
          (num.tryParse('${json['avg_final_price']}') ?? 0.0).toDouble(),
      minDealPrice:
          (num.tryParse('${json['min_deal_price']}') ?? 0.0).toDouble(),
      maxDealPrice:
          (num.tryParse('${json['max_deal_price']}') ?? 0.0).toDouble(),
      totalRevenue:
          (num.tryParse('${json['total_revenue']}') ?? 0.0).toDouble(),
      avgMargin: (num.tryParse('${json['avg_margin']}') ?? 0.0).toDouble(),
      recentSessions: json['recent_sessions'] is List
          ? json['recent_sessions'] as List
          : const [],
    );
  }
}
