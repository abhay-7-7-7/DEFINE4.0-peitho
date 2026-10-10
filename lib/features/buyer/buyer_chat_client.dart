import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'buyer_models.dart';

class BuyerChatClient {
  final String baseUrl;
  final String sessionId;
  final String buyerName;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final void Function(BuyerChatMessage message) onMessageReceived;
  final void Function(bool sellerOnline) onPresenceChanged;
  final void Function(bool isEnded) onRoomStatusChanged;
  final void Function(String error) onError;

  BuyerChatClient({
    required this.baseUrl,
    required this.sessionId,
    required this.buyerName,
    required this.onMessageReceived,
    required this.onPresenceChanged,
    required this.onRoomStatusChanged,
    required this.onError,
  });

  Future<BuyerRoomInfo> fetchInitialRoomInfo() async {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanBase/api/v1/peitho/live-chat/$sessionId?role=buyer');
    
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return BuyerRoomInfo.fromJson(json);
    } else if (res.statusCode == 404) {
      throw Exception('Room does not exist or has expired');
    } else {
      throw Exception('Server returned status ${res.statusCode}');
    }
  }

  void connectWebSocket() {
    _disconnect();

    final cleanBase = baseUrl
        .replaceAll(RegExp(r'/+$'), '')
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    final wsUri = Uri.parse('$cleanBase/api/v1/peitho/live-chat/ws/$sessionId?role=buyer');

    try {
      _channel = WebSocketChannel.connect(wsUri);
      _isConnected = true;

      _sub = _channel!.stream.listen(
        (data) {
          _handleRawMessage(data);
        },
        onError: (err) {
          _isConnected = false;
          onError('Connection issue: $err');
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      onError('Failed to open socket: $e');
    }
  }

  void _handleRawMessage(dynamic data) {
    try {
      final json = jsonDecode(data.toString()) as Map<String, dynamic>;
      final type = json['type']?.toString();

      if (type == 'chat_message') {
        final message = BuyerChatMessage.fromJson(json);
        onMessageReceived(message);
      } else if (type == 'presence') {
        final sellerOnline = json['seller_online'] == true;
        onPresenceChanged(sellerOnline);
      } else if (type == 'room_ended' || type == 'session_ended') {
        onRoomStatusChanged(true);
      } else if (type == 'init') {
        final isEnded = json['is_active'] == false;
        if (isEnded) onRoomStatusChanged(true);
        if (json.containsKey('seller_online')) {
          onPresenceChanged(json['seller_online'] == true);
        }
      }
    } catch (_) {
      // Parse error on frame
    }
  }

  bool sendMessage(String text) {
    if (_channel == null || !_isConnected) {
      return false;
    }

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'chat_message',
        'text': text,
        'sender_name': buyerName,
      }));
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _disconnect();
  }

  void _disconnect() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }
}
