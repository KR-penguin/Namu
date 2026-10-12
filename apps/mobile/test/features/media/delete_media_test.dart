import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/application/delete_media.dart';
import 'package:namu/features/media/domain/media_asset.dart';

import 'support/fake_media_file_store.dart';
import 'support/fake_media_repository.dart';

void main() {
  late FakeMediaRepository repository;
  late FakeMediaFileStore fileStore;
  late DeleteMedia deleteMedia;
  late List<String> trace;

  setUp(() {
    trace = <String>[];
    repository = FakeMediaRepository(trace: trace);
    fileStore = FakeMediaFileStore(trace: trace);
    deleteMedia = DeleteMedia(repository: repository, fileStore: fileStore);
  });

  test('marks deleting before deleting the file and metadata', () async {
    repository.assets['asset-1'] = _readyAsset();
    fileStore.storedKeys.add('media/asset-1.jpg');

    await deleteMedia('asset-1');

    expect(repository.assets, isEmpty);
    expect(fileStore.storedKeys, isEmpty);
    expect(repository.events, ['update:deleting', 'remove:asset-1']);
    expect(fileStore.events, ['delete:asset-1:media/asset-1.jpg']);
    expect(trace, [
      'repository:update:deleting',
      'fileStore:delete:asset-1:media/asset-1.jpg',
      'repository:remove:asset-1',
    ]);
  });

  test(
    'retries safely after the file was deleted but row removal failed',
    () async {
      repository.assets['asset-1'] = _readyAsset();
      repository.removeFailuresRemaining = 1;
      fileStore.storedKeys.add('media/asset-1.jpg');

      await expectLater(deleteMedia('asset-1'), throwsA(isA<StateError>()));

      expect(repository.assets['asset-1']?.lifecycle, MediaLifecycle.deleting);
      expect(fileStore.storedKeys, isEmpty);

      await deleteMedia('asset-1');
      await deleteMedia('asset-1');

      expect(repository.assets, isEmpty);
      expect(fileStore.events, [
        'delete:asset-1:media/asset-1.jpg',
        'delete:asset-1:media/asset-1.jpg',
      ]);
      expect(repository.events, [
        'update:deleting',
        'remove:asset-1',
        'remove:asset-1',
      ]);
    },
  );

  test('leaves deleting metadata when file deletion fails', () async {
    repository.assets['asset-1'] = _readyAsset();
    fileStore.storedKeys.add('media/asset-1.jpg');
    fileStore.deleteError = StateError('delete failed');

    await expectLater(deleteMedia('asset-1'), throwsA(isA<StateError>()));

    expect(repository.assets['asset-1']?.lifecycle, MediaLifecycle.deleting);
    expect(fileStore.storedKeys, {'media/asset-1.jpg'});
    expect(repository.events, ['update:deleting']);
  });
}

MediaAsset _readyAsset() {
  return MediaAsset(
    id: 'asset-1',
    dayKey: DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 9),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    ),
    storageKey: 'media/asset-1.jpg',
    mimeType: MediaMimeType.jpeg,
    byteLength: 1024,
    createdAtUtc: DateTime.utc(2026, 10, 4, 9),
    lifecycle: MediaLifecycle.ready,
  );
}
