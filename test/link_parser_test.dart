import 'package:flutter_test/flutter_test.dart';
import 'package:boldkit_flutter/core/utils/link_parser.dart';

void main() {
  group('LinkParser Unit Tests (at least 15 comprehensive cases)', () {
    test('1. Bare standard UUID token', () {
      const token = '40c5fce0-49c0-424b-b0b3-1fcfbf05a3e1';
      final result = LinkParser.parse(token);
      expect(result.isValid, isTrue);
      expect(result.token, equals(token));
    });

    test('2. Bare short alphanumeric code', () {
      const token = 'ROOM882';
      final result = LinkParser.parse(token);
      expect(result.isValid, isTrue);
      expect(result.token, equals(token));
    });

    test('3. Full HTTP web URL with /buyer-chat/', () {
      const url =
          'http://192.168.1.15:5173/buyer-chat/40c5fce0-49c0-424b-b0b3-1fcfbf05a3e1';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('40c5fce0-49c0-424b-b0b3-1fcfbf05a3e1'));
    });

    test('4. Full HTTPS URL with /join/ and trailing slash', () {
      const url = 'https://trademind.ai/join/session-alpha-99/';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('session-alpha-99'));
    });

    test('5. URL with query parameters and tracking tags', () {
      const url =
          'http://localhost:8000/buyer/deal-42?source=qr&utm_campaign=winter';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('deal-42'));
    });

    test('6. URL using query parameter ?token=...', () {
      const url = 'https://trademind.app/connect?token=QUERY_TOKEN_123';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('QUERY_TOKEN_123'));
    });

    test('7. URL with URL fragment/hash #section', () {
      const url = 'http://10.0.2.2:8000/live-chat/ROOM_HASH_99#chat-feed';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('ROOM_HASH_99'));
    });

    test('8. Custom URI scheme trademind://join/<token>', () {
      const uri = 'trademind://join/CUSTOM_SCHEME_XYZ';
      final result = LinkParser.parse(uri);
      expect(result.isValid, isTrue);
      expect(result.token, equals('CUSTOM_SCHEME_XYZ'));
    });

    test('9. Custom URI scheme with query trademind://join?token=<token>', () {
      const uri = 'trademind://join?token=QUERY_SCHEME_456';
      final result = LinkParser.parse(uri);
      expect(result.isValid, isTrue);
      expect(result.token, equals('QUERY_SCHEME_456'));
    });

    test('10. Custom URI scheme peitho://buyer-chat/<token>', () {
      const uri = 'peitho://buyer-chat/PEITHO_TOKEN_888';
      final result = LinkParser.parse(uri);
      expect(result.isValid, isTrue);
      expect(result.token, equals('PEITHO_TOKEN_888'));
    });

    test('11. Input surrounded by leading/trailing whitespace, tabs, and newlines', () {
      const raw = '   \n\t  TOKEN_SPACED_123   \r\n ';
      final result = LinkParser.parse(raw);
      expect(result.isValid, isTrue);
      expect(result.token, equals('TOKEN_SPACED_123'));
    });

    test('12. Preserves mixed case sensitivity (e.g. Base64-like tokens)', () {
      const token = 'aBcDeFgH1234';
      final result = LinkParser.parse(token);
      expect(result.isValid, isTrue);
      expect(result.token, equals('aBcDeFgH1234'));
    });

    test('13. Relative path string "/join/TOKEN-900/" with leading and trailing slashes', () {
      const raw = '/join/TOKEN-900/';
      final result = LinkParser.parse(raw);
      expect(result.isValid, isTrue);
      expect(result.token, equals('TOKEN-900'));
    });

    test('14. Tunnel URL (e.g. cloudflared or ngrok subdomain)', () {
      const url =
          'https://silent-falcon-99.trycloudflare.com/buyer-chat/TUNNEL_ROOM_101';
      final result = LinkParser.parse(url);
      expect(result.isValid, isTrue);
      expect(result.token, equals('TUNNEL_ROOM_101'));
    });

    test('15. Rejects empty string', () {
      final result = LinkParser.parse('');
      expect(result.isValid, isFalse);
      expect(result.error, contains('cannot be empty'));
    });

    test('16. Rejects whitespace-only string', () {
      final result = LinkParser.parse('   \t\n   ');
      expect(result.isValid, isFalse);
      expect(result.error, contains('cannot be empty'));
    });

    test('17. Rejects malformed random URL without path or token', () {
      final result = LinkParser.parse('https://google.com');
      expect(result.isValid, isFalse);
      expect(result.error, contains('does not contain'));
    });

    test('18. Rejects garbage special characters', () {
      final result = LinkParser.parse('!@#\$%^&*()');
      expect(result.isValid, isFalse);
      expect(result.error, contains('Invalid link or token'));
    });

    test('19. Rejects null input gracefully', () {
      final result = LinkParser.parse(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Input is null'));
    });

    test('20. Rejects tokens that are too short (< 3 chars)', () {
      final result = LinkParser.parse('ab');
      expect(result.isValid, isFalse);
    });
  });
}
