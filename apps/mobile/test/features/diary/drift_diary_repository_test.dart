import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/diary/data/drift_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  late AppDatabase database;
  late DriftDiaryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftDiaryRepository(database);
  });

  tearDown(() => database.close());

  test('saves and restores the complete diary snapshot', () async {
    final entry = _entry();

    await repository.save(entry);
    final restored = await repository.findLatestForDay(entry.dayKey);

    expect(restored, isNotNull);
    expect(restored!.id, entry.id);
    expect(restored.dayKey, entry.dayKey);
    expect(restored.version, entry.version);
    expect(restored.status, entry.status);
    expect(restored.weather.provenance, WeatherProvenance.provider);
    expect(restored.weather.temperatureCelsius, 21.25);
    expect(restored.blocks, hasLength(3));
    expect(restored.memoryCandidates.single.sourceMessageIds, ['message-1']);
    expect(restored.sourceMessageIds, ['message-1', 'message-2']);
    expect(restored.generatedAtUtc, entry.generatedAtUtc);
    expect(restored.updatedAtUtc, entry.updatedAtUtc);
  });

  test(
    'findLatestForDay uses exact day identity and highest version',
    () async {
      final seoul = _dayKey();
      final tokyo = _dayKey(timeZoneId: 'Asia/Tokyo');
      await repository.save(_entry(id: 'seoul-1', version: 1, dayKey: seoul));
      await repository.save(
        _entry(
          id: 'seoul-2',
          version: 2,
          dayKey: seoul,
          generationId: 'generation-2',
        ),
      );
      await repository.save(
        _entry(
          id: 'tokyo-9',
          version: 9,
          dayKey: tokyo,
          generationId: 'generation-tokyo',
        ),
      );

      expect((await repository.findLatestForDay(seoul))?.id, 'seoul-2');
      expect((await repository.findLatestForDay(tokyo))?.id, 'tokyo-9');
      expect(
        await repository.findLatestForDay(
          DiaryDayKey.restore(
            labelDate: LocalDate(2026, 10, 5),
            timeZoneId: 'Asia/Seoul',
            cutoff: Duration.zero,
            policyVersion: 1,
          ),
        ),
        isNull,
      );
    },
  );

  test('listAll orders updated UTC descending then id', () async {
    final sameUpdatedAt = DateTime.utc(2026, 10, 4, 18);
    await repository.save(
      _entry(
        id: 'diary-b',
        version: 1,
        generationId: 'generation-b',
        updatedAtUtc: sameUpdatedAt,
      ),
    );
    await repository.save(
      _entry(
        id: 'diary-a',
        version: 2,
        generationId: 'generation-a',
        updatedAtUtc: sameUpdatedAt,
      ),
    );
    await repository.save(
      _entry(
        id: 'diary-old',
        version: 3,
        generationId: 'generation-old',
        updatedAtUtc: sameUpdatedAt.subtract(const Duration(seconds: 1)),
      ),
    );

    expect((await repository.listAll()).map((entry) => entry.id), [
      'diary-a',
      'diary-b',
      'diary-old',
    ]);
  });

  test('save updates an edited or finalized snapshot by id', () async {
    final draft = _entry(
      version: 1,
      status: DiaryEntryStatus.draft,
      updatedAtUtc: DateTime.utc(2026, 10, 4, 16),
    );
    await repository.save(draft);
    final finalized = draft.finalize(
      updatedAtUtc: DateTime.utc(2026, 10, 4, 17),
    );

    await repository.save(finalized);

    final entries = await repository.listAll();
    expect(entries, hasLength(1));
    expect(entries.single.status, DiaryEntryStatus.finalized);
    expect(entries.single.updatedAtUtc, DateTime.utc(2026, 10, 4, 17));
  });

  test('deleteById removes only the selected snapshot', () async {
    await repository.save(_entry(id: 'keep'));
    await repository.save(
      _entry(id: 'delete', version: 2, generationId: 'generation-delete'),
    );

    await repository.deleteById('delete');
    await repository.deleteById('missing');

    expect((await repository.listAll()).map((entry) => entry.id), ['keep']);
  });

  test(
    'createDraftIfAbsent returns an existing generation atomically',
    () async {
      var buildCalls = 0;
      Future<DiaryEntry> create() {
        return repository.createDraftIfAbsent(
          generationId: 'generation-retry',
          dayKey: _dayKey(),
          build: (version) {
            buildCalls++;
            return _entry(
              id: 'created-once',
              version: version,
              status: DiaryEntryStatus.draft,
              generationId: 'generation-retry',
            );
          },
        );
      }

      final first = await create();
      final retry = await create();

      expect(first.id, 'created-once');
      expect(retry.id, first.id);
      expect(buildCalls, 1);
      expect(await repository.listAll(), hasLength(1));
    },
  );

  test(
    'concurrent generations receive unique versions for the exact day',
    () async {
      final entries = await Future.wait([
        repository.createDraftIfAbsent(
          generationId: 'generation-a',
          dayKey: _dayKey(),
          build: (version) => _entry(
            id: 'diary-a',
            version: version,
            status: DiaryEntryStatus.draft,
            generationId: 'generation-a',
          ),
        ),
        repository.createDraftIfAbsent(
          generationId: 'generation-b',
          dayKey: _dayKey(),
          build: (version) => _entry(
            id: 'diary-b',
            version: version,
            status: DiaryEntryStatus.draft,
            generationId: 'generation-b',
          ),
        ),
      ]);

      expect(entries.map((entry) => entry.version).toSet(), {1, 2});
      expect(await repository.listAll(), hasLength(2));
    },
  );

  test('rejects a draft builder that changes its identity contract', () async {
    expect(
      () => repository.createDraftIfAbsent(
        generationId: 'expected-generation',
        dayKey: _dayKey(),
        build: (version) => _entry(
          id: 'invalid',
          version: version + 1,
          status: DiaryEntryStatus.draft,
          generationId: 'different-generation',
        ),
      ),
      throwsStateError,
    );

    expect(await repository.listAll(), isEmpty);
  });
}

DiaryDayKey _dayKey({String timeZoneId = 'Asia/Seoul'}) {
  return DiaryDayKey.restore(
    labelDate: LocalDate(2026, 10, 4),
    timeZoneId: timeZoneId,
    cutoff: Duration.zero,
    policyVersion: 1,
  );
}

DiaryEntry _entry({
  String id = 'diary-1',
  DiaryDayKey? dayKey,
  int version = 1,
  DiaryEntryStatus status = DiaryEntryStatus.finalized,
  String generationId = 'generation-1',
  DateTime? generatedAtUtc,
  DateTime? updatedAtUtc,
}) {
  final generated = generatedAtUtc ?? DateTime.utc(2026, 10, 4, 15);
  return DiaryEntry(
    id: id,
    dayKey: dayKey ?? _dayKey(),
    version: version,
    status: status,
    weather: WeatherSnapshot.provider(
      condition: '구름 조금',
      temperatureCelsius: 21.25,
      providerId: 'weather-provider',
      observedAtUtc: DateTime.utc(2026, 10, 4, 7, 30),
    ),
    mood: '평온함',
    oneLineSummary: '산책으로 숨을 고른 하루',
    theme: DiaryTheme.dark,
    blocks: const <DiaryBlock>[
      DiaryTextBlock(text: '첫 문단'),
      DiaryPhotoBlock(photoAssetId: 'photo-1'),
      DiaryTextBlock(text: '마지막 문단'),
    ],
    memoryCandidates: <DiaryMemoryCandidate>[
      DiaryMemoryCandidate(
        fact: '사용자는 산책을 좋아한다.',
        sourceMessageIds: const ['message-1'],
      ),
    ],
    sourceMessageIds: const ['message-1', 'message-2'],
    generationId: generationId,
    generatedAtUtc: generated,
    updatedAtUtc: updatedAtUtc ?? generated.add(const Duration(hours: 1)),
  );
}
