import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class ApiKeyItem {
  final int id;
  final String label;
  final String maskedKey;
  final String? createdAt;
  final String? lastUsedAt;
  final bool isActive;

  ApiKeyItem({
    required this.id,
    required this.label,
    required this.maskedKey,
    this.createdAt,
    this.lastUsedAt,
    this.isActive = true,
  });

  factory ApiKeyItem.fromJson(Map<String, dynamic> json) {
    return ApiKeyItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? 'Default',
      maskedKey: json['api_key_masked']?.toString() ?? 'tm_••••••••••••••••••••••••',
      createdAt: json['created_at']?.toString(),
      lastUsedAt: json['last_used_at']?.toString(),
      isActive: json['is_active'] != false && json['is_active'] != 0,
    );
  }
}

class ApiKeysState {
  final bool isLoading;
  final String? error;
  final List<ApiKeyItem> keys;
  final String? newlyCreatedKey; // Full key revealed only once

  const ApiKeysState({
    this.isLoading = false,
    this.error,
    this.keys = const [],
    this.newlyCreatedKey,
  });

  ApiKeysState copyWith({
    bool? isLoading,
    String? error,
    List<ApiKeyItem>? keys,
    String? newlyCreatedKey,
  }) {
    return ApiKeysState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      keys: keys ?? this.keys,
      newlyCreatedKey: newlyCreatedKey,
    );
  }
}

class ApiKeysNotifier extends StateNotifier<ApiKeysState> {
  final ApiClient _api;

  ApiKeysNotifier(this._api) : super(const ApiKeysState()) {
    fetchKeys();
  }

  Future<void> fetchKeys() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/api/v1/api-keys', requiresAuth: true);
      if (res is Map<String, dynamic> && res['keys'] is List) {
        final list = (res['keys'] as List)
            .map((k) => ApiKeyItem.fromJson(k as Map<String, dynamic>))
            .toList();
        state = state.copyWith(isLoading: false, keys: list);
      } else {
        state = state.copyWith(isLoading: false, keys: []);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load API keys: ${e.toString()}',
      );
    }
  }

  Future<String?> createKey(String label) async {
    try {
      final res = await _api.post(
        '/api/v1/api-keys',
        body: {'label': label.isNotEmpty ? label : 'Default'},
        requiresAuth: true,
      );
      final rawKey = res['api_key']?.toString();
      await fetchKeys();
      state = state.copyWith(newlyCreatedKey: rawKey);
      return rawKey;
    } catch (e) {
      state = state.copyWith(error: 'Failed to generate API key: ${e.toString()}');
      return null;
    }
  }

  Future<bool> revokeKey(int keyId) async {
    try {
      await _api.delete('/api/v1/api-keys/$keyId', requiresAuth: true);
      await fetchKeys();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to revoke API key: ${e.toString()}');
      return false;
    }
  }

  void clearNewKey() {
    state = state.copyWith(newlyCreatedKey: null);
  }
}

final apiKeysProvider = StateNotifierProvider<ApiKeysNotifier, ApiKeysState>((ref) {
  final api = ref.watch(apiClientProvider);
  return ApiKeysNotifier(api);
});
