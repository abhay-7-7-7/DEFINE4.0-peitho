import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_dialog.dart';
import '../meetings/meeting_models.dart';
import 'seller_assist_sheet.dart';

class LiveChatMessageItem {
  final String id;
  final String role; // 'seller' | 'buyer'
  final String text;
  final double timestamp;

  const LiveChatMessageItem({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory LiveChatMessageItem.fromJson(Map<String, dynamic> json) {
    return LiveChatMessageItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      role: json['role']?.toString().toLowerCase() ?? 'buyer',
      text: json['text']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toDouble() ??
          DateTime.now().millisecondsSinceEpoch / 1000,
    );
  }
}

class SellerLiveChatScreen extends ConsumerStatefulWidget {
  final LiveMeetingSession session;

  const SellerLiveChatScreen({super.key, required this.session});

  @override
  ConsumerState<SellerLiveChatScreen> createState() =>
      _SellerLiveChatScreenState();
}

class _SellerLiveChatScreenState extends ConsumerState<SellerLiveChatScreen> {
  final List<LiveChatMessageItem> _messages = [];
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;
  bool _isBuyerOnline = false;
  bool _isBuyerTyping = false;
  bool _isRoomEnded = false;

  // Assist State
  AssistData? _assistData;
  final Set<String> _processedBuyerMessageIds = {};
  Timer? _assistTimeoutTimer;
  static const Duration _assistTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _initAssistBaseline();
    _fetchInitialState();
    _connectWebSocket();
  }

  void _initAssistBaseline() {
    _assistData = AssistData(
      unitCost: widget.session.costPrice,
      basePrice: widget.session.basePrice,
      minFloor: widget.session.minFloor,
      maxRounds: widget.session.maxRounds,
      counterPrice: widget.session.basePrice,
    );
  }

  @override
  void dispose() {
    _assistTimeoutTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialState() async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.get(
        '/api/v1/peitho/live-chat/${widget.session.sessionId}',
        queryParams: {'role': 'seller'},
        requiresAuth: true,
      );
      if (res is Map<String, dynamic> && mounted) {
        if (res['messages'] is List) {
          final list = (res['messages'] as List)
              .map((e) => LiveChatMessageItem.fromJson(e as Map<String, dynamic>))
              .toList();
          setState(() {
            _messages.clear();
            _messages.addAll(list);
            _isBuyerOnline = res['buyer_online'] == true;
            _isRoomEnded = res['is_active'] == false;
          });
          _scrollToBottom();
        }
      }
    } catch (_) {}
  }

  void _connectWebSocket() {
    final baseUrl = ref.read(apiBaseUrlProvider);
    final wsUrl = AppConfig.toWebSocketUrl(
      baseUrl,
      '/api/v1/peitho/live-chat/ws/${widget.session.sessionId}?role=seller',
    );

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _subscription = _channel!.stream.listen(
        _handleIncomingWsMessage,
        onDone: () {
          if (mounted) setState(() => _isConnected = false);
        },
        onError: (_) {
          if (mounted) setState(() => _isConnected = false);
        },
      );
      setState(() => _isConnected = true);
    } catch (_) {
      setState(() => _isConnected = false);
    }
  }

  void _handleIncomingWsMessage(dynamic event) {
    try {
      final data = jsonDecode(event.toString()) as Map<String, dynamic>;
      final type = data['type']?.toString();

      if (type == 'init') {
        setState(() {
          _isConnected = true;
          _isBuyerOnline = data['buyer_online'] == true;
        });
      } else if (type == 'presence') {
        if (data.containsKey('buyer_online')) {
          setState(() => _isBuyerOnline = data['buyer_online'] == true);
        }
      } else if (type == 'typing') {
        if (data['role'] == 'buyer') {
          setState(() => _isBuyerTyping = data['typing'] == true);
        }
      } else if (type == 'new_message') {
        final msgJson = data['message'] as Map<String, dynamic>;
        final newMsg = LiveChatMessageItem.fromJson(msgJson);

        setState(() {
          _messages.add(newMsg);
          if (newMsg.role == 'buyer') {
            _isBuyerTyping = false;
          }
        });
        _scrollToBottom();

        // Trigger Assist processing for NEW buyer messages only
        if (newMsg.role == 'buyer' &&
            !_processedBuyerMessageIds.contains(newMsg.id)) {
          _processedBuyerMessageIds.add(newMsg.id);
          _startAssistTimeout();
        }
      } else if (type == 'advisory_update') {
        _assistTimeoutTimer?.cancel();
        setState(() {
          _assistData = AssistData.fromPayload(
            data,
            defaultCost: widget.session.costPrice,
            defaultBase: widget.session.basePrice,
            defaultFloor: widget.session.minFloor,
          );
        });
      } else if (type == 'recommendation_upgrade') {
        // Stage 2 AI replies upgraded
        final newReplies = (data['suggested_replies'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (newReplies.isNotEmpty && _assistData != null) {
          setState(() {
            _assistData = AssistData(
              detectedOffer: _assistData!.detectedOffer,
              quantity: _assistData!.quantity,
              unitCost: _assistData!.unitCost,
              basePrice: _assistData!.basePrice,
              minFloor: _assistData!.minFloor,
              unitProfit: _assistData!.unitProfit,
              marginPct: _assistData!.marginPct,
              totalProfit: _assistData!.totalProfit,
              discountVsBase: _assistData!.discountVsBase,
              gapToFloor: _assistData!.gapToFloor,
              status: _assistData!.status,
              severity: _assistData!.severity,
              explanation: _assistData!.explanation,
              action: _assistData!.action,
              counterPrice: _assistData!.counterPrice,
              suggestedReplies: newReplies,
              currentRound: _assistData!.currentRound,
              maxRounds: _assistData!.maxRounds,
              bbi: _assistData!.bbi,
              pHighWtp: _assistData!.pHighWtp,
              firmnessLevel: _assistData!.firmnessLevel,
            );
          });
        }
      } else if (type == 'room_ended') {
        setState(() => _isRoomEnded = true);
      }
    } catch (_) {}
  }

  void _startAssistTimeout() {
    _assistTimeoutTimer?.cancel();
    _assistTimeoutTimer = Timer(_assistTimeout, () {
      if (mounted && _assistData != null) {
        setState(() {
          _assistData = AssistData(
            detectedOffer: _assistData!.detectedOffer,
            quantity: _assistData!.quantity,
            unitCost: _assistData!.unitCost,
            basePrice: _assistData!.basePrice,
            minFloor: _assistData!.minFloor,
            unitProfit: _assistData!.unitProfit,
            marginPct: _assistData!.marginPct,
            totalProfit: _assistData!.totalProfit,
            discountVsBase: _assistData!.discountVsBase,
            gapToFloor: _assistData!.gapToFloor,
            status: _assistData!.status,
            severity: _assistData!.severity,
            explanation: _assistData!.explanation,
            action: _assistData!.action,
            counterPrice: _assistData!.counterPrice,
            suggestedReplies: _assistData!.suggestedReplies,
            currentRound: _assistData!.currentRound,
            maxRounds: _assistData!.maxRounds,
            isTimedOut: true,
          );
        });
      }
    });
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

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty || text.length > 1000 || _isRoomEnded) return;

    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({
        'type': 'chat_message',
        'text': text,
      }));
    }

    _composerController.clear();
  }

  void _showEndMeetingDialog() async {
    final confirmed = await showBkAlertDialog(
      context: context,
      title: 'End Negotiation Room?',
      message:
          'Closing the room will terminate active buyer sockets and lock further messages.',
      confirmLabel: 'END MEETING',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (confirmed == true) {
      _endSession();
    }
  }

  Future<void> _endSession() async {
    final api = ref.read(apiClientProvider);
    try {
      await api.post(
        '/api/v1/peitho/live-chat/${widget.session.sessionId}/end',
        requiresAuth: true,
      );
    } catch (_) {}

    setState(() => _isRoomEnded = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Negotiation room ended.')),
      );
    }
  }

  void _openAssistPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SellerAssistSheet(
        data: _assistData,
        onUseReply: (reply) {
          _composerController.text = reply;
          Navigator.of(context).pop();
        },
        onOverrideOffer: (offer) {
          // Send seller price quote update
          if (_channel != null && _isConnected) {
            _channel!.sink.add(jsonEncode({
              'type': 'chat_message',
              'text': 'I am willing to consider ${CurrencyFormatter.format(offer)}.',
            }));
          }
        },
        onRetry: () {
          Navigator.of(context).pop();
          _startAssistTimeout();
        },
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.productName,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w900,
                color: t.foreground,
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isBuyerOnline ? t.secondary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _isBuyerOnline ? 'Buyer Online' : 'Buyer Offline',
                  style: TextStyle(fontSize: 11, color: t.mutedForeground),
                ),
                if (_isRoomEnded) ...[
                  const SizedBox(width: 8),
                  const BkBadge(
                    label: 'ENDED',
                    variant: BkBadgeVariant.destructive,
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            tooltip: 'PRANE-X Assist',
            onPressed: _openAssistPanel,
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            tooltip: 'End Meeting',
            onPressed: _showEndMeetingDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Assist Bar at top of chat
          InkWell(
            onTap: _openAssistPanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: t.card,
                border: Border(bottom: BorderSide(color: t.border, width: 1.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: t.accent,
                      border: Border.all(color: t.border, width: 1.5),
                    ),
                    child: const Icon(Icons.analytics, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _assistData?.detectedOffer != null
                          ? 'Detected: ${CurrencyFormatter.format(_assistData!.detectedOffer)} • Margin ${_assistData!.marginPct.toStringAsFixed(1)}%'
                          : 'PRANE-X Assist Ready • Tap to view economics',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: t.foreground,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_up, size: 18, color: t.mutedForeground),
                ],
              ),
            ),
          ),

          // Messages Scroll View
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 48, color: t.mutedForeground),
                          const SizedBox(height: 12),
                          Text(
                            'Negotiation room active.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: t.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Share your buyer link or QR code to begin.',
                            style: TextStyle(fontSize: 12, color: t.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, idx) {
                      final m = _messages[idx];
                      final isSeller = m.role == 'seller';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Align(
                          alignment: isSeller ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.78,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSeller ? t.secondary.withAlpha(35) : t.card,
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isSeller ? 'YOU (SELLER)' : 'BUYER',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: isSeller ? t.secondary : t.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.text,
                                  style: const TextStyle(fontSize: 14, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Typing indicator
          if (_isBuyerTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Buyer is typing...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: t.mutedForeground,
                  ),
                ),
              ),
            ),

          // Bottom Composer
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: t.card,
              border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.background,
                      border: Border.all(color: t.border, width: 2),
                    ),
                    child: TextField(
                      controller: _composerController,
                      enabled: !_isRoomEnded,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 1000,
                      buildCounter: (ctx,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      decoration: InputDecoration(
                        hintText: _isRoomEnded
                            ? 'Negotiation room is ended'
                            : 'Type message or counter-offer...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BkButton(
                  size: BkButtonSize.sm,
                  variant: BkButtonVariant.primary,
                  label: 'SEND',
                  leading: const Icon(Icons.send, size: 16),
                  enabled: !_isRoomEnded,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
