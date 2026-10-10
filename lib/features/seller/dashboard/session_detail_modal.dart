import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_states.dart';
import 'dashboard_provider.dart';

class SessionDetailModal extends ConsumerWidget {
  final int sessionId;

  const SessionDetailModal({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final exportAsync = ref.watch(sessionExportProvider(sessionId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: t.background,
        border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: t.card,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
          title: Text(
            'SESSION #$sessionId TRANSCRIPT',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              color: t.foreground,
              fontSize: 15,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: exportAsync.when(
          loading: () => const BkLoadingState(message: 'Loading chat transcript...'),
          error: (err, _) => BkErrorState(
            error: err.toString(),
            onRetry: () => ref.refresh(sessionExportProvider(sessionId)),
          ),
          data: (session) {
            return Column(
              children: [
                // Session Header Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: t.card,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.productName,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: t.foreground,
                              ),
                            ),
                            Text(
                              '${session.roundsUsed} rounds • ${session.status.toUpperCase()}',
                              style: TextStyle(fontSize: 11, color: t.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      if (session.finalPrice != null)
                        Text(
                          CurrencyFormatter.format(session.finalPrice),
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: session.dealClosed ? t.secondary : t.foreground,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Chat Messages Feed
                Expanded(
                  child: session.messages.isEmpty
                      ? const Center(child: Text('No messages recorded for this session.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: session.messages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, idx) {
                            final m = session.messages[idx];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Round Header
                                Center(
                                  child: BkBadge(
                                    label: 'ROUND ${m.roundNumber}',
                                    variant: BkBadgeVariant.outline,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Buyer Message
                                if (m.userMessage != null && m.userMessage!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 300),
                                      padding: const EdgeInsets.all(12),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BUYER',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: t.mutedForeground,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            m.userMessage!,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                          if (m.offeredPrice != null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              'Offer: ${CurrencyFormatter.format(m.offeredPrice)}',
                                              style: TextStyle(
                                                fontFamily: 'DM Mono',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: t.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Bot / Seller Reply
                                if (m.botReply != null && m.botReply!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 300),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: t.secondary.withAlpha(35),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'SELLER / ENGINE',
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: t.secondary,
                                                ),
                                              ),
                                              if (m.decision != null)
                                                BkBadge(
                                                  label: m.decision!.toUpperCase(),
                                                  variant: BkBadgeVariant.secondary,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            m.botReply!,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                          if (m.counterPrice != null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              'Counter: ${CurrencyFormatter.format(m.counterPrice)}',
                                              style: TextStyle(
                                                fontFamily: 'DM Mono',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: t.secondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),

                // Callback notification if buyer asked for follow up
                if (session.callback != null && session.callback!['phone_number'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: t.accent.withAlpha(50),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Callback requested by buyer: ${session.callback!['phone_number']}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom Export Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.card,
                    border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BkButton(
                          variant: BkButtonVariant.outline,
                          label: 'COPY JSON',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: session.messages
                                  .map((m) =>
                                      'Round ${m.roundNumber}: Buyer: "${m.userMessage}" | Seller: "${m.botReply}"')
                                  .join('\n'),
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied transcript to clipboard')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkButton(
                          variant: BkButtonVariant.primary,
                          label: 'DONE',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
