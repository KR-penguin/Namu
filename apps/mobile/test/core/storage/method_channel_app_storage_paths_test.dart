import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/core/storage/method_channel_app_storage_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('namu/storage.test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('returns the absolute root supplied by the native host', () async {
    late MethodCall receivedCall;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedCall = call;
      return '/private/app-storage';
    });
    final paths = MethodChannelAppStoragePaths.withChannel(channel);

    final root = await paths.appStorageRoot();

    expect(root, '/private/app-storage');
    expect(receivedCall.method, MethodChannelAppStoragePaths.rootMethod);
    expect(receivedCall.arguments, isNull);
  });

  test('rejects null, blank, and relative native paths', () async {
    for (final value in <Object?>[null, '', 'relative/storage']) {
      messenger.setMockMethodCallHandler(channel, (_) async => value);
      final paths = MethodChannelAppStoragePaths.withChannel(channel);

      await expectLater(
        paths.appStorageRoot(),
        throwsA(
          isA<AppStorageUnavailableException>().having(
            (error) => error.reason,
            'reason',
            AppStorageUnavailableReason.invalidRoot,
          ),
        ),
      );
    }
  });

  test(
    'maps native channel failures without exposing native details',
    () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) => throw PlatformException(
          code: 'storage_unavailable',
          message: '/private/sensitive/path',
        ),
      );
      final paths = MethodChannelAppStoragePaths.withChannel(channel);

      await expectLater(
        paths.appStorageRoot(),
        throwsA(
          isA<AppStorageUnavailableException>()
              .having(
                (error) => error.reason,
                'reason',
                AppStorageUnavailableReason.platformFailure,
              )
              .having(
                (error) => error.toString(),
                'redacted message',
                isNot(contains('/private/sensitive/path')),
              ),
        ),
      );
    },
  );

  test('web fallback is explicitly unavailable', () async {
    const paths = UnavailableAppStoragePaths();

    await expectLater(
      paths.appStorageRoot(),
      throwsA(
        isA<AppStorageUnavailableException>().having(
          (error) => error.reason,
          'reason',
          AppStorageUnavailableReason.unsupportedPlatform,
        ),
      ),
    );
  });
}
