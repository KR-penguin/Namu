import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/time_zone_resolver.dart';

void main() {
  test(
    'web preview fallback is explicit and never claims an IANA ID',
    () async {
      final resolver = WebPreviewTimeZoneResolver();
      final instant = DateTime.utc(2026, 10, 4, 12);

      expect(
        () => resolver.snapshotAt(instant),
        throwsA(
          isA<TimeZoneResolverException>().having(
            (error) => error.reason,
            'reason',
            TimeZoneResolverFailureReason.notInitialized,
          ),
        ),
      );

      await resolver.initialize();
      await resolver.refresh();
      final snapshot = resolver.snapshotAt(instant);

      expect(snapshot.timeZoneId, WebPreviewTimeZoneResolver.previewTimeZoneId);
      expect(snapshot.timeZoneId, contains('preview'));
      expect(snapshot.utcOffset, instant.toLocal().timeZoneOffset);
    },
  );

  test('web preview fallback also rejects non-UTC instants', () async {
    final resolver = WebPreviewTimeZoneResolver();
    await resolver.initialize();

    expect(
      () => resolver.snapshotAt(DateTime(2026, 10, 4)),
      throwsArgumentError,
    );
  });
}
