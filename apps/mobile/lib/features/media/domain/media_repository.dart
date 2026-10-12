import 'media_asset.dart';

final class MediaRepositoryConflictException implements Exception {
  const MediaRepositoryConflictException();

  @override
  String toString() => 'A media asset with this identity already exists';
}

final class MediaRepositoryNotFoundException implements Exception {
  const MediaRepositoryNotFoundException();

  @override
  String toString() => 'The media asset does not exist';
}

final class MediaAssetIdentityMismatchException implements Exception {
  const MediaAssetIdentityMismatchException();

  @override
  String toString() => 'Persisted media identity fields cannot change';
}

final class InvalidMediaLifecycleTransitionException implements Exception {
  const InvalidMediaLifecycleTransitionException();

  @override
  String toString() => 'The media lifecycle transition is not allowed';
}

abstract interface class MediaRepository {
  /// Inserts [asset]. An existing ID is a conflict, not an upsert.
  Future<void> insert(MediaAsset asset);

  /// Replaces an existing asset while preserving its identity.
  Future<void> update(MediaAsset asset);

  Future<MediaAsset?> findById(String assetId);

  /// Removes metadata if present. Implementations must make this idempotent.
  Future<void> removeById(String assetId);
}

bool hasSameMediaAssetIdentity(MediaAsset existing, MediaAsset replacement) {
  return existing.id == replacement.id &&
      existing.dayKey == replacement.dayKey &&
      existing.storageKey == replacement.storageKey &&
      existing.mimeType == replacement.mimeType &&
      existing.byteLength == replacement.byteLength &&
      existing.createdAtUtc == replacement.createdAtUtc;
}

bool isAllowedMediaLifecycleTransition(MediaLifecycle from, MediaLifecycle to) {
  if (from == to) {
    return true;
  }
  return switch (from) {
    MediaLifecycle.staging =>
      to == MediaLifecycle.ready ||
          to == MediaLifecycle.deleting ||
          to == MediaLifecycle.missing,
    MediaLifecycle.ready =>
      to == MediaLifecycle.deleting || to == MediaLifecycle.missing,
    MediaLifecycle.missing => to == MediaLifecycle.deleting,
    MediaLifecycle.deleting => false,
  };
}
