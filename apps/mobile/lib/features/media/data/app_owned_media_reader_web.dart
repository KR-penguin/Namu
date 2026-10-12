import 'dart:typed_data';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';

final class AppOwnedMediaReader implements MediaBytesReader {
  const AppOwnedMediaReader(
    AppStoragePaths storagePaths, {
    int maxBytes = 30 * 1024 * 1024,
  });

  @override
  Future<Uint8List> read(MediaAsset asset) async {
    throw const MediaBytesReadException(
      MediaBytesReadFailure.unsupportedPlatform,
    );
  }
}
