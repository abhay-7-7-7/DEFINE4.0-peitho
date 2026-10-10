class DashboardSummaryMetrics {
  final int total;
  final int accepted;
  final int rejected;
  final int active;
  final int expired;
  final int walkedAway;
  final double totalRevenue;
  final double avgDealPrice;
  final double avgRounds;
  final double avgBasePrice;
  final double bestDeal;
  final double worstDeal;

  const DashboardSummaryMetrics({
    this.total = 0,
    this.accepted = 0,
    this.rejected = 0,
    this.active = 0,
    this.expired = 0,
    this.walkedAway = 0,
    this.totalRevenue = 0.0,
    this.avgDealPrice = 0.0,
    this.avgRounds = 0.0,
    this.avgBasePrice = 0.0,
    this.bestDeal = 0.0,
    this.worstDeal = 0.0,
  });

  double get acceptRate =>
      total > 0 ? (accepted / total) * 100.0 : 0.0;

  factory DashboardSummaryMetrics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DashboardSummaryMetrics();
    return DashboardSummaryMetrics(
      total: (json['total'] as num?)?.toInt() ?? 0,
      accepted: (json['accepted'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      active: (json['active'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      walkedAway: (json['walked_away'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      avgDealPrice: (json['avg_deal_price'] as num?)?.toDouble() ?? 0.0,
      avgRounds: (json['avg_rounds'] as num?)?.toDouble() ?? 0.0,
      avgBasePrice: (json['avg_base_price'] as num?)?.toDouble() ?? 0.0,
      bestDeal: (json['best_deal'] as num?)?.toDouble() ?? 0.0,
      worstDeal: (json['worst_deal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ClosedSessionItem {
  final int id;
  final String productName;
  final String status;
  final double basePrice;
  final double? finalPrice;
  final int roundsUsed;
  final String? finalDecision;
  final bool dealClosed;
  final double? buyerLastOffer;
  final double? sellerLastOffer;
  final String? createdAt;
  final String? closedAt;
  final String? callbackPhone;
  final String? callbackRequestedAt;

  const ClosedSessionItem({
    required this.id,
    required this.productName,
    required this.status,
    required this.basePrice,
    this.finalPrice,
    required this.roundsUsed,
    this.finalDecision,
    required this.dealClosed,
    this.buyerLastOffer,
    this.sellerLastOffer,
    this.createdAt,
    this.closedAt,
    this.callbackPhone,
    this.callbackRequestedAt,
  });

  factory ClosedSessionItem.fromJson(Map<String, dynamic> json) {
    return ClosedSessionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? 'Unknown Product',
      status: json['status']?.toString() ?? 'closed',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      roundsUsed: (json['rounds_used'] as num?)?.toInt() ?? 0,
      finalDecision: json['final_decision']?.toString(),
      dealClosed: json['deal_closed'] == true || json['deal_closed'] == 1,
      buyerLastOffer: (json['buyer_last_offer'] as num?)?.toDouble(),
      sellerLastOffer: (json['seller_last_offer'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString(),
      closedAt: json['closed_at']?.toString(),
      callbackPhone: json['callback_phone']?.toString(),
      callbackRequestedAt: json['callback_requested_at']?.toString(),
    );
  }
}

class DashboardData {
  final DashboardSummaryMetrics summary;
  final List<ClosedSessionItem> closedSessions;
  final List<dynamic> activeSessions;

  const DashboardData({
    required this.summary,
    required this.closedSessions,
    required this.activeSessions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final closedList = (json['closed_sessions'] as List?)
            ?.map((e) => ClosedSessionItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final activeList = (json['active_sessions'] as List?) ?? [];

    return DashboardData(
      summary: DashboardSummaryMetrics.fromJson(summaryJson),
      closedSessions: closedList,
      activeSessions: activeList,
    );
  }
}

class ChatMessageRound {
  final int id;
  final int roundNumber;
  final String? userMessage;
  final String? botReply;
  final double? offeredPrice;
  final double? counterPrice;
  final String? decision;
  final String? createdAt;

  const ChatMessageRound({
    required this.id,
    required this.roundNumber,
    this.userMessage,
    this.botReply,
    this.offeredPrice,
    this.counterPrice,
    this.decision,
    this.createdAt,
  });

  factory ChatMessageRound.fromJson(Map<String, dynamic> json) {
    return ChatMessageRound(
      id: (json['id'] as num?)?.toInt() ?? 0,
      roundNumber: (json['round_number'] as num?)?.toInt() ?? 0,
      userMessage: json['user_message']?.toString(),
      botReply: json['bot_reply']?.toString(),
      offeredPrice: (json['offered_price'] as num?)?.toDouble(),
      counterPrice: (json['counter_price'] as num?)?.toDouble(),
      decision: json['decision']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class FullSessionExport {
  final int id;
  final String productName;
  final String status;
  final double basePrice;
  final double? finalPrice;
  final int roundsUsed;
  final bool dealClosed;
  final List<ChatMessageRound> messages;
  final Map<String, dynamic>? callback;

  const FullSessionExport({
    required this.id,
    required this.productName,
    required this.status,
    required this.basePrice,
    this.finalPrice,
    required this.roundsUsed,
    required this.dealClosed,
    required this.messages,
    this.callback,
  });

  factory FullSessionExport.fromJson(Map<String, dynamic> json) {
    final msgList = (json['messages'] as List?)
            ?.map((e) => ChatMessageRound.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return FullSessionExport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      roundsUsed: (json['rounds_used'] as num?)?.toInt() ?? 0,
      dealClosed: json['deal_closed'] == true || json['deal_closed'] == 1,
      messages: msgList,
      callback: json['callback'] as Map<String, dynamic>?,
    );
  }
}
