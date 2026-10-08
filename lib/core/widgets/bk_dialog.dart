import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';
import 'bk_button.dart';

Future<T?> showBkDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
}) {
  final t = BkTokens.of(context);

  return showDialog<T>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: [
              BoxShadow(
                color: t.shadowColor,
                offset: Offset(t.shadowOffset * 2, t.shadowOffset * 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: t.background,
                  border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: t.foreground,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: t.border, width: 2),
                        ),
                        child: Icon(Icons.close, size: 16, color: t.foreground),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: content,
              ),
              // Footer
              if (actions != null && actions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: t.muted.withValues(alpha: 0.2),
                    border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions.map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a)).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> showBkAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'CONFIRM',
  String cancelLabel = 'CANCEL',
  bool isDestructive = false,
}) {
  return showBkDialog<bool>(
    context: context,
    title: title,
    content: Text(
      message,
      style: GoogleFonts.outfit(fontSize: 14, height: 1.5),
    ),
    actions: [
      BkButton(
        label: cancelLabel,
        variant: BkButtonVariant.outline,
        size: BkButtonSize.sm,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      BkButton(
        label: confirmLabel,
        variant: isDestructive ? BkButtonVariant.destructive : BkButtonVariant.primary,
        size: BkButtonSize.sm,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
}
