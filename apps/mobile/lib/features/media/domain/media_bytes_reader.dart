import 'dart:typed_data';

import 'media_asset.dart';

enum MediaBytesReadFailure {
  unsupportedPlatform,
  invalidRoot,
  unsafePath,
  notReady,
  missing,
  tooLarge,
  lengthMismatch,
  unreadable,
}

final class MediaBytesReadException implements Exception {
  const MediaBytesReadException(this.reason);

  final MediaBytesReadFailure reason;

  @override
  String toString() => 'Media bytes are unavailable (${reason.name})';
}

/// Reads original image bytes from app-owned storage.
///
/// Storage keys remain opaque outside the adapter. Consumers must decode the
/// returned image and must not copy these bytes directly into an export.
abstract interface class MediaBytesReader {
  Future<Uint8List> read(MediaAsset asset);
}
