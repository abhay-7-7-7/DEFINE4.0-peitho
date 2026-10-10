class SellerUser {
  final int id;
  final String email;
  final String fullName;

  const SellerUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  factory SellerUser.fromJson(Map<String, dynamic> json) {
    return SellerUser(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
      };
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final SellerUser? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.authenticated(SellerUser user, String token) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated && token != null;
}
