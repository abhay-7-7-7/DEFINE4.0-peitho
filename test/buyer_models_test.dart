import 'package:flutter_test/flutter_test.dart';
import 'package:boldkit_flutter/features/buyer/buyer_models.dart';

void main() {
  group('Buyer Models and Confidentiality Tests', () {
    test('BuyerRoomInfo correctly parses public JSON and rejects confidential leaks', () {
      final json = {
        'session_id': 'sess-123',
        'product_name': 'Mechanical Keyboard',
        'base_price': 120.0,
        'quantity': 2,
        'is_active': true,
        'seller_online': true,
        'messages': [
          {
            'id': 'm1',
            'sender': 'system',
            'sender_name': 'System',
            'text': 'Welcome to negotiation',
            'timestamp': 1712700000.0,
          },
          {
            'id': 'm2',
            'sender': 'buyer',
            'sender_name': 'Buyer',
            'text': 'Can you do 95?',
            'timestamp': 1712700010.0,
          }
        ]
      };

      final room = BuyerRoomInfo.fromJson(json);
      expect(room.sessionId, 'sess-123');
      expect(room.productName, 'Mechanical Keyboard');
      expect(room.basePrice, 120.0);
      expect(room.quantity, 2);
      expect(room.isActive, true);
      expect(room.sellerOnline, true);
      expect(room.initialMessages.length, 2);
      expect(room.initialMessages[1].isBuyer, true);
      expect(room.initialMessages[1].isSeller, false);
      expect(room.initialMessages[1].isSystem, false);
    });

    test('BuyerChatMessage models sender distinctions accurately', () {
      final buyerMsg = BuyerChatMessage(
        id: '1',
        sender: 'buyer',
        senderName: 'Buyer',
        text: 'Offer 100',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1000000),
      );
      final sellerMsg = BuyerChatMessage(
        id: '2',
        sender: 'seller',
        senderName: 'Seller',
        text: 'Counter 110',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1001000),
      );
      final sysMsg = BuyerChatMessage(
        id: '3',
        sender: 'system',
        senderName: 'System',
        text: 'Session ended',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1002000),
      );

      expect(buyerMsg.isBuyer, isTrue);
      expect(buyerMsg.isSeller, isFalse);
      expect(buyerMsg.displayName, 'Buyer');

      expect(sellerMsg.isSeller, isTrue);
      expect(sellerMsg.isBuyer, isFalse);
      expect(sellerMsg.displayName, 'Seller');

      expect(sysMsg.isSystem, isTrue);
      expect(sysMsg.displayName, 'System');
    });

    test('BuyerRoomInfo handles fallback defaults gracefully', () {
      final minimalJson = {
        'session_id': 'sess-min',
      };
      final room = BuyerRoomInfo.fromJson(minimalJson);
      expect(room.sessionId, 'sess-min');
      expect(room.productName, 'Product');
      expect(room.basePrice, 0.0);
      expect(room.quantity, 1);
      expect(room.isActive, true);
      expect(room.sellerOnline, false);
      expect(room.initialMessages, isEmpty);
    });
  });
}
