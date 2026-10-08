import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('SYSTEM STATUS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: BkCard(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      color: t.accent,
                      child: Icon(Icons.build, size: 36, color: t.accentForeground),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SCHEDULED MAINTENANCE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We are currently performing routine upgrades to improve speed and reliability. We expect to be back online shortly.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 14, color: t.mutedForeground, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROGRESS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('75%', style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const BkProgress(value: 0.75, height: 14),
                    const SizedBox(height: 24),
                    BkInput(
                      hint: 'ENTER EMAIL FOR UPDATES',
                      suffix: Icon(Icons.send, color: t.foreground),
                    ),
                    const SizedBox(height: 20),
                    BkButton(
                      label: 'RETURN TO HOME',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.defaultSize,
                      onPressed: () => context.go('/'),
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
