import 'dart:io';
import 'dart:typed_data';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';
import 'package:path/path.dart' as p;

final class AppOwnedMediaReader implements MediaBytesReader {
  const AppOwnedMediaReader(
    this._storagePaths, {
    this.maxBytes = 30 * 1024 * 1024,
  }) : assert(maxBytes > 0);

  final AppStoragePaths _storagePaths;
  final int maxBytes;

  @override
  Future<Uint8List> read(MediaAsset asset) async {
    if (asset.lifecycle != MediaLifecycle.ready) {
      throw const MediaBytesReadException(MediaBytesReadFailure.notReady);
    }

    try {
      final rootPath = await _storagePaths.appStorageRoot();
      if (rootPath.trim().isEmpty || !p.isAbsolute(rootPath)) {
        throw const MediaBytesReadException(MediaBytesReadFailure.invalidRoot);
      }

      final root = Directory(p.normalize(rootPath));
      if (!await root.exists()) {
        throw const MediaBytesReadException(MediaBytesReadFailure.invalidRoot);
      }
      final canonicalRoot = p.normalize(await root.resolveSymbolicLinks());
      final candidate = p.normalize(
        p.joinAll(<String>[root.path, ...p.posix.split(asset.storageKey)]),
      );
      if (!p.isWithin(p.normalize(root.absolute.path), candidate)) {
        throw const MediaBytesReadException(MediaBytesReadFailure.unsafePath);
      }

      if (await FileSystemEntity.type(candidate, followLinks: true) !=
          FileSystemEntityType.file) {
        throw const MediaBytesReadException(MediaBytesReadFailure.missing);
      }
      final canonicalFile = p.normalize(
        await File(candidate).resolveSymbolicLinks(),
      );
      if (!p.isWithin(canonicalRoot, canonicalFile)) {
        throw const MediaBytesReadException(MediaBytesReadFailure.unsafePath);
      }

      final file = File(canonicalFile);
      final length = await file.length();
      if (length > maxBytes) {
        throw const MediaBytesReadException(MediaBytesReadFailure.tooLarge);
      }
      if (length != asset.byteLength) {
        throw const MediaBytesReadException(
          MediaBytesReadFailure.lengthMismatch,
        );
      }
      final bytes = await file.readAsBytes();
      if (bytes.length != length) {
        throw const MediaBytesReadException(
          MediaBytesReadFailure.lengthMismatch,
        );
      }
      return bytes;
    } on MediaBytesReadException {
      rethrow;
    } on AppStorageUnavailableException {
      throw const MediaBytesReadException(MediaBytesReadFailure.invalidRoot);
    } on FileSystemException {
      throw const MediaBytesReadException(MediaBytesReadFailure.unreadable);
    }
  }
}
