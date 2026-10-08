import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkTabItem {
  const BkTabItem({required this.label, this.icon, required this.content});
  final String label;
  final IconData? icon;
  final Widget content;
}

class BkTabs extends StatefulWidget {
  const BkTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.activeColor,
  });

  final List<BkTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final Color? activeColor;

  @override
  State<BkTabs> createState() => _BkTabsState();
}

class _BkTabsState extends State<BkTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final activeBg = widget.activeColor ?? t.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Header Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.tabs.length, (index) {
              final isSelected = index == _selectedIndex;
              final item = widget.tabs[index];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  widget.onChanged?.call(index);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6, bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? activeBg : t.card,
                    border: Border.all(color: t.border, width: t.borderWidth),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: t.shadowColor,
                              offset: Offset(t.shadowOffset, t.shadowOffset),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color:
                              isSelected ? t.primaryForeground : t.foreground,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        item.label.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color:
                              isSelected ? t.primaryForeground : t.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Content Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: widget.tabs[_selectedIndex].content,
        ),
      ],
    );
  }
}
