import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/share/domain/diary_share_output_store.dart';
import 'package:path/path.dart' as p;

final class NativeDiaryShareOutputStore implements DiaryShareOutputStore {
  const NativeDiaryShareOutputStore(this._storagePaths);

  final AppStoragePaths _storagePaths;

  @override
  Future<String> writePng({
    required String entryId,
    required int version,
    required DateTime updatedAtUtc,
    required int pageNumber,
    required Uint8List bytes,
  }) async {
    if (entryId.trim().isEmpty ||
        version < 1 ||
        !updatedAtUtc.isUtc ||
        pageNumber < 1 ||
        !_hasPngSignature(bytes)) {
      throw const DiaryShareOutputException(
        DiaryShareOutputFailure.invalidRequest,
      );
    }

    Directory? temporaryDirectory;
    try {
      final rootPath = await _storagePaths.appStorageRoot();
      if (rootPath.trim().isEmpty || !p.isAbsolute(rootPath)) {
        throw const DiaryShareOutputException(
          DiaryShareOutputFailure.invalidRoot,
        );
      }
      final root = Directory(p.normalize(rootPath));
      await root.create(recursive: true);
      final canonicalRoot = p.normalize(await root.resolveSymbolicLinks());

      final outputDirectory = Directory(
        p.join(canonicalRoot, 'exports', 'share'),
      );
      final stagingDirectory = Directory(
        p.join(canonicalRoot, '.share-staging'),
      );
      await outputDirectory.create(recursive: true);
      await stagingDirectory.create(recursive: true);
      final canonicalOutput = p.normalize(
        await outputDirectory.resolveSymbolicLinks(),
      );
      final canonicalStaging = p.normalize(
        await stagingDirectory.resolveSymbolicLinks(),
      );
      if (!p.isWithin(canonicalRoot, canonicalOutput) ||
          !p.isWithin(canonicalRoot, canonicalStaging)) {
        throw const DiaryShareOutputException(
          DiaryShareOutputFailure.invalidRoot,
        );
      }

      final encodedId = base64Url
          .encode(utf8.encode(entryId))
          .replaceAll('=', '');
      final revision = updatedAtUtc.microsecondsSinceEpoch;
      final fileName =
          '$encodedId-v$version-r$revision-'
          'p${pageNumber.toString().padLeft(3, '0')}.png';
      final target = File(p.join(canonicalOutput, fileName));
      if (!p.isWithin(canonicalRoot, p.normalize(target.path))) {
        throw const DiaryShareOutputException(
          DiaryShareOutputFailure.invalidRoot,
        );
      }
      final targetType = await FileSystemEntity.type(
        target.path,
        followLinks: false,
      );
      if (targetType == FileSystemEntityType.link ||
          targetType == FileSystemEntityType.directory) {
        throw const DiaryShareOutputException(
          DiaryShareOutputFailure.invalidRoot,
        );
      }

      temporaryDirectory = await stagingDirectory.createTemp('write-');
      final staged = File(p.join(temporaryDirectory.path, 'page.part'));
      await staged.writeAsBytes(bytes, flush: true);
      // The staging file and target share a filesystem. rename() is the
      // commit point, so observers see either the previous complete page or
      // the new complete page, never partially written PNG bytes.
      await staged.rename(target.path);
      return target.path;
    } on DiaryShareOutputException {
      rethrow;
    } on AppStorageUnavailableException {
      throw const DiaryShareOutputException(
        DiaryShareOutputFailure.invalidRoot,
      );
    } on FileSystemException {
      throw const DiaryShareOutputException(
        DiaryShareOutputFailure.writeFailed,
      );
    } finally {
      try {
        if (temporaryDirectory != null && await temporaryDirectory.exists()) {
          await temporaryDirectory.delete(recursive: true);
        }
      } on FileSystemException {
        // A stale staging directory is non-authoritative and can be cleaned
        // on the next export; it must not mask the actual render result.
      }
    }
  }

  bool _hasPngSignature(Uint8List bytes) {
    const signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    if (bytes.length < signature.length) return false;
    for (var index = 0; index < signature.length; index += 1) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }
}
