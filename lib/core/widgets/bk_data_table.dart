import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';
import 'bk_button.dart';

class BkDataColumn<T> {
  const BkDataColumn({
    required this.label,
    required this.cellBuilder,
    this.comparator,
    this.flex = 1,
    this.width,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final Widget Function(T item) cellBuilder;
  final int Function(T a, T b)? comparator;
  final int flex;
  final double? width;
  final TextAlign textAlign;
}

/// A feature-rich neubrutalist data table with sorting, selection, search filtering, and pagination.
class BkDataTable<T> extends StatefulWidget {
  const BkDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.selectable = true,
    this.selectedItems = const {},
    this.onSelectionChanged,
    this.rowsPerPage = 5,
    this.searchable = true,
    this.filterPredicate,
  });

  final List<BkDataColumn<T>> columns;
  final List<T> data;
  final bool selectable;
  final Set<T> selectedItems;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final int rowsPerPage;
  final bool searchable;
  final bool Function(T item, String query)? filterPredicate;

  @override
  State<BkDataTable<T>> createState() => _BkDataTableState<T>();
}

class _BkDataTableState<T> extends State<BkDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _currentPage = 0;
  String _searchQuery = '';
  late Set<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant BkDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      _selected = Set.from(widget.selectedItems);
    }
  }

  void _onSort(int columnIndex) {
    final col = widget.columns[columnIndex];
    if (col.comparator == null) return;
    BkMotion.hapticClick();

    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  void _toggleSelectAll(List<T> visibleRows) {
    BkMotion.hapticClick();
    setState(() {
      final allSelected = visibleRows.every((r) => _selected.contains(r));
      if (allSelected) {
        _selected.removeAll(visibleRows);
      } else {
        _selected.addAll(visibleRows);
      }
    });
    widget.onSelectionChanged?.call(_selected);
  }

  void _toggleRow(T row) {
    BkMotion.hapticClick();
    setState(() {
      if (_selected.contains(row)) {
        _selected.remove(row);
      } else {
        _selected.add(row);
      }
    });
    widget.onSelectionChanged?.call(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    // 1. Filter
    List<T> items = List.from(widget.data);
    if (_searchQuery.isNotEmpty && widget.filterPredicate != null) {
      items = items
          .where((it) => widget.filterPredicate!(it, _searchQuery))
          .toList();
    }

    // 2. Sort
    if (_sortColumnIndex != null) {
      final comp = widget.columns[_sortColumnIndex!].comparator;
      if (comp != null) {
        items.sort((a, b) => _sortAscending ? comp(a, b) : comp(b, a));
      }
    }

    // 3. Paginate
    final totalPages =
        (items.length / widget.rowsPerPage).ceil().clamp(1, 9999);
    final pageStart = _currentPage * widget.rowsPerPage;
    final pageItems = items.skip(pageStart).take(widget.rowsPerPage).toList();

    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional Search Header
          if (widget.searchable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: t.border, width: t.borderWidth)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: t.foreground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.foreground),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'FILTER TABLE DATA...',
                        hintStyle: GoogleFonts.outfit(
                            fontSize: 12, color: t.mutedForeground),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (text) {
                        setState(() {
                          _searchQuery = text;
                          _currentPage = 0;
                        });
                      },
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      color: t.primary,
                      child: Text(
                        '${_selected.length} SELECTED',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: t.primaryForeground,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Horizontal Scroll for Mobile Responsive
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 520, // Guaranteed minimum width for column headers
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: t.muted.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        if (widget.selectable) ...[
                          GestureDetector(
                            onTap: () => _toggleSelectAll(pageItems),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: t.background,
                                border: Border.all(color: t.border, width: 2),
                              ),
                              child: pageItems.isNotEmpty &&
                                      pageItems
                                          .every((r) => _selected.contains(r))
                                  ? Icon(Icons.check,
                                      size: 14, color: t.primary)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        ...widget.columns.asMap().entries.map((entry) {
                          final i = entry.key;
                          final col = entry.value;
                          final isSorted = _sortColumnIndex == i;

                          Widget header = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  col.label.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isSorted ? t.primary : t.foreground,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (col.comparator != null) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  isSorted
                                      ? (_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                      : Icons.sort,
                                  size: 14,
                                  color:
                                      isSorted ? t.primary : t.mutedForeground,
                                ),
                              ],
                            ],
                          );

                          if (col.comparator != null) {
                            header = InkWell(
                              onTap: () => _onSort(i),
                              child: header,
                            );
                          }

                          return Expanded(
                            flex: col.flex,
                            child: header,
                          );
                        }),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: t.borderWidth, color: t.border),
                  // Table Rows
                  if (pageItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'NO DATA AVAILABLE',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: t.mutedForeground),
                      ),
                    )
                  else
                    ...pageItems.map((row) {
                      final isChecked = _selected.contains(row);

                      return Container(
                        decoration: BoxDecoration(
                          color: isChecked
                              ? t.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border(
                              bottom: BorderSide(
                                  color: t.border.withValues(alpha: 0.3),
                                  width: 1)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            if (widget.selectable) ...[
                              GestureDetector(
                                onTap: () => _toggleRow(row),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isChecked ? t.primary : t.background,
                                    border:
                                        Border.all(color: t.border, width: 2),
                                  ),
                                  child: isChecked
                                      ? Icon(Icons.check,
                                          size: 14, color: t.primaryForeground)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            ...widget.columns.map((col) {
                              return Expanded(
                                flex: col.flex,
                                child: col.cellBuilder(row),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: t.borderWidth, color: t.border),
          // Pagination Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PAGE ${_currentPage + 1} OF $totalPages (${items.length} ITEMS)',
                  style: GoogleFonts.dmMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: t.mutedForeground),
                ),
                Row(
                  children: [
                    BkButton(
                      label: '< PREV',
                      size: BkButtonSize.sm,
                      variant: BkButtonVariant.outline,
                      onPressed: _currentPage > 0
                          ? () {
                              BkMotion.hapticClick();
                              setState(() => _currentPage--);
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    BkButton(
                      label: 'NEXT >',
                      size: BkButtonSize.sm,
                      variant: BkButtonVariant.outline,
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              BkMotion.hapticClick();
                              setState(() => _currentPage++);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
