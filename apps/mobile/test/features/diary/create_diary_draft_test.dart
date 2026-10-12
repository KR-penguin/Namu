import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/application/create_diary_draft.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/diary_repository.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  late _FakeDiaryRepository repository;
  late List<String> ids;
  late CreateDiaryDraft createDiaryDraft;

  setUp(() {
    repository = _FakeDiaryRepository();
    ids = <String>['diary-1', 'diary-2', 'diary-3'];
    createDiaryDraft = CreateDiaryDraft(
      repository: repository,
      nextId: () => ids.removeAt(0),
      utcNow: () => DateTime.utc(2026, 10, 4, 15),
    );
  });

  test('combines an explicit no-weather snapshot with model output', () async {
    final entry = await createDiaryDraft(
      CreateDiaryDraftCommand(
        generationId: 'generation-1',
        dayKey: _seoulDay(),
        weather: const WeatherSnapshot.noWeather(),
        output: _output(),
        sourceMessageIds: const <String>['message-1'],
      ),
    );

    expect(entry.status, DiaryEntryStatus.draft);
    expect(entry.weather.provenance, WeatherProvenance.noWeather);
    expect(entry.mood, '평온함');
    expect(entry.oneLineSummary, '산책으로 숨을 고른 하루');
    expect(entry.theme, DiaryTheme.dark);
    expect(entry.blocks, hasLength(1));
    expect(entry.memoryCandidates, hasLength(1));
    expect(entry.sourceMessageIds, const <String>['message-1']);
    expect(entry.generatedAtUtc, DateTime.utc(2026, 10, 4, 15));
  });

  test('increments versions only within the exact DiaryDayKey', () async {
    final seoulDay = _seoulDay();
    final utcDayWithSameLabel = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(timeZoneId: 'UTC', utcOffset: Duration.zero),
    );

    final firstSeoul = await createDiaryDraft(
      _command(generationId: 'generation-seoul-1', dayKey: seoulDay),
    );
    final firstUtc = await createDiaryDraft(
      _command(generationId: 'generation-utc-1', dayKey: utcDayWithSameLabel),
    );
    final secondSeoul = await createDiaryDraft(
      _command(generationId: 'generation-seoul-2', dayKey: seoulDay),
    );

    expect(firstSeoul.version, 1);
    expect(firstUtc.version, 1);
    expect(secondSeoul.version, 2);
  });

  test('returns the original draft when generationId is retried', () async {
    final command = _command(
      generationId: 'generation-retry',
      dayKey: _seoulDay(),
    );

    final first = await createDiaryDraft(command);
    final retry = await createDiaryDraft(command);

    expect(retry, same(first));
    expect(repository.entries, hasLength(1));
    expect(ids, <String>['diary-2', 'diary-3']);
  });
}

CreateDiaryDraftCommand _command({
  required String generationId,
  required DiaryDayKey dayKey,
}) {
  return CreateDiaryDraftCommand(
    generationId: generationId,
    dayKey: dayKey,
    weather: WeatherSnapshot.manual(condition: '맑음'),
    output: _output(),
    sourceMessageIds: const <String>['message-1'],
  );
}

DiaryDayKey _seoulDay() {
  return DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );
}

DiaryGenerationOutput _output() {
  return DiaryGenerationOutput(
    schemaVersion: DiaryGenerationOutput.currentSchemaVersion,
    mood: '평온함',
    oneLineSummary: '산책으로 숨을 고른 하루',
    theme: DiaryTheme.dark,
    blocks: const <DiaryBlock>[DiaryTextBlock(text: '선선한 바람을 맞으며 걸었다.')],
    memoryCandidates: <DiaryMemoryCandidate>[
      DiaryMemoryCandidate(
        fact: '사용자는 산책을 좋아한다.',
        sourceMessageIds: const <String>['message-1'],
      ),
    ],
  );
}

final class _FakeDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = <DiaryEntry>[];

  List<DiaryEntry> get entries => List<DiaryEntry>.unmodifiable(_entries);

  @override
  Future<void> deleteById(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<DiaryEntry?> findLatestForDay(DiaryDayKey dayKey) async {
    final matching = _entries.where((entry) => entry.dayKey == dayKey).toList()
      ..sort((left, right) => right.version.compareTo(left.version));
    return matching.isEmpty ? null : matching.first;
  }

  @override
  Future<List<DiaryEntry>> listAll() async {
    return List<DiaryEntry>.of(_entries)..sort((left, right) {
      final byUpdated = right.updatedAtUtc.compareTo(left.updatedAtUtc);
      return byUpdated != 0 ? byUpdated : left.id.compareTo(right.id);
    });
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    _entries.removeWhere((existing) => existing.id == entry.id);
    _entries.add(entry);
  }

  @override
  Future<DiaryEntry> createDraftIfAbsent({
    required String generationId,
    required DiaryDayKey dayKey,
    required DiaryDraftBuilder build,
  }) async {
    for (final entry in _entries) {
      if (entry.generationId == generationId) {
        return entry;
      }
    }

    var nextVersion = 1;
    for (final entry in _entries.where((entry) => entry.dayKey == dayKey)) {
      if (entry.version >= nextVersion) {
        nextVersion = entry.version + 1;
      }
    }

    final entry = build(nextVersion);
    _entries.add(entry);
    return entry;
  }
}
