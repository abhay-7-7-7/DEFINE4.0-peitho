import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthController(this._apiClient, this._storage) : super(AuthState.initial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final res = await _apiClient.get('/api/v1/auth/me', requiresAuth: true);
      if (res is Map<String, dynamic>) {
        final user = SellerUser.fromJson(res);
        await _storage.saveUser(user.toJson());
        state = AuthState.authenticated(user, token);
      } else {
        await _storage.clearAuth();
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      // Offline fallback: check cached user
      final cachedUser = await _storage.getUser();
      if (cachedUser != null) {
        state = AuthState.authenticated(SellerUser.fromJson(cachedUser), token);
      } else {
        state = AuthState.unauthenticated();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final res = await _apiClient.post(
        '/api/v1/auth/login',
        body: {'email': email.trim(), 'password': password},
        requiresAuth: false,
      );

      if (res is Map<String, dynamic> && res.containsKey('token')) {
        final token = res['token'].toString();
        final user = SellerUser.fromJson(res['user'] as Map<String, dynamic>);
        await _storage.saveToken(token);
        await _storage.saveUser(user.toJson());
        state = AuthState.authenticated(user, token);
        return true;
      }
      state = AuthState.error('Unexpected server response format');
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    state = AuthState.loading();
    try {
      final res = await _apiClient.post(
        '/api/v1/auth/register',
        body: {
          'full_name': fullName.trim(),
          'email': email.trim(),
          'password': password,
        },
        requiresAuth: false,
      );

      if (res is Map<String, dynamic> && res.containsKey('token')) {
        final token = res['token'].toString();
        final user = SellerUser.fromJson(res['user'] as Map<String, dynamic>);
        await _storage.saveToken(token);
        await _storage.saveUser(user.toJson());
        state = AuthState.authenticated(user, token);
        return true;
      }
      state = AuthState.error('Unexpected server response format');
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    state = AuthState.unauthenticated();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthController(api, storage);
});
