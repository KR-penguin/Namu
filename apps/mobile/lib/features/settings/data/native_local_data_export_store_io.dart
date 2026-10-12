import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../../core/storage/app_storage_paths.dart';
import '../domain/local_data_export.dart';

/// Stages JSON exports inside the backup-excluded app root.
final class NativeLocalDataExportStore implements LocalDataExportStore {
  const NativeLocalDataExportStore(this._storagePaths);

  final AppStoragePaths _storagePaths;

  @override
  Future<LocalDataExportArtifact> write({
    required Uint8List bytes,
    required DateTime exportedAtUtc,
  }) async {
    if (bytes.isEmpty || !exportedAtUtc.isUtc) {
      throw const LocalDataExportException(
        LocalDataExportFailure.invalidSnapshot,
      );
    }

    final String rawRoot;
    try {
      rawRoot = await _storagePaths.appStorageRoot();
    } on AppStorageUnavailableException {
      throw const LocalDataExportException(LocalDataExportFailure.unavailable);
    }

    final root = p.normalize(rawRoot);
    if (!_isSafeRoot(root)) {
      throw const LocalDataExportException(
        LocalDataExportFailure.unsafeStorage,
      );
    }

    final exports = p.join(root, 'exports');
    final outputDirectory = p.join(exports, 'data');
    if (!p.isWithin(root, outputDirectory)) {
      throw const LocalDataExportException(
        LocalDataExportFailure.unsafeStorage,
      );
    }

    final filename =
        'namu-local-data-v1-${exportedAtUtc.microsecondsSinceEpoch}.json';
    final destinationPath = p.join(outputDirectory, filename);
    final pendingPath = '$destinationPath.pending';

    try {
      await _ensureDirectory(root, allowCreateRecursive: true);
      await _ensureDirectory(exports);
      await _ensureDirectory(outputDirectory);
      await _removeOwnedFileIfPresent(pendingPath);
      await File(pendingPath).writeAsBytes(bytes, flush: true);
      await _removeOwnedFileIfPresent(destinationPath);
      await File(pendingPath).rename(destinationPath);

      return LocalDataExportArtifact(
        path: destinationPath,
        mimeType: 'application/json',
        byteLength: bytes.length,
      );
    } on LocalDataExportException {
      rethrow;
    } on FileSystemException {
      throw const LocalDataExportException(LocalDataExportFailure.writeFailed);
    } finally {
      try {
        final type = await FileSystemEntity.type(
          pendingPath,
          followLinks: false,
        );
        if (type == FileSystemEntityType.file) {
          await File(pendingPath).delete();
        } else if (type == FileSystemEntityType.link) {
          await Link(pendingPath).delete();
        }
      } on FileSystemException {
        // A failed staging cleanup must not replace the original typed error.
      }
    }
  }

  bool _isSafeRoot(String value) {
    if (value.trim().isEmpty || !p.isAbsolute(value)) {
      return false;
    }
    final parent = p.dirname(value);
    return parent != value && p.dirname(parent) != parent;
  }

  Future<void> _ensureDirectory(
    String path, {
    bool allowCreateRecursive = false,
  }) async {
    var type = await FileSystemEntity.type(path, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      await Directory(path).create(recursive: allowCreateRecursive);
      type = await FileSystemEntity.type(path, followLinks: false);
    }
    if (type != FileSystemEntityType.directory) {
      throw const LocalDataExportException(
        LocalDataExportFailure.unsafeStorage,
      );
    }
  }

  Future<void> _removeOwnedFileIfPresent(String path) async {
    final type = await FileSystemEntity.type(path, followLinks: false);
    switch (type) {
      case FileSystemEntityType.notFound:
        return;
      case FileSystemEntityType.file:
        await File(path).delete();
      case FileSystemEntityType.link:
        throw const LocalDataExportException(
          LocalDataExportFailure.unsafeStorage,
        );
      default:
        throw const LocalDataExportException(
          LocalDataExportFailure.unsafeStorage,
        );
    }
  }
}
