import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_dialog.dart';
import '../../../core/widgets/bk_input.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class SellerLoginScreen extends ConsumerStatefulWidget {
  const SellerLoginScreen({super.key});

  @override
  ConsumerState<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends ConsumerState<SellerLoginScreen> {
  final _emailController = TextEditingController(text: 'seller@trademind.com');
  final _passwordController = TextEditingController(text: 'TradeMind#2026');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
    if (success && mounted) {
      context.go('/seller/dashboard');
    }
  }

  void _showNetworkSettingsDialog() {
    final t = BkTokens.of(context);
    final currentBaseUrl = ref.read(apiBaseUrlProvider);
    final textController = TextEditingController(text: currentBaseUrl);

    showBkDialog(
      context: context,
      title: 'Backend Server URL',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Configure host for emulator (10.0.2.2:8000), physical device LAN IP, or Cloudflare tunnel.',
            style: TextStyle(color: t.mutedForeground, fontSize: 13),
          ),
          const SizedBox(height: 12),
          BkInput(
            label: 'Base URL',
            controller: textController,
            hint: 'http://10.0.2.2:8000',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BkButton(
                size: BkButtonSize.sm,
                variant: BkButtonVariant.outline,
                label: '127.0.0.1 (USB)',
                onPressed: () {
                  textController.text = 'http://127.0.0.1:8000';
                },
              ),
              BkButton(
                size: BkButtonSize.sm,
                variant: BkButtonVariant.outline,
                label: '10.30.1.95 (Wi-Fi)',
                onPressed: () {
                  textController.text = 'http://10.30.1.95:8000';
                },
              ),
              BkButton(
                size: BkButtonSize.sm,
                variant: BkButtonVariant.outline,
                label: '10.0.2.2 (Emulator)',
                onPressed: () {
                  textController.text = 'http://10.0.2.2:8000';
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        BkButton(
          variant: BkButtonVariant.outline,
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        BkButton(
          variant: BkButtonVariant.primary,
          label: 'Save URL',
          onPressed: () async {
            await ref
                .read(apiBaseUrlProvider.notifier)
                .setBaseUrl(textController.text);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final authState = ref.watch(authControllerProvider);
    final baseUrl = ref.watch(apiBaseUrlProvider);

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: t.card,
                        border: Border.all(color: t.border, width: t.borderWidth),
                        boxShadow: [
                          BoxShadow(
                            color: t.shadowColor,
                            offset: Offset(t.shadowOffset, t.shadowOffset),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: t.primary,
                              border: Border.all(color: t.border, width: t.borderWidth),
                            ),
                            child: const Icon(Icons.handshake, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRADE MIND',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: t.foreground,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Autonomous Commercial Copilot',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.mutedForeground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Login Card
                    BkCard(
                      backgroundColor: t.card,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'SELLER SIGN IN',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: t.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Access your products, deals, and AI assist.',
                              style: TextStyle(
                                fontSize: 13,
                                color: t.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _showNetworkSettingsDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: t.muted.withAlpha(40),
                                  border: Border.all(color: t.border, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.dns_outlined, size: 14, color: t.mutedForeground),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Server: $baseUrl',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'DM Mono',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: t.foreground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit, size: 12, color: t.mutedForeground),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (authState.errorMessage != null) ...[
                              BkAlert(
                                title: 'Login Error',
                                description: '${authState.errorMessage!}\n(Target: $baseUrl)',
                                variant: BkAlertVariant.destructive,
                              ),
                              const SizedBox(height: 16),
                            ],

                            BkInput(
                              label: 'Email Address',
                              controller: _emailController,
                              hint: 'seller@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!val.contains('@')) return 'Enter valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            BkInput(
                              label: 'Password',
                              controller: _passwordController,
                              hint: '••••••••',
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            BkButton(
                              label: 'SIGN IN',
                              isLoading: authState.status == AuthStatus.loading,
                              variant: BkButtonVariant.primary,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 12),

                            BkButton(
                              label: 'CREATE NEW ACCOUNT',
                              variant: BkButtonVariant.outline,
                              onPressed: () {
                                context.push('/seller/register');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Switch to Buyer Mode
                    BkCard(
                      backgroundColor: t.accent.withAlpha(50),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.qr_code_scanner, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Are you a Buyer?',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: t.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Join a live negotiation room with a QR code or meeting link. No account needed.',
                              style: TextStyle(
                                fontSize: 12,
                                color: t.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            BkButton(
                              size: BkButtonSize.sm,
                              variant: BkButtonVariant.secondary,
                              label: 'JOIN AS BUYER',
                              leading: const Icon(Icons.arrow_forward, size: 16),
                              onPressed: () {
                                context.push('/buyer/join');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Server Configuration Bar
                    InkWell(
                      onTap: _showNetworkSettingsDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: t.muted.withAlpha(40),
                          border: Border.all(color: t.border, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dns_outlined, size: 14, color: t.mutedForeground),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Backend: $baseUrl',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 11,
                                  color: t.mutedForeground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 12, color: t.mutedForeground),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
