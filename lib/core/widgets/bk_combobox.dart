import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkComboboxItem<T> {
  const BkComboboxItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

/// A neubrutalist filterable combobox search input and select.
class BkCombobox<T> extends StatefulWidget {
  const BkCombobox({
    super.key,
    required this.items,
    required this.onSelected,
    this.selectedValue,
    this.placeholder = 'SEARCH OR SELECT...',
    this.label,
  });

  final List<BkComboboxItem<T>> items;
  final ValueChanged<T> onSelected;
  final T? selectedValue;
  final String placeholder;
  final String? label;

  @override
  State<BkCombobox<T>> createState() => _BkComboboxState<T>();
}

class _BkComboboxState<T> extends State<BkCombobox<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isOpen = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final filteredItems = widget.items.where((item) {
      if (_query.isEmpty) return true;
      return item.label.toLowerCase().contains(_query.toLowerCase()) ||
          (item.subtitle?.toLowerCase().contains(_query.toLowerCase()) ??
              false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        // Search Input Box
        Container(
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.search, size: 20, color: t.foreground),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder.toUpperCase(),
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.mutedForeground,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (text) {
                    setState(() => _query = text);
                  },
                ),
              ),
              if (_query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: t.foreground,
                  onPressed: () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
          ),
        ),
        if (_isOpen) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: t.background,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset, t.shadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: filteredItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'NO MATCHING OPTIONS',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.mutedForeground,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: t.border),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = item.value == widget.selectedValue;

                      return ListTile(
                        dense: true,
                        leading: item.icon != null
                            ? Icon(item.icon,
                                size: 18,
                                color: isSelected ? t.primary : t.foreground)
                            : null,
                        title: Text(
                          item.label.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected ? t.primary : t.foreground,
                          ),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: GoogleFonts.outfit(
                                    fontSize: 11, color: t.mutedForeground),
                              )
                            : null,
                        tileColor: isSelected
                            ? t.primary.withValues(alpha: 0.1)
                            : null,
                        onTap: () {
                          BkMotion.hapticClick();
                          widget.onSelected(item.value);
                          _controller.text = item.label;
                          _focusNode.unfocus();
                          setState(() => _isOpen = false);
                        },
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}
