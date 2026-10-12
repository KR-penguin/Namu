import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/storage/app_storage_paths.dart';
import '../domain/local_data_eraser.dart';

/// Deletes the complete native backup-excluded root after its graph is closed.
final class PlatformLocalDataEraser implements LocalDataEraser {
  const PlatformLocalDataEraser(this._storagePaths);

  final AppStoragePaths _storagePaths;

  @override
  LocalDataResetKind get resetKind => LocalDataResetKind.persistentNative;

  @override
  Future<void> erase() async {
    final String rawRoot;
    try {
      rawRoot = await _storagePaths.appStorageRoot();
    } on AppStorageUnavailableException {
      throw const LocalDataEraseException(LocalDataEraseFailure.unavailable);
    }

    final rootPath = p.normalize(rawRoot);
    if (!_isSafeRoot(rootPath)) {
      throw const LocalDataEraseException(LocalDataEraseFailure.unsafeRoot);
    }

    try {
      final type = await FileSystemEntity.type(rootPath, followLinks: false);
      if (type == FileSystemEntityType.notFound) {
        return;
      }
      if (type != FileSystemEntityType.directory) {
        throw const LocalDataEraseException(LocalDataEraseFailure.unsafeRoot);
      }

      await _deleteDirectoryWithoutFollowingLinks(Directory(rootPath));
    } on LocalDataEraseException {
      rethrow;
    } on FileSystemException {
      throw const LocalDataEraseException(LocalDataEraseFailure.deleteFailed);
    }
  }

  bool _isSafeRoot(String value) {
    if (value.trim().isEmpty || !p.isAbsolute(value)) {
      return false;
    }
    final parent = p.dirname(value);
    if (parent == value) {
      return false;
    }
    // Refuse broad roots such as `/tmp` or `C:\data`. Production roots are
    // always deeper app-specific directories, and tests use a child root.
    return p.dirname(parent) != parent;
  }

  Future<void> _deleteDirectoryWithoutFollowingLinks(
    Directory directory,
  ) async {
    await for (final entity in directory.list(followLinks: false)) {
      final type = await FileSystemEntity.type(entity.path, followLinks: false);
      switch (type) {
        case FileSystemEntityType.directory:
          await _deleteDirectoryWithoutFollowingLinks(Directory(entity.path));
        case FileSystemEntityType.file:
          await File(entity.path).delete();
        case FileSystemEntityType.link:
          await Link(entity.path).delete();
        case FileSystemEntityType.notFound:
          break;
        default:
          throw const LocalDataEraseException(LocalDataEraseFailure.unsafeRoot);
      }
    }
    await directory.delete();
  }
}
