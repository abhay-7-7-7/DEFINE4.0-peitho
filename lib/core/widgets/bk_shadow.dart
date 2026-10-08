import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

/// Returns a [BoxDecoration] with neubrutalism hard-offset shadow and border.
///
/// When [pressed] is true the shadow collapses to zero, matching the brutalist
/// push-down press effect.
BoxDecoration bkBoxDecoration({
  required BkTokens t,
  Color? backgroundColor,
  double? shadowOffset,
  Color? shadowColor,
  bool pressed = false,
}) {
  final double offset = pressed ? 0.0 : (shadowOffset ?? t.shadowOffset);
  final Color bg = backgroundColor ?? t.card;
  final Color sc = shadowColor ?? t.shadowColor;
  return BoxDecoration(
    color: bg,
    border: Border.all(color: t.border, width: t.borderWidth),
    boxShadow: offset > 0
        ? [
            BoxShadow(
              color: sc,
              offset: Offset(offset, offset),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ]
        : const [],
  );
}

/// Wraps [child] in the neubrutalism border + hard-offset shadow decoration
/// derived from [BkTokens].
class BkShadow extends StatelessWidget {
  const BkShadow({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shadowOffset,
    this.shadowColor,
    this.pressed = false,
  });

  final Widget child;

  /// Override background colour; defaults to [BkTokens.card].
  final Color? backgroundColor;

  /// Override shadow offset in logical pixels; defaults to [BkTokens.shadowOffset] (4 px).
  final double? shadowOffset;

  /// Override shadow colour; defaults to [BkTokens.shadowColor].
  final Color? shadowColor;

  /// When true the shadow collapses, simulating the pressed state.
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    return DecoratedBox(
      decoration: bkBoxDecoration(
        t: t,
        backgroundColor: backgroundColor,
        shadowOffset: shadowOffset,
        shadowColor: shadowColor,
        pressed: pressed,
      ),
      child: child,
    );
  }
}
