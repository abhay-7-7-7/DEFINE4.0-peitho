import 'package:flutter/material.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';

class AssistData {
  final double? detectedOffer;
  final int quantity;
  final double unitCost;
  final double basePrice;
  final double minFloor;
  final double unitProfit;
  final double marginPct;
  final double totalProfit;
  final double discountVsBase;
  final double gapToFloor;
  final String status; // NO_OFFER_YET, PROFITABLE, ACCEPTABLE, CONTROLLED_LOSS, BELOW_FLOOR_VIOLATION
  final String severity; // info, success, warning, critical
  final String explanation;
  final String action; // ACCEPT, COUNTER, REJECT, FINAL_OFFER
  final double counterPrice;
  final List<String> suggestedReplies;
  final int currentRound;
  final int maxRounds;
  final double bbi;
  final double pHighWtp;
  final int firmnessLevel;
  final bool isTimedOut;
  final bool hasError;

  const AssistData({
    this.detectedOffer,
    this.quantity = 1,
    required this.unitCost,
    required this.basePrice,
    required this.minFloor,
    this.unitProfit = 0.0,
    this.marginPct = 0.0,
    this.totalProfit = 0.0,
    this.discountVsBase = 0.0,
    this.gapToFloor = 0.0,
    this.status = 'NO_OFFER_YET',
    this.severity = 'info',
    this.explanation = 'Awaiting buyer statement...',
    this.action = 'HOLD',
    this.counterPrice = 0.0,
    this.suggestedReplies = const [],
    this.currentRound = 1,
    this.maxRounds = 6,
    this.bbi = 50.0,
    this.pHighWtp = 0.5,
    this.firmnessLevel = 0,
    this.isTimedOut = false,
    this.hasError = false,
  });

  factory AssistData.fromPayload(Map<String, dynamic> data, {
    required double defaultCost,
    required double defaultBase,
    required double defaultFloor,
  }) {
    final prof = data['profitability'] as Map<String, dynamic>? ?? {};
    final adv = data['advisory'] as Map<String, dynamic>? ?? {};
    final metrics = adv['metrics'] as Map<String, dynamic>? ?? {};

    final offer = (prof['detected_offer'] as num?)?.toDouble() ??
        (adv['extracted_buyer_offer'] as num?)?.toDouble();
    final cost = (prof['unit_cost'] as num?)?.toDouble() ?? defaultCost;
    final base = (prof['base_price'] as num?)?.toDouble() ?? defaultBase;
    final floor = (prof['min_floor'] as num?)?.toDouble() ?? defaultFloor;
    final uProfit = (prof['unit_profit'] as num?)?.toDouble() ??
        (offer != null ? offer - cost : 0.0);
    final mPct = (prof['margin_pct'] as num?)?.toDouble() ??
        (offer != null && offer > 0 ? (uProfit / offer) * 100 : 0.0);
    final qty = (prof['detected_quantity'] as num?)?.toInt() ?? 1;

    final disc = offer != null ? base - offer : 0.0;
    final gap = offer != null ? offer - floor : 0.0;

    final replies = (adv['suggested_replies'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return AssistData(
      detectedOffer: offer,
      quantity: qty,
      unitCost: cost,
      basePrice: base,
      minFloor: floor,
      unitProfit: uProfit,
      marginPct: mPct,
      totalProfit: uProfit * qty,
      discountVsBase: disc,
      gapToFloor: gap,
      status: prof['status']?.toString() ?? 'NO_OFFER_YET',
      severity: prof['severity']?.toString() ?? 'info',
      explanation: prof['explanation']?.toString() ??
          adv['reasoning']?.toString() ??
          'Analyzing buyer statement.',
      action: adv['action']?.toString() ?? 'COUNTER',
      counterPrice: (adv['counter_price'] as num?)?.toDouble() ?? base,
      suggestedReplies: replies,
      currentRound: (data['current_round'] as num?)?.toInt() ?? 1,
      maxRounds: (data['max_rounds'] as num?)?.toInt() ?? 6,
      bbi: (metrics['bbi'] as num?)?.toDouble() ?? 50.0,
      pHighWtp: (metrics['p_high_wtp'] as num?)?.toDouble() ?? 0.5,
      firmnessLevel: (metrics['firmness_level'] as num?)?.toInt() ?? 0,
    );
  }
}

class SellerAssistSheet extends StatefulWidget {
  final AssistData? data;
  final ValueChanged<String> onUseReply;
  final ValueChanged<double> onOverrideOffer;
  final VoidCallback onRetry;

  const SellerAssistSheet({
    super.key,
    required this.data,
    required this.onUseReply,
    required this.onOverrideOffer,
    required this.onRetry,
  });

  @override
  State<SellerAssistSheet> createState() => _SellerAssistSheetState();
}

class _SellerAssistSheetState extends State<SellerAssistSheet> {
  bool _isEditingOffer = false;
  late final TextEditingController _offerEditController;

  @override
  void initState() {
    super.initState();
    _offerEditController = TextEditingController(
      text: widget.data?.detectedOffer != null
          ? widget.data!.detectedOffer!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant SellerAssistSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data?.detectedOffer != oldWidget.data?.detectedOffer &&
        !_isEditingOffer) {
      _offerEditController.text = widget.data?.detectedOffer != null
          ? widget.data!.detectedOffer!.toStringAsFixed(2)
          : '';
    }
  }

  @override
  void dispose() {
    _offerEditController.dispose();
    super.dispose();
  }

  void _saveOfferOverride() {
    final parsed = double.tryParse(_offerEditController.text);
    if (parsed != null && parsed > 0) {
      widget.onOverrideOffer(parsed);
      setState(() => _isEditingOffer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final data = widget.data;

    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text('Awaiting buyer messages to generate AI copilot intel...'),
        ),
      );
    }

    if (data.isTimedOut || data.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BkAlert(
              title: 'Assist Unavailable',
              description: 'Assist computation timed out or unavailable. Live chat continues uninterrupted.',
              variant: BkAlertVariant.destructive,
            ),
            const SizedBox(height: 12),
            BkButton(
              size: BkButtonSize.sm,
              variant: BkButtonVariant.secondary,
              label: 'Retry Assist Analysis',
              leading: const Icon(Icons.refresh, size: 16),
              onPressed: widget.onRetry,
            ),
          ],
        ),
      );
    }

    // Determine Zone Color
    Color zoneBg;
    Color zoneBorder;
    String zoneTitle;
    IconData zoneIcon;

    if (data.status == 'BELOW_FLOOR_VIOLATION' ||
        (data.detectedOffer != null && data.detectedOffer! < data.minFloor)) {
      zoneBg = t.destructive.withAlpha(30);
      zoneBorder = t.destructive;
      zoneTitle = 'LOUD LOSS WARNING: BELOW SURVIVAL FLOOR';
      zoneIcon = Icons.warning_amber_rounded;
    } else if (data.status == 'CONTROLLED_LOSS' ||
        (data.detectedOffer != null && data.detectedOffer! < data.unitCost)) {
      zoneBg = t.warning.withAlpha(35);
      zoneBorder = t.warning;
      zoneTitle = 'WARNING: CONTROLLED LOSS / BELOW COST';
      zoneIcon = Icons.report_problem_outlined;
    } else if (data.marginPct >= 20.0) {
      zoneBg = t.secondary.withAlpha(35);
      zoneBorder = t.secondary;
      zoneTitle = 'GREEN ZONE: STRONG PROFIT DEAL';
      zoneIcon = Icons.check_circle_outline;
    } else {
      zoneBg = t.card;
      zoneBorder = t.border;
      zoneTitle = 'MODERATE PROFIT / ACTIVE DIALOGUE';
      zoneIcon = Icons.info_outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: t.background,
        border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: t.primary,
                          border: Border.all(color: t.border, width: 1.5),
                        ),
                        child: const Icon(Icons.psychology, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PRANE-X PROFIT RADAR',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: t.foreground,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  BkBadge(
                    label: 'ROUND ${data.currentRound} / ${data.maxRounds}',
                    variant: BkBadgeVariant.outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Zone Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: zoneBg,
                  border: Border.all(color: zoneBorder, width: t.borderWidth),
                ),
                child: Row(
                  children: [
                    Icon(zoneIcon, color: zoneBorder, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        zoneTitle,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: zoneBorder,
                        ),
                      ),
                    ),
                    BkBadge(
                      label: data.action,
                      variant: BkBadgeVariant.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Editable Detected Offer Chip & Explanation
              BkCard(
                backgroundColor: t.card,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DETECTED OFFER',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: t.mutedForeground,
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _isEditingOffer = !_isEditingOffer),
                            child: Row(
                              children: [
                                Text(
                                  _isEditingOffer ? 'Cancel' : 'Edit Override',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: t.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  _isEditingOffer ? Icons.close : Icons.edit,
                                  size: 12,
                                  color: t.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_isEditingOffer)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _offerEditController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₹ ',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: t.border, width: t.borderWidth),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            BkButton(
                              size: BkButtonSize.sm,
                              variant: BkButtonVariant.primary,
                              label: 'Recalculate',
                              onPressed: _saveOfferOverride,
                            ),
                          ],
                        )
                      else
                        Text(
                          data.detectedOffer != null
                              ? CurrencyFormatter.format(data.detectedOffer)
                              : 'No price anchor verbalized yet',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: data.detectedOffer != null ? t.foreground : t.mutedForeground,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        data.explanation,
                        style: TextStyle(fontSize: 12, color: t.mutedForeground, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Unit Economics Grid
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border.all(color: t.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetricColumn(
                      label: 'UNIT PROFIT',
                      value: CurrencyFormatter.format(data.unitProfit),
                      color: data.unitProfit >= 0 ? t.secondary : t.destructive,
                    ),
                    _MetricColumn(
                      label: 'MARGIN %',
                      value: CurrencyFormatter.formatMargin(data.marginPct),
                      color: data.marginPct >= 20 ? t.secondary : t.warning,
                    ),
                    _MetricColumn(
                      label: 'TOTAL PROFIT',
                      value: CurrencyFormatter.format(data.totalProfit),
                      color: data.totalProfit >= 0 ? t.secondary : t.destructive,
                    ),
                    _MetricColumn(
                      label: 'GAP TO FLOOR',
                      value: CurrencyFormatter.format(data.gapToFloor),
                      color: data.gapToFloor >= 0 ? t.secondary : t.destructive,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tactical Suggested Replies
              if (data.suggestedReplies.isNotEmpty) ...[
                Text(
                  'TACTICAL SUGGESTIONS (TARGET: ${CurrencyFormatter.format(data.counterPrice)})',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                ...data.suggestedReplies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: BkCard(
                      backgroundColor: t.card,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              reply,
                              style: const TextStyle(fontSize: 13, height: 1.35),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                BkButton(
                                  size: BkButtonSize.sm,
                                  variant: BkButtonVariant.outline,
                                  label: 'USE THIS REPLY',
                                  leading: const Icon(Icons.paste_rounded, size: 14),
                                  onPressed: () => widget.onUseReply(reply),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: t.mutedForeground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
