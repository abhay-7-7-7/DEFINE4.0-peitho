import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_states.dart';
import 'callbacks_provider.dart';

class CallbacksScreen extends ConsumerWidget {
  const CallbacksScreen({super.key});

  Future<void> _dialPhone(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final callbacksAsync = ref.watch(callbacksProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'CALLBACK REQUESTS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(callbacksProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(callbacksProvider),
        child: callbacksAsync.when(
          loading: () => const BkLoadingState(message: 'Loading buyer callbacks...'),
          error: (err, _) => BkErrorState(
            error: err.toString(),
            onRetry: () => ref.refresh(callbacksProvider),
          ),
          data: (callbacks) {
            if (callbacks.isEmpty) {
              return BkEmptyState(
                icon: Icons.phone_callback_outlined,
                title: 'No Callback Requests',
                description:
                    'When buyers request a call during autonomous negotiation, their contact requests appear here.',
                actionLabel: 'Refresh',
                onAction: () => ref.refresh(callbacksProvider),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: callbacks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final cb = callbacks[idx];

                return BkCard(
                  backgroundColor: t.card,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cb.productName,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: t.foreground,
                                ),
                              ),
                            ),
                            BkBadge(
                              label: cb.status.toUpperCase(),
                              variant: BkBadgeVariant.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone Number', style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                                Text(
                                  cb.phoneNumber,
                                  style: TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: t.foreground,
                                  ),
                                ),
                              ],
                            ),
                            if (cb.finalPrice != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Negotiated Price', style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                                  Text(
                                    CurrencyFormatter.format(cb.finalPrice),
                                    style: TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: t.secondary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: BkButton(
                                size: BkButtonSize.sm,
                                variant: BkButtonVariant.primary,
                                label: 'CALL BUYER',
                                leading: const Icon(Icons.phone, size: 16),
                                onPressed: () => _dialPhone(context, cb.phoneNumber),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
