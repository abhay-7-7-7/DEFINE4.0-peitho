import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final _categories = ['All', 'Core', 'Form', 'Overlay', 'Navigation'];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final filtered = mockComponents.where((c) {
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'COMPONENTS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: t.foreground,
          ),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field
                  BkInput(
                    hint: 'SEARCH COMPONENTS...',
                    prefix: Icon(Icons.search, color: t.foreground),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? t.primary : t.card,
                                border: Border.all(color: t.border, width: t.borderWidth),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
                                    : null,
                              ),
                              child: Text(
                                cat.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: isSelected ? t.primaryForeground : t.foreground,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${filtered.length} COMPONENTS AVAILABLE',
                    style: GoogleFonts.dmMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: t.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.45,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final comp = filtered[index];
                  return GestureDetector(
                    onTap: () => context.go('/components/${comp.id}'),
                    child: BkCard(
                      interactive: true,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        comp.name.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: t.foreground,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    BkBadge(
                                      label: comp.category,
                                      variant: comp.category == 'Core'
                                          ? BkBadgeVariant.primary
                                          : comp.category == 'Form'
                                              ? BkBadgeVariant.secondary
                                              : comp.category == 'Overlay'
                                                  ? BkBadgeVariant.accent
                                                  : BkBadgeVariant.info,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comp.description,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: t.mutedForeground,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: comp.tags.take(2).map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: t.muted.withValues(alpha: 0.5),
                                          border: Border.all(color: t.border, width: 1),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: GoogleFonts.dmMono(fontSize: 10, color: t.mutedForeground),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'VIEW',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: t.foreground,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14, color: t.foreground),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
