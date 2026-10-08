import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

/// Neubrutalist multi-tag input widget.
class BkTagInput extends StatefulWidget {
  const BkTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.label,
    this.placeholder = 'TYPE AND PRESS ENTER...',
    this.maxTags,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? label;
  final String placeholder;
  final int? maxTags;

  @override
  State<BkTagInput> createState() => _BkTagInputState();
}

class _BkTagInputState extends State<BkTagInput> {
  final TextEditingController _controller = TextEditingController();

  void _addTag(String raw) {
    final clean = raw.trim().toUpperCase();
    if (clean.isEmpty) return;
    if (widget.tags.contains(clean)) return;
    if (widget.maxTags != null && widget.tags.length >= widget.maxTags!) return;

    BkMotion.hapticClick();
    final updated = List<String>.from(widget.tags)..add(clean);
    widget.onChanged(updated);
    _controller.clear();
  }

  void _removeTag(int index) {
    BkMotion.hapticClick();
    final updated = List<String>.from(widget.tags)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: [
              BoxShadow(
                color: t.shadowColor,
                offset: Offset(t.shadowOffset, t.shadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(widget.tags.length, (i) {
                    final tag = widget.tags[i];
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                      decoration: BoxDecoration(
                        color: t.primary,
                        border: Border.all(color: t.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: t.shadowColor,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: t.primaryForeground,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeTag(i),
                            child: Icon(Icons.close,
                                size: 14, color: t.primaryForeground),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _controller,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.foreground,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.mutedForeground,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                ),
                onSubmitted: _addTag,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
