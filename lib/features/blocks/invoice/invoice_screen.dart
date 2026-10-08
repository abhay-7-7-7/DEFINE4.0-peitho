import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_motion.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';
import '../../../data/mock_data.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late List<MockInvoiceItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(mockInvoiceItems);
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);
  double get _tax => _subtotal * 0.15;
  double get _total => _subtotal + _tax;

  void _addItem() {
    final descController =
        TextEditingController(text: 'Additional Consulting Hours');
    final qtyController = TextEditingController(text: '2');
    final priceController = TextEditingController(text: '120.00');

    showBkDialog(
      context: context,
      title: 'ADD INVOICE ITEM',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BkInput(
            controller: descController,
            label: 'DESCRIPTION',
            hint: 'Item description',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BkInput(
                  controller: qtyController,
                  label: 'QTY',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BkInput(
                  controller: priceController,
                  label: 'PRICE (\$)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        BkButton(
          label: 'CANCEL',
          variant: BkButtonVariant.outline,
          size: BkButtonSize.sm,
          onPressed: () => Navigator.of(context).pop(),
        ),
        BkButton(
          label: 'ADD ITEM',
          variant: BkButtonVariant.primary,
          size: BkButtonSize.sm,
          onPressed: () {
            final desc = descController.text.trim();
            final qty = int.tryParse(qtyController.text) ?? 1;
            final price = double.tryParse(priceController.text) ?? 0.0;
            if (desc.isNotEmpty) {
              setState(() {
                _items.add(MockInvoiceItem(
                  description: desc,
                  quantity: qty,
                  unitPrice: price,
                ));
              });
              BkToastManager.show(context,
                  message: 'ITEM ADDED TO INVOICE',
                  variant: BkToastVariant.success);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _removeItem(int index) {
    BkMotion.hapticClick();
    setState(() {
      _items.removeAt(index);
    });
    BkToastManager.show(context, message: 'ITEM REMOVED');
  }

  void _updateQuantity(int index, int delta) {
    BkMotion.hapticClick();
    setState(() {
      final item = _items[index];
      final newQty = item.quantity + delta;
      if (newQty > 0) {
        _items[index] = MockInvoiceItem(
          description: item.description,
          quantity: newQty,
          unitPrice: item.unitPrice,
        );
      } else {
        _items.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final subtotal = _subtotal;
    final tax = _tax;
    final total = _total;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('INVOICE #BK-2026-08',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add item',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addItem,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BkReveal(
                child: BkCard(
                  padding: const EdgeInsets.all(16),
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
                                style: GoogleFonts.outfit(
                                    fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  '100 Brutalist Way, Suite 404\nSan Francisco, CA 94107',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12, color: t.mutedForeground)),
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
                              Text('BILLED TO',
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: t.mutedForeground)),
                              const SizedBox(height: 4),
                              Text('Acme Corporation',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                              Text('billing@acme.corp',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12, color: t.mutedForeground)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ISSUE DATE: OCT 02, 2026',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('DUE DATE: OCT 16, 2026',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 11, color: t.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Line Items Table Header Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'LINE ITEMS (${_items.length})',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          BkButton(
                            label: '+ ADD ITEM',
                            variant: BkButtonVariant.accent,
                            size: BkButtonSize.sm,
                            onPressed: _addItem,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Line Items Table
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth < 520
                              ? 520.0
                              : constraints.maxWidth;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: tableWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: t.border, width: t.borderWidth),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      color: t.muted.withValues(alpha: 0.5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Text('DESCRIPTION',
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900))),
                                          Expanded(
                                              flex: 2,
                                              child: Text('QTY',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900))),
                                          Expanded(
                                              child: Text('PRICE',
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900))),
                                          Expanded(
                                              child: Text('TOTAL',
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900))),
                                          const SizedBox(width: 36),
                                        ],
                                      ),
                                    ),
                                    Container(height: 2, color: t.border),
                                    // Rows
                                    if (_items.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Center(
                                          child: Text(
                                              'No line items. Click "+ ADD ITEM" to add.',
                                              style: GoogleFonts.outfit(
                                                  color: t.mutedForeground)),
                                        ),
                                      )
                                    else
                                      ..._items.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: t.border
                                                        .withValues(alpha: 0.2),
                                                    width: 1)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(item.description,
                                                    style: GoogleFonts.outfit(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _updateQuantity(
                                                              index, -1),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: t.border,
                                                                width: 1)),
                                                        child: const Icon(
                                                            Icons.remove,
                                                            size: 14),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                          '${item.quantity}',
                                                          style: GoogleFonts
                                                              .dmMono(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _updateQuantity(
                                                              index, 1),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: t.border,
                                                                width: 1)),
                                                        child: const Icon(
                                                            Icons.add,
                                                            size: 14),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    '\$${item.unitPrice.toStringAsFixed(2)}',
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.dmMono(
                                                        fontSize: 12)),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    '\$${item.total.toStringAsFixed(2)}',
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.dmMono(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              SizedBox(
                                                width: 36,
                                                child: IconButton(
                                                  icon: Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                      color: t.destructive),
                                                  onPressed: () =>
                                                      _removeItem(index),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Text('Subtotal',
                                          style: GoogleFonts.outfit(
                                              fontSize: 13))),
                                  const SizedBox(width: 8),
                                  Text('\$${subtotal.toStringAsFixed(2)}',
                                      style: GoogleFonts.dmMono(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Text('Tax (15%)',
                                          style: GoogleFonts.outfit(
                                              fontSize: 13))),
                                  const SizedBox(width: 8),
                                  Text('\$${tax.toStringAsFixed(2)}',
                                      style: GoogleFonts.dmMono(fontSize: 13)),
                                ],
                              ),
                              const Divider(height: 16, thickness: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Text('TOTAL',
                                          style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900))),
                                  const SizedBox(width: 8),
                                  Text('\$${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.dmMono(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900)),
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
              BkReveal(
                delay: const Duration(milliseconds: 100),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    BkButton(
                      label: 'PRINT INVOICE',
                      variant: BkButtonVariant.outline,
                      size: BkButtonSize.defaultSize,
                      onPressed: () {
                        BkMotion.hapticClick();
                        BkToastManager.show(context,
                            message: 'SENDING TO PRINTER...');
                      },
                    ),
                    BkButton(
                      label: 'DOWNLOAD PDF',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.defaultSize,
                      onPressed: () {
                        BkMotion.hapticClick();
                        BkToastManager.show(context,
                            message: 'DOWNLOADING PDF...',
                            variant: BkToastVariant.success);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
