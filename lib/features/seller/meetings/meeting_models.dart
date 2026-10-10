class LiveMeetingSession {
  final String sessionId;
  final String productName;
  final double basePrice;
  final double costPrice;
  final double minFloor;
  final String mode;
  final int maxRounds;
  final int quantity;
  final String buyerLink;
  final String localIp;
  final DateTime? scheduledTime;

  const LiveMeetingSession({
    required this.sessionId,
    required this.productName,
    required this.basePrice,
    required this.costPrice,
    required this.minFloor,
    required this.mode,
    required this.maxRounds,
    required this.quantity,
    required this.buyerLink,
    required this.localIp,
    this.scheduledTime,
  });

  factory LiveMeetingSession.fromJson(Map<String, dynamic> json, [DateTime? scheduled]) {
    return LiveMeetingSession(
      sessionId: json['session_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Product Deal',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      minFloor: (json['min_floor'] as num?)?.toDouble() ?? 0.0,
      mode: json['mode']?.toString() ?? 'MAX_PROFIT',
      maxRounds: (json['max_rounds'] as num?)?.toInt() ?? 6,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      buyerLink: json['buyer_link']?.toString() ?? '',
      localIp: json['local_ip']?.toString() ?? '127.0.0.1',
      scheduledTime: scheduled,
    );
  }
}
