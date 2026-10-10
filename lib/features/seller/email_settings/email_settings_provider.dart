import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class EmailSettingsData {
  final String smtpHost;
  final int smtpPort;
  final String smtpUser;
  final String smtpPassword;
  final String fromEmail;
  final String fromName;
  final bool useTls;
  final bool notificationsEnabled;
  final bool notifyOnDeal;
  final bool notifyOnNewSession;
  final bool notifyOnApiKey;

  EmailSettingsData({
    this.smtpHost = 'smtp.gmail.com',
    this.smtpPort = 587,
    this.smtpUser = '',
    this.smtpPassword = '',
    this.fromEmail = '',
    this.fromName = 'TradeMind',
    this.useTls = true,
    this.notificationsEnabled = true,
    this.notifyOnDeal = true,
    this.notifyOnNewSession = true,
    this.notifyOnApiKey = true,
  });

  factory EmailSettingsData.fromJson(Map<String, dynamic> json) {
    return EmailSettingsData(
      smtpHost: json['smtp_host']?.toString() ?? 'smtp.gmail.com',
      smtpPort: (json['smtp_port'] as num?)?.toInt() ?? 587,
      smtpUser: json['smtp_user']?.toString() ?? '',
      smtpPassword: json['smtp_password']?.toString() ?? '',
      fromEmail: json['from_email']?.toString() ?? '',
      fromName: json['from_name']?.toString() ?? 'TradeMind',
      useTls: json['use_tls'] != false && json['use_tls'] != 0,
      notificationsEnabled: json['notifications_enabled'] != false && json['notifications_enabled'] != 0,
      notifyOnDeal: json['notify_on_deal'] != false && json['notify_on_deal'] != 0,
      notifyOnNewSession: json['notify_on_new_session'] != false && json['notify_on_new_session'] != 0,
      notifyOnApiKey: json['notify_on_api_key'] != false && json['notify_on_api_key'] != 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'smtp_host': smtpHost,
        'smtp_port': smtpPort,
        'smtp_user': smtpUser,
        'smtp_password': smtpPassword,
        'from_email': fromEmail,
        'from_name': fromName,
        'use_tls': useTls,
        'notifications_enabled': notificationsEnabled,
        'notify_on_deal': notifyOnDeal,
        'notify_on_new_session': notifyOnNewSession,
        'notify_on_api_key': notifyOnApiKey,
      };
}

class EmailSettingsState {
  final bool isLoading;
  final bool isSaving;
  final bool isTesting;
  final String? error;
  final String? testSuccessMessage;
  final EmailSettingsData? settings;

  const EmailSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.isTesting = false,
    this.error,
    this.testSuccessMessage,
    this.settings,
  });

  EmailSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isTesting,
    String? error,
    String? testSuccessMessage,
    EmailSettingsData? settings,
  }) {
    return EmailSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isTesting: isTesting ?? this.isTesting,
      error: error,
      testSuccessMessage: testSuccessMessage,
      settings: settings ?? this.settings,
    );
  }
}

class EmailSettingsNotifier extends StateNotifier<EmailSettingsState> {
  final ApiClient _api;

  EmailSettingsNotifier(this._api) : super(const EmailSettingsState()) {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/api/v1/email/settings', requiresAuth: true);
      if (res is Map<String, dynamic>) {
        state = state.copyWith(
          isLoading: false,
          settings: EmailSettingsData.fromJson(res),
        );
      } else {
        state = state.copyWith(isLoading: false, settings: EmailSettingsData());
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load email settings: ${e.toString()}',
      );
    }
  }

  Future<bool> saveSettings(EmailSettingsData data) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _api.put(
        '/api/v1/email/settings',
        body: data.toJson(),
        requiresAuth: true,
      );
      state = state.copyWith(isSaving: false, settings: data);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save email settings: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> sendTestEmail({String? toEmail}) async {
    state = state.copyWith(isTesting: true, error: null, testSuccessMessage: null);
    try {
      final res = await _api.post(
        '/api/v1/email/test',
        body: {'to_email': toEmail},
        requiresAuth: true,
      );
      final msg = res['message']?.toString() ?? 'Test email dispatched successfully!';
      state = state.copyWith(isTesting: false, testSuccessMessage: msg);
      return true;
    } catch (e) {
      state = state.copyWith(
        isTesting: false,
        error: 'Failed to send test email: ${e.toString()}',
      );
      return false;
    }
  }
}

final emailSettingsProvider =
    StateNotifierProvider<EmailSettingsNotifier, EmailSettingsState>((ref) {
  final api = ref.watch(apiClientProvider);
  return EmailSettingsNotifier(api);
});
