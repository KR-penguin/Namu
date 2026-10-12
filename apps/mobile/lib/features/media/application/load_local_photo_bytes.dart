import 'dart:typed_data';

import '../domain/media_asset.dart';
import '../domain/media_bytes_reader.dart';
import '../domain/media_repository.dart';

/// Resolves an opaque media identity before crossing the file-storage boundary.
final class LoadLocalPhotoBytes {
  const LoadLocalPhotoBytes({required this.repository, required this.reader});

  final MediaRepository repository;
  final MediaBytesReader reader;

  Future<Uint8List> call(String assetId) async {
    if (assetId.trim().isEmpty) {
      throw ArgumentError.value(assetId, 'assetId', 'must not be blank');
    }

    final asset = await repository.findById(assetId);
    if (asset == null) {
      throw const MediaBytesReadException(MediaBytesReadFailure.missing);
    }
    if (asset.lifecycle != MediaLifecycle.ready) {
      throw const MediaBytesReadException(MediaBytesReadFailure.notReady);
    }

    return reader.read(asset);
  }
}
