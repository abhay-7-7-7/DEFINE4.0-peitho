import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkAccordionItem {
  const BkAccordionItem({
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget content;
  final bool initiallyExpanded;
}

class BkAccordion extends StatefulWidget {
  const BkAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
  });

  final List<BkAccordionItem> items;
  final bool allowMultiple;

  @override
  State<BkAccordion> createState() => _BkAccordionState();
}

class _BkAccordionState extends State<BkAccordion> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.items.map((i) => i.initiallyExpanded).toList();
  }

  void _toggle(int index) {
    setState(() {
      if (!widget.allowMultiple) {
        for (int i = 0; i < _isExpanded.length; i++) {
          if (i != index) _isExpanded[i] = false;
        }
      }
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Column(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final expanded = _isExpanded[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              InkWell(
                onTap: () => _toggle(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  color: expanded ? t.muted.withValues(alpha: 0.3) : t.card,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: t.foreground,
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: expanded ? t.primary : t.background,
                          border: Border.all(color: t.border, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            expanded ? Icons.remove : Icons.add,
                            size: 18,
                            color: expanded ? t.primaryForeground : t.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
                  ),
                  child: item.content,
                ),
            ],
          ),
        );
      }),
    );
  }
}
