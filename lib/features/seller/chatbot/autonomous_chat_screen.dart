import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_radio.dart';
import '../../../core/widgets/bk_states.dart';
import '../products/product_models.dart';
import '../products/products_provider.dart';
import 'autonomous_chat_models.dart';
import 'autonomous_chat_provider.dart';

class AutonomousChatScreen extends ConsumerStatefulWidget {
  const AutonomousChatScreen({super.key});

  @override
  ConsumerState<AutonomousChatScreen> createState() => _AutonomousChatScreenState();
}

class _AutonomousChatScreenState extends ConsumerState<AutonomousChatScreen> {
  final _messageController = TextEditingController();
  final _offerController = TextEditingController();
  final _scrollController = ScrollController();

  Product? _selectedProduct;
  String _mode = 'MAX_PROFIT';
  int _maxRounds = 10;

  @override
  void dispose() {
    _messageController.dispose();
    _offerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleStart(List<Product> products) {
    final p = _selectedProduct ?? (products.isNotEmpty ? products.first : null);
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a product first')),
      );
      return;
    }

    final config = AutonomousSessionConfig(
      productId: p.id,
      productName: p.name,
      basePrice: p.basePrice,
      costPrice: p.costPrice,
      minPrice: p.minAcceptablePrice,
      mode: _mode,
      maxRounds: _maxRounds,
    );

    ref.read(autonomousChatProvider.notifier).startSession(config);
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    final offer = double.tryParse(_offerController.text.trim());
    if (text.isEmpty && offer == null) return;

    ref.read(autonomousChatProvider.notifier).sendMessage(
          text.isNotEmpty ? text : 'I offer ${CurrencyFormatter.format(offer)}',
          manualOffer: offer,
        );

    _messageController.clear();
    _offerController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final chatState = ref.watch(autonomousChatProvider);
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'AUTONOMOUS BOT DEMO',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
        actions: [
          if (chatState.sessionId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Session',
              onPressed: () => ref.read(autonomousChatProvider.notifier).reset(),
            ),
        ],
      ),
      body: chatState.sessionId == null
          ? _buildConfigurationView(t, productsState)
          : _buildLiveSimulationView(t, chatState),
    );
  }

  Widget _buildConfigurationView(BkTokens t, ProductsState productsState) {
    final products = productsState.products;

    if (productsState.isLoading) {
      return const BkLoadingState(message: 'Loading products for simulation...');
    }

    if (products.isEmpty) {
      return BkEmptyState(
        title: 'NO PRODUCTS FOUND',
        description: 'You need at least one product configured to launch an autonomous bot simulation.',
        actionLabel: 'REFRESH PRODUCTS',
        onAction: () => ref.read(productsProvider.notifier).fetchProducts(),
      );
    }

    final p = _selectedProduct ?? products.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TEST AUTONOMOUS BOT AGENT',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simulate a live buyer negotiating against your AI pricing engine in real-time.',
            style: TextStyle(fontSize: 13, color: t.mutedForeground),
          ),
          const SizedBox(height: 16),

          // Product Selector Card
          BkCard(
            backgroundColor: t.card,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT TARGET PRODUCT',
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
                      color: t.background,
                      border: Border.all(color: t.border, width: t.borderWidth),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Product>(
                        isExpanded: true,
                        value: _selectedProduct ?? products.first,
                        items: products.map((prod) {
                          return DropdownMenuItem<Product>(
                            value: prod,
                            child: Text(
                              '${prod.name} (${CurrencyFormatter.format(prod.basePrice)})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProduct = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricBadge('Base Price', CurrencyFormatter.format(p.basePrice), t.primary),
                      _metricBadge('Floor Price', CurrencyFormatter.format(p.minAcceptablePrice), t.warning),
                      _metricBadge('Cost Price', CurrencyFormatter.format(p.costPrice), t.mutedForeground),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Strategy Selector
          BkCard(
            backgroundColor: t.card,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkRadioGroup<String>(
                    label: 'CONCESSION STRATEGY',
                    selectedValue: _mode,
                    onChanged: (val) => setState(() => _mode = val),
                    options: const [
                      BkRadioOption(
                        value: 'MAX_PROFIT',
                        label: 'Max Profit',
                        description: 'Tight margin protection, slow concessions',
                      ),
                      BkRadioOption(
                        value: 'MIN_LOSS',
                        label: 'Min Loss',
                        description: 'Aggressive volume clearing, concessions toward floor',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MAX ROUNDS: $_maxRounds',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.foreground,
                    ),
                  ),
                  Slider(
                    value: _maxRounds.toDouble(),
                    min: 3,
                    max: 20,
                    divisions: 17,
                    activeColor: t.primary,
                    inactiveColor: t.muted,
                    label: '$_maxRounds rounds',
                    onChanged: (val) => setState(() => _maxRounds = val.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          BkButton(
            size: BkButtonSize.lg,
            variant: BkButtonVariant.primary,
            label: 'LAUNCH SIMULATION',
            onPressed: () => _handleStart(products),
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontFamily: 'DM Mono', fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ],
    );
  }

  Widget _buildLiveSimulationView(BkTokens t, AutonomousChatState chatState) {
    final turns = chatState.turns;
    final isSending = chatState.isSending;
    final isClosed = chatState.isDealClosed;

    return Column(
      children: [
        // Top Simulation HUD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: t.card,
            border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatState.config?.productName ?? 'Product',
                    style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  Text(
                    'Mode: ${chatState.config?.mode} • Round ${turns.length ~/ 2}/${chatState.config?.maxRounds}',
                    style: TextStyle(fontSize: 11, color: t.mutedForeground),
                  ),
                ],
              ),
              if (isClosed)
                const BkBadge(
                  label: 'DEAL CLOSED',
                  variant: BkBadgeVariant.success,
                )
              else
                const BkBadge(
                  label: 'ACTIVE',
                  variant: BkBadgeVariant.secondary,
                ),
            ],
          ),
        ),

        // Closed banner
        if (isClosed && chatState.finalAgreedPrice != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: t.success.withAlpha(40),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: t.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Agreement reached at ${CurrencyFormatter.format(chatState.finalAgreedPrice!)}!',
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13, color: t.foreground),
                  ),
                ),
              ],
            ),
          ),

        // Error message if any
        if (chatState.error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BkAlert(
              title: 'Simulation Notice',
              description: chatState.error!,
              variant: BkAlertVariant.warning,
            ),
          ),

        // Chat Turns List
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: turns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final turn = turns[idx];
              final isBuyer = turn.role == 'buyer';

              return Align(
                alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBuyer ? t.card : t.secondary.withAlpha(25),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBuyer ? 'BUYER SIMULATOR' : 'AUTONOMOUS SELLER BOT',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isBuyer ? t.mutedForeground : t.secondary,
                            ),
                          ),
                          if (turn.decision != null)
                            BkBadge(
                              label: turn.decision!,
                              variant: turn.decision == 'ACCEPT'
                                  ? BkBadgeVariant.success
                                  : turn.decision == 'REJECT'
                                      ? BkBadgeVariant.destructive
                                      : BkBadgeVariant.outline,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(turn.message, style: const TextStyle(fontSize: 13)),
                      if (turn.counterPrice != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Counter: ${CurrencyFormatter.format(turn.counterPrice)}',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isBuyer ? t.primary : t.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Quick Offer Chips
        if (!isClosed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: t.card,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Quick Buyer Offer: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  ..._generateQuickChips(chatState.config?.basePrice ?? 100).map((val) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () {
                          _offerController.text = val.toStringAsFixed(0);
                          _messageController.text = 'Can you do ${CurrencyFormatter.format(val)}?';
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: t.background,
                            border: Border.all(color: t.border, width: 1.5),
                          ),
                          child: Text(
                            CurrencyFormatter.format(val),
                            style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        // Bottom Input Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: BkInput(
                    hint: '₹ Offer',
                    controller: _offerController,
                    keyboardType: TextInputType.number,
                    enabled: !isClosed && !isSending,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BkInput(
                    hint: isClosed ? 'Deal concluded' : 'Message as buyer...',
                    controller: _messageController,
                    enabled: !isClosed && !isSending,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                BkButton(
                  variant: BkButtonVariant.primary,
                  label: 'SEND',
                  isLoading: isSending,
                  onPressed: isClosed ? () {} : _handleSend,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<double> _generateQuickChips(double base) {
    return [
      (base * 0.75).roundToDouble(),
      (base * 0.85).roundToDouble(),
      (base * 0.90).roundToDouble(),
      (base * 0.95).roundToDouble(),
    ];
  }
}
