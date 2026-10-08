import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkTooltip extends StatelessWidget {
  const BkTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: t.foreground,
        border: Border.all(color: t.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      textStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: t.background,
        letterSpacing: 0.5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: child,
    );
  }
}
