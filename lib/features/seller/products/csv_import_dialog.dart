import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import 'products_provider.dart';

class CsvImportDialog extends ConsumerStatefulWidget {
  const CsvImportDialog({super.key});

  @override
  ConsumerState<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends ConsumerState<CsvImportDialog> {
  final _csvController = TextEditingController(
    text: 'name,basePrice,costPrice,category\n'
        'Apple iPhone 16 Pro,1199,850,Smartphones\n'
        'Dell XPS 15 Laptop,1899,1300,Computers\n'
        'Sony WH-1000XM5,499,280,Audio',
  );
  bool _importing = false;
  String? _resultMessage;
  List<String> _errors = [];

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    final text = _csvController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _importing = true;
      _resultMessage = null;
      _errors = [];
    });

    final res = await ref.read(productsProvider.notifier).importCsv(text);
    final created = res['created'] ?? 0;
    final errors = (res['errors'] as List?)?.map((e) => e.toString()).toList() ?? [];

    if (mounted) {
      setState(() {
        _importing = false;
        _resultMessage = 'Successfully imported $created product(s)';
        _errors = errors;
      });
      if (errors.isEmpty && created > 0) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.border, width: t.borderWidth),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              offset: Offset(t.shadowOffset * 2, t.shadowOffset * 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: t.background,
                border: Border(
                  bottom: BorderSide(color: t.border, width: t.borderWidth),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'BULK CSV PRODUCT IMPORT',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: t.foreground,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: t.border, width: 2),
                      ),
                      child: Icon(Icons.close, size: 16, color: t.foreground),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_resultMessage != null) ...[
                      BkAlert(
                        title: 'Import Result',
                        description: _resultMessage!,
                        variant: _errors.isEmpty
                            ? BkAlertVariant.success
                            : BkAlertVariant.destructive,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_errors.isNotEmpty) ...[
                      BkCard(
                        backgroundColor: t.destructive.withAlpha(25),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _errors
                                .map((err) => Text('• $err',
                                    style: TextStyle(
                                      color: t.destructive,
                                      fontSize: 12,
                                      fontFamily: 'DM Mono',
                                    )))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: t.card,
                        border: Border.all(color: t.border, width: t.borderWidth),
                      ),
                      child: TextField(
                        controller: _csvController,
                        maxLines: 7,
                        style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintText:
                              'name,basePrice,costPrice,category\nProduct A,100,60,General',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: t.muted.withAlpha(50),
                border: Border(
                  top: BorderSide(color: t.border, width: t.borderWidth),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BkButton(
                    variant: BkButtonVariant.outline,
                    label: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  BkButton(
                    variant: BkButtonVariant.primary,
                    label: 'Run Import',
                    isLoading: _importing,
                    onPressed: _handleImport,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
