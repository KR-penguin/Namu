import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/message.dart';

import 'support/fake_message_repository.dart';

void main() {
  test('listForDay returns only the exact key in UTC order', () async {
    final repository = FakeMessageRepository();
    final instant = DateTime.utc(2026, 10, 4, 8);
    final seoulDay = DiaryDayKey.fromInstant(
      instant: instant,
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: Duration(hours: 9),
      ),
    );
    final utcDayWithSameLabel = DiaryDayKey.fromInstant(
      instant: instant,
      timeZone: TimeZoneSnapshot(timeZoneId: 'UTC', utcOffset: Duration.zero),
    );
    final nextSeoulDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 5, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: Duration(hours: 9),
      ),
    );

    await repository.upsert(
      _message(
        id: 'later',
        dayKey: seoulDay,
        createdAtUtc: DateTime.utc(2026, 10, 4, 9),
      ),
    );
    await repository.upsert(
      _message(
        id: 'same-label-other-zone',
        dayKey: utcDayWithSameLabel,
        createdAtUtc: DateTime.utc(2026, 10, 4, 7),
      ),
    );
    await repository.upsert(
      _message(
        id: 'earlier',
        dayKey: seoulDay,
        createdAtUtc: DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await repository.upsert(
      _message(
        id: 'other-day',
        dayKey: nextSeoulDay,
        createdAtUtc: DateTime.utc(2026, 10, 5, 8),
      ),
    );

    final messages = await repository.listForDay(seoulDay);

    expect(messages.map((message) => message.id), <String>['earlier', 'later']);
  });

  test(
    'listDayKeysOldestFirst returns unique complete day identities',
    () async {
      final repository = FakeMessageRepository();
      final older = DiaryDayKey.restore(
        labelDate: LocalDate(2026, 10, 3),
        timeZoneId: 'Asia/Seoul',
        cutoff: Duration.zero,
        policyVersion: DiaryDayKey.v1PolicyVersion,
      );
      final newerSeoul = DiaryDayKey.restore(
        labelDate: LocalDate(2026, 10, 4),
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
      await repository.upsert(
        _message(
          id: 'newer-2',
          dayKey: newerUtc,
          createdAtUtc: DateTime.utc(2026, 10, 4),
        ),
      );
      await repository.upsert(
        _message(
          id: 'older',
          dayKey: older,
          createdAtUtc: DateTime.utc(2026, 10, 3),
        ),
      );
      await repository.upsert(
        _message(
          id: 'newer-1',
          dayKey: newerSeoul,
          createdAtUtc: DateTime.utc(2026, 10, 4),
        ),
      );
      await repository.upsert(
        _message(
          id: 'older-duplicate',
          dayKey: older,
          createdAtUtc: DateTime.utc(2026, 10, 3, 1),
        ),
      );

      expect(await repository.listDayKeysOldestFirst(), <DiaryDayKey>[
        older,
        newerSeoul,
        newerUtc,
      ]);
    },
  );

  test('interrupted-send recovery fails unanswered pending users and completes answered ones', () async {
    final repository = FakeMessageRepository();
    final dayKey = DiaryDayKey.restore(
      labelDate: LocalDate(2026, 10, 4),
      timeZoneId: 'Asia/Seoul',
      cutoff: Duration.zero,
      policyVersion: DiaryDayKey.v1PolicyVersion,
    );
    final unanswered = Message(
      id: 'unanswered-user',
      requestId: 'unanswered-request',
      dayKey: dayKey,
      role: MessageRole.user,
      text: '아직 답이 없어',
      createdAtUtc: DateTime.utc(2026, 10, 4, 1),
      status: MessageStatus.pending,
    );
    final answered = Message(
      id: 'answered-user',
      requestId: 'answered-request',
      dayKey: dayKey,
      role: MessageRole.user,
      text: '답이 저장됐어',
      createdAtUtc: DateTime.utc(2026, 10, 4, 2),
      status: MessageStatus.pending,
    );
    await repository.upsert(unanswered);
    await repository.upsert(answered);
    await repository.upsert(
      Message(
        id: 'answered-assistant',
        requestId: answered.requestId,
        dayKey: dayKey,
        role: MessageRole.assistant,
        text: '이미 저장된 답',
        createdAtUtc: DateTime.utc(2026, 10, 4, 2, 1),
        status: MessageStatus.sent,
      ),
    );

    await repository.recoverInterruptedSendsForDay(dayKey);

    final messages = await repository.listForDay(dayKey);
    expect(
      messages.singleWhere((message) => message.id == unanswered.id).status,
      MessageStatus.failed,
    );
    expect(
      messages.singleWhere((message) => message.id == answered.id).status,
      MessageStatus.sent,
    );
    expect(
      messages.singleWhere((message) => message.id == unanswered.id).requestId,
      unanswered.requestId,
    );
  });
}

Message _message({
  required String id,
  required DiaryDayKey dayKey,
  required DateTime createdAtUtc,
}) {
  return Message(
    id: id,
    requestId: 'request-$id',
    dayKey: dayKey,
    role: MessageRole.user,
    text: id,
    createdAtUtc: createdAtUtc,
    status: MessageStatus.sent,
  );
}
