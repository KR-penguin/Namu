import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';

void main() {
  final seoul = TimeZoneSnapshot(
    timeZoneId: 'Asia/Seoul',
    utcOffset: const Duration(hours: 9),
  );

  group('DiaryDayKey.fromInstant', () {
    test('uses the Seoul midnight boundary', () {
      final beforeMidnight = DiaryDayKey.fromInstant(
        instant: DateTime.parse('2026-10-03T14:59:59Z'),
        timeZone: seoul,
      );
      final atMidnight = DiaryDayKey.fromInstant(
        instant: DateTime.parse('2026-10-03T15:00:00Z'),
        timeZone: seoul,
      );

      expect(beforeMidnight.labelDate, LocalDate(2026, 10, 3));
      expect(atMidnight.labelDate, LocalDate(2026, 10, 4));
    });

    test('keeps the timezone ID as part of the key identity', () {
      final instant = DateTime.parse('2026-10-03T15:00:00Z');
      final seoulKey = DiaryDayKey.fromInstant(
        instant: instant,
        timeZone: seoul,
      );
      final fixedOffsetKey = DiaryDayKey.fromInstant(
        instant: instant,
        timeZone: TimeZoneSnapshot(
          timeZoneId: 'Etc/GMT-9',
          utcOffset: const Duration(hours: 9),
        ),
      );

      expect(fixedOffsetKey.labelDate, seoulKey.labelDate);
      expect(fixedOffsetKey, isNot(seoulKey));
    });

    test('rejects a non-UTC instant', () {
      expect(
        () => DiaryDayKey.fromInstant(
          instant: DateTime(2026, 10, 4),
          timeZone: seoul,
        ),
        throwsArgumentError,
      );
    });

    test('rejects a non-zero cutoff for policy v1', () {
      expect(
        () => DiaryDayKey.fromInstant(
          instant: DateTime.parse('2026-10-03T15:00:00Z'),
          timeZone: seoul,
          cutoff: const Duration(hours: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  test('equality, hashCode, and toString use all key fields', () {
    final first = DiaryDayKey.fromInstant(
      instant: DateTime.parse('2026-10-03T15:00:00Z'),
      timeZone: seoul,
    );
    final second = DiaryDayKey.fromInstant(
      instant: DateTime.parse('2026-10-03T15:00:00Z'),
      timeZone: seoul,
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(
      first.toString(),
      'DiaryDayKey('
      'labelDate: 2026-10-04, '
      'timeZoneId: Asia/Seoul, '
      'cutoff: 00:00, '
      'policyVersion: 1)',
    );
  });

  group('DiaryDayKey.restore', () {
    test('restores the exact persisted key identity', () {
      final original = DiaryDayKey.fromInstant(
        instant: DateTime.parse('2026-10-03T15:00:00Z'),
        timeZone: seoul,
      );

      final restored = DiaryDayKey.restore(
        labelDate: original.labelDate,
        timeZoneId: original.timeZoneId,
        cutoff: original.cutoff,
        policyVersion: original.policyVersion,
      );

      expect(restored, original);
    });

    test('rejects unsupported persisted policy data', () {
      expect(
        () => DiaryDayKey.restore(
          labelDate: LocalDate(2026, 10, 4),
          timeZoneId: ' ',
          cutoff: Duration.zero,
          policyVersion: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => DiaryDayKey.restore(
          labelDate: LocalDate(2026, 10, 4),
          timeZoneId: 'Asia/Seoul',
          cutoff: const Duration(hours: 1),
          policyVersion: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => DiaryDayKey.restore(
          labelDate: LocalDate(2026, 10, 4),
          timeZoneId: 'Asia/Seoul',
          cutoff: Duration.zero,
          policyVersion: 2,
        ),
        throwsArgumentError,
      );
    });
  });
}
