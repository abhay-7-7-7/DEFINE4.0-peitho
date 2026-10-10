import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import '../live_chat/seller_live_chat_screen.dart';
import '../products/products_provider.dart';
import 'meeting_share_sheet.dart';
import 'meetings_provider.dart';

class MeetingScheduleScreen extends ConsumerStatefulWidget {
  const MeetingScheduleScreen({super.key});

  @override
  ConsumerState<MeetingScheduleScreen> createState() => _MeetingScheduleScreenState();
}

class _MeetingScheduleScreenState extends ConsumerState<MeetingScheduleScreen> {
  final _productNameController = TextEditingController(text: 'Sony WH-1000XM5');
  final _basePriceController = TextEditingController(text: '500.00');
  final _costPriceController = TextEditingController(text: '250.00');
  final _minFloorController = TextEditingController(text: '320.00');

  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _creating = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _basePriceController.dispose();
    _costPriceController.dispose();
    _minFloorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  Future<void> _createMeeting({bool isInstant = false}) async {
    final name = _productNameController.text.trim();
    final base = double.tryParse(_basePriceController.text) ?? 500.0;
    final cost = double.tryParse(_costPriceController.text) ?? 250.0;
    final floor = double.tryParse(_minFloorController.text) ?? 320.0;

    DateTime? scheduledDateTime;
    if (!isInstant && _scheduledDate != null && _scheduledTime != null) {
      scheduledDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    }

    setState(() => _creating = true);

    final session = await ref.read(meetingsProvider.notifier).createLiveSession(
          productName: name,
          basePrice: base,
          costPrice: cost,
          minFloor: floor,
          scheduledTime: scheduledDateTime,
        );

    if (mounted) {
      setState(() => _creating = false);
      if (session != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => MeetingShareSheet(session: session),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize meeting session.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final productsState = ref.watch(productsProvider);
    final meetings = ref.watch(meetingsProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'LIVE MEETINGS & ROOMS',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instant Meeting Setup Card
            BkCard(
              backgroundColor: t.card,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'START LIVE NEGOTIATION',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Generate a live tokenized room for a buyer on another device or web browser.',
                      style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    ),
                    const SizedBox(height: 14),

                    // Quick Select from Products
                    if (productsState.products.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Select from Catalog (Optional)',
                          labelStyle: TextStyle(fontSize: 12, color: t.mutedForeground),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: t.border, width: t.borderWidth),
                          ),
                        ),
                        items: productsState.products.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(
                              '${p.name} (${CurrencyFormatter.format(p.basePrice)})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final p = productsState.products.firstWhere((e) => e.id == id);
                            setState(() {
                              _productNameController.text = p.name;
                              _basePriceController.text = p.basePrice.toStringAsFixed(2);
                              _costPriceController.text = p.costPrice.toStringAsFixed(2);
                              _minFloorController.text = p.minAcceptablePrice.toStringAsFixed(2);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    BkInput(
                      label: 'Product Name',
                      controller: _productNameController,
                      hint: 'Product name',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: BkInput(
                            label: 'Asking Price',
                            controller: _basePriceController,
                            hint: '500.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BkInput(
                            label: 'Cost Price',
                            controller: _costPriceController,
                            hint: '250.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BkInput(
                            label: 'Survival Floor',
                            controller: _minFloorController,
                            hint: '320.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    BkButton(
                      label: 'START INSTANT ROOM',
                      isLoading: _creating,
                      variant: BkButtonVariant.primary,
                      leading: const Icon(Icons.bolt, size: 18),
                      onPressed: () => _createMeeting(isInstant: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Schedule Meeting Section
            BkCard(
              backgroundColor: t.card,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'SCHEDULE FOR LATER',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: t.foreground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: BkButton(
                            size: BkButtonSize.sm,
                            variant: BkButtonVariant.outline,
                            leading: const Icon(Icons.calendar_month, size: 16),
                            label: _scheduledDate == null
                                ? 'Select Date'
                                : DateFormat('MMM dd, yyyy').format(_scheduledDate!),
                            onPressed: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkButton(
                            size: BkButtonSize.sm,
                            variant: BkButtonVariant.outline,
                            leading: const Icon(Icons.schedule, size: 16),
                            label: _scheduledTime == null
                                ? 'Select Time'
                                : _scheduledTime!.format(context),
                            onPressed: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BkButton(
                      label: 'SCHEDULE MEETING',
                      variant: BkButtonVariant.secondary,
                      onPressed: () => _createMeeting(isInstant: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Active Meeting Rooms
            Text(
              'ACTIVE ROOMS (${meetings.length})',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            if (meetings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No active rooms yet. Click "Start Instant Room" above.',
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                  ),
                ),
              )
            else
              ...meetings.map((m) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: BkCard(
                    backgroundColor: t.card,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  m.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(m.basePrice),
                                style: const TextStyle(fontFamily: 'DM Mono', fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Token: ${m.sessionId}',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 11,
                              color: t.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: BkButton(
                                  size: BkButtonSize.sm,
                                  variant: BkButtonVariant.outline,
                                  label: 'SHARE QR',
                                  leading: const Icon(Icons.qr_code, size: 14),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => MeetingShareSheet(session: m),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BkButton(
                                  size: BkButtonSize.sm,
                                  variant: BkButtonVariant.primary,
                                  label: 'ENTER CHAT',
                                  leading: const Icon(Icons.arrow_forward, size: 14),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SellerLiveChatScreen(session: m),
                                      ),
                                    );
                                  },
                                ),
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
        ),
      ),
    );
  }
}
