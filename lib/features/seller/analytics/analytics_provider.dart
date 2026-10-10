import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'analytics_models.dart';

class AnalyticsState {
  final bool isLoading;
  final String? error;
  final AnalyticsCalculationResult? result;

  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    AnalyticsCalculationResult? result,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final ApiClient _api;

  AnalyticsNotifier(this._api) : super(const AnalyticsState());

  Future<void> calculate({
    required double costPrice,
    required double sellingPrice,
    required int initialStock,
    double platformFeePercent = 0.0,
    double shippingCost = 0.0,
    double marketingCost = 0.0,
    int chats = 100,
    int orders = 30,
    int unitsSold = 30,
    int returns = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post(
        '/api/v1/analytics/calculate',
        body: {
          'product': {
            'cost_price': costPrice,
            'selling_price': sellingPrice,
            'initial_stock': initialStock,
            'platform_fee_percent': platformFeePercent,
            'shipping_cost': shippingCost,
            'marketing_cost': marketingCost,
          },
          'performance': {
            'chats': chats,
            'orders': orders,
            'units_sold': unitsSold,
            'returns': returns,
          },
        },
        requiresAuth: true,
      );

      if (res is Map<String, dynamic>) {
        final calc = AnalyticsCalculationResult.fromJson(res);
        state = state.copyWith(isLoading: false, result: calc);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to calculate analytics: ${e.toString()}',
      );
    }
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final api = ref.watch(apiClientProvider);
  return AnalyticsNotifier(api);
});
