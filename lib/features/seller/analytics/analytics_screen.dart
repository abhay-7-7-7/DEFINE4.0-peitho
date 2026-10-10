import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_states.dart';
import '../products/product_models.dart';
import '../products/products_provider.dart';
import 'analytics_models.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final _costController = TextEditingController(text: '600');
  final _sellingController = TextEditingController(text: '999');
  final _stockController = TextEditingController(text: '50');
  final _chatsController = TextEditingController(text: '120');
  final _ordersController = TextEditingController(text: '35');

  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runCalculation();
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _sellingController.dispose();
    _stockController.dispose();
    _chatsController.dispose();
    _ordersController.dispose();
    super.dispose();
  }

  void _onProductSelected(Product? p) {
    if (p == null) return;
    setState(() {
      _selectedProduct = p;
      _costController.text = p.costPrice.toStringAsFixed(0);
      _sellingController.text = p.basePrice.toStringAsFixed(0);
    });
    _runCalculation();
  }

  void _runCalculation() {
    final cost = double.tryParse(_costController.text) ?? 600.0;
    final selling = double.tryParse(_sellingController.text) ?? 999.0;
    final stock = int.tryParse(_stockController.text) ?? 50;
    final chats = int.tryParse(_chatsController.text) ?? 120;
    final orders = int.tryParse(_ordersController.text) ?? 35;

    ref.read(analyticsProvider.notifier).calculate(
          costPrice: cost,
          sellingPrice: selling,
          initialStock: stock,
          chats: chats,
          orders: orders,
          unitsSold: orders,
          returns: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'BUSINESS ANALYTICS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recalculate',
            onPressed: _runCalculation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Preset Picker
            if (productsState.products.isNotEmpty) ...[
              Text(
                'LOAD PRODUCT PARAMETERS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: t.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border.all(color: t.border, width: t.borderWidth),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Product?>(
                    isExpanded: true,
                    value: _selectedProduct,
                    hint: const Text('Select a product to prefill inputs'),
                    items: [
                      const DropdownMenuItem<Product?>(
                        value: null,
                        child: Text('Custom Manual Parameters'),
                      ),
                      ...productsState.products.map((p) => DropdownMenuItem<Product?>(
                            value: p,
                            child: Text('${p.name} (Cost: ₹${p.costPrice.toStringAsFixed(0)}, Price: ₹${p.basePrice.toStringAsFixed(0)})'),
                          )),
                    ],
                    onChanged: _onProductSelected,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Parameters Card
            BkCard(
              backgroundColor: t.card,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCENARIO INPUT PARAMETERS',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: BkInput(
                            label: 'Cost Price',
                            controller: _costController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkInput(
                            label: 'Selling Price',
                            controller: _sellingController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: BkInput(
                            label: 'Stock Units',
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkInput(
                            label: 'Chats Inquiries',
                            controller: _chatsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkInput(
                            label: 'Orders',
                            controller: _ordersController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BkButton(
                      size: BkButtonSize.sm,
                      variant: BkButtonVariant.secondary,
                      label: 'RUN SIMULATION',
                      isLoading: analyticsState.isLoading,
                      onPressed: _runCalculation,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // State Handling
            if (analyticsState.isLoading)
              const BkLoadingState(message: 'Calculating metrics & scenario signals...')
            else if (analyticsState.error != null)
              BkErrorState(
                error: analyticsState.error!,
                onRetry: _runCalculation,
              )
            else if (analyticsState.result != null) ...[
              _buildMetricsSummary(t, analyticsState.result!.summary),
              const SizedBox(height: 16),
              _buildInsightsSection(t, analyticsState.result!.insights),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSummary(BkTokens t, SummaryMetrics s) {
    final isProfit = s.profitStatus == 'PROFIT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profit / Loss Highlight Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isProfit ? t.success.withAlpha(35) : t.destructive.withAlpha(35),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NET PROFIT / LOSS',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: t.mutedForeground),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(s.profitOrLoss),
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isProfit ? t.secondary : t.destructive,
                    ),
                  ),
                ],
              ),
              BkBadge(
                label: '${s.profitMarginPercent.toStringAsFixed(1)}% MARGIN',
                variant: isProfit ? BkBadgeVariant.success : BkBadgeVariant.destructive,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid of Key Performance Indicators
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _kpiCard(t, 'GROSS REVENUE', CurrencyFormatter.format(s.grossRevenue), t.primary),
            _kpiCard(t, 'TOTAL COST', CurrencyFormatter.format(s.totalCost), t.mutedForeground),
            _kpiCard(t, 'PROFIT / UNIT', CurrencyFormatter.format(s.profitPerUnit), t.secondary),
            _kpiCard(t, 'CONVERSION RATE', '${s.conversionRate.toStringAsFixed(1)}%', t.accent),
            _kpiCard(t, 'UNITS SOLD', '${s.netUnitsSold} units', t.foreground),
            _kpiCard(t, 'STOCK REMAINING', '${s.remainingStock} units', t.warning),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(BkTokens t, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            offset: Offset(t.shadowOffset - 1, t.shadowOffset - 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.bold, color: t.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'DM Mono', fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BkTokens t, List<BusinessInsightItem> insights) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STRATEGIC RECOMMENDATIONS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: t.foreground,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: insights.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, idx) {
            final item = insights[idx];
            final variant = switch (item.severity.toLowerCase()) {
              'success' => BkAlertVariant.success,
              'warning' => BkAlertVariant.warning,
              'critical' => BkAlertVariant.destructive,
              _ => BkAlertVariant.info,
            };

            return BkAlert(
              title: item.title,
              description: item.message,
              variant: variant,
            );
          },
        ),
      ],
    );
  }
}
