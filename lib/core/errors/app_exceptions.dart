/// Structured error models for TradeMind Mobile.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Cannot connect to server. Check your network or server URL.']);
}

class AppTimeoutException extends AppException {
  const AppTimeoutException([super.message = 'Request timed out. Please try again.']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Session expired or unauthorized. Please log in again.'])
      : super(statusCode: 401);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.details})
      : super(statusCode: 422);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found or expired.'])
      : super(statusCode: 404);
}

class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Too many requests. Please wait before trying again.'])
      : super(statusCode: 429);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Internal server error occurred.'])
      : super(statusCode: 500);
}
