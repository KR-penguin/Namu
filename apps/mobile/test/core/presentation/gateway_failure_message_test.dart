import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/network/gateway_exception.dart';
import 'package:namu/core/presentation/gateway_failure_message.dart';
import 'package:namu/l10n/namu_localizations.dart';

void main() {
  group('gatewayFailureMessage', () {
    final ko = namuLocalizationsFor(const Locale('ko'));
    final typedFailures = <GatewayException, String>{
      const GatewayException.unconfigured(): '연결 설정',
      const GatewayException.unauthorized(401): '연결 인증',
      const GatewayException.invalidAttestation(403): '기기 인증',
      const GatewayException.rateLimited(429): '요청이 잠시 많아요',
      const GatewayException.requestTooLarge(statusCode: 413): '너무 길어',
      const GatewayException.responseTooLarge(): '답변이 너무 길어',
      const GatewayException.idempotencyConflict(409): '안전하게 다시 처리',
      const GatewayException.rejected(400): '처리할 수 없어요',
      const GatewayException.safetyBlocked(422): 'AI 안전 기준',
      const GatewayException.modelTimeout(504): '답변이 늦어져',
      const GatewayException.modelTruncated(502): '완성되지 않아',
      const GatewayException.invalidModelResponse(502): '답변 형식',
      const GatewayException.server(503): '서비스가 잠시 불안정',
      const GatewayException.timeout(): '답변이 늦어져',
      const GatewayException.network(): '네트워크',
      const GatewayException.invalidResponse(): '답변 형식',
    };

    for (final entry in typedFailures.entries) {
      test('${entry.key.category.name} is redacted and actionable', () {
        final chat = gatewayFailureMessage(
          entry.key,
          operation: AiGatewayOperation.chatReply,
          l10n: ko,
        );
        final diary = gatewayFailureMessage(
          entry.key,
          operation: AiGatewayOperation.diaryDraft,
          l10n: ko,
        );

        expect(chat, contains(entry.value));
        expect(diary, contains(entry.value));
        expect(chat, contains('기기에 남아 있어요'));
        expect(diary, contains('기기에 남아 있어요'));
        expect(chat, isNot(contains('${entry.key.statusCode}')));
        expect(diary, isNot(contains('${entry.key.statusCode}')));
        expect(chat, isNot(contains('GatewayException')));
        expect(diary, isNot(contains('GatewayException')));
      });
    }

    test('rate limit rounds an advisory delay up without server details', () {
      const failure = GatewayException.rateLimited(
        429,
        retryAfter: Duration(seconds: 61),
      );

      final message = gatewayFailureMessage(
        failure,
        operation: AiGatewayOperation.chatReply,
        l10n: ko,
      );

      expect(message, contains('약 2분 후'));
      expect(message, isNot(contains('429')));
    });

    test('unknown failures never expose their text', () {
      final message = gatewayFailureMessage(
        StateError('private user content and server body'),
        operation: AiGatewayOperation.diaryDraft,
        l10n: ko,
      );

      expect(message, '일기 초안을 만들지 못했어요. 오늘 기록은 기기에 남아 있어요.');
      expect(message, isNot(contains('private')));
    });

    test('uses the selected locale without exposing the failure text', () {
      final message = gatewayFailureMessage(
        StateError('private user content and server body'),
        operation: AiGatewayOperation.chatReply,
        l10n: namuLocalizationsFor(const Locale('en')),
      );

      expect(
        message,
        'Couldn’t get an AI reply. Your message is still on this device.',
      );
      expect(message, isNot(contains('private')));
    });
  });
}
