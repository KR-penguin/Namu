import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/archive/application/archive_controller.dart';
import 'package:namu/features/archive/presentation/archive_screen.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/diary_repository.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

void main() {
  Widget subject({
    required ArchiveController controller,
    ValueChanged<DiaryEntry>? onEntrySelected,
    TextScaler? textScaler,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          final screen = ArchiveScreen(
            controller: controller,
            onEntrySelected: onEntrySelected ?? (_) {},
          );
          if (textScaler == null) {
            return screen;
          }
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: screen,
          );
        },
      ),
    );
  }

  testWidgets('shows an honest empty state', (tester) async {
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([() async => const []]),
    );

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('archive.empty')), findsOneWidget);
    expect(find.text('아직 보관된 일기가 없어요'), findsOneWidget);
    expect(find.textContaining('샘플'), findsNothing);
  });

  testWidgets('shows a private error message and retries', (tester) async {
    final entry = _entry(id: 'recovered', day: 4);
    final repository = _ScriptedDiaryRepository([
      () async => throw StateError('secret raw database failure'),
      () async => [entry],
    ]);
    final controller = ArchiveController(repository: repository);

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('archive.error')), findsOneWidget);
    expect(find.text('일기를 불러오지 못했어요'), findsOneWidget);
    expect(find.textContaining('secret raw database failure'), findsNothing);

    await tester.tap(find.byKey(const Key('archive.retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('archive.error')), findsNothing);
    expect(find.byKey(const Key('archive.entry.recovered')), findsOneWidget);
    expect(repository.listAllCalls, 2);
  });

  testWidgets('renders newest-updated diaries first with required details', (
    tester,
  ) async {
    final older = _entry(
      id: 'older',
      day: 2,
      updatedAtUtc: DateTime.utc(2026, 10, 2, 12),
      status: DiaryEntryStatus.draft,
      mood: '조용함',
      summary: '오래된 하루의 기록',
    );
    final newer = _entry(
      id: 'newer',
      day: 4,
      updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
      mood: '상쾌함',
      summary: '새로운 하루의 기록',
    );
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([
        () async => [older, newer],
      ]),
    );

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('2026년 10월 4일 · 일요일'), findsOneWidget);
    expect(find.text('기분 · 상쾌함'), findsOneWidget);
    expect(find.text('새로운 하루의 기록'), findsOneWidget);
    expect(find.text('확정'), findsOneWidget);
    expect(find.text('초안'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('archive.entry.newer'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('archive.entry.older'))).dy,
      ),
    );
  });

  testWidgets('entry is an accessible button and forwards selection', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final entry = _entry(id: 'chosen', day: 4);
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([
        () async => [entry],
      ]),
    );
    DiaryEntry? selected;

    await tester.pumpWidget(
      subject(
        controller: controller,
        onEntrySelected: (entry) => selected = entry,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('2026년 10월 4일, 기분 차분함, 확정, 4일의 한 줄'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('archive.entry.chosen')));

    expect(selected, same(entry));
    semantics.dispose();
  });

  testWidgets('searches date mood and summary while keeping every version', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final firstVersion = _entry(
      id: 'first-version',
      day: 4,
      version: 1,
      mood: '차분함',
      summary: '공원 산책을 한 날',
      updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
    );
    final secondVersion = _entry(
      id: 'second-version',
      day: 4,
      version: 2,
      mood: '평온함',
      summary: '산책 기록을 다시 정리한 날',
      updatedAtUtc: DateTime.utc(2026, 10, 4, 12),
    );
    final other = _entry(
      id: 'other',
      day: 5,
      mood: '활기참',
      summary: '친구와 저녁 식사',
    );
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([
        () async => [firstVersion, other, secondVersion],
      ]),
    );

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();

    final search = find.byKey(const Key('archive.search.field'));
    expect(search, findsOneWidget);
    expect(tester.widget<TextField>(search).decoration?.labelText, '보관함 검색');
    expect(find.bySemanticsLabel('일기 보관함 검색'), findsOneWidget);

    await tester.enterText(search, '2026-10-04 산책');
    await tester.pump();

    expect(
      find.byKey(const Key('archive.entry.first-version')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('archive.entry.second-version')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('archive.entry.other')), findsNothing);

    await tester.tap(find.byKey(const Key('archive.search.clear')));
    await tester.pump();

    expect(find.byKey(const Key('archive.entry.other')), findsOneWidget);
    expect(controller.searchQuery, isEmpty);
    semantics.dispose();
  });

  testWidgets('shows an explicit no-results state and can clear the query', (
    tester,
  ) async {
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([
        () async => [_entry(id: 'entry', day: 4)],
      ]),
    );

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('archive.search.field')),
      '검색되지 않는 문장',
    );
    await tester.pump();

    expect(find.byKey(const Key('archive.noResults')), findsOneWidget);
    expect(find.text('검색 결과가 없어요'), findsOneWidget);
    expect(find.byKey(const Key('archive.empty')), findsNothing);

    await tester.tap(find.byKey(const Key('archive.noResults.clear')));
    await tester.pump();

    expect(find.byKey(const Key('archive.noResults')), findsNothing);
    expect(find.byKey(const Key('archive.entry.entry')), findsOneWidget);
  });

  testWidgets('keeps the query and filtered results when reload fails', (
    tester,
  ) async {
    final repository = _ScriptedDiaryRepository([
      () async => [
        _entry(id: 'match', day: 4, mood: '차분함'),
        _entry(id: 'other', day: 5, mood: '활기참'),
      ],
      () async => throw StateError('private database error'),
    ]);
    final controller = ArchiveController(repository: repository);

    await tester.pumpWidget(subject(controller: controller));
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('archive.search.field'));
    await tester.enterText(search, '차분');
    await tester.pump();

    await tester.tap(find.byKey(const Key('archive.reload')));
    await tester.pumpAndSettle();

    expect(controller.searchQuery, '차분');
    expect(tester.widget<TextField>(search).controller?.text, '차분');
    expect(find.byKey(const Key('archive.entry.match')), findsOneWidget);
    expect(find.byKey(const Key('archive.entry.other')), findsNothing);
    expect(find.textContaining('private database error'), findsNothing);
    expect(find.textContaining('기존 일기는 그대로'), findsOneWidget);
  });

  testWidgets('search fits a 320 by 568 large-text viewport without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final longText = List.filled(20, '아주 긴 기록').join(' ');
    final entries = List.generate(
      6,
      (index) => _entry(
        id: 'entry-$index',
        day: index + 1,
        mood: longText,
        summary: longText,
      ),
    );
    final controller = ArchiveController(
      repository: _ScriptedDiaryRepository([() async => entries]),
    );

    await tester.pumpWidget(
      subject(controller: controller, textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const Key('archive.search.field')),
      '아주 긴 기록',
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('archive.entry.entry-0')),
      400,
      scrollable: find.descendant(
        of: find.byKey(const Key('archive.list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('archive.entry.entry-0')), findsOneWidget);
    expect(tester.takeException(), isNull);
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
  DateTime? updatedAtUtc,
  int version = 1,
  DiaryEntryStatus status = DiaryEntryStatus.finalized,
  String mood = '차분함',
  String? summary,
}) {
  final timestamp = updatedAtUtc ?? DateTime.utc(2026, 10, day, 12);
  final dayKey = DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, day, 12),
    timeZone: TimeZoneSnapshot(timeZoneId: 'Etc/UTC', utcOffset: Duration.zero),
  );
  return DiaryEntry(
    id: id,
    dayKey: dayKey,
    version: version,
    status: status,
    weather: const WeatherSnapshot.noWeather(),
    mood: mood,
    oneLineSummary: summary ?? '$day일의 한 줄',
    theme: DiaryTheme.light,
    blocks: const [DiaryTextBlock(text: '본문')],
    memoryCandidates: const [],
    sourceMessageIds: const [],
    generationId: 'generation-$id',
    generatedAtUtc: timestamp,
    updatedAtUtc: timestamp,
  );
}
