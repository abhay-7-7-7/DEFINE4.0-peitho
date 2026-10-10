import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_dialog.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_states.dart';
import 'api_keys_provider.dart';

class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  void _showGenerateModal() {
    final labelController = TextEditingController(text: 'Mobile Integration');

    showBkDialog(
      context: context,
      title: 'GENERATE NEW API KEY',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'API keys grant full programmatic access to your TradeMind negotiation engine and catalog.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          BkInput(
            label: 'Key Label',
            hint: 'e.g. Production Webhook, Zapier Bot',
            controller: labelController,
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
          label: 'GENERATE',
          onPressed: () async {
            Navigator.of(context).pop();
            await ref.read(apiKeysProvider.notifier).createKey(labelController.text.trim());
          },
        ),
      ],
    );
  }

  void _showRevokeConfirmation(ApiKeyItem key) async {
    final confirmed = await showBkAlertDialog(
      context: context,
      title: 'REVOKE API KEY',
      message: 'Are you sure you want to permanently revoke key "${key.label}"? Any integration using this key will immediately fail.',
      confirmLabel: 'REVOKE KEY',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(apiKeysProvider.notifier).revokeKey(key.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final state = ref.watch(apiKeysProvider);
    final notifier = ref.read(apiKeysProvider.notifier);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'API ACCESS KEYS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Keys',
            onPressed: () => notifier.fetchKeys(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchKeys(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Generate Key Callout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUTHENTICATED API KEYS',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: t.foreground,
                        ),
                      ),
                      Text(
                        'Manage keys for programmatic session creation.',
                        style: TextStyle(fontSize: 12, color: t.mutedForeground),
                      ),
                    ],
                  ),
                ),
                BkButton(
                  size: BkButtonSize.sm,
                  variant: BkButtonVariant.primary,
                  label: '+ NEW KEY',
                  onPressed: _showGenerateModal,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Newly Created Key Banner (Shown only once)
            if (state.newlyCreatedKey != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.primary.withAlpha(30),
                  border: Border.all(color: t.border, width: t.borderWidth),
                  boxShadow: [
                    BoxShadow(
                      color: t.shadowColor,
                      offset: Offset(t.shadowOffset, t.shadowOffset),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KEY CREATED — COPY NOW!',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: t.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => notifier.clearNewKey(),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This secret key will never be displayed again. Store it securely.',
                      style: TextStyle(fontSize: 12, color: t.foreground),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: t.card,
                      child: SelectableText(
                        state.newlyCreatedKey!,
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BkButton(
                      size: BkButtonSize.sm,
                      variant: BkButtonVariant.outline,
                      label: 'COPY TO CLIPBOARD',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: state.newlyCreatedKey!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API Key copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Keys Feed
            if (state.isLoading && state.keys.isEmpty)
              const BkLoadingState(message: 'Loading active API keys...')
            else if (state.error != null && state.keys.isEmpty)
              BkErrorState(
                error: state.error!,
                onRetry: () => notifier.fetchKeys(),
              )
            else if (state.keys.isEmpty)
              BkEmptyState(
                title: 'NO API KEYS GENERATED',
                description: 'You have not generated any API keys yet. Create one to integrate TradeMind with external systems.',
                actionLabel: 'GENERATE KEY',
                onAction: _showGenerateModal,
              )
            else
              ...state.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: BkCard(
                    backgroundColor: t.card,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key.label.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              BkBadge(
                                label: key.isActive ? 'ACTIVE' : 'REVOKED',
                                variant: key.isActive ? BkBadgeVariant.success : BkBadgeVariant.outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            color: t.background,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    key.maskedKey,
                                    style: const TextStyle(fontFamily: 'DM Mono', fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  tooltip: 'Copy masked key',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: key.maskedKey));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Masked key copied')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key.createdAt != null
                                    ? 'Created: ${key.createdAt!.split(' ')[0]}'
                                    : 'Created recently',
                                style: TextStyle(fontSize: 11, color: t.mutedForeground),
                              ),
                              GestureDetector(
                                onTap: () => _showRevokeConfirmation(key),
                                child: Text(
                                  'REVOKE',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: t.destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
