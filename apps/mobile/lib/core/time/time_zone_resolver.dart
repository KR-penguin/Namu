import 'time_zone_snapshot.dart';

enum TimeZoneResolverFailureReason {
  notInitialized,
  invalidIdentifier,
  platformFailure,
  rulesUnavailable,
}

final class TimeZoneResolverException implements Exception {
  const TimeZoneResolverException(this.reason);

  final TimeZoneResolverFailureReason reason;

  @override
  String toString() => 'TimeZoneResolverException(${reason.name})';
}

/// Supplies one stable zone identity and the rules that apply at each instant.
///
/// Callers initialize once before constructing a synchronous diary schedule,
/// then refresh on foreground before deriving a new active day.
abstract interface class TimeZoneResolver {
  Future<void> initialize();

  Future<void> refresh();

  TimeZoneSnapshot snapshotAt(DateTime instantUtc);
}

/// Browser-only review adapter.
///
/// Dart exposes the browser's offset but not a portable, validated IANA rule
/// source. The explicit non-IANA ID prevents transient previews from being
/// mistaken for production day identities.
final class WebPreviewTimeZoneResolver implements TimeZoneResolver {
  static const String previewTimeZoneId = 'namu-web-preview-local-offset';

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> refresh() async {
    _isInitialized = true;
  }

  @override
  TimeZoneSnapshot snapshotAt(DateTime instantUtc) {
    _requireUtc(instantUtc);
    if (!_isInitialized) {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.notInitialized,
      );
    }
    return TimeZoneSnapshot(
      timeZoneId: previewTimeZoneId,
      utcOffset: instantUtc.toLocal().timeZoneOffset,
    );
  }
}

void _requireUtc(DateTime instantUtc) {
  if (!instantUtc.isUtc) {
    throw ArgumentError.value(instantUtc, 'instantUtc', 'must be in UTC');
  }
}
