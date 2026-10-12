import '../../../core/time/diary_day_key.dart';
import '../../../core/time/time_zone_snapshot.dart';

typedef TimeZoneAtInstant = TimeZoneSnapshot Function(DateTime instantUtc);

abstract interface class DiaryDaySchedule {
  DiaryDayKey dayKeyAt(DateTime instantUtc);

  DateTime nextBoundaryAfter(DateTime instantUtc);
}

/// Resolves the v1 00:00 boundary without assuming every local day is 24 hours.
///
/// [timeZoneAt] is injected because platform timezone rules and tests own the
/// mapping from a UTC instant to its local timezone snapshot.
final class LocalMidnightDiarySchedule implements DiaryDaySchedule {
  const LocalMidnightDiarySchedule({required this.timeZoneAt});

  final TimeZoneAtInstant timeZoneAt;

  @override
  DiaryDayKey dayKeyAt(DateTime instantUtc) {
    _requireUtc(instantUtc);
    return DiaryDayKey.fromInstant(
      instant: instantUtc,
      timeZone: timeZoneAt(instantUtc),
    );
  }

  @override
  DateTime nextBoundaryAfter(DateTime instantUtc) {
    _requireUtc(instantUtc);
    final currentDate = dayKeyAt(instantUtc).labelDate;
    var upper = instantUtc.add(const Duration(hours: 30));
    var expansionCount = 0;
    while (dayKeyAt(upper).labelDate == currentDate) {
      expansionCount += 1;
      if (expansionCount > 3) {
        throw StateError('Could not resolve the next local day boundary.');
      }
      upper = upper.add(const Duration(hours: 24));
    }

    var lowerMicros = instantUtc.microsecondsSinceEpoch;
    var upperMicros = upper.microsecondsSinceEpoch;
    while (upperMicros - lowerMicros > 1) {
      final midpointMicros = lowerMicros + (upperMicros - lowerMicros) ~/ 2;
      final midpoint = DateTime.fromMicrosecondsSinceEpoch(
        midpointMicros,
        isUtc: true,
      );
      if (dayKeyAt(midpoint).labelDate == currentDate) {
        lowerMicros = midpointMicros;
      } else {
        upperMicros = midpointMicros;
      }
    }

    return DateTime.fromMicrosecondsSinceEpoch(upperMicros, isUtc: true);
  }

  static void _requireUtc(DateTime instant) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instantUtc', 'must be in UTC');
    }
  }
}
