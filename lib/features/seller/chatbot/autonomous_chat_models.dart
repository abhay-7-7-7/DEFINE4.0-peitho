class AutonomousSessionConfig {
  final int productId;
  final String productName;
  final double basePrice;
  final double costPrice;
  final double minPrice;
  final String mode; // 'MAX_PROFIT' | 'MIN_LOSS'
  final int maxRounds;
  final double buyerAggressiveness; // 0.0 to 1.0

  const AutonomousSessionConfig({
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.costPrice,
    required this.minPrice,
    this.mode = 'MAX_PROFIT',
    this.maxRounds = 10,
    this.buyerAggressiveness = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId.toString(),
        'product_name': productName,
        'base_price': basePrice,
        'cost_price': costPrice,
        'floor_price': minPrice,
        'mode': mode,
        'max_rounds': maxRounds,
        'buyer_aggressiveness': buyerAggressiveness,
      };
}

class AutonomousTurnItem {
  final int round;
  final String role; // 'buyer' or 'seller'
  final String message;
  final double? offerPrice;
  final String? decision; // 'ACCEPT' | 'COUNTER' | 'REJECT' | 'WALK_AWAY'
  final double? counterPrice;
  final String? strategyExplanation;
  final DateTime timestamp;

  AutonomousTurnItem({
    required this.round,
    required this.role,
    required this.message,
    this.offerPrice,
    this.decision,
    this.counterPrice,
    this.strategyExplanation,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AutonomousSessionAnalytics {
  final String sessionId;
  final int totalTurns;
  final double? finalPrice;
  final double? concessionRate;
  final double? buyerUtility;
  final double? sellerUtility;
  final bool dealClosed;
  final String status;

  AutonomousSessionAnalytics({
    required this.sessionId,
    required this.totalTurns,
    this.finalPrice,
    this.concessionRate,
    this.buyerUtility,
    this.sellerUtility,
    required this.dealClosed,
    required this.status,
  });

  factory AutonomousSessionAnalytics.fromJson(Map<String, dynamic> json) {
    return AutonomousSessionAnalytics(
      sessionId: json['session_id']?.toString() ?? '',
      totalTurns: (json['total_turns'] as num?)?.toInt() ?? 0,
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      concessionRate: (json['concession_rate'] as num?)?.toDouble(),
      buyerUtility: (json['buyer_utility'] as num?)?.toDouble(),
      sellerUtility: (json['seller_utility'] as num?)?.toDouble(),
      dealClosed: json['deal_closed'] == true,
      status: json['status']?.toString() ?? 'active',
    );
  }
}
