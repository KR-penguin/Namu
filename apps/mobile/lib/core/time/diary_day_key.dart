import 'local_date.dart';
import 'time_zone_snapshot.dart';

final class DiaryDayKey {
  DiaryDayKey._({
    required this.labelDate,
    required this.timeZoneId,
    required this.cutoff,
    required this.policyVersion,
  });

  static const int v1PolicyVersion = 1;
  static const Duration v1Cutoff = Duration.zero;

  factory DiaryDayKey.fromInstant({
    required DateTime instant,
    required TimeZoneSnapshot timeZone,
    Duration cutoff = v1Cutoff,
  }) {
    if (!instant.isUtc) {
      throw ArgumentError.value(instant, 'instant', 'must be in UTC');
    }
    if (cutoff != v1Cutoff) {
      throw ArgumentError.value(
        cutoff,
        'cutoff',
        'policy v1 only supports a 00:00 cutoff',
      );
    }

    final localWallTime = instant.add(timeZone.utcOffset);

    return DiaryDayKey._(
      labelDate: LocalDate(
        localWallTime.year,
        localWallTime.month,
        localWallTime.day,
      ),
      timeZoneId: timeZone.timeZoneId,
      cutoff: cutoff,
      policyVersion: v1PolicyVersion,
    );
  }

  factory DiaryDayKey.restore({
    required LocalDate labelDate,
    required String timeZoneId,
    required Duration cutoff,
    required int policyVersion,
  }) {
    if (timeZoneId.trim().isEmpty) {
      throw ArgumentError.value(timeZoneId, 'timeZoneId', 'must not be empty');
    }
    if (policyVersion != v1PolicyVersion) {
      throw ArgumentError.value(
        policyVersion,
        'policyVersion',
        'only policy version $v1PolicyVersion is supported',
      );
    }
    if (cutoff != v1Cutoff) {
      throw ArgumentError.value(
        cutoff,
        'cutoff',
        'policy v1 only supports a 00:00 cutoff',
      );
    }

    return DiaryDayKey._(
      labelDate: labelDate,
      timeZoneId: timeZoneId,
      cutoff: cutoff,
      policyVersion: policyVersion,
    );
  }

  final LocalDate labelDate;
  final String timeZoneId;
  final Duration cutoff;
  final int policyVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryDayKey &&
          labelDate == other.labelDate &&
          timeZoneId == other.timeZoneId &&
          cutoff == other.cutoff &&
          policyVersion == other.policyVersion;

  @override
  int get hashCode => Object.hash(labelDate, timeZoneId, cutoff, policyVersion);

  @override
  String toString() =>
      'DiaryDayKey('
      'labelDate: $labelDate, '
      'timeZoneId: $timeZoneId, '
      'cutoff: ${_formatCutoff(cutoff)}, '
      'policyVersion: $policyVersion)';

  static String _formatCutoff(Duration cutoff) {
    final hours = cutoff.inHours.toString().padLeft(2, '0');
    final minutes = (cutoff.inMinutes % Duration.minutesPerHour)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes';
  }
}
