import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'dashboard_models.dart';

class DashboardFilterState {
  final String statusFilter; // all, accepted, rejected, active, expired, walked_away
  final String searchQuery;
  final String sortField; // closed_at, final_price, rounds_used, product_name
  final bool sortAscending;

  const DashboardFilterState({
    this.statusFilter = 'all',
    this.searchQuery = '',
    this.sortField = 'closed_at',
    this.sortAscending = false,
  });

  DashboardFilterState copyWith({
    String? statusFilter,
    String? searchQuery,
    String? sortField,
    bool? sortAscending,
  }) {
    return DashboardFilterState(
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class DashboardFilterNotifier extends StateNotifier<DashboardFilterState> {
  DashboardFilterNotifier() : super(const DashboardFilterState());

  void setFilter(String filter) => state = state.copyWith(statusFilter: filter);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void toggleSort(String field) {
    if (state.sortField == field) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortField: field, sortAscending: false);
    }
  }
}

final dashboardFilterProvider =
    StateNotifierProvider<DashboardFilterNotifier, DashboardFilterState>((ref) {
  return DashboardFilterNotifier();
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/v1/chat-sessions/dashboard/summary', requiresAuth: true);
  if (res is Map<String, dynamic>) {
    return DashboardData.fromJson(res);
  }
  throw Exception('Failed to load dashboard summary');
});

final sessionExportProvider =
    FutureProvider.family<FullSessionExport, int>((ref, sessionId) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/v1/chat-sessions/$sessionId/export', requiresAuth: true);
  if (res is Map<String, dynamic>) {
    return FullSessionExport.fromJson(res);
  }
  throw Exception('Failed to export session #$sessionId');
});
