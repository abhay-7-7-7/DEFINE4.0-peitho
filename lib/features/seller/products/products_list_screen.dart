import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_dialog.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_states.dart';
import 'csv_import_dialog.dart';
import 'product_form_screen.dart';
import 'product_models.dart';
import 'product_stats_screen.dart';
import 'products_provider.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await showBkAlertDialog(
      context: context,
      title: 'DELETE PRODUCT',
      message:
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
      confirmLabel: 'DELETE',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(productsProvider.notifier).deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final state = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'PRODUCT CATALOG (${state.products.length})',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Import CSV',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CsvImportDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchProducts(),
        child: Column(
          children: [
            // Search and Category Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: BkInput(
                hint: 'Search products or category...',
                prefix: const Icon(Icons.search, size: 20),
                onChanged: (val) => notifier.setSearch(val),
              ),
            ),
            if (state.allCategories.length > 1)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.allCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) {
                    final cat = state.allCategories[idx];
                    final isSelected = cat == state.selectedCategory;
                    return InkWell(
                      onTap: () => notifier.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? t.primary : t.card,
                          border: Border.all(color: t.border, width: t.borderWidth),
                        ),
                        child: Text(
                          cat.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : t.foreground,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),

            // Content List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading && state.products.isEmpty) {
                    return const BkLoadingState(message: 'Loading product catalog...');
                  }
                  if (state.errorMessage != null && state.products.isEmpty) {
                    return BkErrorState(
                      error: state.errorMessage!,
                      onRetry: () => notifier.fetchProducts(),
                    );
                  }
                  if (state.filteredProducts.isEmpty) {
                    return BkEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No Products Found',
                      description: state.products.isEmpty
                          ? 'Add your first product or import a CSV to start commercial negotiations.'
                          : 'No products match your search criteria.',
                      actionLabel: state.products.isEmpty ? 'Add Product' : 'Clear Filter',
                      onAction: state.products.isEmpty
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                              );
                            }
                          : () {
                              notifier.setSearch('');
                              notifier.setCategory('All');
                            },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = state.filteredProducts[index];
                      final marginPct = p.basePrice > 0
                          ? ((p.basePrice - p.costPrice) / p.basePrice) * 100
                          : 0.0;

                      return BkCard(
                        backgroundColor: t.card,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: t.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            BkBadge(
                                              label: p.category,
                                              variant: BkBadgeVariant.outline,
                                            ),
                                            const SizedBox(width: 6),
                                            BkBadge(
                                              label: p.mode,
                                              variant: p.mode == 'MAX_PROFIT'
                                                  ? BkBadgeVariant.secondary
                                                  : BkBadgeVariant.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: t.card,
                                        shape: const RoundedRectangleBorder(),
                                        builder: (_) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.bar_chart),
                                                title: const Text('Live Analytics'),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ProductStatsScreen(product: p),
                                                    ),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.edit_outlined),
                                                title: const Text('Edit Product'),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ProductFormScreen(productToEdit: p),
                                                    ),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.delete_outline, color: t.destructive),
                                                title: Text('Delete', style: TextStyle(color: t.destructive)),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  _showDeleteDialog(context, ref, p);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Pricing Grid
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: t.muted.withAlpha(40),
                                  border: Border.all(color: t.border, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Listed Price', style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                                        Text(
                                          CurrencyFormatter.format(p.basePrice),
                                          style: TextStyle(
                                            fontFamily: 'DM Mono',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: t.foreground,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Unit Cost', style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                                        Text(
                                          CurrencyFormatter.format(p.costPrice),
                                          style: TextStyle(
                                            fontFamily: 'DM Mono',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: t.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Floor Price', style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                                        Text(
                                          CurrencyFormatter.format(p.minAcceptablePrice),
                                          style: TextStyle(
                                            fontFamily: 'DM Mono',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: t.destructive,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Base Margin', style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                                        Text(
                                          CurrencyFormatter.formatMargin(marginPct),
                                          style: TextStyle(
                                            fontFamily: 'DM Mono',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: t.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Deals closed summary badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${p.stats.totalSessions} sessions • ${p.stats.acceptedDeals} deals closed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: t.mutedForeground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductStatsScreen(product: p),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          'VIEW STATS',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: t.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward, size: 12, color: t.primary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
