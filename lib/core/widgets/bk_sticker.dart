import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

enum BkStickerVariant { defaultVariant, primary, secondary, destructive, outline, neon }
enum BkStickerRotation { none, slight, medium, heavy, slightRight, mediumRight, heavyRight }

class BkSticker extends StatelessWidget {
  const BkSticker({
    super.key,
    required this.child,
    this.variant = BkStickerVariant.defaultVariant,
    this.rotation = BkStickerRotation.slight,
    this.dashed = false,
    this.tape = false,
    this.onTap,
  });

  final Widget child;
  final BkStickerVariant variant;
  final BkStickerRotation rotation;
  final bool dashed;
  final bool tape;
  final VoidCallback? onTap;

  double get _angle => switch (rotation) {
    BkStickerRotation.none => 0.0,
    BkStickerRotation.slight => -2.0 * math.pi / 180,
    BkStickerRotation.medium => -6.0 * math.pi / 180,
    BkStickerRotation.heavy => -12.0 * math.pi / 180,
    BkStickerRotation.slightRight => 2.0 * math.pi / 180,
    BkStickerRotation.mediumRight => 6.0 * math.pi / 180,
    BkStickerRotation.heavyRight => 12.0 * math.pi / 180,
  };

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final (bg, fg) = switch (variant) {
      BkStickerVariant.primary => (t.primary, t.primaryForeground),
      BkStickerVariant.secondary => (t.secondary, t.secondaryForeground),
      BkStickerVariant.destructive => (t.destructive, t.destructiveForeground),
      BkStickerVariant.outline => (t.card, t.foreground),
      BkStickerVariant.neon => (t.neonPink, Colors.white),
      BkStickerVariant.defaultVariant => (t.accent, t.accentForeground),
    };

    Widget stickerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      child: DefaultTextStyle(
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          color: fg,
        ),
        child: child,
      ),
    );

    if (dashed) {
      stickerContent = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: t.border.withValues(alpha: 0.5), width: 1.5),
        ),
        child: stickerContent,
      );
    }

    if (tape) {
      stickerContent = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          stickerContent,
          Positioned(
            top: -10,
            child: Transform.rotate(
              angle: -3 * math.pi / 180,
              child: Container(
                width: 48,
                height: 16,
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.8),
                  border: Border.all(color: t.border, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Transform.rotate(
      angle: _angle,
      child: GestureDetector(onTap: onTap, child: stickerContent),
    );
  }
}

class BkStamp extends StatelessWidget {
  const BkStamp({
    super.key,
    required this.text,
    this.color,
    this.size = 80.0,
    this.rotation = -12.0,
  });

  final String text;
  final Color? color;
  final double size;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final stampColor = color ?? t.destructive;

    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: stampColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: stampColor, width: 2),
          ),
          child: Center(
            child: Text(
              text.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w900,
                color: stampColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BkStickyNote extends StatelessWidget {
  const BkStickyNote({
    super.key,
    required this.child,
    this.color,
    this.pin = false,
    this.width = 180.0,
    this.rotation = -2.0,
  });

  final Widget child;
  final Color? color;
  final bool pin;
  final double width;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final noteBg = color ?? t.accent;

    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: noteBg,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset, t.shadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
          if (pin)
            Positioned(
              top: -8,
              left: width / 2 - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: t.destructive,
                  border: Border.all(color: t.border, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, offset: Offset(2, 2)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
