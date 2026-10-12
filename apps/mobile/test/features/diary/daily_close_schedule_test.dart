import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/application/daily_close_schedule.dart';

void main() {
  final schedule = LocalMidnightDiarySchedule(
    timeZoneAt: (_) => TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );

  test('23:59:59.999 schedules the close exactly one millisecond later', () {
    final now = DateTime.utc(2026, 10, 4, 14, 59, 59, 999);

    final boundary = schedule.nextBoundaryAfter(now);

    expect(boundary, DateTime.utc(2026, 10, 4, 15));
    expect(boundary.difference(now), const Duration(milliseconds: 1));
    expect(schedule.dayKeyAt(now).labelDate, LocalDate(2026, 10, 4));
  });

  test('00:00 belongs to the new day and schedules the following midnight', () {
    final now = DateTime.utc(2026, 10, 4, 15);

    final boundary = schedule.nextBoundaryAfter(now);

    expect(schedule.dayKeyAt(now).labelDate, LocalDate(2026, 10, 5));
    expect(boundary, DateTime.utc(2026, 10, 5, 15));
    expect(boundary.difference(now), const Duration(days: 1));
  });

  test('spring DST day schedules its next midnight 23 hours later', () {
    final newYorkSchedule = LocalMidnightDiarySchedule(
      timeZoneAt: _newYorkTimeZoneAt,
    );
    final midnightBeforeJump = DateTime.utc(2026, 3, 8, 5);

    final boundary = newYorkSchedule.nextBoundaryAfter(midnightBeforeJump);

    expect(boundary, DateTime.utc(2026, 3, 9, 4));
    expect(boundary.difference(midnightBeforeJump), const Duration(hours: 23));
  });

  test('fall DST day schedules its next midnight 25 hours later', () {
    final newYorkSchedule = LocalMidnightDiarySchedule(
      timeZoneAt: _newYorkTimeZoneAt,
    );
    final midnightBeforeRepeat = DateTime.utc(2026, 11, 1, 4);

    final boundary = newYorkSchedule.nextBoundaryAfter(midnightBeforeRepeat);

    expect(boundary, DateTime.utc(2026, 11, 2, 5));
    expect(
      boundary.difference(midnightBeforeRepeat),
      const Duration(hours: 25),
    );
  });

  test(
    'rejects a clock or timezone resolver that returns a non-UTC instant',
    () {
      expect(
        () => schedule.dayKeyAt(DateTime(2026, 10, 4)),
        throwsArgumentError,
      );
      expect(
        () => schedule.nextBoundaryAfter(DateTime(2026, 10, 4)),
        throwsArgumentError,
      );
    },
  );
}

TimeZoneSnapshot _newYorkTimeZoneAt(DateTime instantUtc) {
  final daylightStarts = DateTime.utc(2026, 3, 8, 7);
  final daylightEnds = DateTime.utc(2026, 11, 1, 6);
  final daylight =
      !instantUtc.isBefore(daylightStarts) && instantUtc.isBefore(daylightEnds);
  return TimeZoneSnapshot(
    timeZoneId: 'America/New_York',
    utcOffset: Duration(hours: daylight ? -4 : -5),
  );
}
