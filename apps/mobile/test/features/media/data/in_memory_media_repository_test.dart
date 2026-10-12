import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

void main() {
  late InMemoryMediaRepository repository;

  setUp(() {
    repository = InMemoryMediaRepository();
  });

  test('inserts staging and completes the allowed ready transition', () async {
    final staging = _asset(lifecycle: MediaLifecycle.staging);

    await repository.insert(staging);
    await repository.update(staging.withLifecycle(MediaLifecycle.ready));

    expect(
      (await repository.findById('asset-1'))?.lifecycle,
      MediaLifecycle.ready,
    );
  });

  test('rejects a duplicate identity without replacing the original', () async {
    final original = _asset(lifecycle: MediaLifecycle.staging);
    await repository.insert(original);

    await expectLater(
      repository.insert(
        _asset(
          lifecycle: MediaLifecycle.staging,
          storageKey: 'media/different.jpg',
        ),
      ),
      throwsA(isA<MediaRepositoryConflictException>()),
    );

    expect(
      (await repository.findById('asset-1'))?.storageKey,
      original.storageKey,
    );
  });

  test('allows only lifecycle changes for an existing identity', () async {
    final staging = _asset(lifecycle: MediaLifecycle.staging);
    await repository.insert(staging);

    for (final changedIdentity in <MediaAsset>[
      _asset(lifecycle: MediaLifecycle.ready, storageKey: 'media/changed.jpg'),
      _asset(lifecycle: MediaLifecycle.ready, byteLength: 99),
      _asset(
        lifecycle: MediaLifecycle.ready,
        createdAtUtc: DateTime.utc(2026, 10, 4, 10),
      ),
      _asset(
        lifecycle: MediaLifecycle.ready,
        dayKey: DiaryDayKey.fromInstant(
          instant: DateTime.utc(2026, 10, 5, 9),
          timeZone: TimeZoneSnapshot(
            timeZoneId: 'Asia/Seoul',
            utcOffset: const Duration(hours: 9),
          ),
        ),
      ),
    ]) {
      await expectLater(
        repository.update(changedIdentity),
        throwsA(isA<MediaAssetIdentityMismatchException>()),
      );
    }

    expect(await repository.findById('asset-1'), same(staging));
  });

  test('rejects backward and terminal lifecycle transitions', () async {
    final staging = _asset(lifecycle: MediaLifecycle.staging);
    await repository.insert(staging);
    final ready = staging.withLifecycle(MediaLifecycle.ready);
    await repository.update(ready);

    await expectLater(
      repository.update(ready.withLifecycle(MediaLifecycle.staging)),
      throwsA(isA<InvalidMediaLifecycleTransitionException>()),
    );
    final deleting = ready.withLifecycle(MediaLifecycle.deleting);
    await repository.update(deleting);
    await expectLater(
      repository.update(deleting.withLifecycle(MediaLifecycle.ready)),
      throwsA(isA<InvalidMediaLifecycleTransitionException>()),
    );
  });

  test('lifecycle transition matrix is explicit and stable', () {
    final allowed = <(MediaLifecycle, MediaLifecycle)>{
      for (final state in MediaLifecycle.values) (state, state),
      (MediaLifecycle.staging, MediaLifecycle.ready),
      (MediaLifecycle.staging, MediaLifecycle.deleting),
      (MediaLifecycle.staging, MediaLifecycle.missing),
      (MediaLifecycle.ready, MediaLifecycle.deleting),
      (MediaLifecycle.ready, MediaLifecycle.missing),
      (MediaLifecycle.missing, MediaLifecycle.deleting),
    };

    for (final from in MediaLifecycle.values) {
      for (final to in MediaLifecycle.values) {
        expect(
          isAllowedMediaLifecycleTransition(from, to),
          allowed.contains((from, to)),
          reason: '${from.name} -> ${to.name}',
        );
      }
    }
  });

  test(
    'requires staging for insert and an existing identity for update',
    () async {
      await expectLater(
        repository.insert(_asset(lifecycle: MediaLifecycle.ready)),
        throwsA(isA<InvalidMediaLifecycleTransitionException>()),
      );
      await expectLater(
        repository.update(_asset(lifecycle: MediaLifecycle.ready)),
        throwsA(isA<MediaRepositoryNotFoundException>()),
      );
    },
  );

  test('remove is idempotent', () async {
    await repository.insert(_asset(lifecycle: MediaLifecycle.staging));

    await repository.removeById('asset-1');
    await repository.removeById('asset-1');

    expect(await repository.findById('asset-1'), isNull);
  });
}

MediaAsset _asset({
  required MediaLifecycle lifecycle,
  DiaryDayKey? dayKey,
  String storageKey = 'media/asset-1.jpg',
  int byteLength = 10,
  DateTime? createdAtUtc,
}) {
  return MediaAsset(
    id: 'asset-1',
    dayKey:
        dayKey ??
        DiaryDayKey.fromInstant(
          instant: DateTime.utc(2026, 10, 4, 9),
          timeZone: TimeZoneSnapshot(
            timeZoneId: 'Asia/Seoul',
            utcOffset: const Duration(hours: 9),
          ),
        ),
    storageKey: storageKey,
    mimeType: MediaMimeType.jpeg,
    byteLength: byteLength,
    createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4, 9),
    lifecycle: lifecycle,
  );
}
