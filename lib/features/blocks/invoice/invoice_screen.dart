import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';
import '../../../data/mock_data.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final subtotal = mockInvoiceItems.fold<double>(0, (sum, item) => sum + item.total);
    final tax = subtotal * 0.15;
    final total = subtotal + tax;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('INVOICE #BK-2026-08', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BkCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOLDKIT INC.',
                                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text('100 Brutalist Way, Suite 404\nSan Francisco, CA 94107',
                                  style: GoogleFonts.outfit(fontSize: 12, color: t.mutedForeground)),
                            ],
                          ),
                          const BkBadge(
                            label: 'PAID IN FULL',
                            variant: BkBadgeVariant.success,
                          ),
                        ],
                      ),
                      const Divider(height: 40, thickness: 3),

                      // Billed To & Dates
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BILLED TO', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: t.mutedForeground)),
                              const SizedBox(height: 4),
                              Text('Acme Corporation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              Text('billing@acme.corp', style: GoogleFonts.outfit(fontSize: 12, color: t.mutedForeground)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ISSUE DATE: OCT 02, 2026', style: GoogleFonts.dmMono(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('DUE DATE: OCT 16, 2026', style: GoogleFonts.dmMono(fontSize: 11, color: t.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Line Items Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: t.border, width: t.borderWidth),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              color: t.muted.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('DESCRIPTION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900))),
                                  Expanded(child: Text('QTY', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900))),
                                  Expanded(child: Text('PRICE', textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900))),
                                  Expanded(child: Text('TOTAL', textAlign: TextAlign.right, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900))),
                                ],
                              ),
                            ),
                            Container(height: 2, color: t.border),
                            // Rows
                            ...mockInvoiceItems.map((item) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: t.border.withValues(alpha: 0.2), width: 1)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(item.description, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                    Expanded(
                                      child: Text('${item.quantity}', textAlign: TextAlign.center, style: GoogleFonts.dmMono(fontSize: 12)),
                                    ),
                                    Expanded(
                                      child: Text('\$${item.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.right, style: GoogleFonts.dmMono(fontSize: 12)),
                                    ),
                                    Expanded(
                                      child: Text('\$${item.total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Totals
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text('Subtotal', style: GoogleFonts.outfit(fontSize: 13))),
                                  const SizedBox(width: 8),
                                  Text('\$${subtotal.toStringAsFixed(2)}', style: GoogleFonts.dmMono(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text('Tax (15%)', style: GoogleFonts.outfit(fontSize: 13))),
                                  const SizedBox(width: 8),
                                  Text('\$${tax.toStringAsFixed(2)}', style: GoogleFonts.dmMono(fontSize: 13)),
                                ],
                              ),
                              const Divider(height: 16, thickness: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text('TOTAL', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900))),
                                  const SizedBox(width: 8),
                                  Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.dmMono(fontSize: 16, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  BkButton(
                    label: 'PRINT INVOICE',
                    variant: BkButtonVariant.outline,
                    size: BkButtonSize.defaultSize,
                    onPressed: () {},
                  ),
                  BkButton(
                    label: 'DOWNLOAD PDF',
                    variant: BkButtonVariant.primary,
                    size: BkButtonSize.defaultSize,
                    onPressed: () => BkToastManager.show(context, message: 'Downloading PDF...', variant: BkToastVariant.success),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
