import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/network/gateway_config.dart';

void main() {
  group('GatewayConfig', () {
    test('builds versioned endpoints from an explicit HTTPS origin', () {
      final config = GatewayConfig(
        baseUri: Uri.parse('https://gateway.example.com'),
      );

      expect(config.isConfigured, isTrue);
      expect(
        config.chatReplyUri,
        Uri.parse('https://gateway.example.com/v1/chat/reply'),
      );
      expect(
        config.diaryGenerateUri,
        Uri.parse('https://gateway.example.com/v1/diary/generate'),
      );
    });

    test('does not guess a gateway when the compile-time value is absent', () {
      final config = GatewayConfig.fromEnvironment();

      expect(config.isConfigured, isFalse);
      expect(config.chatReplyUri, isNull);
      expect(config.diaryGenerateUri, isNull);
    });

    test('rejects insecure remote origins', () {
      expect(
        () => GatewayConfig(baseUri: Uri.parse('http://gateway.example.com')),
        throwsArgumentError,
      );
    });

    test('allows loopback HTTP only through the explicit development flag', () {
      final loopback = Uri.parse('http://127.0.0.1:8080');

      expect(() => GatewayConfig(baseUri: loopback), throwsArgumentError);

      final config = GatewayConfig(
        baseUri: loopback,
        allowInsecureLoopback: true,
      );
      expect(
        config.chatReplyUri,
        Uri.parse('http://127.0.0.1:8080/v1/chat/reply'),
      );
    });

    test('accepts localhost and IPv6 loopback for explicit development', () {
      for (final uri in <Uri>[
        Uri.parse('http://localhost:8080'),
        Uri.parse('http://[::1]:8080'),
      ]) {
        expect(
          GatewayConfig(baseUri: uri, allowInsecureLoopback: true).isConfigured,
          isTrue,
        );
      }
    });

    test('rejects ambiguous base URLs', () {
      for (final uri in <Uri>[
        Uri.parse('https://user@gateway.example.com'),
        Uri.parse('https://gateway.example.com/base'),
        Uri.parse('https://gateway.example.com?region=test'),
        Uri.parse('https://gateway.example.com#fragment'),
      ]) {
        expect(() => GatewayConfig(baseUri: uri), throwsArgumentError);
      }
    });
  });
}
