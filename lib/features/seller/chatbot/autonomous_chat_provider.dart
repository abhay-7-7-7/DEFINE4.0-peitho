import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'autonomous_chat_models.dart';

class AutonomousChatState {
  final String? sessionId;
  final bool isInitializing;
  final bool isSending;
  final String? error;
  final List<AutonomousTurnItem> turns;
  final AutonomousSessionConfig? config;
  final AutonomousSessionAnalytics? analytics;
  final bool isDealClosed;
  final double? finalAgreedPrice;

  const AutonomousChatState({
    this.sessionId,
    this.isInitializing = false,
    this.isSending = false,
    this.error,
    this.turns = const [],
    this.config,
    this.analytics,
    this.isDealClosed = false,
    this.finalAgreedPrice,
  });

  AutonomousChatState copyWith({
    String? sessionId,
    bool? isInitializing,
    bool? isSending,
    String? error,
    List<AutonomousTurnItem>? turns,
    AutonomousSessionConfig? config,
    AutonomousSessionAnalytics? analytics,
    bool? isDealClosed,
    double? finalAgreedPrice,
  }) {
    return AutonomousChatState(
      sessionId: sessionId ?? this.sessionId,
      isInitializing: isInitializing ?? this.isInitializing,
      isSending: isSending ?? this.isSending,
      error: error,
      turns: turns ?? this.turns,
      config: config ?? this.config,
      analytics: analytics ?? this.analytics,
      isDealClosed: isDealClosed ?? this.isDealClosed,
      finalAgreedPrice: finalAgreedPrice ?? this.finalAgreedPrice,
    );
  }
}

class AutonomousChatNotifier extends StateNotifier<AutonomousChatState> {
  final ApiClient _api;

  AutonomousChatNotifier(this._api) : super(const AutonomousChatState());

  Future<void> startSession(AutonomousSessionConfig config) async {
    state = state.copyWith(isInitializing: true, error: null, config: config, turns: []);
    try {
      final res = await _api.post(
        '/api/v1/negotiate/sessions',
        body: {
          'product_id': config.productId.toString(),
          'product_name': config.productName,
          'cost_price': config.costPrice,
          'selling_price': config.basePrice,
          'initial_stock': 100,
          'min_margin_percent': ((config.basePrice - config.minPrice) / config.basePrice) * 100,
          'negotiation_mode': config.mode,
          'max_rounds': config.maxRounds,
        },
        requiresAuth: true,
      );

      final sessionId = res['session_id']?.toString() ?? '';
      final initialOffer = (res['initial_offer'] as num?)?.toDouble() ?? config.basePrice;

      final initialTurn = AutonomousTurnItem(
        round: 0,
        role: 'seller',
        message: 'Hello! I am offering ${config.productName} listed at ₹$initialOffer. What is your offer?',
        counterPrice: initialOffer,
        decision: 'INITIAL_OFFER',
      );

      state = state.copyWith(
        sessionId: sessionId,
        isInitializing: false,
        turns: [initialTurn],
      );
    } catch (e) {
      state = state.copyWith(
        isInitializing: false,
        error: 'Failed to start negotiation session: ${e.toString()}',
      );
    }
  }

  Future<void> sendMessage(String message, {double? manualOffer}) async {
    final sId = state.sessionId;
    if (sId == null || state.isSending || state.isDealClosed) return;

    final roundNum = state.turns.length ~/ 2 + 1;
    final buyerTurn = AutonomousTurnItem(
      round: roundNum,
      role: 'buyer',
      message: message,
      offerPrice: manualOffer,
    );

    state = state.copyWith(
      isSending: true,
      error: null,
      turns: [...state.turns, buyerTurn],
    );

    try {
      // Use chat endpoint
      final res = await _api.post(
        '/api/v1/negotiate/sessions/$sId/chat',
        body: {
          'message': message,
          if (manualOffer != null) 'offered_price': manualOffer,
        },
        requiresAuth: true,
      );

      final reply = res['reply']?.toString() ?? res['message']?.toString() ?? 'Offer received.';
      final decision = res['decision']?.toString() ?? res['status']?.toString();
      final counterPrice = (res['counter_price'] as num?)?.toDouble() ??
          (res['price'] as num?)?.toDouble();
      final isClosed = res['deal_closed'] == true || decision == 'ACCEPT';
      final agreed = (res['final_price'] as num?)?.toDouble() ?? (isClosed ? (counterPrice ?? manualOffer) : null);

      final sellerTurn = AutonomousTurnItem(
        round: roundNum,
        role: 'seller',
        message: reply,
        decision: decision,
        counterPrice: counterPrice,
        strategyExplanation: res['strategy_notes']?.toString(),
      );

      state = state.copyWith(
        isSending: false,
        turns: [...state.turns, sellerTurn],
        isDealClosed: isClosed,
        finalAgreedPrice: agreed,
      );

      // Refresh analytics
      await fetchAnalytics();
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  Future<void> fetchAnalytics() async {
    final sId = state.sessionId;
    if (sId == null) return;
    try {
      final res = await _api.get('/api/v1/negotiate/sessions/$sId/analytics', requiresAuth: true);
      if (res is Map<String, dynamic>) {
        state = state.copyWith(analytics: AutonomousSessionAnalytics.fromJson(res));
      }
    } catch (_) {
      // Non-blocking
    }
  }

  void reset() {
    state = const AutonomousChatState();
  }
}

final autonomousChatProvider =
    StateNotifierProvider<AutonomousChatNotifier, AutonomousChatState>((ref) {
  final api = ref.watch(apiClientProvider);
  return AutonomousChatNotifier(api);
});
