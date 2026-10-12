import 'media_asset.dart';

abstract interface class MediaFileStore {
  /// Returns a relative opaque key without creating a file.
  String storageKeyFor({
    required String assetId,
    required MediaMimeType mimeType,
  });

  /// Resolves [sourceToken] inside the platform adapter and atomically commits it.
  Future<void> persist({
    required String assetId,
    required String storageKey,
    required String sourceToken,
  });

  /// Deletes the file if it exists. A missing file is a successful outcome.
  Future<void> deleteIfExists({
    required String assetId,
    required String storageKey,
  });
}
