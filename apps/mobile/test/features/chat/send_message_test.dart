import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/application/send_message.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';

import 'support/fake_chat_reply_gateway.dart';
import 'support/fake_message_repository.dart';

void main() {
  late DiaryDayKey dayKey;
  late FakeMessageRepository repository;

  setUp(() {
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: Duration(hours: 9),
      ),
    );
    repository = FakeMessageRepository();
  });

  test(
    'stores pending before the gateway call, then stores the reply',
    () async {
      late FakeChatReplyGateway gateway;
      gateway = FakeChatReplyGateway(
        onReply: (pendingUserMessage) async {
          final stored = await repository.findUserByRequestId('request-1');
          expect(stored?.status, MessageStatus.pending);
          expect(pendingUserMessage.status, MessageStatus.pending);
          return ChatReply(
            messageId: 'assistant-1',
            text: '산책하며 어떤 기분이 들었어?',
            createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          );
        },
      );
      final sendMessage = SendMessage(
        repository: repository,
        replyGateway: gateway,
      );

      await sendMessage(
        SendMessageCommand(
          messageId: 'user-1',
          requestId: 'request-1',
          dayKey: dayKey,
          text: '오늘은 산책했어',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8),
        ),
      );

      final messages = await repository.listForDay(dayKey);
      expect(messages, hasLength(2));
      expect(messages[0].id, 'user-1');
      expect(messages[0].role, MessageRole.user);
      expect(messages[0].status, MessageStatus.sent);
      expect(messages[1].id, 'assistant-1');
      expect(messages[1].requestId, 'request-1');
      expect(messages[1].dayKey, dayKey);
      expect(messages[1].role, MessageRole.assistant);
      expect(messages[1].status, MessageStatus.sent);
    },
  );

  test('keeps the user message as failed when the gateway fails', () async {
    final gateway = FakeChatReplyGateway(
      onReply: (_) => Future<ChatReply>.error(StateError('offline')),
    );
    final sendMessage = SendMessage(
      repository: repository,
      replyGateway: gateway,
    );

    await expectLater(
      sendMessage(_command(dayKey)),
      throwsA(isA<StateError>()),
    );

    final messages = await repository.listForDay(dayKey);
    expect(messages, hasLength(1));
    expect(messages.single.role, MessageRole.user);
    expect(messages.single.status, MessageStatus.failed);
  });

  test('retrying a request id does not duplicate its user message', () async {
    var attempt = 0;
    final gateway = FakeChatReplyGateway(
      onReply: (_) async {
        attempt += 1;
        if (attempt == 1) {
          throw StateError('offline');
        }
        final stored = await repository.findUserByRequestId('request-1');
        expect(stored?.id, 'user-1');
        expect(stored?.status, MessageStatus.pending);
        return ChatReply(
          messageId: 'assistant-1',
          text: '다시 연결됐어.',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
        );
      },
    );
    final sendMessage = SendMessage(
      repository: repository,
      replyGateway: gateway,
    );

    await expectLater(
      sendMessage(_command(dayKey)),
      throwsA(isA<StateError>()),
    );
    await sendMessage(_command(dayKey));

    final messages = await repository.listForDay(dayKey);
    final userMessages = messages
        .where((message) => message.role == MessageRole.user)
        .toList();
    expect(userMessages, hasLength(1));
    expect(userMessages.single.id, 'user-1');
    expect(userMessages.single.status, MessageStatus.sent);
    expect(gateway.requests, hasLength(2));
  });
}

SendMessageCommand _command(DiaryDayKey dayKey) {
  return SendMessageCommand(
    messageId: 'user-1',
    requestId: 'request-1',
    dayKey: dayKey,
    text: '오늘은 산책했어',
    createdAtUtc: DateTime.utc(2026, 10, 4, 8),
  );
}
