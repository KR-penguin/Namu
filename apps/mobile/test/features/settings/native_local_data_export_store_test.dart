import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/settings/data/native_local_data_export_store.dart';
import 'package:namu/features/settings/domain/local_data_export.dart';
import 'package:path/path.dart' as p;

void main() {
  test('atomically writes JSON under the app-owned export root', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'namu-data-export-',
    );
    addTearDown(() async {
      if (await temporary.exists()) {
        await temporary.delete(recursive: true);
      }
    });
    final root = Directory(p.join(temporary.path, 'namu', 'storage'));
    await root.create(recursive: true);
    final store = NativeLocalDataExportStore(_StoragePaths(root.path));
    final bytes = Uint8List.fromList([123, 34, 118, 34, 58, 49, 125]);

    final artifact = await store.write(
      bytes: bytes,
      exportedAtUtc: DateTime.utc(2026, 10, 10, 1, 2, 3, 4, 5),
    );

    expect(p.isWithin(root.path, artifact.path), isTrue);
    expect(p.extension(artifact.path), '.json');
    expect(artifact.mimeType, 'application/json');
    expect(artifact.byteLength, bytes.length);
    expect(await File(artifact.path).readAsBytes(), bytes);
    expect(
      Directory(p.dirname(artifact.path))
          .listSync()
          .where((entity) => entity.path.endsWith('.pending')),
      isEmpty,
    );
  });

  test(
    'rejects a symlinked export directory instead of following it',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'namu-data-export-link-',
      );
      addTearDown(() async {
        if (await temporary.exists()) {
          await temporary.delete(recursive: true);
        }
      });
      final root = Directory(p.join(temporary.path, 'namu', 'storage'));
      final outside = Directory(p.join(temporary.path, 'outside'));
      await root.create(recursive: true);
      await outside.create();
      await Link(p.join(root.path, 'exports')).create(outside.path);
      final store = NativeLocalDataExportStore(_StoragePaths(root.path));

      await expectLater(
        store.write(
          bytes: Uint8List.fromList([123, 125]),
          exportedAtUtc: DateTime.utc(2026, 10, 10),
        ),
        throwsA(
          isA<LocalDataExportException>().having(
            (error) => error.reason,
            'reason',
            LocalDataExportFailure.unsafeStorage,
          ),
        ),
      );
      expect(outside.listSync(), isEmpty);
    },
  );

  test('rejects unavailable storage with a redacted typed failure', () async {
    const store = NativeLocalDataExportStore(UnavailableAppStoragePaths());

    await expectLater(
      store.write(
        bytes: Uint8List.fromList([123, 125]),
        exportedAtUtc: DateTime.utc(2026, 10, 10),
      ),
      throwsA(
        isA<LocalDataExportException>().having(
          (error) => error.reason,
          'reason',
          LocalDataExportFailure.unavailable,
        ),
      ),
    );
  });
}

final class _StoragePaths implements AppStoragePaths {
  const _StoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
