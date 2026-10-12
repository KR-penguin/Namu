enum MediaFileStoreOperation { resolveKey, persist, delete }

final class MediaFileStoreUnavailableException implements Exception {
  const MediaFileStoreUnavailableException(this.operation);

  final MediaFileStoreOperation operation;

  @override
  String toString() =>
      'Persistent media storage is unavailable (${operation.name})';
}

final class UnsafeMediaStorageKeyException implements Exception {
  const UnsafeMediaStorageKeyException();

  @override
  String toString() => 'The media storage key is not safe for this asset';
}

final class InvalidMediaSourceException implements Exception {
  const InvalidMediaSourceException();

  @override
  String toString() => 'The selected media source is unavailable';
}

final class InvalidAppStorageRootException implements Exception {
  const InvalidAppStorageRootException();

  @override
  String toString() => 'The app storage root is invalid';
}
