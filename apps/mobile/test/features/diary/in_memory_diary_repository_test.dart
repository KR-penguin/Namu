import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  late InMemoryDiaryRepository repository;
  late DiaryDayKey dayKey;

  setUp(() {
    repository = InMemoryDiaryRepository();
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
  });

  test(
    'creates one draft per generation and increments day versions',
    () async {
      final first = await repository.createDraftIfAbsent(
        generationId: 'generation-1',
        dayKey: dayKey,
        build: (version) => _entry(
          id: 'diary-1',
          generationId: 'generation-1',
          dayKey: dayKey,
          version: version,
          updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
        ),
      );
      final duplicate = await repository.createDraftIfAbsent(
        generationId: 'generation-1',
        dayKey: dayKey,
        build: (_) => throw StateError('must not rebuild'),
      );
      final second = await repository.createDraftIfAbsent(
        generationId: 'generation-2',
        dayKey: dayKey,
        build: (version) => _entry(
          id: 'diary-2',
          generationId: 'generation-2',
          dayKey: dayKey,
          version: version,
          updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
        ),
      );

      expect(duplicate, same(first));
      expect(first.version, 1);
      expect(second.version, 2);
      expect((await repository.findLatestForDay(dayKey))?.id, 'diary-2');
    },
  );

  test('saves edits, lists newest first, and deletes idempotently', () async {
    final entry = _entry(
      id: 'diary-1',
      generationId: 'generation-1',
      dayKey: dayKey,
      version: 1,
      updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    );
    await repository.save(entry);
    final finalized = entry.finalize(
      updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
    );

    await repository.save(finalized);

    expect(
      (await repository.listAll()).single.status,
      DiaryEntryStatus.finalized,
    );
    await repository.deleteById(entry.id);
    await repository.deleteById(entry.id);
    expect(await repository.findLatestForDay(dayKey), isNull);
  });

  test('rejects identity conflicts at the storage boundary', () async {
    final first = _entry(
      id: 'diary-1',
      generationId: 'generation-1',
      dayKey: dayKey,
      version: 1,
      updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    );
    await repository.save(first);

    await expectLater(
      repository.save(
        _entry(
          id: 'diary-2',
          generationId: 'generation-1',
          dayKey: dayKey,
          version: 2,
          updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
        ),
      ),
      throwsStateError,
    );
  });
}

DiaryEntry _entry({
  required String id,
  required String generationId,
  required DiaryDayKey dayKey,
  required int version,
  required DateTime updatedAtUtc,
}) {
  return DiaryEntry(
    id: id,
    dayKey: dayKey,
    version: version,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '차분함',
    oneLineSummary: '오늘의 한 줄',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '오늘의 본문')],
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: generationId,
    generatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: updatedAtUtc,
  );
}
