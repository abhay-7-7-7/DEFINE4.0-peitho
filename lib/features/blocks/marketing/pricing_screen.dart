import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';
import '../../../data/mock_data.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _annual = false;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('PRICING PLANS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'TRANSPARENT PRICING',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No hidden fees. Scale as your team and apps grow.',
              style: GoogleFonts.outfit(fontSize: 15, color: t.mutedForeground),
            ),
            const SizedBox(height: 24),

            // Billing Toggle
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('MONTHLY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                BkSwitch(
                  value: _annual,
                  onChanged: (v) => setState(() => _annual = v),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ANNUAL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 6),
                    const BkBadge(label: 'SAVE 20%', variant: BkBadgeVariant.accent),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Plan Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;
                final cards = mockPricingPlans.map((plan) {
                  return Container(
                    width: isWide ? (constraints.maxWidth - 48) / 3 : double.infinity,
                    margin: EdgeInsets.only(bottom: isWide ? 0 : 20),
                    child: BkCard(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: plan.highlighted ? t.accent.withValues(alpha: 0.15) : t.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan.badgeLabel != null) ...[
                              BkBadge(label: plan.badgeLabel!, variant: BkBadgeVariant.primary),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              plan.name.toUpperCase(),
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  plan.price,
                                  style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  plan.period,
                                  style: GoogleFonts.outfit(fontSize: 14, color: t.mutedForeground),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              plan.description,
                              style: GoogleFonts.outfit(fontSize: 13, color: t.mutedForeground),
                            ),
                            const Divider(height: 32, thickness: 2),
                            // Feature list
                            ...plan.features.map((f) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: t.primary,
                                        border: Border.all(color: t.border, width: 2),
                                      ),
                                      child: Icon(Icons.check, size: 12, color: t.primaryForeground),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: BkButton(
                                label: plan.ctaLabel.toUpperCase(),
                                variant: plan.highlighted ? BkButtonVariant.primary : BkButtonVariant.outline,
                                size: BkButtonSize.defaultSize,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList();

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: cards,
                  );
                }
                return Column(children: cards);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
