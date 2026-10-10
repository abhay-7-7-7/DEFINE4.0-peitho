import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/app_exceptions.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final Ref _ref;
  final http.Client _httpClient;
  static const Duration defaultTimeout = Duration(seconds: 15);

  ApiClient(this._ref, [http.Client? client])
      : _httpClient = client ?? http.Client();

  String get _baseUrl => _ref.read(apiBaseUrlProvider);
  SecureStorageService get _storage => _ref.read(secureStorageProvider);

  /// Performs an HTTP GET
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    return _send(
      'GET',
      endpoint,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  /// Performs an HTTP POST
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    return _send(
      'POST',
      endpoint,
      body: body,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  /// Performs an HTTP PUT
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    return _send(
      'PUT',
      endpoint,
      body: body,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  /// Performs an HTTP DELETE
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    return _send(
      'DELETE',
      endpoint,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  Future<dynamic> _send(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    var uri = Uri.parse('$_baseUrl$cleanEndpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final reqTimeout = timeout ?? defaultTimeout;

    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers).timeout(reqTimeout);
          break;
        case 'POST':
          final encoded = body != null ? jsonEncode(body) : null;
          response = await _httpClient.post(uri, headers: headers, body: encoded).timeout(reqTimeout);
          break;
        case 'PUT':
          final encoded = body != null ? jsonEncode(body) : null;
          response = await _httpClient.put(uri, headers: headers, body: encoded).timeout(reqTimeout);
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: headers).timeout(reqTimeout);
          break;
        default:
          throw UnsupportedError('Method $method not supported');
      }

      return _handleResponse(response);
    } on TimeoutException {
      throw const AppTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Connection error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.trim().isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    // Handle Error Status Codes
    String errorMessage = 'Request failed (${response.statusCode})';
    dynamic errorDetails;

    try {
      final parsed = jsonDecode(response.body);
      if (parsed is Map<String, dynamic>) {
        if (parsed['details'] != null && parsed['details'] is List) {
          final list = parsed['details'] as List;
          final msgs = list.map((e) => e['message'] ?? e.toString()).join('; ');
          errorMessage = msgs.isNotEmpty ? msgs : errorMessage;
          errorDetails = list;
        } else if (parsed['detail'] != null) {
          if (parsed['detail'] is String) {
            errorMessage = parsed['detail'];
          } else if (parsed['detail'] is List) {
            final list = parsed['detail'] as List;
            errorMessage = list.map((e) => e['msg'] ?? e.toString()).join('; ');
            errorDetails = list;
          }
        } else if (parsed['message'] != null) {
          errorMessage = parsed['message'].toString();
        }
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
        // Automatically clear stale credentials
        _storage.clearAuth();
        throw AuthException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 422:
        throw ValidationException(errorMessage, details: errorDetails);
      case 429:
        throw RateLimitException(errorMessage);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage);
      default:
        throw ServerException(errorMessage);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});
