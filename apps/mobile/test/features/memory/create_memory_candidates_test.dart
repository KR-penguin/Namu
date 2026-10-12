import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/memory/application/create_memory_candidates.dart';
import 'package:namu/features/memory/data/in_memory_memory_fact_repository.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';

void main() {
  late InMemoryMemoryFactRepository repository;
  late CreateMemoryCandidates createCandidates;

  setUp(() {
    repository = InMemoryMemoryFactRepository();
    createCandidates = CreateMemoryCandidates(
      repository: repository,
      utcNow: () => DateTime.utc(2026, 10, 4, 12),
    );
  });

  test('only a finalized diary can publish memory candidates', () async {
    await expectLater(createCandidates(_entry()), throwsStateError);
    expect(await repository.listAll(), isEmpty);
  });

  test(
    'creates conservative candidates with deterministic identities',
    () async {
      final entry = _entry().finalize(
        updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
      );

      final created = await createCandidates(entry);

      expect(created.map((fact) => fact.id), [
        'diary-1:memory:0',
        'diary-1:memory:1',
      ]);
      expect(
        created.every((fact) => fact.status == MemoryStatus.candidate),
        isTrue,
      );
      expect(
        created.every(
          (fact) => fact.sensitivity == MemorySensitivity.sensitive,
        ),
        isTrue,
      );
      expect(
        created.every((fact) => fact.category == MemoryCategory.other),
        isTrue,
      );
      expect(created.first.sourceMessageIds, ['message-1']);
    },
  );

  test('retry never overwrites a candidate the user already changed', () async {
    final entry = _entry().finalize(
      updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
    );
    await repository.save(
      MemoryFact(
        id: 'diary-1:memory:0',
        fact: '사용자가 직접 다듬은 기억',
        sourceMessageIds: const ['message-1'],
        category: MemoryCategory.other,
        sensitivity: MemorySensitivity.sensitive,
        status: MemoryStatus.active,
        createdAtUtc: DateTime.utc(2026, 10, 4, 11),
        updatedAtUtc: DateTime.utc(2026, 10, 4, 11, 30),
      ),
    );

    final result = await createCandidates(entry);

    expect(result.first.fact, '사용자가 직접 다듬은 기억');
    expect(result.first.status, MemoryStatus.active);
    expect(result.last.id, 'diary-1:memory:1');
    expect(await repository.listAll(), hasLength(2));
  });
}

DiaryEntry _entry() {
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );
  return DiaryEntry(
    id: 'diary-1',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '기쁨',
    oneLineSummary: '좋아하는 것들을 발견한 날',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '기억할 하루')],
    memoryCandidates: [
      DiaryMemoryCandidate(
        fact: '사용자는 재즈를 좋아한다.',
        sourceMessageIds: const ['message-1'],
      ),
      DiaryMemoryCandidate(
        fact: '사용자는 아침 산책을 시작했다.',
        sourceMessageIds: const ['message-2'],
      ),
    ],
    sourceMessageIds: const ['message-1', 'message-2'],
    generationId: 'generation-1',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
  );
}
