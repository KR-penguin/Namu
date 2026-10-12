import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/chat/data/drift_message_repository.dart';
import 'package:namu/features/chat/domain/message.dart';

void main() {
  late AppDatabase database;
  late DriftMessageRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftMessageRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftMessageRepository', () {
    test('round-trips every message field', () async {
      final message = _message(
        id: 'message-1',
        requestId: 'request-1',
        text: '산책했어',
        photoAssetId: 'photo-1',
        createdAtUtc: DateTime.utc(2026, 10, 4, 1, 2, 3, 456, 789),
        status: MessageStatus.failed,
      );

      await repository.upsert(message);

      expect(await repository.listForDay(message.dayKey), [
        isA<Message>()
            .having((value) => value.id, 'id', message.id)
            .having((value) => value.requestId, 'requestId', message.requestId)
            .having((value) => value.dayKey, 'dayKey', message.dayKey)
            .having((value) => value.role, 'role', message.role)
            .having((value) => value.text, 'text', message.text)
            .having(
              (value) => value.photoAssetId,
              'photoAssetId',
              message.photoAssetId,
            )
            .having(
              (value) => value.createdAtUtc,
              'createdAtUtc',
              message.createdAtUtc,
            )
            .having((value) => value.status, 'status', message.status),
      ]);
    });

    test(
      'matches the complete day identity and orders by UTC then id',
      () async {
        final seoul = _dayKey(timeZoneId: 'Asia/Seoul');
        final tokyo = _dayKey(timeZoneId: 'Asia/Tokyo');
        final instant = DateTime.utc(2026, 10, 4, 1);

        await repository.upsert(
          _message(
            id: 'message-b',
            requestId: 'request-b',
            dayKey: seoul,
            createdAtUtc: instant,
          ),
        );
        await repository.upsert(
          _message(
            id: 'message-a',
            requestId: 'request-a',
            dayKey: seoul,
            createdAtUtc: instant,
          ),
        );
        await repository.upsert(
          _message(
            id: 'message-before',
            requestId: 'request-before',
            dayKey: seoul,
            createdAtUtc: instant.subtract(const Duration(microseconds: 1)),
          ),
        );
        await repository.upsert(
          _message(
            id: 'message-other-zone',
            requestId: 'request-other-zone',
            dayKey: tokyo,
            createdAtUtc: instant,
          ),
        );

        final messages = await repository.listForDay(seoul);

        expect(messages.map((message) => message.id), [
          'message-before',
          'message-a',
          'message-b',
        ]);
      },
    );

    test('findUserByRequestId returns only the user message', () async {
      final user = _message(id: 'user', requestId: 'same-request');
      final assistant = _message(
        id: 'assistant',
        requestId: 'same-request',
        role: MessageRole.assistant,
      );
      await repository.upsert(user);
      await repository.upsert(assistant);

      final found = await repository.findUserByRequestId('same-request');

      expect(found?.id, 'user');
      expect(await repository.findUserByRequestId('missing'), isNull);
    });

    test('same id is updated without creating a duplicate', () async {
      final pending = _message(id: 'message-1', requestId: 'request-1');
      await repository.upsert(pending);

      await repository.upsert(pending.withStatus(MessageStatus.sent));

      final messages = await repository.listForDay(pending.dayKey);
      expect(messages, hasLength(1));
      expect(messages.single.status, MessageStatus.sent);
    });

    test(
      'same request and role is atomically replaced by the upsert',
      () async {
        final original = _message(id: 'old-id', requestId: 'request-1');
        final replacement = _message(
          id: 'new-id',
          requestId: 'request-1',
          text: '수정된 내용',
        );
        await repository.upsert(original);

        await repository.upsert(replacement);

        final messages = await repository.listForDay(original.dayKey);
        expect(messages, hasLength(1));
        expect(messages.single.id, 'new-id');
        expect(messages.single.text, '수정된 내용');
      },
    );

    test('lists only unique day identities oldest first', () async {
      final older = DiaryDayKey.restore(
        labelDate: LocalDate(2026, 10, 3),
        timeZoneId: 'Asia/Seoul',
        cutoff: Duration.zero,
        policyVersion: DiaryDayKey.v1PolicyVersion,
      );
      final newerUtc = DiaryDayKey.restore(
        labelDate: LocalDate(2026, 10, 4),
        timeZoneId: 'UTC',
        cutoff: Duration.zero,
        policyVersion: DiaryDayKey.v1PolicyVersion,
      );
      final newerSeoul = _dayKey();
      await repository.upsert(
        _message(id: 'newer-utc', requestId: 'newer-utc', dayKey: newerUtc),
      );
      await repository.upsert(
        _message(id: 'older-a', requestId: 'older-a', dayKey: older),
      );
      await repository.upsert(
        _message(
          id: 'newer-seoul',
          requestId: 'newer-seoul',
          dayKey: newerSeoul,
        ),
      );
      await repository.upsert(
        _message(id: 'older-b', requestId: 'older-b', dayKey: older),
      );

      expect(await repository.listDayKeysOldestFirst(), [
        older,
        newerSeoul,
        newerUtc,
      ]);
    });

    test(
      'atomically reconciles interrupted pending sends and is idempotent',
      () async {
        final interrupted = _message(
          id: 'user-interrupted',
          requestId: 'request-interrupted',
          text: '앱이 종료되기 전 남은 메시지',
          photoAssetId: 'photo-interrupted',
          createdAtUtc: DateTime.utc(2026, 10, 4, 1, 2, 3),
          status: MessageStatus.pending,
        );
        final completedUser = _message(
          id: 'user-completed',
          requestId: 'request-completed',
          status: MessageStatus.pending,
        );
        final completedAssistant = _message(
          id: 'assistant-completed',
          requestId: 'request-completed',
          role: MessageRole.assistant,
          status: MessageStatus.sent,
        );
        final otherDay = DiaryDayKey.restore(
          labelDate: LocalDate(2026, 10, 5),
          timeZoneId: 'Asia/Seoul',
          cutoff: Duration.zero,
          policyVersion: DiaryDayKey.v1PolicyVersion,
        );
        final untouched = _message(
          id: 'user-other-day',
          requestId: 'request-other-day',
          dayKey: otherDay,
          status: MessageStatus.pending,
        );
        await repository.upsert(interrupted);
        await repository.upsert(completedUser);
        await repository.upsert(completedAssistant);
        await repository.upsert(untouched);

        await repository.recoverInterruptedSendsForDay(interrupted.dayKey);
        await repository.recoverInterruptedSendsForDay(interrupted.dayKey);

        final recovered = await repository.listForDay(interrupted.dayKey);
        final recoveredInterrupted = recovered.singleWhere(
          (message) => message.id == interrupted.id,
        );
        final recoveredCompleted = recovered.singleWhere(
          (message) => message.id == completedUser.id,
        );
        expect(recoveredInterrupted.status, MessageStatus.failed);
        expect(recoveredInterrupted.requestId, interrupted.requestId);
        expect(recoveredInterrupted.text, interrupted.text);
        expect(recoveredInterrupted.photoAssetId, interrupted.photoAssetId);
        expect(recoveredInterrupted.createdAtUtc, interrupted.createdAtUtc);
        expect(recoveredCompleted.status, MessageStatus.sent);
        expect(
          recovered
              .singleWhere((message) => message.id == completedAssistant.id)
              .status,
          MessageStatus.sent,
        );
        expect(
          (await repository.listForDay(otherDay)).single.status,
          MessageStatus.pending,
        );
      },
    );
  });

  test('messages survive closing and reopening a file database', () async {
    await database.close();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'namu-message-repository-',
    );
    final file = File('${temporaryDirectory.path}/messages.sqlite');

    try {
      var fileDatabase = AppDatabase(NativeDatabase(file));
      var fileRepository = DriftMessageRepository(fileDatabase);
      final message = _message(id: 'persisted', requestId: 'persisted-request');
      await fileRepository.upsert(message);
      await fileDatabase.close();

      fileDatabase = AppDatabase(NativeDatabase(file));
      fileRepository = DriftMessageRepository(fileDatabase);
      final restored = await fileRepository.listForDay(message.dayKey);

      expect(restored.map((value) => value.id), ['persisted']);
      await fileDatabase.close();
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }

    database = AppDatabase(NativeDatabase.memory());
  });
}

DiaryDayKey _dayKey({String timeZoneId = 'Asia/Seoul'}) {
  return DiaryDayKey.restore(
    labelDate: LocalDate(2026, 10, 4),
    timeZoneId: timeZoneId,
    cutoff: Duration.zero,
    policyVersion: DiaryDayKey.v1PolicyVersion,
  );
}

Message _message({
  required String id,
  required String requestId,
  DiaryDayKey? dayKey,
  MessageRole role = MessageRole.user,
  String? text = '오늘 이야기',
  String? photoAssetId,
  DateTime? createdAtUtc,
  MessageStatus status = MessageStatus.pending,
}) {
  return Message(
    id: id,
    requestId: requestId,
    dayKey: dayKey ?? _dayKey(),
    role: role,
    text: text,
    photoAssetId: photoAssetId,
    createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4),
    status: status,
  );
}
