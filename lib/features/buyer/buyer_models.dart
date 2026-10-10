class BuyerRoomInfo {
  final String sessionId;
  final String productName;
  final double basePrice;
  final int quantity;
  final bool isActive;
  final bool sellerOnline;
  final List<BuyerChatMessage> initialMessages;

  const BuyerRoomInfo({
    required this.sessionId,
    required this.productName,
    required this.basePrice,
    this.quantity = 1,
    this.isActive = true,
    this.sellerOnline = false,
    this.initialMessages = const [],
  });

  factory BuyerRoomInfo.fromJson(Map<String, dynamic> json) {
    final rawMsgs = json['messages'] as List<dynamic>?;
    final msgs = rawMsgs != null
        ? rawMsgs
            .whereType<Map<String, dynamic>>()
            .map((m) => BuyerChatMessage.fromJson(m))
            .toList()
        : <BuyerChatMessage>[];

    return BuyerRoomInfo(
      sessionId: json['session_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Product',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] != false,
      sellerOnline: json['seller_online'] == true,
      initialMessages: msgs,
    );
  }
}

class BuyerChatMessage {
  final String id;
  final String sender; // 'buyer' or 'seller' or 'system'
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isOptimistic;
  final bool hasFailed;

  BuyerChatMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    DateTime? timestamp,
    this.isOptimistic = false,
    this.hasFailed = false,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isBuyer => sender.toLowerCase() == 'buyer';
  bool get isSeller => sender.toLowerCase() == 'seller';
  bool get isSystem => sender.toLowerCase() == 'system';
  String get displayName =>
      senderName.isNotEmpty ? senderName : (isBuyer ? 'Buyer' : (isSeller ? 'Seller' : 'System'));

  factory BuyerChatMessage.fromJson(Map<String, dynamic> json) {
    final senderRole = json['role']?.toString() ?? json['sender']?.toString() ?? 'seller';
    return BuyerChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: senderRole.toLowerCase(),
      senderName: json['sender_name']?.toString() ?? (senderRole.toLowerCase() == 'buyer' ? 'You' : 'Seller'),
      text: json['text']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(((json['timestamp'] as num).toDouble() * 1000).toInt())
          : DateTime.now(),
    );
  }

  BuyerChatMessage copyWith({
    String? id,
    String? sender,
    String? senderName,
    String? text,
    DateTime? timestamp,
    bool? isOptimistic,
    bool? hasFailed,
  }) {
    return BuyerChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      hasFailed: hasFailed ?? this.hasFailed,
    );
  }
}
