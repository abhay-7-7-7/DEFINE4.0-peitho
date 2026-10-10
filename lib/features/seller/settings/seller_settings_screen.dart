import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_dialog.dart';
import '../../../core/widgets/bk_input.dart';
import '../auth/auth_controller.dart';

class SellerSettingsScreen extends ConsumerWidget {
  const SellerSettingsScreen({super.key});

  void _showLanguageSwitcher(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final t = BkTokens.of(ctx);
        final currentLocale = ref.watch(appLocaleProvider);

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.background,
                  border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SELECT LANGUAGE / भाषा',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: supportedLanguages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (c, idx) {
                    final lang = supportedLanguages[idx];
                    final isSelected = lang.code == currentLocale.localeCode;

                    return GestureDetector(
                      onTap: () {
                        ref.read(appLocaleProvider.notifier).setLocale(lang.code);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? t.secondary.withAlpha(40) : t.card,
                          border: Border.all(color: t.border, width: isSelected ? 2.5 : 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  lang.name,
                                  style: TextStyle(fontSize: 11, color: t.mutedForeground),
                                ),
                              ],
                            ),
                            if (lang.rtl)
                              const BkBadge(
                                label: 'RTL',
                                variant: BkBadgeVariant.outline,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNetworkSettingsDialog(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final currentBaseUrl = ref.read(apiBaseUrlProvider);
    final textController = TextEditingController(text: currentBaseUrl);

    showBkDialog(
      context: context,
      title: 'BACKEND NETWORK URL',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Configure host for Android emulator (10.0.2.2:8000), physical LAN IP, or Cloudflare tunnel.',
            style: TextStyle(color: t.mutedForeground, fontSize: 13),
          ),
          const SizedBox(height: 12),
          BkInput(
            label: 'Base URL',
            controller: textController,
            hint: 'http://10.0.2.2:8000',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BkButton(
                  size: BkButtonSize.sm,
                  variant: BkButtonVariant.outline,
                  label: '10.0.2.2',
                  onPressed: () {
                    textController.text = 'http://10.0.2.2:8000';
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BkButton(
                  size: BkButtonSize.sm,
                  variant: BkButtonVariant.outline,
                  label: '127.0.0.1',
                  onPressed: () {
                    textController.text = 'http://127.0.0.1:8000';
                  },
                ),
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
            await ref.read(apiBaseUrlProvider.notifier).setBaseUrl(textController.text);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showBkAlertDialog(
      context: context,
      title: 'LOGOUT SESSION?',
      message: 'Are you sure you want to log out of your seller account?',
      confirmLabel: 'LOGOUT',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/seller/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final appLocale = ref.watch(appLocaleProvider);
    final currentBaseUrl = ref.watch(apiBaseUrlProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'TOOLS & SETTINGS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: t.primary,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'S',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: t.foreground,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 12, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const BkBadge(label: 'SELLER', variant: BkBadgeVariant.primary),
                ],
              ),
            ),

          // Tools Navigation Section
          _sectionHeader(t, 'INTEGRATIONS & ENGINES'),
          const SizedBox(height: 8),
          _navTile(
            t: t,
            icon: Icons.analytics_outlined,
            title: 'Business Analytics',
            subtitle: 'Calculate margins, simulate scenarios, view recommendations',
            onTap: () => context.push('/seller/analytics'),
          ),
          _navTile(
            t: t,
            icon: Icons.key_outlined,
            title: 'API Access Keys',
            subtitle: 'Manage programmatic API keys and webhooks',
            onTap: () => context.push('/seller/api-keys'),
          ),
          _navTile(
            t: t,
            icon: Icons.mail_outline,
            title: 'Email & SMTP Configuration',
            subtitle: 'Transaction notifications and test email dispatcher',
            onTap: () => context.push('/seller/email-settings'),
          ),
          _navTile(
            t: t,
            icon: Icons.mic_outlined,
            title: 'Sarvam Voice Call Engine',
            subtitle: 'Real-time WebSocket audio streaming diagnostics',
            onTap: () => context.push('/seller/voice'),
          ),
          _navTile(
            t: t,
            icon: Icons.phone_callback_outlined,
            title: 'Buyer Callback Requests',
            subtitle: 'Inspect buyer requests and phone follow-ups',
            onTap: () => context.push('/seller/callbacks'),
          ),

          const SizedBox(height: 16),

          // Preferences Section
          _sectionHeader(t, 'APPLICATION PREFERENCES'),
          const SizedBox(height: 8),
          _navTile(
            t: t,
            icon: Icons.language,
            title: 'Language / भाषा',
            subtitle: 'Current: ${appLocale.localeCode.toUpperCase()}',
            onTap: () => _showLanguageSwitcher(context, ref),
          ),
          _navTile(
            t: t,
            icon: Icons.cloud_outlined,
            title: 'Backend Server URL',
            subtitle: currentBaseUrl,
            onTap: () => _showNetworkSettingsDialog(context, ref),
          ),

          const SizedBox(height: 24),

          // Logout Action
          BkButton(
            variant: BkButtonVariant.destructive,
            label: 'LOG OUT ACCOUNT',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BkTokens t, String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: t.mutedForeground,
      ),
    );
  }

  Widget _navTile({
    required BkTokens t,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.border, width: t.borderWidth),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.background,
                  border: Border.all(color: t.border, width: 1.5),
                ),
                child: Icon(icon, size: 20, color: t.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: t.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: t.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
