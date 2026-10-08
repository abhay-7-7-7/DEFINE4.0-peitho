import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';
import 'favorites_provider.dart';

class ComponentsScreen extends ConsumerStatefulWidget {
  const ComponentsScreen({super.key});

  @override
  ConsumerState<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends ConsumerState<ComponentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _sortByAscending = true;
  bool _isGridView = true;

  final _categories = [
    'All',
    'Favorites',
    'Core',
    'Form',
    'Overlay',
    'Navigation'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    BkMotion.hapticLight();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    final favorites = ref.watch(favoritesProvider);

    List<MockComponentInfo> filtered = mockComponents.where((c) {
      if (_selectedCategory == 'Favorites') {
        if (!favorites.contains(c.id)) return false;
      } else if (_selectedCategory != 'All' &&
          c.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesDesc = c.description.toLowerCase().contains(q);
        final matchesTags = c.tags.any((tag) => tag.toLowerCase().contains(q));
        if (!matchesName && !matchesDesc && !matchesTags) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      return _sortByAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name);
    });

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
        actions: [
          IconButton(
            icon: Icon(_sortByAscending ? Icons.sort_by_alpha : Icons.swap_vert,
                color: t.foreground),
            tooltip: _sortByAscending ? 'Sort Z-A' : 'Sort A-Z',
            onPressed: () {
              BkMotion.hapticClick();
              setState(() => _sortByAscending = !_sortByAscending);
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view,
                color: t.foreground),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              BkMotion.hapticClick();
              setState(() => _isGridView = !_isGridView);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: t.primary,
        backgroundColor: t.card,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field
                    BkInput(
                      hint: 'SEARCH 75+ COMPONENTS...',
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
                          final isFav = cat == 'Favorites';

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                BkMotion.hapticClick();
                                setState(() => _selectedCategory = cat);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isFav ? t.accent : t.primary)
                                      : t.card,
                                  border: Border.all(
                                      color: t.border, width: t.borderWidth),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color: t.shadowColor,
                                              offset: const Offset(3, 3))
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFav) ...[
                                      Icon(
                                        Icons.favorite,
                                        size: 14,
                                        color: isSelected
                                            ? t.accentForeground
                                            : t.primary,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      cat.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: isSelected
                                            ? (isFav
                                                ? t.accentForeground
                                                : t.primaryForeground)
                                            : t.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Animated count
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        '${filtered.length} COMPONENTS AVAILABLE',
                        key: ValueKey(filtered.length),
                        style: GoogleFonts.dmMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: t.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          color: t.muted,
                          child: Icon(Icons.search_off,
                              size: 36, color: t.mutedForeground),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO COMPONENTS MATCHED',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: t.foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try clearing your search query or switching categories.',
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent:
                        (220.0 * MediaQuery.textScalerOf(context).scale(1.0))
                            .clamp(210.0, 280.0),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comp = filtered[index];
                      final isFav = favorites.contains(comp.id);

                      return BkReveal(
                        delay: BkMotion.staggerDelay * (index % 6),
                        child: _ComponentCard(
                          comp: comp,
                          isFavorite: isFav,
                          tokens: t,
                          onToggleFavorite: () => ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(comp.id),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comp = filtered[index];
                      final isFav = favorites.contains(comp.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BkReveal(
                          delay: BkMotion.staggerDelay * (index % 6),
                          child: _ComponentListTile(
                            comp: comp,
                            isFavorite: isFav,
                            tokens: t,
                            onToggleFavorite: () => ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(comp.id),
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
      ),
    );
  }
}

class _ComponentCard extends StatefulWidget {
  const _ComponentCard({
    required this.comp,
    required this.isFavorite,
    required this.tokens,
    required this.onToggleFavorite,
  });

  final MockComponentInfo comp;
  final bool isFavorite;
  final BkTokens tokens;
  final VoidCallback onToggleFavorite;

  @override
  State<_ComponentCard> createState() => _ComponentCardState();
}

class _ComponentCardState extends State<_ComponentCard> {
  bool _heartBounce = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final comp = widget.comp;

    return Hero(
      tag: 'component-${comp.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => context.go('/components/${comp.id}'),
          child: BkCard(
            interactive: true,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              comp.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: t.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BkMotion.hapticClick();
                              setState(() => _heartBounce = true);
                              widget.onToggleFavorite();
                            },
                            child: AnimatedScale(
                              scale: _heartBounce ? 1.4 : 1.0,
                              duration: const Duration(milliseconds: 140),
                              curve: BkMotion.bounce,
                              onEnd: () => setState(() => _heartBounce = false),
                              child: Icon(
                                widget.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: widget.isFavorite
                                    ? t.destructive
                                    : t.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          comp.description,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: t.mutedForeground,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    BkBadge(
                      label: comp.category,
                      variant: comp.category == 'Core'
                          ? BkBadgeVariant.primary
                          : comp.category == 'Form'
                              ? BkBadgeVariant.secondary
                              : comp.category == 'Overlay'
                                  ? BkBadgeVariant.accent
                                  : BkBadgeVariant.outline,
                    ),
                    ...comp.tags.take(2).map((tag) =>
                        BkBadge(label: tag, variant: BkBadgeVariant.outline)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComponentListTile extends StatelessWidget {
  const _ComponentListTile({
    required this.comp,
    required this.isFavorite,
    required this.tokens,
    required this.onToggleFavorite,
  });

  final MockComponentInfo comp;
  final bool isFavorite;
  final BkTokens tokens;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    return Hero(
      tag: 'component-${comp.id}',
      child: Material(
        color: Colors.transparent,
        child: BkCard(
          interactive: true,
          onTap: () => context.go('/components/${comp.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comp.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comp.description,
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: t.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BkBadge(label: comp.category, variant: BkBadgeVariant.outline),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  BkMotion.hapticClick();
                  onToggleFavorite();
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? t.destructive : t.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
