import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_file_store.dart';
import 'package:namu/features/media/domain/media_repository.dart';

final class ImportPhotoCommand {
  const ImportPhotoCommand({
    required this.assetId,
    required this.dayKey,
    required this.selection,
    required this.createdAtUtc,
  });

  final String assetId;
  final DiaryDayKey dayKey;
  final PhotoImportSelection selection;
  final DateTime createdAtUtc;
}

final class UnsupportedMediaMimeTypeException implements Exception {
  const UnsupportedMediaMimeTypeException(this.mimeType);

  final String mimeType;

  @override
  String toString() => 'Unsupported media MIME type: $mimeType';
}

final class InvalidMediaSizeException implements Exception {
  const InvalidMediaSizeException({
    required this.byteLength,
    required this.maxByteLength,
  });

  final int byteLength;
  final int maxByteLength;

  @override
  String toString() =>
      'Invalid media size: $byteLength bytes (maximum $maxByteLength)';
}

final class InvalidPhotoSourceException implements Exception {
  const InvalidPhotoSourceException();

  @override
  String toString() => 'Photo source token must not be blank';
}

final class PhotoImportRollbackException implements Exception {
  const PhotoImportRollbackException({
    required this.cause,
    required this.cleanupFailure,
  });

  final Object cause;
  final Object cleanupFailure;

  @override
  String toString() =>
      'Photo import failed and rollback was incomplete: $cleanupFailure';
}

final class ImportPhoto {
  const ImportPhoto({
    required this.repository,
    required this.fileStore,
    this.maxByteLength = defaultMaxByteLength,
  }) : assert(maxByteLength > 0);

  static const int defaultMaxByteLength = 20 * 1024 * 1024;

  final MediaRepository repository;
  final MediaFileStore fileStore;
  final int maxByteLength;

  Future<MediaAsset> call(ImportPhotoCommand command) async {
    final selection = command.selection;
    final mimeType = MediaMimeType.tryParse(selection.mimeType);
    if (mimeType == null) {
      throw UnsupportedMediaMimeTypeException(selection.mimeType);
    }
    if (selection.byteLength <= 0 || selection.byteLength > maxByteLength) {
      throw InvalidMediaSizeException(
        byteLength: selection.byteLength,
        maxByteLength: maxByteLength,
      );
    }
    if (selection.token.trim().isEmpty) {
      throw const InvalidPhotoSourceException();
    }

    final storageKey = fileStore.storageKeyFor(
      assetId: command.assetId,
      mimeType: mimeType,
    );
    final stagingAsset = MediaAsset(
      id: command.assetId,
      dayKey: command.dayKey,
      storageKey: storageKey,
      mimeType: mimeType,
      byteLength: selection.byteLength,
      createdAtUtc: command.createdAtUtc,
      lifecycle: MediaLifecycle.staging,
    );
    await repository.insert(stagingAsset);

    try {
      await fileStore.persist(
        assetId: stagingAsset.id,
        storageKey: stagingAsset.storageKey,
        sourceToken: selection.token,
      );
    } catch (error, stackTrace) {
      await _rollback(
        cause: error,
        asset: stagingAsset,
        deleteStoredFile: false,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }

    final readyAsset = stagingAsset.withLifecycle(MediaLifecycle.ready);
    try {
      await repository.update(readyAsset);
    } catch (error, stackTrace) {
      await _rollback(
        cause: error,
        asset: stagingAsset,
        deleteStoredFile: true,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
    return readyAsset;
  }

  Future<void> _rollback({
    required Object cause,
    required MediaAsset asset,
    required bool deleteStoredFile,
  }) async {
    if (deleteStoredFile) {
      try {
        await fileStore.deleteIfExists(
          assetId: asset.id,
          storageKey: asset.storageKey,
        );
      } catch (error) {
        // Keep the staging row so a startup reconciler can still locate and
        // retry deleting a possibly committed file.
        throw PhotoImportRollbackException(cause: cause, cleanupFailure: error);
      }
    }

    try {
      await repository.removeById(asset.id);
    } catch (error) {
      throw PhotoImportRollbackException(cause: cause, cleanupFailure: error);
    }
  }
}
