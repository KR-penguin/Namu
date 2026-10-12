import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/application/chat_controller.dart';
import 'package:namu/features/chat/application/send_message.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';

import 'support/fake_chat_reply_gateway.dart';
import 'support/fake_message_repository.dart';

void main() {
  late DiaryDayKey dayKey;
  late FakeMessageRepository repository;
  late List<String> ids;

  setUp(() {
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    repository = FakeMessageRepository();
    ids = <String>['message-1', 'request-1', 'message-2', 'request-2'];
  });

  ChatController buildController(ChatReplyGateway gateway) {
    return ChatController(
      dayKey: dayKey,
      repository: repository,
      sendMessage: SendMessage(repository: repository, replyGateway: gateway),
      utcNow: () => DateTime.utc(2026, 10, 4, 8),
      nextId: () => ids.removeAt(0),
    );
  }

  test('loads the exact day from the repository', () async {
    await repository.upsert(
      Message(
        id: 'existing',
        requestId: 'existing-request',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '기존 메시지',
        createdAtUtc: DateTime.utc(2026, 10, 4, 7),
        status: MessageStatus.sent,
      ),
    );
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );

    await controller.load();

    expect(controller.isLoading, isFalse);
    expect(controller.messages.single.id, 'existing');
    expect(controller.error, isNull);
  });

  test('switches to a new active day and loads only its messages', () async {
    final nextDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    await repository.upsert(
      Message(
        id: 'today-message',
        requestId: 'today-request',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '오늘 메시지',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8),
        status: MessageStatus.sent,
      ),
    );
    await repository.upsert(
      Message(
        id: 'next-message',
        requestId: 'next-request',
        dayKey: nextDay,
        role: MessageRole.user,
        text: '다음 날 메시지',
        createdAtUtc: DateTime.utc(2026, 10, 5, 8),
        status: MessageStatus.sent,
      ),
    );
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );
    await controller.load();

    await controller.switchDay(nextDay);

    expect(controller.dayKey, nextDay);
    expect(controller.messages.single.id, 'next-message');
  });

  test('an old-day reply cannot replace the new-day conversation', () async {
    final nextDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    final response = Completer<ChatReply>();
    final controller = buildController(
      FakeChatReplyGateway(onReply: (_) => response.future),
    );

    final send = controller.sendText('자정 직전 메시지');
    await Future<void>.delayed(Duration.zero);
    await controller.switchDay(nextDay);
    response.complete(
      ChatReply(
        messageId: 'old-day-assistant',
        text: '이 답은 이전 날짜에 저장돼.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
      ),
    );
    await send;

    expect(controller.dayKey, nextDay);
    expect(controller.messages, isEmpty);
    expect(await repository.listForDay(dayKey), hasLength(2));
  });

  test(
    'load makes an interrupted pending user retryable with the same IDs',
    () async {
      final interrupted = Message(
        id: 'interrupted-user',
        requestId: 'interrupted-request',
        dayKey: dayKey,
        role: MessageRole.user,
        text: '답을 받기 전에 앱이 종료됐어',
        createdAtUtc: DateTime.utc(2026, 10, 4, 7),
        status: MessageStatus.pending,
      );
      await repository.upsert(interrupted);
      var gatewayCalls = 0;
      final gateway = FakeChatReplyGateway(
        onReply: (message) async {
          gatewayCalls += 1;
          return ChatReply(
            messageId: 'assistant-after-retry',
            text: '이제 답할게.',
            createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          );
        },
      );
      final controller = buildController(gateway);

      await controller.load();

      expect(gatewayCalls, 0);
      expect(controller.messages.single.status, MessageStatus.failed);

      await controller.retryFailed(interrupted.id);

      expect(gatewayCalls, 1);
      expect(gateway.requests.single.id, interrupted.id);
      expect(gateway.requests.single.requestId, interrupted.requestId);
      expect(
        controller.messages.where(
          (message) => message.role == MessageRole.user,
        ),
        hasLength(1),
      );
      expect(controller.messages, hasLength(2));
    },
  );

  test(
    'load completes a pending user when its assistant reply was already saved',
    () async {
      const requestId = 'partially-committed-request';
      await repository.upsert(
        Message(
          id: 'partially-committed-user',
          requestId: requestId,
          dayKey: dayKey,
          role: MessageRole.user,
          text: '이 요청은 응답이 이미 있어',
          createdAtUtc: DateTime.utc(2026, 10, 4, 7),
          status: MessageStatus.pending,
        ),
      );
      await repository.upsert(
        Message(
          id: 'already-saved-assistant',
          requestId: requestId,
          dayKey: dayKey,
          role: MessageRole.assistant,
          text: '저장된 답변',
          createdAtUtc: DateTime.utc(2026, 10, 4, 7, 1),
          status: MessageStatus.sent,
        ),
      );
      var gatewayCalls = 0;
      final controller = buildController(
        FakeChatReplyGateway(
          onReply: (_) async {
            gatewayCalls += 1;
            throw StateError('must not be called during recovery');
          },
        ),
      );

      await controller.load();

      expect(gatewayCalls, 0);
      expect(controller.messages, hasLength(2));
      expect(
        controller.messages
            .singleWhere((message) => message.role == MessageRole.user)
            .status,
        MessageStatus.sent,
      );
      expect(
        controller.messages
            .singleWhere((message) => message.role == MessageRole.assistant)
            .text,
        '저장된 답변',
      );
    },
  );

  test('sends nonblank text and reloads user and assistant messages', () async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async => ChatReply(
          messageId: 'assistant-1',
          text: '그 산책에서 가장 기억나는 장면은 뭐야?',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
        ),
      ),
    );

    await controller.sendText('  오늘 산책했어  ');

    expect(controller.isSending, isFalse);
    expect(controller.error, isNull);
    expect(controller.messages, hasLength(2));
    expect(controller.messages.first.text, '오늘 산책했어');
    expect(controller.messages.last.role, MessageRole.assistant);
  });

  test('sends an imported photo asset with an optional caption', () async {
    late FakeChatReplyGateway gateway;
    gateway = FakeChatReplyGateway(
      onReply: (_) async => ChatReply(
        messageId: 'assistant-1',
        text: '사진 속 순간을 남겨둘게.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
      ),
    );
    final controller = buildController(gateway);

    await controller.sendPhoto('photo-1', caption: '산책길');

    expect(gateway.requests.single.photoAssetId, 'photo-1');
    expect(gateway.requests.single.text, '산책길');
    expect(controller.messages, hasLength(2));
  });

  test('rejects a blank photo asset id before allocating IDs', () async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => throw StateError('must not be called'),
      ),
    );

    await expectLater(controller.sendPhoto('   '), throwsArgumentError);

    expect(ids, hasLength(4));
    expect(repository.messages, isEmpty);
  });

  test('keeps a failed local message and exposes a retryable error', () async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) => Future<ChatReply>.error(StateError('offline')),
      ),
    );

    await expectLater(
      controller.sendText('연결이 없어도 이 메시지는 남아야 해'),
      throwsStateError,
    );

    expect(controller.isSending, isFalse);
    expect(controller.error, isA<StateError>());
    expect(controller.messages.single.status, MessageStatus.failed);
  });

  test(
    'ignores blank text without allocating IDs or calling the gateway',
    () async {
      var gatewayCalls = 0;
      final controller = buildController(
        FakeChatReplyGateway(
          onReply: (_) async {
            gatewayCalls += 1;
            throw StateError('must not be called');
          },
        ),
      );

      await controller.sendText('   ');

      expect(gatewayCalls, 0);
      expect(ids, hasLength(4));
      expect(controller.messages, isEmpty);
    },
  );

  test('rejects a concurrent send while one request is in flight', () async {
    final reply = Completer<ChatReply>();
    final controller = buildController(
      FakeChatReplyGateway(onReply: (_) => reply.future),
    );

    final firstSend = controller.sendText('첫 번째');
    await Future<void>.delayed(Duration.zero);

    await expectLater(controller.sendText('두 번째'), throwsStateError);

    reply.complete(
      ChatReply(
        messageId: 'assistant-1',
        text: '첫 번째 답변',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
      ),
    );
    await firstSend;

    expect(controller.messages, hasLength(2));
  });

  test('clears the sending state when refreshing messages fails', () async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async {
          repository.listError = StateError('database read failed');
          return ChatReply(
            messageId: 'assistant-1',
            text: '응답은 저장됐어',
            createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          );
        },
      ),
    );

    await expectLater(controller.sendText('보내기'), throwsStateError);

    expect(controller.isSending, isFalse);
    expect(controller.error, isA<StateError>());
  });

  test(
    'retries a failed message with the original idempotency identity',
    () async {
      var attempt = 0;
      late FakeChatReplyGateway gateway;
      gateway = FakeChatReplyGateway(
        onReply: (_) async {
          attempt += 1;
          if (attempt == 1) {
            throw StateError('offline');
          }
          return ChatReply(
            messageId: 'assistant-1',
            text: '다시 연결됐어.',
            createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
          );
        },
      );
      final controller = buildController(gateway);

      await expectLater(controller.sendText('다시 보내줘'), throwsStateError);
      final failed = controller.messages.single;
      final remainingIdsBeforeRetry = List<String>.from(ids);

      await controller.retryFailed(failed.id);

      expect(gateway.requests, hasLength(2));
      expect(gateway.requests[1].id, failed.id);
      expect(gateway.requests[1].requestId, failed.requestId);
      expect(ids, remainingIdsBeforeRetry);
      expect(controller.messages, hasLength(2));
      expect(controller.messages.first.status, MessageStatus.sent);
    },
  );

  test('rejects retry for a message that is not failed', () async {
    final controller = buildController(
      FakeChatReplyGateway(
        onReply: (_) async => ChatReply(
          messageId: 'assistant-1',
          text: '응답',
          createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
        ),
      ),
    );
    await controller.sendText('성공 메시지');

    await expectLater(
      controller.retryFailed(controller.messages.first.id),
      throwsStateError,
    );
  });
}
