import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

enum BkToastVariant {
  defaultToast,
  success,
  warning,
  error;

  static const info = BkToastVariant.defaultToast;
  static const destructive = BkToastVariant.error;
}

class BkToastManager {
  BkToastManager._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    BkToastVariant variant = BkToastVariant.defaultToast,
    Duration duration = const Duration(seconds: 4),
  }) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final t = BkTokens.of(context);

    final (bg, fg, icon) = switch (variant) {
      BkToastVariant.success => (
          t.success,
          t.successForeground,
          Icons.check_circle
        ),
      BkToastVariant.warning => (
          t.warning,
          t.warningForeground,
          Icons.warning_amber
        ),
      BkToastVariant.error => (
          t.destructive,
          t.destructiveForeground,
          Icons.error
        ),
      BkToastVariant.defaultToast => (t.foreground, t.background, Icons.info),
    };

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 24,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                children: [
                  Icon(icon, color: fg, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) ...[
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: fg,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          message,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _currentEntry?.remove();
                      _currentEntry = null;
                    },
                    child: Icon(Icons.close, size: 16, color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}
