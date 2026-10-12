import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/data/media_file_store_exceptions.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_file_store.dart';

final class NativeMediaFileStore implements MediaFileStore {
  const NativeMediaFileStore(AppStoragePaths storagePaths);

  @override
  String storageKeyFor({
    required String assetId,
    required MediaMimeType mimeType,
  }) {
    throw const MediaFileStoreUnavailableException(
      MediaFileStoreOperation.resolveKey,
    );
  }

  @override
  Future<void> persist({
    required String assetId,
    required String storageKey,
    required String sourceToken,
  }) async {
    throw const MediaFileStoreUnavailableException(
      MediaFileStoreOperation.persist,
    );
  }

  @override
  Future<void> deleteIfExists({
    required String assetId,
    required String storageKey,
  }) async {
    throw const MediaFileStoreUnavailableException(
      MediaFileStoreOperation.delete,
    );
  }
}
