import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/application/import_photo.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/domain/media_asset.dart';

import 'support/fake_media_file_store.dart';
import 'support/fake_media_repository.dart';

void main() {
  late FakeMediaRepository repository;
  late FakeMediaFileStore fileStore;
  late ImportPhoto importPhoto;
  late List<String> trace;

  setUp(() {
    trace = <String>[];
    repository = FakeMediaRepository(trace: trace);
    fileStore = FakeMediaFileStore(trace: trace);
    importPhoto = ImportPhoto(repository: repository, fileStore: fileStore);
  });

  test('stages metadata before persisting and then marks it ready', () async {
    final dayKey = _dayKey();
    final asset = await importPhoto(
      ImportPhotoCommand(
        assetId: 'asset-1',
        dayKey: dayKey,
        selection: const PhotoImportSelection(
          token: 'picker-token-1',
          mimeType: 'image/jpeg',
          byteLength: 1024,
        ),
        createdAtUtc: DateTime.utc(2026, 10, 4, 9),
      ),
    );

    expect(asset.id, 'asset-1');
    expect(asset.dayKey, same(dayKey));
    expect(asset.mimeType, MediaMimeType.jpeg);
    expect(asset.storageKey, 'media/asset-1.jpg');
    expect(asset.lifecycle, MediaLifecycle.ready);
    expect(repository.assets['asset-1']?.lifecycle, MediaLifecycle.ready);
    expect(fileStore.storedKeys, {'media/asset-1.jpg'});
    expect(repository.events, ['insert:staging', 'update:ready']);
    expect(fileStore.events, [
      'key:asset-1:jpeg',
      'persist:asset-1:media/asset-1.jpg:picker-token-1',
    ]);
    expect(trace, [
      'fileStore:key:asset-1:jpeg',
      'repository:insert:staging',
      'fileStore:persist:asset-1:media/asset-1.jpg:picker-token-1',
      'repository:update:ready',
    ]);
  });

  test('rejects an unsupported MIME type before side effects', () async {
    await expectLater(
      importPhoto(
        _command(
          selection: const PhotoImportSelection(
            token: 'picker-token-1',
            mimeType: 'image/gif',
            byteLength: 1024,
          ),
        ),
      ),
      throwsA(isA<UnsupportedMediaMimeTypeException>()),
    );

    expect(repository.events, isEmpty);
    expect(fileStore.events, isEmpty);
  });

  test('rejects zero and oversized files before side effects', () async {
    for (final byteLength in <int>[0, ImportPhoto.defaultMaxByteLength + 1]) {
      await expectLater(
        importPhoto(
          _command(
            selection: PhotoImportSelection(
              token: 'picker-token-1',
              mimeType: 'image/png',
              byteLength: byteLength,
            ),
          ),
        ),
        throwsA(isA<InvalidMediaSizeException>()),
      );
    }

    expect(repository.events, isEmpty);
    expect(fileStore.events, isEmpty);
  });

  test('removes staging metadata when file persistence fails', () async {
    fileStore.persistError = StateError('copy failed');

    await expectLater(importPhoto(_command()), throwsA(isA<StateError>()));

    expect(repository.assets, isEmpty);
    expect(repository.events, ['insert:staging', 'remove:asset-1']);
    expect(fileStore.storedKeys, isEmpty);
  });

  test(
    'removes the stored file and staging row if ready update fails',
    () async {
      repository.failReadyUpdate = true;

      await expectLater(importPhoto(_command()), throwsA(isA<StateError>()));

      expect(repository.assets, isEmpty);
      expect(fileStore.storedKeys, isEmpty);
      expect(repository.events, [
        'insert:staging',
        'update:ready',
        'remove:asset-1',
      ]);
      expect(fileStore.events.last, 'delete:asset-1:media/asset-1.jpg');
      expect(trace, [
        'fileStore:key:asset-1:jpeg',
        'repository:insert:staging',
        'fileStore:persist:asset-1:media/asset-1.jpg:picker-token-1',
        'repository:update:ready',
        'fileStore:delete:asset-1:media/asset-1.jpg',
        'repository:remove:asset-1',
      ]);
    },
  );

  test('keeps staging metadata when rollback cannot delete the file', () async {
    repository.failReadyUpdate = true;
    fileStore.deleteError = StateError('delete failed');

    await expectLater(
      importPhoto(_command()),
      throwsA(isA<PhotoImportRollbackException>()),
    );

    expect(repository.assets['asset-1']?.lifecycle, MediaLifecycle.staging);
    expect(fileStore.storedKeys, {'media/asset-1.jpg'});
    expect(repository.events, ['insert:staging', 'update:ready']);
  });
}

ImportPhotoCommand _command({PhotoImportSelection? selection}) {
  return ImportPhotoCommand(
    assetId: 'asset-1',
    dayKey: _dayKey(),
    selection:
        selection ??
        const PhotoImportSelection(
          token: 'picker-token-1',
          mimeType: 'image/jpeg',
          byteLength: 1024,
        ),
    createdAtUtc: DateTime.utc(2026, 10, 4, 9),
  );
}

DiaryDayKey _dayKey() {
  return DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 9),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );
}
