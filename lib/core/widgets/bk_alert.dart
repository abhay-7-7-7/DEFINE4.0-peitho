import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

enum BkAlertVariant { info, success, warning, destructive }

class BkAlert extends StatelessWidget {
  const BkAlert({
    super.key,
    required this.title,
    this.description,
    this.variant = BkAlertVariant.info,
    this.icon,
    this.onClose,
  });

  final String title;
  final String? description;
  final BkAlertVariant variant;
  final Widget? icon;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final (bg, fg, defaultIcon) = switch (variant) {
      BkAlertVariant.info => (t.info, t.infoForeground, Icons.info_outline),
      BkAlertVariant.success => (
          t.success,
          t.successForeground,
          Icons.check_circle_outline
        ),
      BkAlertVariant.warning => (
          t.warning,
          t.warningForeground,
          Icons.warning_amber_outlined
        ),
      BkAlertVariant.destructive => (
          t.destructive,
          t.destructiveForeground,
          Icons.error_outline
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon ?? Icon(defaultIcon, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: fg,
                    letterSpacing: 0.5,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fg.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.close, color: fg, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}
