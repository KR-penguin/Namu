import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 8),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );

  DiaryEntry buildEntry({
    DateTime? generatedAtUtc,
    DateTime? updatedAtUtc,
    Iterable<DiaryBlock>? blocks,
    Iterable<DiaryMemoryCandidate>? memoryCandidates,
    Iterable<String>? sourceMessageIds,
  }) {
    return DiaryEntry(
      id: 'diary-1',
      dayKey: dayKey,
      version: 1,
      status: DiaryEntryStatus.draft,
      weather: const WeatherSnapshot.noWeather(),
      mood: '평온함',
      oneLineSummary: '천천히 걸으며 마음을 정리한 날',
      theme: DiaryTheme.light,
      blocks:
          blocks ??
          const <DiaryBlock>[DiaryTextBlock(text: '오후에 동네를 천천히 걸었다.')],
      memoryCandidates:
          memoryCandidates ??
          <DiaryMemoryCandidate>[
            DiaryMemoryCandidate(
              fact: '사용자는 산책을 좋아한다.',
              sourceMessageIds: const <String>['message-1'],
            ),
          ],
      sourceMessageIds:
          sourceMessageIds ?? const <String>['message-1', 'message-2'],
      generationId: 'generation-1',
      generatedAtUtc: generatedAtUtc ?? DateTime.utc(2026, 10, 4, 15),
      updatedAtUtc: updatedAtUtc ?? DateTime.utc(2026, 10, 4, 15),
    );
  }

  test('requires generated and updated timestamps to be UTC', () {
    expect(
      () => buildEntry(generatedAtUtc: DateTime(2026, 10, 4, 15)),
      throwsArgumentError,
    );
    expect(
      () => buildEntry(updatedAtUtc: DateTime(2026, 10, 4, 15)),
      throwsArgumentError,
    );
  });

  test('copies and exposes ordered collections as immutable', () {
    final blocks = <DiaryBlock>[
      const DiaryTextBlock(text: '첫 문단'),
      const DiaryPhotoBlock(photoAssetId: 'photo-1'),
      const DiaryTextBlock(text: '마지막 문단'),
    ];
    final candidates = <DiaryMemoryCandidate>[
      DiaryMemoryCandidate(
        fact: '사용자는 산책을 좋아한다.',
        sourceMessageIds: const <String>['message-1'],
      ),
    ];
    final sourceMessageIds = <String>['message-1', 'message-2'];

    final entry = buildEntry(
      blocks: blocks,
      memoryCandidates: candidates,
      sourceMessageIds: sourceMessageIds,
    );
    blocks.clear();
    candidates.clear();
    sourceMessageIds.clear();

    expect(entry.blocks, hasLength(3));
    expect(entry.blocks[0], isA<DiaryTextBlock>());
    expect(entry.blocks[1], isA<DiaryPhotoBlock>());
    expect(entry.blocks[2], isA<DiaryTextBlock>());
    expect(entry.memoryCandidates, hasLength(1));
    expect(entry.sourceMessageIds, <String>['message-1', 'message-2']);
    expect(
      () => entry.blocks.add(const DiaryTextBlock(text: '변경')),
      throwsUnsupportedError,
    );
    expect(() => entry.memoryCandidates.clear(), throwsUnsupportedError);
    expect(
      () => entry.sourceMessageIds.add('message-3'),
      throwsUnsupportedError,
    );
  });

  test('finalizing returns a new finalized snapshot', () {
    final draft = buildEntry();
    final finalized = draft.finalize(
      updatedAtUtc: DateTime.utc(2026, 10, 4, 16),
    );

    expect(draft.status, DiaryEntryStatus.draft);
    expect(finalized.status, DiaryEntryStatus.finalized);
    expect(finalized.id, draft.id);
    expect(finalized.version, draft.version);
    expect(finalized.generatedAtUtc, draft.generatedAtUtc);
    expect(finalized.updatedAtUtc, DateTime.utc(2026, 10, 4, 16));
  });

  test(
    'revision changes editable content without changing snapshot identity',
    () {
      final original = buildEntry();

      final revised = original.revise(
        weather: WeatherSnapshot.manual(
          condition: '맑음',
          temperatureCelsius: 18.5,
        ),
        mood: '설렘',
        oneLineSummary: '새로운 장면을 오래 기억한 날',
        theme: DiaryTheme.dark,
        blocks: const <DiaryBlock>[
          DiaryTextBlock(text: '노을을 보며 한참 멈춰 있었다.'),
          DiaryPhotoBlock(photoAssetId: 'photo-1'),
        ],
        updatedAtUtc: DateTime.utc(2026, 10, 4, 16),
      );

      expect(revised.id, original.id);
      expect(revised.dayKey, original.dayKey);
      expect(revised.version, original.version);
      expect(revised.status, original.status);
      expect(revised.generationId, original.generationId);
      expect(revised.generatedAtUtc, original.generatedAtUtc);
      expect(revised.weather.provenance, WeatherProvenance.manual);
      expect(revised.weather.condition, '맑음');
      expect(revised.weather.temperatureCelsius, 18.5);
      expect(revised.mood, '설렘');
      expect(revised.oneLineSummary, '새로운 장면을 오래 기억한 날');
      expect(revised.theme, DiaryTheme.dark);
      expect(revised.blocks, hasLength(2));
    },
  );

  test('revision rejects an update timestamp older than the snapshot', () {
    final original = buildEntry(updatedAtUtc: DateTime.utc(2026, 10, 4, 16));

    expect(
      () => original.revise(
        weather: original.weather,
        mood: original.mood,
        oneLineSummary: original.oneLineSummary,
        theme: original.theme,
        blocks: original.blocks,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 15, 59),
      ),
      throwsArgumentError,
    );
  });
}
