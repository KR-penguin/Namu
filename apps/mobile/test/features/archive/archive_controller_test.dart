import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/archive/application/archive_controller.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/diary_repository.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  test(
    'reload exposes loading and stores entries in repository order',
    () async {
      final pending = Completer<List<DiaryEntry>>();
      final repository = _ScriptedDiaryRepository([() => pending.future]);
      final controller = ArchiveController(repository: repository);

      final reload = controller.reload();

      expect(controller.isLoading, isTrue);
      expect(controller.hasLoaded, isFalse);
      expect(controller.entries, isEmpty);
      expect(controller.error, isNull);

      final older = _entry(
        id: 'older',
        day: 2,
        updatedAtUtc: DateTime.utc(2026, 10, 2, 12),
      );
      final newer = _entry(
        id: 'newer',
        day: 4,
        updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
      );
      pending.complete([older, newer]);
      await reload;

      expect(controller.isLoading, isFalse);
      expect(controller.hasLoaded, isTrue);
      expect(controller.entries.map((entry) => entry.id), ['newer', 'older']);
      expect(
        () => controller.entries.add(older),
        throwsUnsupportedError,
        reason: 'Callers must not mutate controller state.',
      );
    },
  );

  test('reload reports errors, retains data, and can recover', () async {
    final first = _entry(
      id: 'first',
      day: 3,
      updatedAtUtc: DateTime.utc(2026, 10, 3, 12),
    );
    final recovered = _entry(
      id: 'recovered',
      day: 4,
      updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
    );
    final repository = _ScriptedDiaryRepository([
      () async => [first],
      () async => throw StateError('offline'),
      () async => [recovered],
    ]);
    final controller = ArchiveController(repository: repository);

    await controller.reload();
    await expectLater(controller.reload(), throwsStateError);

    expect(controller.isLoading, isFalse);
    expect(controller.error, isA<StateError>());
    expect(controller.entries.single.id, 'first');

    await controller.reload();

    expect(controller.error, isNull);
    expect(controller.entries.single.id, 'recovered');
    expect(repository.listAllCalls, 3);
  });

  test(
    'search normalizes case and whitespace across date mood and summary',
    () async {
      final firstVersion = _entry(
        id: 'first-version',
        day: 4,
        version: 1,
        mood: 'Calm Evening',
        summary: '공원 산책을 한 날',
        updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
      );
      final secondVersion = _entry(
        id: 'second-version',
        day: 4,
        version: 2,
        mood: '차분함',
        summary: '다시 정리한 산책 기록',
        updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
      );
      final other = _entry(
        id: 'other',
        day: 5,
        mood: '활기참',
        summary: '친구와 저녁 식사',
        updatedAtUtc: DateTime.utc(2026, 10, 5, 12),
      );
      final controller = ArchiveController(
        repository: _ScriptedDiaryRepository([
          () async => [firstVersion, other, secondVersion],
        ]),
      );

      await controller.reload();

      controller.updateSearchQuery('  CALM   evening  ');
      expect(controller.entries.map((entry) => entry.id), ['first-version']);

      controller.updateSearchQuery('2026-10-04 산책');
      expect(controller.entries.map((entry) => entry.id), [
        'second-version',
        'first-version',
      ]);

      controller.updateSearchQuery('   ');
      expect(controller.entries.map((entry) => entry.id), [
        'other',
        'second-version',
        'first-version',
      ]);
    },
  );

  test(
    'search query and filtered view survive reload errors and recovery',
    () async {
      final first = _entry(
        id: 'first',
        day: 3,
        mood: '차분함',
        summary: '조용히 쉰 날',
        updatedAtUtc: DateTime.utc(2026, 10, 3, 12),
      );
      final recoveredMatch = _entry(
        id: 'recovered-match',
        day: 4,
        mood: '차분함',
        summary: '산책한 날',
        updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
      );
      final recoveredOther = _entry(
        id: 'recovered-other',
        day: 5,
        mood: '활기참',
        summary: '친구를 만난 날',
        updatedAtUtc: DateTime.utc(2026, 10, 5, 12),
      );
      final repository = _ScriptedDiaryRepository([
        () async => [first],
        () async => throw StateError('offline'),
        () async => [recoveredOther, recoveredMatch],
      ]);
      final controller = ArchiveController(repository: repository);

      await controller.reload();
      controller.updateSearchQuery('차분');
      await expectLater(controller.reload(), throwsStateError);

      expect(controller.searchQuery, '차분');
      expect(controller.entries.map((entry) => entry.id), ['first']);

      await controller.reload();

      expect(controller.searchQuery, '차분');
      expect(controller.entries.map((entry) => entry.id), ['recovered-match']);
    },
  );

  test('ignores duplicate reload requests while one is running', () async {
    final pending = Completer<List<DiaryEntry>>();
    final repository = _ScriptedDiaryRepository([() => pending.future]);
    final controller = ArchiveController(repository: repository);

    final first = controller.reload();
    final duplicate = controller.reload();

    expect(repository.listAllCalls, 1);
    pending.complete(const []);
    await Future.wait([first, duplicate]);
    expect(controller.hasLoaded, isTrue);
  });
}

final class _ScriptedDiaryRepository implements DiaryRepository {
  _ScriptedDiaryRepository(this._loads);

  final List<Future<List<DiaryEntry>> Function()> _loads;
  int listAllCalls = 0;

  @override
  Future<List<DiaryEntry>> listAll() {
    listAllCalls += 1;
    return _loads.removeAt(0)();
  }

  @override
  Future<void> deleteById(String id) => throw UnimplementedError();

  @override
  Future<DiaryEntry?> findLatestForDay(DiaryDayKey dayKey) =>
      throw UnimplementedError();

  @override
  Future<void> save(DiaryEntry entry) => throw UnimplementedError();

  @override
  Future<DiaryEntry> createDraftIfAbsent({
    required String generationId,
    required DiaryDayKey dayKey,
    required DiaryDraftBuilder build,
  }) => throw UnimplementedError();
}

DiaryEntry _entry({
  required String id,
  required int day,
  required DateTime updatedAtUtc,
  int version = 1,
  String mood = '차분함',
  String? summary,
}) {
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, day, 12),
    timeZone: TimeZoneSnapshot(timeZoneId: 'Etc/UTC', utcOffset: Duration.zero),
  );
  return DiaryEntry(
    id: id,
    dayKey: dayKey,
    version: version,
    status: DiaryEntryStatus.finalized,
    weather: const WeatherSnapshot.noWeather(),
    mood: mood,
    oneLineSummary: summary ?? '$day일의 한 줄',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '본문')],
    memoryCandidates: const [],
    sourceMessageIds: const [],
    generationId: 'generation-$id',
    generatedAtUtc: updatedAtUtc,
    updatedAtUtc: updatedAtUtc,
  );
}
