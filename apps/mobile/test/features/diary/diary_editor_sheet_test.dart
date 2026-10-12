import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/l10n/ai_response_locale.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/diary/application/diary_controller.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/diary/presentation/diary_editor_sheet.dart';
import 'package:namu/features/media/presentation/local_photo.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/l10n/app_localizations.dart';

void main() {
  late DiaryController controller;

  setUp(() async {
    final dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
    final diaries = InMemoryDiaryRepository();
    await diaries.save(_entry(dayKey));
    controller = DiaryController(
      dayKey: dayKey,
      diaryRepository: diaries,
      messageRepository: InMemoryMessageRepository(),
      generationGateway: _UnusedGateway(),
      responseLocaleProvider: () => AiResponseLocale.ko,
      personaProvider: AiPersona.safeDefault,
      weatherProvider: () async => const WeatherSnapshot.noWeather(),
      nextId: () => 'unused-id',
      utcNow: () => DateTime.utc(2026, 10, 4, 12),
    );
    await controller.load();
  });

  tearDown(() => controller.dispose());

  testWidgets('saves weather, mood, summary, theme, text and photo inclusion', (
    tester,
  ) async {
    await _openSheet(tester, controller);

    await tester.enterText(find.byKey(const Key('diary.editor.mood')), '뿌듯함');
    await tester.enterText(
      find.byKey(const Key('diary.editor.summary')),
      '내가 직접 다듬어 간직할 하루',
    );
    await tester.tap(find.byKey(const Key('diary.editor.weather.enabled')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.condition')),
      '맑음',
    );
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.temperature')),
      '18.5',
    );
    await tester.enterText(
      find.byKey(const Key('diary.editor.block.0.text')),
      '직접 고친 첫 문단',
    );
    await tester.ensureVisible(find.text('어두운 배경'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('어두운 배경'));
    await tester.ensureVisible(
      find.byKey(const Key('diary.editor.block.1.remove')),
    );
    await tester.tap(find.byKey(const Key('diary.editor.block.1.remove')));
    await tester.ensureVisible(find.byKey(const Key('diary.editor.save')));
    await tester.tap(find.byKey(const Key('diary.editor.save')));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryEditorSheet), findsNothing);
    expect(controller.entry?.mood, '뿌듯함');
    expect(controller.entry?.oneLineSummary, '내가 직접 다듬어 간직할 하루');
    expect(controller.entry?.weather.provenance, WeatherProvenance.manual);
    expect(controller.entry?.weather.condition, '맑음');
    expect(controller.entry?.weather.temperatureCelsius, 18.5);
    expect(controller.entry?.theme, DiaryTheme.dark);
    expect(controller.entry?.blocks, hasLength(2));
    expect(controller.entry?.blocks.whereType<DiaryPhotoBlock>(), isEmpty);
    expect(
      (controller.entry?.blocks.first as DiaryTextBlock).text,
      '직접 고친 첫 문단',
    );
  });

  testWidgets('keeps invalid manual temperature in the editor', (tester) async {
    await _openSheet(tester, controller);

    await tester.tap(find.byKey(const Key('diary.editor.weather.enabled')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.condition')),
      '흐림',
    );
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.temperature')),
      '열여덟',
    );
    await tester.ensureVisible(find.byKey(const Key('diary.editor.save')));
    await tester.tap(find.byKey(const Key('diary.editor.save')));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryEditorSheet), findsOneWidget);
    expect(find.text('기분, 날씨, 한 줄 요약, 본문을 확인해 주세요.'), findsOneWidget);
    expect(controller.entry?.weather.provenance, WeatherProvenance.noWeather);
  });

  testWidgets('accepts the locale decimal separator for temperature', (
    tester,
  ) async {
    await _openSheet(tester, controller, locale: const Locale('es'));

    await tester.tap(find.byKey(const Key('diary.editor.weather.enabled')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.condition')),
      'soleado',
    );
    await tester.enterText(
      find.byKey(const Key('diary.editor.weather.temperature')),
      '18,5',
    );
    await tester.ensureVisible(find.byKey(const Key('diary.editor.save')));
    await tester.tap(find.byKey(const Key('diary.editor.save')));
    await tester.pumpAndSettle();

    expect(controller.entry?.weather.condition, 'soleado');
    expect(controller.entry?.weather.temperatureCelsius, 18.5);
  });

  testWidgets('reorders blocks and keeps validation errors in the sheet', (
    tester,
  ) async {
    await _openSheet(tester, controller);

    await tester.ensureVisible(
      find.byKey(const Key('diary.editor.block.0.down')),
    );
    await tester.tap(find.byKey(const Key('diary.editor.block.0.down')));
    await tester.enterText(find.byKey(const Key('diary.editor.mood')), '   ');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('diary.editor.save')));
    await tester.tap(find.byKey(const Key('diary.editor.save')));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryEditorSheet), findsOneWidget);
    expect(find.text('기분, 날씨, 한 줄 요약, 본문을 확인해 주세요.'), findsOneWidget);
    expect(controller.entry?.blocks.first, isA<DiaryTextBlock>());
  });

  testWidgets('shows a safe local thumbnail without exposing its asset id', (
    tester,
  ) async {
    final requestedIds = <String>[];
    final semantics = tester.ensureSemantics();

    await _openSheet(
      tester,
      controller,
      photoBytesLoader: (assetId) async {
        requestedIds.add(assetId);
        return _onePixelPng;
      },
    );
    await tester.ensureVisible(
      find.byKey(const Key('diary.editor.block.1.photo')),
    );
    await tester.pumpAndSettle();

    expect(requestedIds, <String>['photo-1']);
    expect(find.byKey(const Key('localPhoto.image')), findsOneWidget);
    expect(find.textContaining('photo-1'), findsNothing);
    expect(find.bySemanticsLabel('첨부 사진'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('photo-1')), findsNothing);
    semantics.dispose();
  });

  testWidgets('uses a non-sensitive fallback when photo bytes cannot load', (
    tester,
  ) async {
    await _openSheet(
      tester,
      controller,
      photoBytesLoader: (_) => Future<Uint8List>.error(StateError('missing')),
    );
    await tester.ensureVisible(
      find.byKey(const Key('diary.editor.block.1.photo')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('localPhoto.fallback')), findsOneWidget);
    expect(find.textContaining('photo-1'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openSheet(
  WidgetTester tester,
  DiaryController controller, {
  LocalPhotoBytesLoader? photoBytesLoader,
  Locale locale = const Locale('ko'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => DiaryEditorSheet(
                controller: controller,
                photoBytesLoader: photoBytesLoader,
              ),
            ),
            child: const Text('편집 열기'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('편집 열기'));
  await tester.pumpAndSettle();
}

DiaryEntry _entry(DiaryDayKey dayKey) {
  return DiaryEntry(
    id: 'diary-1',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '차분함',
    oneLineSummary: '처음 만들어진 한 줄',
    theme: DiaryTheme.light,
    blocks: const [
      DiaryTextBlock(text: '첫 문단'),
      DiaryPhotoBlock(photoAssetId: 'photo-1'),
      DiaryTextBlock(text: '마지막 문단'),
    ],
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: 'generation-1',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
  );
}

final class _UnusedGateway implements DiaryGenerationGateway {
  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) {
    throw StateError('must not be called');
  }
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
  'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);
