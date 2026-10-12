import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/application/import_photo.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/features/media/application/pick_and_import_photo.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

import 'support/fake_media_file_store.dart';

void main() {
  late InMemoryMediaRepository repository;
  late FakeMediaFileStore fileStore;
  late DiaryDayKey dayKey;

  setUp(() {
    repository = InMemoryMediaRepository();
    fileStore = FakeMediaFileStore();
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 9),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
  });

  PickAndImportPhoto buildCoordinator({
    required PhotoSelector selector,
    DateTime Function()? utcNow,
    String Function()? nextId,
  }) {
    return PickAndImportPhoto(
      selector: selector,
      importPhoto: ImportPhoto(repository: repository, fileStore: fileStore),
      utcNow: utcNow ?? () => DateTime.utc(2026, 10, 4, 9),
      nextId: nextId ?? () => 'asset-1',
    );
  }

  test('selects and imports a ready asset for the exact day', () async {
    final selector = _FakePhotoSelector(selection: _jpegSelection());

    final asset = await buildCoordinator(selector: selector)(dayKey);

    expect(selector.calls, 1);
    expect(asset?.id, 'asset-1');
    expect(asset?.dayKey, same(dayKey));
    expect(asset?.createdAtUtc, DateTime.utc(2026, 10, 4, 9));
    expect(asset?.lifecycle, MediaLifecycle.ready);
    expect(
      (await repository.findById('asset-1'))?.lifecycle,
      MediaLifecycle.ready,
    );
  });

  test(
    'returns null on cancellation without allocating identity or time',
    () async {
      var clockCalls = 0;
      var idCalls = 0;
      final coordinator = buildCoordinator(
        selector: _FakePhotoSelector(selection: null),
        utcNow: () {
          clockCalls += 1;
          return DateTime.utc(2026, 10, 4, 9);
        },
        nextId: () {
          idCalls += 1;
          return 'asset-1';
        },
      );

      expect(await coordinator(dayKey), isNull);
      expect(clockCalls, 0);
      expect(idCalls, 0);
      expect(fileStore.events, isEmpty);
    },
  );

  test(
    'rejects a non-UTC clock before allocating an ID or importing',
    () async {
      var idCalls = 0;
      final coordinator = buildCoordinator(
        selector: _FakePhotoSelector(selection: _jpegSelection()),
        utcNow: () => DateTime(2026, 10, 4, 9),
        nextId: () {
          idCalls += 1;
          return 'asset-1';
        },
      );

      await expectLater(coordinator(dayKey), throwsStateError);

      expect(idCalls, 0);
      expect(await repository.findById('asset-1'), isNull);
      expect(fileStore.events, isEmpty);
    },
  );

  test('rejects a blank generated ID before importing', () async {
    final coordinator = buildCoordinator(
      selector: _FakePhotoSelector(selection: _jpegSelection()),
      nextId: () => '   ',
    );

    await expectLater(coordinator(dayKey), throwsStateError);

    expect(fileStore.events, isEmpty);
  });

  test(
    'propagates selection failure without allocating or changing data',
    () async {
      var clockCalls = 0;
      final error = StateError('picker failed');
      final coordinator = buildCoordinator(
        selector: _FakePhotoSelector(error: error),
        utcNow: () {
          clockCalls += 1;
          return DateTime.utc(2026, 10, 4, 9);
        },
      );

      await expectLater(coordinator(dayKey), throwsA(same(error)));

      expect(clockCalls, 0);
      expect(fileStore.events, isEmpty);
    },
  );

  test(
    'preserves the original import error and leaves no partial asset',
    () async {
      final error = StateError('copy failed');
      fileStore.persistError = error;
      final coordinator = buildCoordinator(
        selector: _FakePhotoSelector(selection: _jpegSelection()),
      );

      await expectLater(coordinator(dayKey), throwsA(same(error)));

      expect(await repository.findById('asset-1'), isNull);
      expect(fileStore.storedKeys, isEmpty);
    },
  );

  test(
    'duplicate generated ID never overwrites an existing ready asset',
    () async {
      final firstCoordinator = buildCoordinator(
        selector: _FakePhotoSelector(selection: _jpegSelection()),
      );
      final original = await firstCoordinator(dayKey);
      final persistCallsBeforeDuplicate = fileStore.events
          .where((event) => event.startsWith('persist:'))
          .length;
      final secondCoordinator = buildCoordinator(
        selector: _FakePhotoSelector(
          selection: const PhotoImportSelection(
            token: 'picker-token-2',
            mimeType: 'image/jpeg',
            byteLength: 20,
          ),
        ),
      );

      await expectLater(
        secondCoordinator(dayKey),
        throwsA(isA<MediaRepositoryConflictException>()),
      );

      expect(await repository.findById('asset-1'), same(original));
      expect(
        fileStore.events.where((event) => event.startsWith('persist:')).length,
        persistCallsBeforeDuplicate,
      );
    },
  );
}

PhotoImportSelection _jpegSelection() {
  return const PhotoImportSelection(
    token: 'picker-token-1',
    mimeType: 'image/jpeg',
    byteLength: 10,
  );
}

final class _FakePhotoSelector implements PhotoSelector {
  _FakePhotoSelector({this.selection, this.error});

  final PhotoImportSelection? selection;
  final Object? error;
  int calls = 0;

  @override
  Future<PhotoImportSelection?> selectFromGallery() async {
    calls += 1;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return selection;
  }
}
