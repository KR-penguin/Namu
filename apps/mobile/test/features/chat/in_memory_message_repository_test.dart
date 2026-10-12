import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/chat/domain/message.dart';

void main() {
  late InMemoryMessageRepository repository;
  late DiaryDayKey seoulDay;

  setUp(() {
    repository = InMemoryMessageRepository();
    seoulDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
  });

  test('upserts the same id and finds the user by request id', () async {
    final pending = _message(
      id: 'user-1',
      requestId: 'request-1',
      dayKey: seoulDay,
      status: MessageStatus.pending,
    );

    await repository.upsert(pending);
    await repository.upsert(pending.withStatus(MessageStatus.failed));

    final stored = await repository.findUserByRequestId('request-1');
    expect(stored?.id, 'user-1');
    expect(stored?.status, MessageStatus.failed);
    expect(await repository.listForDay(seoulDay), hasLength(1));
  });

  test('rejects a second message for the same request and role', () async {
    await repository.upsert(
      _message(id: 'user-1', requestId: 'request-1', dayKey: seoulDay),
    );

    await expectLater(
      repository.upsert(
        _message(id: 'user-2', requestId: 'request-1', dayKey: seoulDay),
      ),
      throwsStateError,
    );
  });

  test('allows one user and one assistant for the same request', () async {
    await repository.upsert(
      _message(id: 'user-1', requestId: 'request-1', dayKey: seoulDay),
    );
    await repository.upsert(
      _message(
        id: 'assistant-1',
        requestId: 'request-1',
        dayKey: seoulDay,
        role: MessageRole.assistant,
      ),
    );

    expect(await repository.listForDay(seoulDay), hasLength(2));
  });

  test('filters by the exact day identity and sorts by UTC then id', () async {
    final sameLabelUtcKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(timeZoneId: 'UTC', utcOffset: Duration.zero),
    );
    await repository.upsert(
      _message(
        id: 'b',
        requestId: 'request-b',
        dayKey: seoulDay,
        createdAtUtc: DateTime.utc(2026, 10, 4, 9),
      ),
    );
    await repository.upsert(
      _message(
        id: 'a',
        requestId: 'request-a',
        dayKey: seoulDay,
        createdAtUtc: DateTime.utc(2026, 10, 4, 9),
      ),
    );
    await repository.upsert(
      _message(
        id: 'other',
        requestId: 'request-other',
        dayKey: sameLabelUtcKey,
      ),
    );

    final result = await repository.listForDay(seoulDay);

    expect(result.map((message) => message.id), ['a', 'b']);
  });

  test('lists unique day keys oldest first', () async {
    final older = DiaryDayKey.restore(
      labelDate: LocalDate(2026, 10, 3),
      timeZoneId: 'Asia/Seoul',
      cutoff: Duration.zero,
      policyVersion: DiaryDayKey.v1PolicyVersion,
    );
    await repository.upsert(
      _message(id: 'newer', requestId: 'request-newer', dayKey: seoulDay),
    );
    await repository.upsert(
      _message(id: 'older-b', requestId: 'request-older-b', dayKey: older),
    );
    await repository.upsert(
      _message(id: 'older-a', requestId: 'request-older-a', dayKey: older),
    );

    expect(await repository.listDayKeysOldestFirst(), [older, seoulDay]);
  });

  test(
    'recovers pending users without changing their persisted identity',
    () async {
      final interrupted = _message(
        id: 'user-interrupted',
        requestId: 'request-interrupted',
        dayKey: seoulDay,
        status: MessageStatus.pending,
      );
      final completedUser = _message(
        id: 'user-completed',
        requestId: 'request-completed',
        dayKey: seoulDay,
        status: MessageStatus.pending,
      );
      final completedAssistant = _message(
        id: 'assistant-completed',
        requestId: 'request-completed',
        dayKey: seoulDay,
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

      await repository.recoverInterruptedSendsForDay(seoulDay);
      await repository.recoverInterruptedSendsForDay(seoulDay);

      final recovered = await repository.listForDay(seoulDay);
      final recoveredInterrupted = recovered.singleWhere(
        (message) => message.id == interrupted.id,
      );
      final recoveredCompleted = recovered.singleWhere(
        (message) => message.id == completedUser.id,
      );
      expect(recoveredInterrupted.status, MessageStatus.failed);
      expect(recoveredInterrupted.requestId, interrupted.requestId);
      expect(recoveredInterrupted.text, interrupted.text);
      expect(recoveredInterrupted.createdAtUtc, interrupted.createdAtUtc);
      expect(recoveredCompleted.status, MessageStatus.sent);
      expect(
        recovered.singleWhere(
          (message) => message.role == MessageRole.assistant,
        ),
        same(completedAssistant),
      );
      expect(
        (await repository.listForDay(otherDay)).single.status,
        MessageStatus.pending,
      );
    },
  );
}

Message _message({
  required String id,
  required String requestId,
  required DiaryDayKey dayKey,
  MessageRole role = MessageRole.user,
  MessageStatus status = MessageStatus.sent,
  DateTime? createdAtUtc,
}) {
  return Message(
    id: id,
    requestId: requestId,
    dayKey: dayKey,
    role: role,
    text: id,
    createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4, 8),
    status: status,
  );
}
