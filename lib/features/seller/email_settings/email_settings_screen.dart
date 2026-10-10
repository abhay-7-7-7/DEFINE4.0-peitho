import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_states.dart';
import 'email_settings_provider.dart';

class EmailSettingsScreen extends ConsumerStatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  ConsumerState<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends ConsumerState<EmailSettingsScreen> {
  final _hostController = TextEditingController(text: 'smtp.gmail.com');
  final _portController = TextEditingController(text: '587');
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fromEmailController = TextEditingController();
  final _fromNameController = TextEditingController(text: 'TradeMind');

  bool _useTls = true;
  bool _notificationsEnabled = true;
  bool _notifyOnDeal = true;
  bool _notifyOnNewSession = true;
  bool _notifyOnApiKey = true;

  bool _initialized = false;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _fromEmailController.dispose();
    _fromNameController.dispose();
    super.dispose();
  }

  void _populateFromState(EmailSettingsData data) {
    if (_initialized) return;
    _initialized = true;
    _hostController.text = data.smtpHost;
    _portController.text = data.smtpPort.toString();
    _userController.text = data.smtpUser;
    _passwordController.text = data.smtpPassword;
    _fromEmailController.text = data.fromEmail;
    _fromNameController.text = data.fromName;
    _useTls = data.useTls;
    _notificationsEnabled = data.notificationsEnabled;
    _notifyOnDeal = data.notifyOnDeal;
    _notifyOnNewSession = data.notifyOnNewSession;
    _notifyOnApiKey = data.notifyOnApiKey;
  }

  void _save() async {
    final updated = EmailSettingsData(
      smtpHost: _hostController.text.trim(),
      smtpPort: int.tryParse(_portController.text.trim()) ?? 587,
      smtpUser: _userController.text.trim(),
      smtpPassword: _passwordController.text.trim(),
      fromEmail: _fromEmailController.text.trim(),
      fromName: _fromNameController.text.trim(),
      useTls: _useTls,
      notificationsEnabled: _notificationsEnabled,
      notifyOnDeal: _notifyOnDeal,
      notifyOnNewSession: _notifyOnNewSession,
      notifyOnApiKey: _notifyOnApiKey,
    );

    final ok = await ref.read(emailSettingsProvider.notifier).saveSettings(updated);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email settings saved successfully!')),
      );
    }
  }

  void _test() {
    ref.read(emailSettingsProvider.notifier).sendTestEmail();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final state = ref.watch(emailSettingsProvider);

    if (state.settings != null) {
      _populateFromState(state.settings!);
    }

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'EMAIL & SMTP SETTINGS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: BkButton(
              size: BkButtonSize.sm,
              variant: BkButtonVariant.primary,
              label: 'SAVE',
              isLoading: state.isSaving,
              onPressed: _save,
            ),
          ),
        ],
      ),
      body: state.isLoading && state.settings == null
          ? const BkLoadingState(message: 'Loading SMTP settings...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.error != null) ...[
                    BkAlert(
                      title: 'SMTP Error',
                      description: state.error!,
                      variant: BkAlertVariant.destructive,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (state.testSuccessMessage != null) ...[
                    BkAlert(
                      title: 'Test Email Dispatched',
                      description: state.testSuccessMessage!,
                      variant: BkAlertVariant.success,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // SMTP Server Details
                  BkCard(
                    backgroundColor: t.card,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OUTGOING SMTP SERVER',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: t.foreground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: BkInput(
                                  label: 'Host',
                                  controller: _hostController,
                                  hint: 'smtp.gmail.com',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: BkInput(
                                  label: 'Port',
                                  controller: _portController,
                                  hint: '587',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          BkInput(
                            label: 'Username / Email',
                            controller: _userController,
                            hint: 'your.account@gmail.com',
                          ),
                          const SizedBox(height: 10),
                          BkInput(
                            label: 'App Password / Secret',
                            controller: _passwordController,
                            obscureText: true,
                            hint: '••••••••••••••••',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: BkInput(
                                  label: 'From Email',
                                  controller: _fromEmailController,
                                  hint: 'support@yourdomain.com',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: BkInput(
                                  label: 'From Name',
                                  controller: _fromNameController,
                                  hint: 'TradeMind Store',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Use TLS Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: const Text('Enables encrypted STARTTLS transport', style: TextStyle(fontSize: 11)),
                            value: _useTls,
                            activeTrackColor: t.primary,
                            onChanged: (val) => setState(() => _useTls = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notification Triggers Card
                  BkCard(
                    backgroundColor: t.card,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOTIFICATION PREFERENCES',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: t.foreground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Enable Email Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: const Text('Master switch for automated transactional emails', style: TextStyle(fontSize: 11)),
                            value: _notificationsEnabled,
                            activeTrackColor: t.primary,
                            onChanged: (val) => setState(() => _notificationsEnabled = val),
                          ),
                          const Divider(),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notify on Deal Closed', style: TextStyle(fontSize: 13)),
                            value: _notifyOnDeal,
                            activeColor: t.primary,
                            onChanged: _notificationsEnabled ? (val) => setState(() => _notifyOnDeal = val ?? true) : null,
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notify on New Negotiation Session', style: TextStyle(fontSize: 13)),
                            value: _notifyOnNewSession,
                            activeColor: t.primary,
                            onChanged: _notificationsEnabled ? (val) => setState(() => _notifyOnNewSession = val ?? true) : null,
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Notify on API Key Events', style: TextStyle(fontSize: 13)),
                            value: _notifyOnApiKey,
                            activeColor: t.primary,
                            onChanged: _notificationsEnabled ? (val) => setState(() => _notifyOnApiKey = val ?? true) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Test Email Action
                  BkButton(
                    variant: BkButtonVariant.secondary,
                    label: 'DISPATCH TEST EMAIL',
                    isLoading: state.isTesting,
                    onPressed: _test,
                  ),
                ],
              ),
            ),
    );
  }
}
