import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class Error500Screen extends StatelessWidget {
  const Error500Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('500 SERVER ERROR', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '500',
                style: GoogleFonts.outfit(
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -4,
                  height: 0.9,
                  color: t.destructive,
                  shadows: [
                    Shadow(color: t.shadowColor, offset: const Offset(6, 6)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border.all(color: t.border, width: t.borderWidth),
                  boxShadow: [
                    BoxShadow(color: t.shadowColor, offset: const Offset(4, 4)),
                  ],
                ),
                child: Text(
                  'INTERNAL SERVER EXPLOSION',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'Our servers encountered an unexpected condition. Engineers have been deployed to fix it immediately.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 14, color: t.mutedForeground, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  BkButton(
                    label: 'TRY AGAIN',
                    variant: BkButtonVariant.primary,
                    size: BkButtonSize.defaultSize,
                    onPressed: () => context.go('/'),
                  ),
                  BkButton(
                    label: 'VIEW STATUS',
                    variant: BkButtonVariant.outline,
                    size: BkButtonSize.defaultSize,
                    onPressed: () => context.go('/blocks/maintenance'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
