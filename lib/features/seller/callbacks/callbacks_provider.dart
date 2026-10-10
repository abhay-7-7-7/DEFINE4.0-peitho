import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class CallbackItem {
  final int id;
  final int sessionId;
  final String phoneNumber;
  final String productName;
  final String status;
  final String negotiationStatus;
  final double? finalPrice;
  final String createdAt;

  const CallbackItem({
    required this.id,
    required this.sessionId,
    required this.phoneNumber,
    required this.productName,
    required this.status,
    required this.negotiationStatus,
    this.finalPrice,
    required this.createdAt,
  });

  factory CallbackItem.fromJson(Map<String, dynamic> json) {
    return CallbackItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'General Inquiry',
      status: json['status']?.toString() ?? 'pending',
      negotiationStatus: json['negotiation_status']?.toString() ?? 'pending',
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

final callbacksProvider = FutureProvider<List<CallbackItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/v1/chat-sessions/callback-requests', requiresAuth: true);
  if (res is List) {
    return res.map((e) => CallbackItem.fromJson(e as Map<String, dynamic>)).toList();
  }
  return const [];
});
