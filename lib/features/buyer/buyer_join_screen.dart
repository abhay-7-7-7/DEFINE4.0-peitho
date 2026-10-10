import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/utils/link_parser.dart';
import '../../core/widgets/bk_alert.dart';
import '../../core/widgets/bk_badge.dart';
import '../../core/widgets/bk_button.dart';
import '../../core/widgets/bk_card.dart';
import '../../core/widgets/bk_input.dart';
import 'buyer_chat_client.dart';

class BuyerJoinScreen extends ConsumerStatefulWidget {
  final String? initialToken;

  const BuyerJoinScreen({super.key, this.initialToken});

  @override
  ConsumerState<BuyerJoinScreen> createState() => _BuyerJoinScreenState();
}

class _BuyerJoinScreenState extends ConsumerState<BuyerJoinScreen> {
  final _tokenController = TextEditingController();
  final _nameController = TextEditingController(text: 'Buyer');

  bool _isScanning = false;
  bool _isChecking = false;
  String? _errorMessage;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenController.text = widget.initialToken!;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _startScanner() {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
      );
    });
  }

  void _stopScanner() {
    _scannerController?.dispose();
    _scannerController = null;
    setState(() => _isScanning = false);
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        final parsed = LinkParser.parse(rawValue);
        if (parsed.isValid && parsed.token != null) {
          _stopScanner();
          _tokenController.text = parsed.token!;
          _joinRoom();
          return;
        }
      }
    }
  }

  Future<void> _joinRoom() async {
    final rawInput = _tokenController.text.trim();
    if (rawInput.isEmpty) {
      setState(() => _errorMessage = 'Please enter or scan a negotiation link / token.');
      return;
    }

    final parsed = LinkParser.parse(rawInput);
    if (!parsed.isValid || parsed.token == null) {
      setState(() => _errorMessage =
          parsed.error ?? 'Invalid link format. Could not extract a valid room token.');
      return;
    }

    final token = parsed.token!;

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final baseUrl = ref.read(apiBaseUrlProvider);
    final buyerName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Buyer';

    final tempClient = BuyerChatClient(
      baseUrl: baseUrl,
      sessionId: token,
      buyerName: buyerName,
      onMessageReceived: (_) {},
      onPresenceChanged: (_) {},
      onRoomStatusChanged: (_) {},
      onError: (_) {},
    );

    try {
      await tempClient.fetchInitialRoomInfo();
      tempClient.dispose();

      if (!mounted) return;
      setState(() => _isChecking = false);

      context.push('/buyer-chat/$token?name=${Uri.encodeComponent(buyerName)}');
    } catch (e) {
      tempClient.dispose();
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _errorMessage = 'Could not access room ($token): ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'JOIN NEGOTIATION ROOM',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
      ),
      body: _isScanning ? _buildScannerView(t) : _buildFormView(t),
    );
  }

  Widget _buildScannerView(BkTokens t) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: t.card,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POINT CAMERA AT SELLER QR CODE',
                style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13, color: t.foreground),
              ),
              BkButton(
                size: BkButtonSize.sm,
                variant: BkButtonVariant.outline,
                label: 'CANCEL',
                onPressed: _stopScanner,
              ),
            ],
          ),
        ),
        Expanded(
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
            errorBuilder: (ctx, err) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Camera permission unavailable or denied.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      BkButton(
                        variant: BkButtonVariant.primary,
                        label: 'PASTE CODE MANUALLY',
                        onPressed: _stopScanner,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormView(BkTokens t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge & Intro
          const Row(
            children: [
              BkBadge(
                label: 'PUBLIC BUYER PORTAL',
                variant: BkBadgeVariant.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'JOIN AS BUYER',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: t.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan the seller\'s QR code or paste the invitation link / room token to begin live negotiation.',
            style: TextStyle(fontSize: 13, color: t.mutedForeground),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) ...[
            BkAlert(
              title: 'Invalid Room Link',
              description: _errorMessage!,
              variant: BkAlertVariant.destructive,
            ),
            const SizedBox(height: 16),
          ],

          // QR Scanner CTA Card
          BkCard(
            backgroundColor: t.card,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: t.secondary),
                  const SizedBox(height: 10),
                  Text(
                    'HAVE A QR CODE?',
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, fontSize: 14, color: t.foreground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan directly from the seller\'s screen or printout.',
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  BkButton(
                    variant: BkButtonVariant.secondary,
                    label: 'SCAN SELLER QR CODE',
                    onPressed: _startScanner,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manual Entry Card
          BkCard(
            backgroundColor: t.card,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OR ENTER INVITATION LINK / CODE',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: t.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BkInput(
                    label: 'Room Link or Token',
                    hint: 'e.g. trademind://join/uuid or paste full URL',
                    controller: _tokenController,
                    prefix: const Icon(Icons.link, size: 20),
                  ),
                  const SizedBox(height: 12),
                  BkInput(
                    label: 'Your Display Name',
                    hint: 'Buyer',
                    controller: _nameController,
                    prefix: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: 16),
                  BkButton(
                    size: BkButtonSize.lg,
                    variant: BkButtonVariant.primary,
                    label: 'ENTER NEGOTIATION ROOM',
                    isLoading: _isChecking,
                    onPressed: _joinRoom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
