import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

// ── Enum ──────────────────────────────────────────────────────────────────────

enum BkBadgeVariant {
  primary,
  secondary,
  accent,
  destructive,
  success,
  warning,
  info,
  outline,
}

// ── BkBadge ───────────────────────────────────────────────────────────────────

/// Compact neubrutalist badge / chip with hard-offset shadow.
///
/// Supports press and hover interaction when [onTap] is provided.
class BkBadge extends StatefulWidget {
  const BkBadge({
    super.key,
    required this.label,
    this.variant = BkBadgeVariant.primary,
    this.leading,
    this.onTap,
  });

  final String label;
  final BkBadgeVariant variant;

  /// Optional leading icon/widget.
  final Widget? leading;

  /// When set, the badge becomes interactive with press animation.
  final VoidCallback? onTap;

  @override
  State<BkBadge> createState() => _BkBadgeState();
}

class _BkBadgeState extends State<BkBadge> {
  bool _pressed = false;
  bool _hovered = false;

  _BadgeColors _colors(BkTokens t) {
    switch (widget.variant) {
      case BkBadgeVariant.primary:
        return _BadgeColors(bg: t.primary, fg: t.primaryForeground);
      case BkBadgeVariant.secondary:
        return _BadgeColors(bg: t.secondary, fg: t.secondaryForeground);
      case BkBadgeVariant.accent:
        return _BadgeColors(bg: t.accent, fg: t.accentForeground);
      case BkBadgeVariant.destructive:
        return _BadgeColors(bg: t.destructive, fg: t.destructiveForeground);
      case BkBadgeVariant.success:
        return _BadgeColors(bg: t.success, fg: t.successForeground);
      case BkBadgeVariant.warning:
        return _BadgeColors(bg: t.warning, fg: t.warningForeground);
      case BkBadgeVariant.info:
        return _BadgeColors(bg: t.info, fg: t.infoForeground);
      case BkBadgeVariant.outline:
        return _BadgeColors(bg: t.background, fg: t.foreground);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final _BadgeColors c = _colors(t);
    final bool interactive = widget.onTap != null;

    final double shadowOffset = _pressed ? 0 : (_hovered ? 3 : 2);
    final Offset translate = _pressed ? const Offset(2, 2) : Offset.zero;

    Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      transform: Matrix4.translationValues(translate.dx, translate.dy, 0),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border.all(color: t.border, width: 2),
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                )
              ]
            : const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(color: c.fg, size: 12),
              child: widget.leading!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.fg,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );

    if (!interactive) return badge;

    badge = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: badge,
    );

    if (kIsWeb || _isDesktop(context)) {
      badge = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: badge,
      );
    }

    return badge;
  }

  bool _isDesktop(BuildContext context) {
    final p = Theme.of(context).platform;
    return p == TargetPlatform.macOS ||
        p == TargetPlatform.windows ||
        p == TargetPlatform.linux;
  }
}

class _BadgeColors {
  const _BadgeColors({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}
