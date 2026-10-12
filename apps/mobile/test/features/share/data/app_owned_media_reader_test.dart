import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/data/app_owned_media_reader.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory testDirectory;
  late Directory appRoot;
  late AppOwnedMediaReader reader;

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('namu-reader-test-');
    appRoot = Directory(p.join(testDirectory.path, 'app-root'));
    await appRoot.create(recursive: true);
    reader = AppOwnedMediaReader(_FakeAppStoragePaths(appRoot.path));
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('reads a ready media file below the app-owned root', () async {
    final file = File(p.join(appRoot.path, 'media', 'asset.png'));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(<int>[1, 2, 3, 4], flush: true);

    final bytes = await reader.read(_asset(storageKey: 'media/asset.png'));

    expect(bytes, <int>[1, 2, 3, 4]);
  });

  test('rejects a symlink that resolves outside the app-owned root', () async {
    final outside = File(p.join(testDirectory.path, 'private.png'));
    await outside.writeAsBytes(<int>[9, 8, 7], flush: true);
    final link = Link(p.join(appRoot.path, 'media', 'asset.png'));
    await link.parent.create(recursive: true);
    await link.create(outside.path);

    await expectLater(
      reader.read(_asset(storageKey: 'media/asset.png')),
      throwsA(
        isA<MediaBytesReadException>().having(
          (error) => error.reason,
          'reason',
          MediaBytesReadFailure.unsafePath,
        ),
      ),
    );
  });

  test(
    'rejects missing, non-ready, and unexpectedly oversized files',
    () async {
      await expectLater(
        reader.read(_asset(storageKey: 'media/missing.png')),
        throwsA(
          isA<MediaBytesReadException>().having(
            (error) => error.reason,
            'reason',
            MediaBytesReadFailure.missing,
          ),
        ),
      );

      final file = File(p.join(appRoot.path, 'media', 'asset.png'));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      await expectLater(
        reader.read(
          _asset(
            storageKey: 'media/asset.png',
            lifecycle: MediaLifecycle.staging,
          ),
        ),
        throwsA(
          isA<MediaBytesReadException>().having(
            (error) => error.reason,
            'reason',
            MediaBytesReadFailure.notReady,
          ),
        ),
      );
      await expectLater(
        AppOwnedMediaReader(
          _FakeAppStoragePaths(appRoot.path),
          maxBytes: 3,
        ).read(_asset(storageKey: 'media/asset.png')),
        throwsA(
          isA<MediaBytesReadException>().having(
            (error) => error.reason,
            'reason',
            MediaBytesReadFailure.tooLarge,
          ),
        ),
      );
    },
  );
}

MediaAsset _asset({
  required String storageKey,
  MediaLifecycle lifecycle = MediaLifecycle.ready,
}) {
  return MediaAsset(
    id: 'asset-1',
    dayKey: DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    ),
    storageKey: storageKey,
    mimeType: MediaMimeType.png,
    byteLength: 4,
    createdAtUtc: DateTime.utc(2026, 10, 4),
    lifecycle: lifecycle,
  );
}

final class _FakeAppStoragePaths implements AppStoragePaths {
  const _FakeAppStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
