import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'meeting_models.dart';

class MeetingsNotifier extends StateNotifier<List<LiveMeetingSession>> {
  final ApiClient _apiClient;

  MeetingsNotifier(this._apiClient) : super(const []);

  Future<LiveMeetingSession?> createLiveSession({
    required String productName,
    required double basePrice,
    required double costPrice,
    required double minFloor,
    String mode = 'MAX_PROFIT',
    int maxRounds = 6,
    int quantity = 1,
    DateTime? scheduledTime,
  }) async {
    try {
      final res = await _apiClient.post(
        '/api/v1/peitho/live-chat/start',
        body: {
          'product_name': productName,
          'base_price': basePrice,
          'cost_price': costPrice,
          'min_floor': minFloor,
          'mode': mode,
          'max_rounds': maxRounds,
          'quantity': quantity,
        },
        requiresAuth: true,
      );

      if (res is Map<String, dynamic>) {
        final session = LiveMeetingSession.fromJson(res, scheduledTime);
        state = [session, ...state];
        return session;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void removeSession(String sessionId) {
    state = state.where((s) => s.sessionId != sessionId).toList();
  }
}

final meetingsProvider =
    StateNotifierProvider<MeetingsNotifier, List<LiveMeetingSession>>((ref) {
  final api = ref.watch(apiClientProvider);
  return MeetingsNotifier(api);
});
