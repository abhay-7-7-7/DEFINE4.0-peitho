import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

Future<T?> showBkBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  final t = BkTokens.of(context);

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: t.card,
          border: Border(
            top: BorderSide(color: t.border, width: t.borderWidth),
            left: BorderSide(color: t.border, width: t.borderWidth),
            right: BorderSide(color: t.border, width: t.borderWidth),
          ),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              offset: const Offset(0, -4),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.border,
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: t.foreground,
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
              Container(height: t.borderWidth, color: t.border),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<T?> showBkSideSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  final t = BkTokens.of(context);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Side Sheet',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 420),
            height: double.infinity,
            decoration: BoxDecoration(
              color: t.card,
              border: Border(
                  left: BorderSide(color: t.border, width: t.borderWidth)),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: const Offset(-6, 0),
                  blurRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: t.background,
                      border: Border(
                          bottom: BorderSide(
                              color: t.border, width: t.borderWidth)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: t.foreground,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                border: Border.all(color: t.border, width: 2)),
                            child: Icon(Icons.close,
                                size: 16, color: t.foreground),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        ),
        child: child,
      );
    },
  );
}
