import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum BkButtonVariant {
  primary,
  secondary,
  accent,
  destructive,
  outline,
  ghost,
  link,
  noShadow,
  reverse,
}

enum BkButtonSize {
  sm,
  md,
  lg,
  xl,
  icon;

  static const BkButtonSize defaultSize = BkButtonSize.md;
}

// ── BkButton ─────────────────────────────────────────────────────────────────

/// A neubrutalist button with push-down press animation, 9 variants, and 5
/// sizes. All variants meet the minimum 48 px touch target (WCAG 2.5.5).
class BkButton extends StatefulWidget {
  const BkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BkButtonVariant.primary,
    this.size = BkButtonSize.md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.enabled = true,
  });

  /// Button label text. For [BkButtonVariant.icon] this is used as semantic
  /// label and tooltip.
  final String label;

  final VoidCallback? onPressed;
  final BkButtonVariant variant;
  final BkButtonSize size;

  /// Widget placed before the label (e.g. an icon).
  final Widget? leading;

  /// Widget placed after the label.
  final Widget? trailing;

  /// Shows a loading spinner and disables interaction.
  final bool isLoading;

  /// Explicit enabled flag — set to false to disable without null callback.
  final bool enabled;

  @override
  State<BkButton> createState() => _BkButtonState();
}

class _BkButtonState extends State<BkButton> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _isDisabled => !widget.enabled || widget.isLoading || widget.onPressed == null;

  void _handleTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isDisabled) return;
    setState(() => _pressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() => setState(() => _pressed = false);

  // ── Size metrics ────────────────────────────────────────────────────────────

  double get _minHeight {
    switch (widget.size) {
      case BkButtonSize.sm:
        return 48.0;
      case BkButtonSize.md:
        return 48.0;
      case BkButtonSize.lg:
        return 56.0;
      case BkButtonSize.xl:
        return 64.0;
      case BkButtonSize.icon:
        return 48.0;
    }
  }

  double get _minWidth {
    switch (widget.size) {
      case BkButtonSize.sm:
        return 0;
      case BkButtonSize.md:
        return 0;
      case BkButtonSize.lg:
        return 0;
      case BkButtonSize.xl:
        return 0;
      case BkButtonSize.icon:
        return 48.0;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case BkButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case BkButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case BkButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
      case BkButtonSize.xl:
        return const EdgeInsets.symmetric(horizontal: 36, vertical: 18);
      case BkButtonSize.icon:
        return const EdgeInsets.all(12);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case BkButtonSize.sm:
        return 12;
      case BkButtonSize.md:
        return 14;
      case BkButtonSize.lg:
        return 16;
      case BkButtonSize.xl:
        return 18;
      case BkButtonSize.icon:
        return 14;
    }
  }

  // ── Colour resolution ───────────────────────────────────────────────────────

  _BkButtonColors _resolveColors(BkTokens t) {
    switch (widget.variant) {
      case BkButtonVariant.primary:
        return _BkButtonColors(
          bg: t.primary,
          fg: t.primaryForeground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
        );
      case BkButtonVariant.secondary:
        return _BkButtonColors(
          bg: t.secondary,
          fg: t.secondaryForeground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
        );
      case BkButtonVariant.accent:
        return _BkButtonColors(
          bg: t.accent,
          fg: t.accentForeground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
        );
      case BkButtonVariant.destructive:
        return _BkButtonColors(
          bg: t.destructive,
          fg: t.destructiveForeground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
        );
      case BkButtonVariant.outline:
        return _BkButtonColors(
          bg: t.background,
          fg: t.foreground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
        );
      case BkButtonVariant.ghost:
        return _BkButtonColors(
          bg: _hovered && !_isDisabled ? t.muted : Colors.transparent,
          fg: t.foreground,
          border: Colors.transparent,
          shadow: Colors.transparent,
          hasShadow: false,
          hasBorder: false,
        );
      case BkButtonVariant.link:
        return _BkButtonColors(
          bg: Colors.transparent,
          fg: t.primary,
          border: Colors.transparent,
          shadow: Colors.transparent,
          hasShadow: false,
          hasBorder: false,
          isLink: true,
        );
      case BkButtonVariant.noShadow:
        return _BkButtonColors(
          bg: t.primary,
          fg: t.primaryForeground,
          border: t.border,
          shadow: Colors.transparent,
          hasShadow: false,
          hasBorder: true,
        );
      case BkButtonVariant.reverse:
        return _BkButtonColors(
          bg: t.primary,
          fg: t.primaryForeground,
          border: t.border,
          shadow: t.shadowColor,
          hasShadow: true,
          hasBorder: true,
          isReverse: true,
        );
    }
  }

  // ── Animation offset ────────────────────────────────────────────────────────

  Offset _translateOffset(BkTokens t, _BkButtonColors colors) {
    if (!colors.hasShadow) return Offset.zero;
    if (_isDisabled) return Offset.zero;

    if (colors.isReverse) {
      // Hover lifts in opposite direction; press returns to neutral
      if (_pressed) return Offset.zero;
      if (_hovered) return const Offset(-4, -4);
      return Offset(t.shadowOffset, t.shadowOffset);
    }

    if (_pressed) return const Offset(2, 2);
    if (_hovered) return const Offset(-1, -1);
    return Offset.zero;
  }

  double _effectiveShadow(BkTokens t, _BkButtonColors colors) {
    if (!colors.hasShadow) return 0;
    if (_isDisabled) return t.shadowOffset;
    if (colors.isReverse) {
      if (_pressed) return t.shadowOffset;
      if (_hovered) return t.shadowOffset + 2;
      return t.shadowOffset;
    }
    if (_pressed) return 0;
    if (_hovered) return t.shadowOffset + 2;
    return t.shadowOffset;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final _BkButtonColors colors = _resolveColors(t);
    final Offset translate = _translateOffset(t, colors);
    final double shadowSize = _effectiveShadow(t, colors);

    Widget label = _buildLabel(t, colors);

    // Core content
    Widget content = Container(
      constraints: BoxConstraints(
        minHeight: _minHeight,
        minWidth: _minWidth,
      ),
      padding: _padding,
      child: label,
    );

    // Decoration
    BoxDecoration decoration;
    if (colors.hasBorder) {
      decoration = BoxDecoration(
        color: _isDisabled ? colors.bg.withValues(alpha: 0.5) : colors.bg,
        border: Border.all(color: colors.border, width: t.borderWidth),
        boxShadow: shadowSize > 0
            ? [
                BoxShadow(
                  color: colors.shadow,
                  offset: Offset(shadowSize, shadowSize),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ]
            : const [],
      );
    } else {
      decoration = BoxDecoration(
        color: colors.bg,
      );
    }

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(translate.dx, translate.dy, 0),
      decoration: decoration,
      child: content,
    );

    // Wrap in gesture + mouse region
    Widget interactive = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: kIsWeb || _isDesktop()
          ? MouseRegion(
              cursor: _isDisabled
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              onEnter: (_) {
                if (!_isDisabled) setState(() => _hovered = true);
              },
              onExit: (_) => setState(() => _hovered = false),
              child: button,
            )
          : button,
    );

    if (widget.size == BkButtonSize.icon) {
      interactive = Semantics(
        label: widget.label,
        button: true,
        child: Tooltip(message: widget.label, child: interactive),
      );
    }

    return interactive;
  }

  Widget _buildLabel(BkTokens t, _BkButtonColors colors) {
    final Color fg = _isDisabled ? colors.fg.withValues(alpha: 0.5) : colors.fg;

    final TextStyle style = GoogleFonts.outfit(
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      color: fg,
      letterSpacing: 0.5,
      decoration:
          colors.isLink ? TextDecoration.underline : TextDecoration.none,
      decorationColor: fg,
    );

    if (widget.size == BkButtonSize.icon) {
      return widget.leading ?? const SizedBox.shrink();
    }

    final List<Widget> children = [];
    if (widget.isLoading) {
      children.add(
        SizedBox(
          width: _fontSize + 2,
          height: _fontSize + 2,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
          ),
        ),
      );
    } else if (widget.leading != null) {
      children.add(
        IconTheme(
          data: IconThemeData(color: fg, size: _fontSize + 4),
          child: widget.leading!,
        ),
      );
    }

    if (widget.variant != BkButtonVariant.link ||
        widget.leading == null && widget.trailing == null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: _fontSize * 0.5));
      }
    }

    if (widget.size != BkButtonSize.icon) {
      children.add(
        Flexible(
          child: Text(
            widget.label,
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }

    if (widget.trailing != null && !widget.isLoading) {
      children.add(SizedBox(width: _fontSize * 0.5));
      children.add(
        IconTheme(
          data: IconThemeData(color: fg, size: _fontSize + 4),
          child: widget.trailing!,
        ),
      );
    }

    if (children.isEmpty) return Text(widget.label, style: style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  bool _isDesktop() {
    try {
      final platform = Theme.of(context).platform;
      return platform == TargetPlatform.macOS ||
          platform == TargetPlatform.windows ||
          platform == TargetPlatform.linux;
    } catch (_) {
      return false;
    }
  }
}

// ── Internal helper ──────────────────────────────────────────────────────────

class _BkButtonColors {
  const _BkButtonColors({
    required this.bg,
    required this.fg,
    required this.border,
    required this.shadow,
    required this.hasShadow,
    required this.hasBorder,
    this.isLink = false,
    this.isReverse = false,
  });

  final Color bg;
  final Color fg;
  final Color border;
  final Color shadow;
  final bool hasShadow;
  final bool hasBorder;
  final bool isLink;
  final bool isReverse;
}
