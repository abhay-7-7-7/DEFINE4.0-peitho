import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_states.dart';
import 'dashboard_provider.dart';
import 'session_detail_modal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = BkTokens.of(context);
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final filterState = ref.watch(dashboardFilterProvider);
    final filterNotifier = ref.read(dashboardFilterProvider.notifier);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'NEGOTIATION DASHBOARD',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardDataProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardDataProvider.future),
        child: dashboardAsync.when(
          loading: () => const BkLoadingState(message: 'Loading negotiation metrics...'),
          error: (err, _) => BkErrorState(
            error: err.toString(),
            onRetry: () => ref.refresh(dashboardDataProvider),
          ),
          data: (data) {
            final s = data.summary;

            // Filter closed sessions by status and search
            var filtered = data.closedSessions.where((cs) {
              final matchesStatus = filterState.statusFilter == 'all' ||
                  cs.status.toLowerCase() == filterState.statusFilter.toLowerCase() ||
                  (filterState.statusFilter == 'walked_away' &&
                      (cs.status == 'walked_away' || cs.status == 'buyer_walked'));
              final matchesSearch = filterState.searchQuery.isEmpty ||
                  cs.productName.toLowerCase().contains(filterState.searchQuery.toLowerCase());
              return matchesStatus && matchesSearch;
            }).toList();

            return CustomScrollView(
              slivers: [
                // Top Aggregate Metrics Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row 1: Total & Accept Rate
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: 'TOTAL DEALS',
                                value: '${s.total}',
                                subtitle: '${s.active} active sessions',
                                accent: t.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                label: 'ACCEPT RATE',
                                value: '${s.acceptRate.toStringAsFixed(1)}%',
                                subtitle: '${s.accepted} accepted / ${s.rejected} rejected',
                                accent: t.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Row 2: Revenue & Best Deal
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: 'TOTAL REVENUE',
                                value: CurrencyFormatter.format(s.totalRevenue, compact: true),
                                subtitle: 'Avg deal ${CurrencyFormatter.format(s.avgDealPrice)}',
                                accent: t.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                label: 'BEST DEAL',
                                value: CurrencyFormatter.format(s.bestDeal),
                                subtitle: 'Avg rounds: ${s.avgRounds.toStringAsFixed(1)}',
                                accent: t.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Search Bar
                        BkInput(
                          hint: 'Search sessions by product...',
                          prefix: const Icon(Icons.search, size: 20),
                          onChanged: (val) => filterNotifier.setSearch(val),
                        ),
                        const SizedBox(height: 12),

                        // Status Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'ALL (${data.closedSessions.length})',
                                isSelected: filterState.statusFilter == 'all',
                                onTap: () => filterNotifier.setFilter('all'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'ACCEPTED (${s.accepted})',
                                isSelected: filterState.statusFilter == 'accepted',
                                onTap: () => filterNotifier.setFilter('accepted'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'REJECTED (${s.rejected})',
                                isSelected: filterState.statusFilter == 'rejected',
                                onTap: () => filterNotifier.setFilter('rejected'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'EXPIRED (${s.expired})',
                                isSelected: filterState.statusFilter == 'expired',
                                onTap: () => filterNotifier.setFilter('expired'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'WALKED AWAY (${s.walkedAway})',
                                isSelected: filterState.statusFilter == 'walked_away',
                                onTap: () => filterNotifier.setFilter('walked_away'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sessions List
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          'No sessions matching current filter.',
                          style: TextStyle(color: t.mutedForeground),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, idx) {
                          final session = filtered[idx];
                          final isAccepted = session.status == 'accepted';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => SessionDetailModal(sessionId: session.id),
                                );
                              },
                              child: BkCard(
                                backgroundColor: t.card,
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              session.productName,
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: t.foreground,
                                              ),
                                            ),
                                          ),
                                          BkBadge(
                                            label: session.status.toUpperCase(),
                                            variant: isAccepted
                                                ? BkBadgeVariant.secondary
                                                : BkBadgeVariant.outline,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${session.roundsUsed} rounds used',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: t.mutedForeground,
                                            ),
                                          ),
                                          Text(
                                            session.finalPrice != null
                                                ? CurrencyFormatter.format(session.finalPrice)
                                                : 'No final price',
                                            style: TextStyle(
                                              fontFamily: 'DM Mono',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: isAccepted ? t.secondary : t.foreground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (session.callbackPhone != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Callback: ${session.callbackPhone}',
                                              style: TextStyle(
                                                fontFamily: 'DM Mono',
                                                fontSize: 11,
                                                color: t.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? t.primary : t.card,
          border: Border.all(color: t.border, width: t.borderWidth),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : t.foreground,
          ),
        ),
      ),
    );
  }
}
