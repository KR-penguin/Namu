import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/data/media_file_store_exceptions.dart';
import 'package:namu/features/media/data/native_media_file_store_web.dart'
    as web;
import 'package:namu/features/media/domain/media_asset.dart';

void main() {
  const fileStore = web.NativeMediaFileStore(_UnavailablePaths());

  test(
    'web adapter fails explicitly instead of pretending to persist',
    () async {
      expect(
        () => fileStore.storageKeyFor(
          assetId: 'asset-1',
          mimeType: MediaMimeType.jpeg,
        ),
        throwsA(isA<MediaFileStoreUnavailableException>()),
      );
      await expectLater(
        fileStore.persist(
          assetId: 'asset-1',
          storageKey: 'media/asset-1.jpg',
          sourceToken: '/tmp/photo.jpg',
        ),
        throwsA(isA<MediaFileStoreUnavailableException>()),
      );
      await expectLater(
        fileStore.deleteIfExists(
          assetId: 'asset-1',
          storageKey: 'media/asset-1.jpg',
        ),
        throwsA(isA<MediaFileStoreUnavailableException>()),
      );
    },
  );
}

final class _UnavailablePaths implements AppStoragePaths {
  const _UnavailablePaths();

  @override
  Future<String> appStorageRoot() => throw UnimplementedError();
}
