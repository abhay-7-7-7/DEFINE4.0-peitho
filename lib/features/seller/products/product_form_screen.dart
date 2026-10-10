import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../../../core/widgets/bk_radio.dart';
import 'product_models.dart';
import 'products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxRoundsController;
  late String _mode;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? 'General');
    _basePriceController = TextEditingController(
        text: p != null ? p.basePrice.toStringAsFixed(2) : '');
    _costPriceController = TextEditingController(
        text: p != null ? p.costPrice.toStringAsFixed(2) : '');
    _minPriceController = TextEditingController(
        text: p != null ? p.minAcceptablePrice.toStringAsFixed(2) : '');
    _maxRoundsController = TextEditingController(
        text: p != null ? p.maxRounds.toString() : '10');
    _mode = p?.mode ?? 'MAX_PROFIT';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _basePriceController.dispose();
    _costPriceController.dispose();
    _minPriceController.dispose();
    _maxRoundsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final basePrice = double.tryParse(_basePriceController.text) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    final minPrice = double.tryParse(_minPriceController.text) ?? costPrice;
    final maxRounds = int.tryParse(_maxRoundsController.text) ?? 10;

    if (costPrice >= basePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cost price must be less than base listed price')),
      );
      return;
    }

    setState(() => _submitting = true);

    final payload = {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'base_price': basePrice,
      'cost_price': costPrice,
      'min_acceptable_price': minPrice,
      'max_loss_percent': 0.0,
      'mode': _mode,
      'max_rounds': maxRounds,
    };

    bool success;
    if (widget.productToEdit != null) {
      success = await ref
          .read(productsProvider.notifier)
          .updateProduct(widget.productToEdit!.id, payload);
    } else {
      success =
          await ref.read(productsProvider.notifier).createProduct(payload);
    }

    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product. Check inputs.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final isEditing = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          isEditing ? 'EDIT PRODUCT' : 'NEW PRODUCT',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BkCard(
                backgroundColor: t.card,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BASIC INFORMATION',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: t.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BkInput(
                        label: 'Product Name',
                        controller: _nameController,
                        hint: 'Sony WH-1000XM5 Headphones',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      BkInput(
                        label: 'Category',
                        controller: _categoryController,
                        hint: 'Audio / Electronics / General',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Pricing Boundaries Card
              BkCard(
                backgroundColor: t.card,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ECONOMIC BOUNDARIES',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: t.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BkInput(
                              label: 'Listed Price (₹)',
                              controller: _basePriceController,
                              hint: '500.00',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || double.tryParse(v) == null)
                                  ? 'Enter valid price'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BkInput(
                              label: 'Unit Cost (₹)',
                              controller: _costPriceController,
                              hint: '250.00',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || double.tryParse(v) == null)
                                  ? 'Enter unit cost'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BkInput(
                        label: 'Survival Floor Price (₹) — Never conceded below',
                        controller: _minPriceController,
                        hint: '320.00',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || double.tryParse(v) == null)
                            ? 'Enter floor price'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Strategy Mode
              BkCard(
                backgroundColor: t.card,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BkRadioGroup<String>(
                        label: 'NEGOTIATION STRATEGY MODE',
                        selectedValue: _mode,
                        onChanged: (val) => setState(() => _mode = val),
                        options: const [
                          BkRadioOption(
                            value: 'MAX_PROFIT',
                            label: 'Max Profit',
                            description: 'Conservative concession',
                          ),
                          BkRadioOption(
                            value: 'MIN_LOSS',
                            label: 'Min Loss',
                            description: 'Inventory clearing',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BkInput(
                        label: 'Max Allowed Rounds',
                        controller: _maxRoundsController,
                        hint: '10',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              BkButton(
                label: isEditing ? 'UPDATE PRODUCT' : 'CREATE PRODUCT',
                isLoading: _submitting,
                variant: BkButtonVariant.primary,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
