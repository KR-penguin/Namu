import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/diary/data/diary_entry_json_codec.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  const codec = DiaryEntryJsonCodec();

  test('round-trips the complete diary snapshot without losing order', () {
    final entry = _entry();

    final restored = codec.decode(codec.encode(entry));

    expect(restored.id, entry.id);
    expect(restored.dayKey, entry.dayKey);
    expect(restored.version, entry.version);
    expect(restored.status, entry.status);
    expect(restored.weather.provenance, WeatherProvenance.provider);
    expect(restored.weather.condition, '구름 조금');
    expect(restored.weather.temperatureCelsius, 21.25);
    expect(restored.weather.providerId, 'weather-provider');
    expect(
      restored.weather.observedAtUtc,
      DateTime.utc(2026, 10, 4, 7, 30, 12, 345, 678),
    );
    expect(restored.mood, entry.mood);
    expect(restored.oneLineSummary, entry.oneLineSummary);
    expect(restored.theme, DiaryTheme.dark);
    expect(restored.blocks, [
      isA<DiaryTextBlock>().having((block) => block.text, 'text', '첫 문단'),
      isA<DiaryPhotoBlock>().having(
        (block) => block.photoAssetId,
        'photoAssetId',
        'photo-1',
      ),
      isA<DiaryTextBlock>().having((block) => block.text, 'text', '마지막 문단'),
    ]);
    expect(restored.memoryCandidates, hasLength(1));
    expect(restored.memoryCandidates.single.fact, '사용자는 산책을 좋아한다.');
    expect(restored.memoryCandidates.single.sourceMessageIds, ['message-1']);
    expect(restored.sourceMessageIds, ['message-1', 'message-2']);
    expect(restored.generationId, entry.generationId);
    expect(restored.generatedAtUtc, entry.generatedAtUtc);
    expect(restored.updatedAtUtc, entry.updatedAtUtc);
  });

  test('uses an exact versioned top-level contract', () {
    final json = _jsonFor(_entry());
    json['unexpected'] = true;

    expect(() => codec.decode(jsonEncode(json)), throwsFormatException);

    json.remove('unexpected');
    json.remove('mood');
    expect(() => codec.decode(jsonEncode(json)), throwsFormatException);

    json['mood'] = '평온함';
    json['schemaVersion'] = 2;
    expect(() => codec.decode(jsonEncode(json)), throwsFormatException);
  });

  test('rejects unsupported persisted enums and block fields', () {
    final statusJson = _jsonFor(_entry())..['status'] = 'archived';
    expect(() => codec.decode(jsonEncode(statusJson)), throwsFormatException);

    final themeJson = _jsonFor(_entry())..['theme'] = 'sepia';
    expect(() => codec.decode(jsonEncode(themeJson)), throwsFormatException);

    final weatherJson = _jsonFor(_entry());
    (weatherJson['weather']! as Map<String, Object?>)['provenance'] = 'guess';
    expect(() => codec.decode(jsonEncode(weatherJson)), throwsFormatException);

    final blockJson = _jsonFor(_entry());
    final blocks = blockJson['blocks']! as List<Object?>;
    (blocks.first as Map<String, Object?>)['photoAssetId'] = 'not-allowed';
    expect(() => codec.decode(jsonEncode(blockJson)), throwsFormatException);
  });

  test('rejects timestamps that are not explicit UTC instants', () {
    final generatedJson = _jsonFor(_entry())
      ..['generatedAtUtc'] = '2026-10-04T15:00:00';
    expect(
      () => codec.decode(jsonEncode(generatedJson)),
      throwsFormatException,
    );

    final observedJson = _jsonFor(_entry());
    (observedJson['weather']! as Map<String, Object?>)['observedAtUtc'] =
        '2026-10-04T07:30:00+09:00';
    expect(() => codec.decode(jsonEncode(observedJson)), throwsFormatException);
  });
}

Map<String, Object?> _jsonFor(DiaryEntry entry) {
  return (jsonDecode(const DiaryEntryJsonCodec().encode(entry))
      as Map<String, Object?>);
}

DiaryEntry _entry({
  String id = 'diary-1',
  DiaryDayKey? dayKey,
  int version = 2,
  DiaryEntryStatus status = DiaryEntryStatus.finalized,
  String generationId = 'generation-1',
  DateTime? generatedAtUtc,
  DateTime? updatedAtUtc,
}) {
  return DiaryEntry(
    id: id,
    dayKey:
        dayKey ??
        DiaryDayKey.restore(
          labelDate: LocalDate(2026, 10, 4),
          timeZoneId: 'Asia/Seoul',
          cutoff: Duration.zero,
          policyVersion: 1,
        ),
    version: version,
    status: status,
    weather: WeatherSnapshot.provider(
      condition: '구름 조금',
      temperatureCelsius: 21.25,
      providerId: 'weather-provider',
      observedAtUtc: DateTime.utc(2026, 10, 4, 7, 30, 12, 345, 678),
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
    generatedAtUtc:
        generatedAtUtc ?? DateTime.utc(2026, 10, 4, 15, 0, 1, 234, 567),
    updatedAtUtc: updatedAtUtc ?? DateTime.utc(2026, 10, 4, 16, 0, 1, 987, 654),
  );
}
