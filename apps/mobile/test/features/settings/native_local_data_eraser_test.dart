import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/settings/data/platform_local_data_eraser.dart';
import 'package:namu/features/settings/domain/local_data_eraser.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'namu-local-reset-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('deletes the complete backup-excluded app root idempotently', () async {
    final root = Directory(p.join(temporaryDirectory.path, 'namu-root'));
    await File(p.join(root.path, 'namu.sqlite')).create(recursive: true);
    await File(p.join(root.path, 'namu.sqlite-wal'))
        .writeAsString('private wal');
    await _writeFile(p.join(root.path, 'media', 'photo.jpg'), 'private photo');
    await _writeFile(
      p.join(root.path, 'exports', 'share', 'page.png'),
      'derived export',
    );
    await _writeFile(p.join(root.path, '.staging', 'photo.part'), 'staging');
    await _writeFile(
      p.join(root.path, '.share-staging', 'page.part'),
      'share staging',
    );
    await _writeFile(
      p.join(root.path, 'settings', 'ai-data-consent-v1.json'),
      'accepted',
    );

    final eraser = PlatformLocalDataEraser(_FixedStoragePaths(root.path));

    expect(eraser.resetKind, LocalDataResetKind.persistentNative);
    await eraser.erase();
    await eraser.erase();

    expect(await root.exists(), isFalse);
  });

  test('rejects a root that is itself a symbolic link', () async {
    final target = Directory(p.join(temporaryDirectory.path, 'target'));
    await target.create();
    final linkedRoot = Link(p.join(temporaryDirectory.path, 'linked-root'));
    await linkedRoot.create(target.path);
    final eraser = PlatformLocalDataEraser(_FixedStoragePaths(linkedRoot.path));

    await expectLater(
      eraser.erase(),
      throwsA(
        isA<LocalDataEraseException>().having(
          (error) => error.reason,
          'reason',
          LocalDataEraseFailure.unsafeRoot,
        ),
      ),
    );

    expect(await target.exists(), isTrue);
  });

  test('rejects a filesystem root instead of deleting broadly', () async {
    final eraser = PlatformLocalDataEraser(
      _FixedStoragePaths(p.rootPrefix(temporaryDirectory.path)),
    );

    await expectLater(
      eraser.erase(),
      throwsA(
        isA<LocalDataEraseException>().having(
          (error) => error.reason,
          'reason',
          LocalDataEraseFailure.unsafeRoot,
        ),
      ),
    );
  });
}

Future<void> _writeFile(String path, String contents) async {
  final file = File(path);
  await file.create(recursive: true);
  await file.writeAsString(contents, flush: true);
}

final class _FixedStoragePaths implements AppStoragePaths {
  const _FixedStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
