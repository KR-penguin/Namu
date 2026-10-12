import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/media/data/media_file_store_exceptions.dart';
import 'package:namu/features/media/data/native_media_file_store.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory testDirectory;
  late Directory appRoot;
  late Directory pickerRoot;
  late NativeMediaFileStore fileStore;

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('namu-media-test-');
    appRoot = Directory(p.join(testDirectory.path, 'app-root'));
    pickerRoot = Directory(p.join(testDirectory.path, 'picker'));
    await pickerRoot.create(recursive: true);
    fileStore = NativeMediaFileStore(_FakeAppStoragePaths(appRoot.path));
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('builds deterministic safe keys for every supported MIME type', () {
    final keys = <MediaMimeType, String>{
      for (final mimeType in MediaMimeType.values)
        mimeType: fileStore.storageKeyFor(
          assetId: '../asset/with separators',
          mimeType: mimeType,
        ),
    };

    expect(keys[MediaMimeType.jpeg], endsWith('.jpg'));
    expect(keys[MediaMimeType.png], endsWith('.png'));
    expect(keys[MediaMimeType.heic], endsWith('.heic'));
    for (final key in keys.values) {
      expect(key, startsWith('media/'));
      expect(key, isNot(contains('..')));
      expect(key, isNot(contains(r'\')));
      expect(p.posix.isAbsolute(key), isFalse);
    }
  });

  test('copies, flushes, and renames into the final storage key', () async {
    final source = File(p.join(pickerRoot.path, 'picked.jpg'));
    const bytes = <int>[0, 1, 2, 3, 255];
    await source.writeAsBytes(bytes, flush: true);
    final storageKey = fileStore.storageKeyFor(
      assetId: 'asset-1',
      mimeType: MediaMimeType.jpeg,
    );

    await fileStore.persist(
      assetId: 'asset-1',
      storageKey: storageKey,
      sourceToken: source.path,
    );

    final stored = File(p.join(appRoot.path, storageKey));
    expect(await stored.readAsBytes(), bytes);
    expect(await source.readAsBytes(), bytes);
    final staging = Directory(p.join(appRoot.path, '.staging'));
    expect(await staging.list().toList(), isEmpty);
  });

  test('an existing final file makes a repeated persist idempotent', () async {
    final source = File(p.join(pickerRoot.path, 'picked.png'));
    await source.writeAsBytes(<int>[1, 2, 3], flush: true);
    final storageKey = fileStore.storageKeyFor(
      assetId: 'asset-1',
      mimeType: MediaMimeType.png,
    );

    await fileStore.persist(
      assetId: 'asset-1',
      storageKey: storageKey,
      sourceToken: source.path,
    );
    await source.writeAsBytes(<int>[9, 9, 9], flush: true);
    await fileStore.persist(
      assetId: 'asset-1',
      storageKey: storageKey,
      sourceToken: source.path,
    );

    expect(await File(p.join(appRoot.path, storageKey)).readAsBytes(), <int>[
      1,
      2,
      3,
    ]);
    expect(
      await Directory(p.join(appRoot.path, '.staging')).list().toList(),
      isEmpty,
    );
  });

  test('rejects traversal and keys belonging to another asset', () async {
    final source = File(p.join(pickerRoot.path, 'picked.jpg'));
    await source.writeAsBytes(<int>[1], flush: true);
    final otherAssetKey = fileStore.storageKeyFor(
      assetId: 'asset-2',
      mimeType: MediaMimeType.jpeg,
    );

    for (final unsafeKey in <String>['../outside.jpg', otherAssetKey]) {
      await expectLater(
        fileStore.persist(
          assetId: 'asset-1',
          storageKey: unsafeKey,
          sourceToken: source.path,
        ),
        throwsA(isA<UnsafeMediaStorageKeyException>()),
      );
    }

    expect(
      await File(p.join(testDirectory.path, 'outside.jpg')).exists(),
      isFalse,
    );
  });

  test('rejects relative or missing picker source paths', () async {
    final storageKey = fileStore.storageKeyFor(
      assetId: 'asset-1',
      mimeType: MediaMimeType.jpeg,
    );

    for (final sourceToken in <String>[
      'relative/picked.jpg',
      p.join(testDirectory.path, 'missing.jpg'),
    ]) {
      await expectLater(
        fileStore.persist(
          assetId: 'asset-1',
          storageKey: storageKey,
          sourceToken: sourceToken,
        ),
        throwsA(isA<InvalidMediaSourceException>()),
      );
    }
  });

  test('delete is safe to retry after the file is already gone', () async {
    final source = File(p.join(pickerRoot.path, 'picked.heic'));
    await source.writeAsBytes(<int>[4, 5, 6], flush: true);
    final storageKey = fileStore.storageKeyFor(
      assetId: 'asset-1',
      mimeType: MediaMimeType.heic,
    );
    await fileStore.persist(
      assetId: 'asset-1',
      storageKey: storageKey,
      sourceToken: source.path,
    );

    await fileStore.deleteIfExists(assetId: 'asset-1', storageKey: storageKey);
    await fileStore.deleteIfExists(assetId: 'asset-1', storageKey: storageKey);

    expect(await File(p.join(appRoot.path, storageKey)).exists(), isFalse);
  });
}

final class _FakeAppStoragePaths implements AppStoragePaths {
  const _FakeAppStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
