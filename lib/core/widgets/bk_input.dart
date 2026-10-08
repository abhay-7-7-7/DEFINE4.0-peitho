import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

// ── BkInput ───────────────────────────────────────────────────────────────────

/// Neubrutalist single-line text input wrapping [TextFormField].
///
/// Features 3 px border, 0 border radius, hard-offset focus ring, and optional
/// label, hint, prefix/suffix widgets, and error text.
class BkInput extends StatefulWidget {
  const BkInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.autofocus = false,
    this.maxLength,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final int? maxLength;

  @override
  State<BkInput> createState() => _BkInputState();
}

class _BkInputState extends State<BkInput> {
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final bool hasError = widget.errorText != null;

    final Color borderColor =
        hasError ? t.destructive : (_focused ? t.ring : t.border);
    final double shadowOffset = _focused ? t.shadowOffset : 0;
    final Color shadowColor = hasError ? t.destructive : t.shadowColor;

    final TextStyle baseStyle = GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? t.foreground : t.mutedForeground,
    );

    Widget field = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: widget.enabled ? t.background : t.muted,
        border: Border.all(color: borderColor, width: t.borderWidth),
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                )
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        maxLength: widget.maxLength,
        style: baseStyle,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: baseStyle.copyWith(color: t.mutedForeground),
          prefixIcon: widget.prefix != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IconTheme(
                    data: IconThemeData(color: t.mutedForeground, size: 18),
                    child: widget.prefix!,
                  ),
                )
              : null,
          suffixIcon: widget.suffix != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IconTheme(
                    data: IconThemeData(color: t.mutedForeground, size: 18),
                    child: widget.suffix!,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          counterText: '',
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.foreground,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
        ],
        field,
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: t.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

// ── BkTextarea ───────────────────────────────────────────────────────────────

/// Neubrutalist multi-line text area.
class BkTextarea extends StatefulWidget {
  const BkTextarea({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.minLines = 4,
    this.maxLines = 8,
    this.onChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<BkTextarea> createState() => _BkTextareaState();
}

class _BkTextareaState extends State<BkTextarea> {
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);
    final bool hasError = widget.errorText != null;
    final Color borderColor =
        hasError ? t.destructive : (_focused ? t.ring : t.border);
    final double shadowOffset = _focused ? t.shadowOffset : 0;

    final TextStyle baseStyle = GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: widget.enabled ? t.foreground : t.mutedForeground,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.foreground,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: widget.enabled ? t.background : t.muted,
            border: Border.all(color: borderColor, width: t.borderWidth),
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
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: baseStyle,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: baseStyle.copyWith(color: t.mutedForeground),
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: t.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

// ── BkOtpInput ────────────────────────────────────────────────────────────────

/// A row of [length] individual character fields that auto-advances focus,
/// suitable for OTP / PIN entry.
class BkOtpInput extends StatefulWidget {
  const BkOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
  }) : assert(length >= 2 && length <= 10, 'OTP length must be between 2 and 10');

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  @override
  State<BkOtpInput> createState() => _BkOtpInputState();
}

class _BkOtpInputState extends State<BkOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling: distribute characters across fields
      final chars = value.split('');
      for (int i = 0; i < chars.length && index + i < widget.length; i++) {
        _controllers[index + i].text = chars[i];
      }
      final nextIndex = (index + chars.length).clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty) {
      _controllers[index].text = value;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      // Deletion: move focus back
      if (index > 0) _focusNodes[index - 1].requestFocus();
    }

    final currentValue = _value;
    widget.onChanged?.call(currentValue);
    if (currentValue.length == widget.length &&
        !currentValue.contains('') ) {
      widget.onCompleted?.call(currentValue);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final BkTokens t = BkTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final count = widget.length;
        double spacing = 8.0;
        double cellWidth = 48.0;
        if (availableWidth.isFinite && availableWidth > 0) {
          final totalNeeded = count * 48.0 + (count - 1) * 8.0;
          if (totalNeeded > availableWidth) {
            spacing = (availableWidth < 300) ? 4.0 : 6.0;
            cellWidth = ((availableWidth - (count - 1) * spacing) / count).clamp(24.0, 48.0);
          }
        }
        final cellHeight = (cellWidth * 1.15).clamp(36.0, 56.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i < widget.length - 1 ? spacing : 0),
              child: SizedBox(
                width: cellWidth,
                height: cellHeight,
                child: _OtpCell(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  obscureText: widget.obscureText,
                  onChanged: (v) => _onChanged(i, v),
                  tokens: t,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _OtpCell extends StatefulWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.onChanged,
    required this.tokens,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final BkTokens tokens;

  @override
  State<_OtpCell> createState() => _OtpCellState();
}

class _OtpCellState extends State<_OtpCell> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BkTokens t = widget.tokens;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: t.background,
        border: Border.all(
          color: _focused ? t.ring : t.border,
          width: t.borderWidth,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset, t.shadowOffset),
                  blurRadius: 0,
                )
              ]
            : const [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: widget.onChanged,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: t.foreground,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
      ),
    );
  }
}
