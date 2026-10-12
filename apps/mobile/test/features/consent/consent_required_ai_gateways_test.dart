import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/consent/application/consent_required_ai_gateways.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';

void main() {
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: Duration(hours: 9),
    ),
  );
  final message = Message(
    id: 'message-1',
    requestId: 'request-1',
    dayKey: dayKey,
    role: MessageRole.user,
    text: '오늘 산책했어',
    createdAtUtc: DateTime.utc(2026, 10, 4),
    status: MessageStatus.pending,
  );

  test('chat gateway refuses network work before consent', () async {
    final repository = InMemoryAiDataConsentRepository();
    final delegate = _ChatGateway();
    final gateway = ConsentRequiredChatReplyGateway(
      consentRepository: repository,
      delegate: delegate,
    );

    await expectLater(
      gateway.replyTo(message),
      throwsA(isA<AiDataConsentRequiredException>()),
    );

    expect(delegate.callCount, 0);
  });

  test('chat gateway delegates after current consent is accepted', () async {
    final repository = InMemoryAiDataConsentRepository(
      initial: AiDataConsent.accepted(decidedAtUtc: DateTime.utc(2026, 10, 4)),
    );
    final delegate = _ChatGateway();
    final gateway = ConsentRequiredChatReplyGateway(
      consentRepository: repository,
      delegate: delegate,
    );

    final reply = await gateway.replyTo(message);

    expect(reply.messageId, 'assistant-1');
    expect(delegate.callCount, 1);
  });

  test('diary gateway also refuses generation after revocation', () async {
    final repository = InMemoryAiDataConsentRepository(
      initial: AiDataConsent.revoked(decidedAtUtc: DateTime.utc(2026, 10, 4)),
    );
    final delegate = _DiaryGateway();
    final gateway = ConsentRequiredDiaryGenerationGateway(
      consentRepository: repository,
      delegate: delegate,
    );
    final request = DiaryGenerationRequest(
      generationId: 'generation-1',
      responseLocale: AiResponseLocale.ko,
      dayKey: dayKey,
      weather: const WeatherSnapshot.noWeather(),
      persona: AiPersona.safeDefault(),
      messages: [message],
    );

    await expectLater(
      gateway.generate(request),
      throwsA(isA<AiDataConsentRequiredException>()),
    );

    expect(delegate.callCount, 0);
  });
}

final class _ChatGateway implements ChatReplyGateway {
  int callCount = 0;

  @override
  Future<ChatReply> replyTo(Message pendingMessage) async {
    callCount += 1;
    return ChatReply(
      messageId: 'assistant-1',
      text: '좋은 산책이었겠네요.',
      createdAtUtc: DateTime.utc(2026, 10, 4, 0, 0, 1),
    );
  }
}

final class _DiaryGateway implements DiaryGenerationGateway {
  int callCount = 0;

  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) async {
    callCount += 1;
    throw UnimplementedError();
  }
}
