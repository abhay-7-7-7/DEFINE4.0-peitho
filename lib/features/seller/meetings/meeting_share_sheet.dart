import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../live_chat/seller_live_chat_screen.dart';
import 'meeting_models.dart';

class MeetingShareSheet extends StatelessWidget {
  final LiveMeetingSession session;

  const MeetingShareSheet({super.key, required this.session});

  Future<void> _shareWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      'Join our commercial negotiation room for "${session.productName}" (Asking: ${CurrencyFormatter.format(session.basePrice)}).\n\n'
      'Direct link: ${session.buyerLink}\n'
      'Or enter token in TradeMind: ${session.sessionId}',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.background,
        border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHARE NEGOTIATION ROOM',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: t.foreground,
                          ),
                        ),
                        Text(
                          session.productName,
                          style: TextStyle(fontSize: 13, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // QR Code Card
              Center(
                child: BkCard(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        QrImageView(
                          data: session.buyerLink.isNotEmpty
                              ? session.buyerLink
                              : session.sessionId,
                          version: QrVersions.auto,
                          size: 190.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan to join on buyer device',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: t.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Room Token Display
              BkCard(
                backgroundColor: t.card,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROOM TOKEN',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: t.mutedForeground,
                              ),
                            ),
                            Text(
                              session.sessionId,
                              style: const TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy Token',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: session.sessionId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Room token copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: BkButton(
                      variant: BkButtonVariant.secondary,
                      label: 'WHATSAPP',
                      leading: const Icon(Icons.chat, size: 18),
                      onPressed: () => _shareWhatsApp(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BkButton(
                      variant: BkButtonVariant.outline,
                      label: 'COPY LINK',
                      leading: const Icon(Icons.link, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: session.buyerLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Buyer link copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              BkButton(
                variant: BkButtonVariant.primary,
                label: 'ENTER LIVE NEGOTIATION',
                leading: const Icon(Icons.arrow_forward, size: 18),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SellerLiveChatScreen(session: session),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
