final class TimeZoneSnapshot {
  TimeZoneSnapshot({required this.timeZoneId, required this.utcOffset}) {
    if (timeZoneId.trim().isEmpty) {
      throw ArgumentError.value(timeZoneId, 'timeZoneId', 'must not be empty');
    }
  }

  final String timeZoneId;
  final Duration utcOffset;
}
