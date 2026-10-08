import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

// ── BkCard ────────────────────────────────────────────────────────────────────

/// A neubrutalist card with 3 px border and 4 px hard-offset shadow.
///
/// Set [interactive] to true to enable a push-down press animation.
class BkCard extends StatefulWidget {
  const BkCard({
    super.key,
    this.child,
    this.backgroundColor,
    this.shadowColor,
    this.shadowOffset,
    this.interactive = false,
    this.onTap,
    this.padding,
  });

  final Widget? child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? shadowOffset;

  /// When true, tapping the card produces a push-down animation.
  final bool interactive;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  State<BkCard> createState() => _BkCardState();
}

class _BkCardState extends State<BkCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final bool isInteractive = widget.interactive || widget.onTap != null;

    final double offset =
        _pressed ? 0.0 : (widget.shadowOffset ?? t.shadowOffset);
    final Color sc = widget.shadowColor ?? t.shadowColor;
    final Color bg = widget.backgroundColor ?? t.card;

    final BoxDecoration decoration = BoxDecoration(
      color: bg,
      border: Border.all(color: t.border, width: t.borderWidth),
      boxShadow: offset > 0
          ? [
              BoxShadow(
                color: sc,
                offset: Offset(offset, offset),
                blurRadius: 0,
                spreadRadius: 0,
              )
            ]
          : const [],
    );

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      transform: Matrix4.translationValues(
        _pressed ? 2 : 0,
        _pressed ? 2 : 0,
        0,
      ),
      decoration: decoration,
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: widget.child,
    );

    if (!isInteractive) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: card,
    );
  }
}

// ── BkCardHeader ─────────────────────────────────────────────────────────────

/// Header section of a [BkCard] — typically holds [BkCardTitle] and
/// [BkCardDescription].
class BkCardHeader extends StatelessWidget {
  const BkCardHeader({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: child,
    );
  }
}

// ── BkCardTitle ──────────────────────────────────────────────────────────────

/// Bold uppercase title inside a card header.
class BkCardTitle extends StatelessWidget {
  const BkCardTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: t.cardForeground,
        letterSpacing: 0.5,
      ).merge(style),
    );
  }
}

// ── BkCardDescription ────────────────────────────────────────────────────────

/// Muted body text beneath [BkCardTitle].
class BkCardDescription extends StatelessWidget {
  const BkCardDescription(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: t.mutedForeground,
        ).merge(style),
      ),
    );
  }
}

// ── BkCardContent ────────────────────────────────────────────────────────────

/// Main content area of a [BkCard].
class BkCardContent extends StatelessWidget {
  const BkCardContent({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

// ── BkCardFooter ─────────────────────────────────────────────────────────────

/// Footer area of a [BkCard], typically contains action buttons.
class BkCardFooter extends StatelessWidget {
  const BkCardFooter({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: child,
    );
  }
}

// ── BkLayeredCard ─────────────────────────────────────────────────────────────

/// A stacked paper effect card with 1–3 visible background layers.
///
/// Each layer is offset by [layerOffset] pixels (default 8) diagonally and
/// rendered in successively muted colours derived from [BkTokens].
class BkLayeredCard extends StatelessWidget {
  const BkLayeredCard({
    super.key,
    required this.child,
    this.layers = 2,
    this.layerOffset = 8.0,
    this.primaryColor,
  }) : assert(layers >= 1 && layers <= 3, 'layers must be between 1 and 3');

  final Widget child;

  /// Number of background layer cards behind the main card. Clamped to 1–3.
  final int layers;

  /// Pixel offset between each layer in both x and y directions.
  final double layerOffset;

  /// Override the top card background; defaults to [BkTokens.card].
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);

    // Layer colours: back → front: secondary, muted, card
    final List<Color> layerColors = [
      t.secondary.withValues(alpha: 0.35),
      t.muted,
      primaryColor ?? t.card,
    ];

    // We render (layers + 1) stacked widgets; only the top card has children.
    final int totalCards = (layers + 1).clamp(2, 4);
    final List<Widget> stack = [];

    for (int i = 0; i < totalCards; i++) {
      final bool isTop = i == totalCards - 1;
      final double dx = (totalCards - 1 - i) * layerOffset;
      final double dy = (totalCards - 1 - i) * layerOffset;
      final Color color = layerColors[
          (i - (totalCards - layerColors.length)).clamp(0, layerColors.length - 1)];

      stack.add(
        Positioned(
          left: dx,
          top: dy,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: t.border, width: t.borderWidth),
            ),
            child: isTop ? null : const SizedBox.expand(),
          ),
        ),
      );
    }

    // Top card with actual content
    final double topPad = (totalCards - 1) * layerOffset;
    return Padding(
      padding: EdgeInsets.only(left: topPad, top: topPad),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background layers (positioned relative to the Stack)
          ...stack.sublist(0, stack.length - 1).map(
                (w) => w,
              ),
          // Foreground card
          DecoratedBox(
            decoration: BoxDecoration(
              color: primaryColor ?? t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
