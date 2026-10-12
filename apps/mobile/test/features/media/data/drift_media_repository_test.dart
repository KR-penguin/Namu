import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/media/data/drift_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMediaRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftMediaRepository(database);
  });

  tearDown(() => database.close());

  test('inserts staging and round-trips every asset field', () async {
    final asset = _asset(lifecycle: MediaLifecycle.staging);

    await repository.insert(asset);
    final restored = await repository.findById(asset.id);

    expect(restored?.id, asset.id);
    expect(restored?.dayKey, asset.dayKey);
    expect(restored?.storageKey, asset.storageKey);
    expect(restored?.mimeType, asset.mimeType);
    expect(restored?.byteLength, asset.byteLength);
    expect(restored?.createdAtUtc, asset.createdAtUtc);
    expect(restored?.lifecycle, MediaLifecycle.staging);
  });

  test('rejects duplicate identities and non-staging inserts', () async {
    await repository.insert(_asset(lifecycle: MediaLifecycle.staging));

    await expectLater(
      repository.insert(
        _asset(
          lifecycle: MediaLifecycle.staging,
          storageKey: 'media/duplicate.jpg',
        ),
      ),
      throwsA(isA<MediaRepositoryConflictException>()),
    );
    await expectLater(
      repository.insert(
        _asset(id: 'ready-asset', lifecycle: MediaLifecycle.ready),
      ),
      throwsA(isA<InvalidMediaLifecycleTransitionException>()),
    );
  });

  test('updates only identity-preserving lifecycle transitions', () async {
    final staging = _asset(lifecycle: MediaLifecycle.staging);
    await repository.insert(staging);
    final ready = staging.withLifecycle(MediaLifecycle.ready);
    await repository.update(ready);

    expect(
      (await repository.findById(staging.id))?.lifecycle,
      MediaLifecycle.ready,
    );

    await expectLater(
      repository.update(
        MediaAsset(
          id: ready.id,
          dayKey: ready.dayKey,
          storageKey: 'media/changed.jpg',
          mimeType: ready.mimeType,
          byteLength: ready.byteLength,
          createdAtUtc: ready.createdAtUtc,
          lifecycle: MediaLifecycle.deleting,
        ),
      ),
      throwsA(isA<MediaAssetIdentityMismatchException>()),
    );
    await expectLater(
      repository.update(ready.withLifecycle(MediaLifecycle.staging)),
      throwsA(isA<InvalidMediaLifecycleTransitionException>()),
    );
    await expectLater(
      repository.update(_asset(id: 'missing', lifecycle: MediaLifecycle.ready)),
      throwsA(isA<MediaRepositoryNotFoundException>()),
    );
  });

  test('supports deleting flow and idempotent metadata removal', () async {
    final staging = _asset(lifecycle: MediaLifecycle.staging);
    await repository.insert(staging);
    final ready = staging.withLifecycle(MediaLifecycle.ready);
    await repository.update(ready);
    await repository.update(ready.withLifecycle(MediaLifecycle.deleting));

    await repository.removeById(staging.id);
    await repository.removeById(staging.id);

    expect(await repository.findById(staging.id), isNull);
  });
}

MediaAsset _asset({
  String id = 'asset-1',
  required MediaLifecycle lifecycle,
  String storageKey = 'media/asset-1.jpg',
  MediaMimeType mimeType = MediaMimeType.jpeg,
  int byteLength = 12345,
}) {
  return MediaAsset(
    id: id,
    dayKey: DiaryDayKey.restore(
      labelDate: LocalDate(2026, 10, 4),
      timeZoneId: 'Asia/Seoul',
      cutoff: Duration.zero,
      policyVersion: 1,
    ),
    storageKey: storageKey,
    mimeType: mimeType,
    byteLength: byteLength,
    createdAtUtc: DateTime.utc(2026, 10, 4, 9, 8, 7, 654, 321),
    lifecycle: lifecycle,
  );
}
