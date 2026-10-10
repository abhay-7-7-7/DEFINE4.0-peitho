import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _prefKeyBaseUrl = 'trademind_api_base_url';

  /// Compile-time default passed via --dart-define=API_URL=...
  static const String compileTimeBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  /// Compile-time currency symbol or code (defaults to INR ₹)
  static const String defaultCurrency = String.fromEnvironment(
    'CURRENCY',
    defaultValue: 'INR',
  );

  /// Automatic environment fallback based on platform
  static String get defaultFallbackUrl {
    if (compileTimeBaseUrl.isNotEmpty) {
      return compileTimeBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback alias
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  /// Converts HTTP/HTTPS URL to corresponding WS/WSS URL
  static String toWebSocketUrl(String httpUrl, String endpointPath) {
    var base = httpUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (base.startsWith('https://')) {
      base = 'wss://${base.substring(8)}';
    } else if (base.startsWith('http://')) {
      base = 'ws://${base.substring(7)}';
    } else if (!base.startsWith('ws://') && !base.startsWith('wss://')) {
      base = 'ws://$base';
    }

    final path = endpointPath.startsWith('/') ? endpointPath : '/$endpointPath';
    return '$base$path';
  }
}

/// StateNotifier that manages the active API base URL at runtime.
class ApiBaseUrlNotifier extends StateNotifier<String> {
  ApiBaseUrlNotifier() : super(AppConfig.defaultFallbackUrl) {
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(AppConfig._prefKeyBaseUrl);
      if (saved != null && saved.trim().isNotEmpty) {
        state = saved.trim().replaceAll(RegExp(r'/+$'), '');
      }
    } catch (_) {}
  }

  Future<void> setBaseUrl(String newUrl) async {
    final cleaned = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (cleaned.isNotEmpty) {
      state = cleaned;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig._prefKeyBaseUrl, cleaned);
      } catch (_) {}
    }
  }

  Future<void> resetToDefault() async {
    state = AppConfig.defaultFallbackUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig._prefKeyBaseUrl);
    } catch (_) {}
  }
}

final apiBaseUrlProvider =
    StateNotifierProvider<ApiBaseUrlNotifier, String>((ref) {
  return ApiBaseUrlNotifier();
});
