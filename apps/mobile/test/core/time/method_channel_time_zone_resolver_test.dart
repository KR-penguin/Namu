import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/method_channel_time_zone_resolver.dart';
import 'package:namu/core/time/time_zone_resolver.dart';
import 'package:namu/features/diary/application/daily_close_schedule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('namu/time_zone.test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'initialize loads a stable IANA identifier from the native host',
    () async {
      late MethodCall receivedCall;
      messenger.setMockMethodCallHandler(channel, (call) async {
        receivedCall = call;
        return 'Asia/Seoul';
      });
      final resolver = MethodChannelTimeZoneResolver.withChannel(channel);

      await resolver.initialize();
      final snapshot = resolver.snapshotAt(DateTime.utc(2026, 10, 4));

      expect(receivedCall.method, MethodChannelTimeZoneResolver.idMethod);
      expect(receivedCall.arguments, isNull);
      expect(snapshot.timeZoneId, 'Asia/Seoul');
      expect(snapshot.utcOffset, const Duration(hours: 9));
    },
  );

  test(
    'refresh replaces the zone and keeps instant-specific DST rules',
    () async {
      var nativeId = 'Asia/Seoul';
      messenger.setMockMethodCallHandler(channel, (_) async => nativeId);
      final resolver = MethodChannelTimeZoneResolver.withChannel(channel);
      await resolver.initialize();

      nativeId = 'America/New_York';
      await resolver.refresh();

      expect(
        resolver.snapshotAt(DateTime.utc(2026, 1, 15)).timeZoneId,
        'America/New_York',
      );
      expect(
        resolver.snapshotAt(DateTime.utc(2026, 1, 15)).utcOffset,
        const Duration(hours: -5),
      );
      expect(
        resolver.snapshotAt(DateTime.utc(2026, 7, 15)).utcOffset,
        const Duration(hours: -4),
      );
    },
  );

  test('snapshotAt plugs into the local-midnight schedule', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => 'America/New_York',
    );
    final resolver = MethodChannelTimeZoneResolver.withChannel(channel);
    await resolver.initialize();
    final schedule = LocalMidnightDiarySchedule(
      timeZoneAt: resolver.snapshotAt,
    );

    final boundary = schedule.nextBoundaryAfter(DateTime.utc(2026, 3, 8, 5));

    expect(boundary, DateTime.utc(2026, 3, 9, 4));
  });

  test('snapshotAt requires initialization and a UTC instant', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => 'Asia/Seoul');
    final resolver = MethodChannelTimeZoneResolver.withChannel(channel);

    expect(
      () => resolver.snapshotAt(DateTime.utc(2026, 10, 4)),
      throwsA(
        isA<TimeZoneResolverException>().having(
          (error) => error.reason,
          'reason',
          TimeZoneResolverFailureReason.notInitialized,
        ),
      ),
    );

    await resolver.initialize();

    expect(
      () => resolver.snapshotAt(DateTime(2026, 10, 4)),
      throwsArgumentError,
    );
  });

  test('rejects invalid and unknown native channel results', () async {
    for (final value in <Object?>[
      null,
      9,
      '',
      '   ',
      'Not/A_Real_Zone',
      'GMT+09:00',
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => value);
      final resolver = MethodChannelTimeZoneResolver.withChannel(channel);

      await expectLater(
        resolver.initialize(),
        throwsA(
          isA<TimeZoneResolverException>().having(
            (error) => error.reason,
            'reason',
            TimeZoneResolverFailureReason.invalidIdentifier,
          ),
        ),
        reason: 'channel result $value must not become a persisted zone ID',
      );
    }
  });

  test('maps platform failures without exposing native details', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) => throw PlatformException(
        code: 'time_zone_unavailable',
        message: 'private native diagnostic',
      ),
    );
    final resolver = MethodChannelTimeZoneResolver.withChannel(channel);

    await expectLater(
      resolver.initialize(),
      throwsA(
        isA<TimeZoneResolverException>()
            .having(
              (error) => error.reason,
              'reason',
              TimeZoneResolverFailureReason.platformFailure,
            )
            .having(
              (error) => error.toString(),
              'redacted message',
              isNot(contains('private native diagnostic')),
            ),
      ),
    );
  });

  test('maps a missing native channel to a typed platform failure', () async {
    const missingChannel = MethodChannel('namu/time_zone.missing');
    final resolver = MethodChannelTimeZoneResolver.withChannel(missingChannel);

    await expectLater(
      resolver.initialize(),
      throwsA(
        isA<TimeZoneResolverException>().having(
          (error) => error.reason,
          'reason',
          TimeZoneResolverFailureReason.platformFailure,
        ),
      ),
    );
  });

  test('a failed refresh preserves the last valid timezone snapshot', () async {
    Object? nativeResult = 'Asia/Seoul';
    messenger.setMockMethodCallHandler(channel, (_) async => nativeResult);
    final resolver = MethodChannelTimeZoneResolver.withChannel(channel);
    await resolver.initialize();

    nativeResult = 'Unknown/Zone';
    await expectLater(
      resolver.refresh(),
      throwsA(isA<TimeZoneResolverException>()),
    );

    final snapshot = resolver.snapshotAt(DateTime.utc(2026, 10, 4));
    expect(snapshot.timeZoneId, 'Asia/Seoul');
    expect(snapshot.utcOffset, const Duration(hours: 9));
  });

  test('concurrent initialization shares one native lookup', () async {
    final result = Completer<String>();
    var callCount = 0;
    messenger.setMockMethodCallHandler(channel, (_) {
      callCount += 1;
      return result.future;
    });
    final resolver = MethodChannelTimeZoneResolver.withChannel(channel);

    final first = resolver.initialize();
    final second = resolver.initialize();
    result.complete('Asia/Seoul');
    await Future.wait(<Future<void>>[first, second]);

    expect(callCount, 1);
  });
}
