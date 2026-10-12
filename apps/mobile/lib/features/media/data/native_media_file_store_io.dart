import 'dart:convert';
import 'dart:io';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/data/media_file_store_exceptions.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_file_store.dart';
import 'package:path/path.dart' as p;

final class NativeMediaFileStore implements MediaFileStore {
  const NativeMediaFileStore(this._storagePaths);

  final AppStoragePaths _storagePaths;

  @override
  String storageKeyFor({
    required String assetId,
    required MediaMimeType mimeType,
  }) {
    final encodedId = _encodedAssetId(assetId);
    return 'media/$encodedId.${_extensionFor(mimeType)}';
  }

  @override
  Future<void> persist({
    required String assetId,
    required String storageKey,
    required String sourceToken,
  }) async {
    _validateStorageKey(assetId: assetId, storageKey: storageKey);
    final root = await _appRoot();
    final target = _fileFor(root, storageKey);

    // A committed target means a previous attempt reached the atomic rename.
    if (await target.exists()) {
      return;
    }

    final source = _sourceFile(sourceToken);
    if (!await source.exists()) {
      throw const InvalidMediaSourceException();
    }

    final stagingDirectory = Directory(p.join(root.path, '.staging'));
    await stagingDirectory.create(recursive: true);
    await target.parent.create(recursive: true);
    final staging = File(
      p.join(stagingDirectory.path, '${p.basename(storageKey)}.part'),
    );
    if (await staging.exists()) {
      await staging.delete();
    }

    try {
      final sink = staging.openWrite(mode: FileMode.writeOnly);
      try {
        await sink.addStream(source.openRead());
        await sink.flush();
      } finally {
        await sink.close();
      }

      // A concurrent retry may have committed while this copy was running.
      if (await target.exists()) {
        await staging.delete();
        return;
      }
      await staging.rename(target.path);
    } catch (_) {
      if (await staging.exists()) {
        await staging.delete();
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteIfExists({
    required String assetId,
    required String storageKey,
  }) async {
    _validateStorageKey(assetId: assetId, storageKey: storageKey);
    final root = await _appRoot();
    final target = _fileFor(root, storageKey);
    if (await target.exists()) {
      await target.delete();
    }
  }

  Future<Directory> _appRoot() async {
    final rootPath = await _storagePaths.appStorageRoot();
    if (!p.isAbsolute(rootPath)) {
      throw const InvalidAppStorageRootException();
    }
    final root = Directory(p.normalize(rootPath));
    await root.create(recursive: true);
    return root;
  }

  File _sourceFile(String sourceToken) {
    if (sourceToken.trim().isEmpty || !p.isAbsolute(sourceToken)) {
      throw const InvalidMediaSourceException();
    }
    return File(p.normalize(sourceToken));
  }

  File _fileFor(Directory root, String storageKey) {
    final keySegments = p.posix.split(storageKey);
    return File(p.joinAll(<String>[root.path, ...keySegments]));
  }

  void _validateStorageKey({
    required String assetId,
    required String storageKey,
  }) {
    final allowedKeys = <String>{
      for (final mimeType in MediaMimeType.values)
        storageKeyFor(assetId: assetId, mimeType: mimeType),
    };
    if (!allowedKeys.contains(storageKey)) {
      throw const UnsafeMediaStorageKeyException();
    }
  }

  String _encodedAssetId(String assetId) {
    if (assetId.trim().isEmpty) {
      throw const UnsafeMediaStorageKeyException();
    }
    return base64Url.encode(utf8.encode(assetId)).replaceAll('=', '');
  }

  String _extensionFor(MediaMimeType mimeType) {
    return switch (mimeType) {
      MediaMimeType.jpeg => 'jpg',
      MediaMimeType.png => 'png',
      MediaMimeType.heic => 'heic',
    };
  }
}
