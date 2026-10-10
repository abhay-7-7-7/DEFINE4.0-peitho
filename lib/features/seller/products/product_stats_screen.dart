import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_states.dart';
import 'product_models.dart';
import 'products_provider.dart';

class ProductStatsScreen extends ConsumerWidget {
  final Product product;

  const ProductStatsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final statsAsync = ref.watch(productStatsProvider(product.id));

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          product.name.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: statsAsync.when(
        loading: () => const BkLoadingState(message: 'Loading live product analytics...'),
        error: (err, _) => BkErrorState(
          error: err.toString(),
          onRetry: () => ref.refresh(productStatsProvider(product.id)),
        ),
        data: (stats) {
          if (stats == null) {
            return BkEmptyState(
              title: 'No Data Yet',
              description: 'No negotiation sessions recorded for this product.',
              actionLabel: 'Refresh',
              onAction: () => ref.refresh(productStatsProvider(product.id)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Pricing Baseline Card
                BkCard(
                  backgroundColor: t.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRICING BASELINE',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: t.mutedForeground,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _PriceItem(label: 'Listed Price', amount: product.basePrice, color: t.primary),
                            _PriceItem(label: 'Unit Cost', amount: product.costPrice, color: t.mutedForeground),
                            _PriceItem(label: 'Floor Limit', amount: product.minAcceptablePrice, color: t.destructive),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Key Performance Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatTile(
                      label: 'TOTAL SESSIONS',
                      value: '${stats.totalSessions}',
                      subvalue: '${stats.activeSessions} active currently',
                      accent: t.primary,
                    ),
                    _StatTile(
                      label: 'ACCEPT RATE',
                      value: '${stats.acceptRate.toStringAsFixed(1)}%',
                      subvalue: '${stats.acceptedDeals} deals closed',
                      accent: t.secondary,
                    ),
                    _StatTile(
                      label: 'TOTAL REVENUE',
                      value: CurrencyFormatter.format(stats.totalRevenue, compact: true),
                      subvalue: 'Avg deal ${CurrencyFormatter.format(stats.avgFinalPrice)}',
                      accent: t.accent,
                    ),
                    _StatTile(
                      label: 'AVG PROFIT MARGIN',
                      value: CurrencyFormatter.formatMargin(stats.avgMargin),
                      subvalue: 'Avg ${stats.avgRounds.toStringAsFixed(1)} rounds',
                      accent: stats.avgMargin >= 20 ? t.secondary : t.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Deal Range Summary
                BkCard(
                  backgroundColor: t.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SETTLEMENT RANGE',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: t.mutedForeground,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lowest: ${CurrencyFormatter.format(stats.minDealPrice)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Highest: ${CurrencyFormatter.format(stats.maxDealPrice)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: t.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Sessions
                Text(
                  'RECENT NEGOTIATIONS (${stats.recentSessions.length})',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                if (stats.recentSessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'No negotiation sessions completed yet.',
                        style: TextStyle(color: t.mutedForeground, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...stats.recentSessions.map((session) {
                    final isClosed = session['deal_closed'] == true;
                    final finalPrice = session['final_price'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: BkCard(
                        backgroundColor: t.card,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            'Session #${session['id']} • ${session['status']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            '${session['rounds_used']} rounds used',
                            style: TextStyle(fontSize: 11, color: t.mutedForeground),
                          ),
                          trailing: Text(
                            finalPrice != null
                                ? CurrencyFormatter.format(num.tryParse('$finalPrice'))
                                : (isClosed ? 'Accepted' : 'No deal'),
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isClosed ? t.secondary : t.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final num amount;
  final Color color;

  const _PriceItem({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subvalue;
  final Color accent;

  const _StatTile({
    required this.label,
    required this.value,
    required this.subvalue,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: t.mutedForeground,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: t.foreground,
            ),
          ),
          Text(
            subvalue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: t.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
