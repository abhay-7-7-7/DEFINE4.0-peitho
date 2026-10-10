import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/bk_alert.dart';
import '../../core/widgets/bk_badge.dart';
import '../../core/widgets/bk_button.dart';
import '../../core/widgets/bk_states.dart';
import 'buyer_chat_client.dart';
import 'buyer_models.dart';

class BuyerChatScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String buyerName;

  const BuyerChatScreen({
    super.key,
    required this.sessionId,
    this.buyerName = 'Buyer',
  });

  @override
  ConsumerState<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends ConsumerState<BuyerChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  BuyerChatClient? _client;
  BuyerRoomInfo? _roomInfo;

  bool _isLoading = true;
  String? _initError;
  bool _isSellerOnline = false;
  bool _isRoomEnded = false;
  bool _isConnected = false;

  final List<BuyerChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _initRoom();
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _client?.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
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

  Future<void> _initRoom() async {
    setState(() {
      _isLoading = true;
      _initError = null;
    });

    final baseUrl = ref.read(apiBaseUrlProvider);

    _client = BuyerChatClient(
      baseUrl: baseUrl,
      sessionId: widget.sessionId,
      buyerName: widget.buyerName,
      onMessageReceived: (msg) {
        if (!mounted) return;
        setState(() {
          // If we had an optimistic message with matching text, replace it
          final existingIdx = _messages.indexWhere(
            (m) => m.isOptimistic && m.text == msg.text && m.sender == msg.sender,
          );
          if (existingIdx != -1) {
            _messages[existingIdx] = msg;
          } else {
            _messages.add(msg);
          }
        });
        _scrollToBottom();
      },
      onPresenceChanged: (sellerOnline) {
        if (!mounted) return;
        setState(() => _isSellerOnline = sellerOnline);
      },
      onRoomStatusChanged: (ended) {
        if (!mounted) return;
        setState(() => _isRoomEnded = ended);
      },
      onError: (err) {
        if (!mounted) return;
        setState(() => _isConnected = false);
      },
    );

    try {
      final info = await _client!.fetchInitialRoomInfo();
      _client!.connectWebSocket();

      if (!mounted) return;
      setState(() {
        _roomInfo = info;
        _isSellerOnline = info.sellerOnline;
        _isRoomEnded = !info.isActive;
        _isConnected = true;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initError = e.toString();
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || text.length > 1000 || _isRoomEnded) return;

    final optimisticMsg = BuyerChatMessage(
      id: 'opt_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'buyer',
      senderName: widget.buyerName,
      text: text,
      isOptimistic: true,
    );

    setState(() {
      _messages.add(optimisticMsg);
    });
    _messageController.clear();
    _scrollToBottom();

    final ok = _client?.sendMessage(text) ?? false;
    if (!ok) {
      // Mark as failed
      if (mounted) {
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == optimisticMsg.id);
          if (idx != -1) {
            _messages[idx] = _messages[idx].copyWith(hasFailed: true, isOptimistic: false);
          }
        });
      }
    }
  }

  void _retryMessage(BuyerChatMessage msg) {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        _messages[idx] = msg.copyWith(hasFailed: false, isOptimistic: true);
      }
    });

    final ok = _client?.sendMessage(msg.text) ?? false;
    if (!ok && mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == msg.id);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(hasFailed: true, isOptimistic: false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: t.background,
        appBar: _buildSimpleAppBar(t),
        body: const BkLoadingState(message: 'Entering negotiation room...'),
      );
    }

    if (_initError != null) {
      return Scaffold(
        backgroundColor: t.background,
        appBar: _buildSimpleAppBar(t),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BkAlert(
                  title: 'Room Unavailable',
                  description: _initError!,
                  variant: BkAlertVariant.destructive,
                ),
                const SizedBox(height: 16),
                BkButton(
                  variant: BkButtonVariant.primary,
                  label: 'RETRY CONNECTION',
                  onPressed: _initRoom,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final charCount = _messageController.text.length;
    final isOverLimit = charCount > 1000;
    final canSend = _messageController.text.trim().isNotEmpty && !isOverLimit && !_isRoomEnded;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _roomInfo?.productName ?? 'Product Negotiation',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: t.foreground,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isSellerOnline ? t.success : t.mutedForeground,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _isSellerOnline ? 'Seller Online' : 'Seller Offline',
                  style: TextStyle(fontSize: 11, color: t.mutedForeground),
                ),
                if (_roomInfo != null) ...[
                  Text(' • ', style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                  Text(
                    'Listed: ${CurrencyFormatter.format(_roomInfo!.basePrice)}',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: t.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          if (_isRoomEnded)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Center(
                child: BkBadge(
                  label: 'ENDED',
                  variant: BkBadgeVariant.destructive,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Reconnecting Banner if socket down
          if (!_isConnected && !_isRoomEnded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: t.warning.withAlpha(50),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: t.warning),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Reconnecting live socket...',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _client?.connectWebSocket(),
                    child: Text(
                      'RECONNECT',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: t.foreground),
                    ),
                  ),
                ],
              ),
            ),

          // Ended room banner
          if (_isRoomEnded)
            Container(
              padding: const EdgeInsets.all(12),
              color: t.destructive.withAlpha(35),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: t.destructive),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This negotiation session has concluded. Further messages are locked.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Message Feed
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: t.mutedForeground),
                          const SizedBox(height: 12),
                          Text(
                            'Negotiation room is open.',
                            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 14, color: t.foreground),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send your opening counter or question below to start.',
                            style: TextStyle(fontSize: 12, color: t.mutedForeground),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final msg = _messages[idx];
                      final isBuyer = msg.sender == 'buyer';

                      return Align(
                        alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 290),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBuyer ? t.card : t.secondary.withAlpha(25),
                            border: Border.all(
                              color: msg.hasFailed ? t.destructive : t.border,
                              width: t.borderWidth,
                            ),
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
                                    isBuyer ? 'YOU (${widget.buyerName.toUpperCase()})' : 'SELLER',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: isBuyer ? t.mutedForeground : t.secondary,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(msg.timestamp),
                                    style: TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontSize: 9,
                                      color: t.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.text,
                                style: const TextStyle(fontSize: 13),
                              ),
                              if (msg.hasFailed) ...[
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => _retryMessage(msg),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, size: 14, color: t.destructive),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Failed to send. Tap to retry.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: t.destructive,
                                        ),
                                      ),
                                    ],
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

          // Composer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.card,
              border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isRoomEnded ? t.muted.withAlpha(30) : t.background,
                            border: Border.all(
                              color: isOverLimit ? t.destructive : t.border,
                              width: t.borderWidth,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            enabled: !_isRoomEnded,
                            maxLines: 3,
                            minLines: 1,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: InputBorder.none,
                              hintText: _isRoomEnded ? 'Negotiation room ended' : 'Type your offer or counter...',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BkButton(
                        size: BkButtonSize.md,
                        variant: BkButtonVariant.primary,
                        label: 'SEND',
                        onPressed: canSend ? _sendMessage : () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$charCount / 1000',
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isOverLimit ? t.destructive : t.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(BkTokens t) {
    return AppBar(
      backgroundColor: t.card,
      elevation: 0,
      shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
      title: Text(
        'LIVE NEGOTIATION',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: t.foreground,
        ),
      ),
    );
  }
}
