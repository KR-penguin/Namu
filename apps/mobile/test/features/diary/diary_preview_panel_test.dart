import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/diary/presentation/diary_preview_panel.dart';
import 'package:namu/features/media/presentation/local_photo.dart';
import 'package:namu/l10n/app_localizations.dart';
import 'package:namu/l10n/namu_formatters.dart';

void main() {
  late DiaryDayKey dayKey;

  setUp(() {
    dayKey = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    );
  });

  Widget subject({
    DiaryEntry? entry,
    bool isGenerating = false,
    bool canGenerate = true,
    VoidCallback? onBack,
    VoidCallback? onGenerate,
    VoidCallback? onFinalize,
    VoidCallback? onEdit,
    VoidCallback? onShare,
    LocalPhotoBytesLoader? photoBytesLoader,
    TextScaler? textScaler,
    Locale locale = const Locale('ko'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        if (textScaler == null) return child!;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        );
      },
      home: Scaffold(
        body: DiaryPreviewPanel(
          dayKey: dayKey,
          entry: entry,
          isGenerating: isGenerating,
          canGenerate: canGenerate,
          onBack: onBack,
          onGenerate: onGenerate,
          onFinalize: onFinalize,
          onEdit: onEdit,
          onShare: onShare,
          photoBytesLoader: photoBytesLoader,
        ),
      ),
    );
  }

  testWidgets('shows an honest empty state and forwards generation intent', (
    tester,
  ) async {
    var generationCount = 0;
    await tester.pumpWidget(subject(onGenerate: () => generationCount += 1));

    expect(find.byKey(const Key('diary.preview.panel')), findsOneWidget);
    expect(find.byKey(const Key('diary.empty')), findsOneWidget);
    expect(find.text('아직 오늘의 일기가 없어요'), findsOneWidget);
    expect(find.textContaining('샘플 데이터'), findsNothing);

    await tester.tap(find.byKey(const Key('diary.generate')));
    expect(generationCount, 1);
  });

  testWidgets('disables generation without source messages', (tester) async {
    await tester.pumpWidget(subject(canGenerate: false, onGenerate: () {}));

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('diary.generate')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('먼저 오늘의 이야기를 남겨주세요.'), findsOneWidget);
  });

  testWidgets('renders the actual diary snapshot and its ordered blocks', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      subject(
        entry: _entry(dayKey),
        photoBytesLoader: (_) async => _onePixelPng,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diary.entry.card')), findsOneWidget);
    expect(
      find.text(NamuFormatters.fullDate(dayKey.labelDate, const Locale('ko'))),
      findsOneWidget,
    );
    expect(find.text('직접 입력 · 맑음 21°'), findsOneWidget);
    expect(find.text('차분함'), findsOneWidget);
    expect(find.text('조금 느려도, 오늘은 충분히 좋았다.'), findsOneWidget);
    expect(find.text('오늘은 평소보다 천천히 하루를 시작했다.'), findsOneWidget);
    expect(find.text('저녁에는 잠깐 동네를 걸었다.'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('diary.photo.photo-1')));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('첨부 사진'), findsOneWidget);
    expect(find.byKey(const Key('localPhoto.image')), findsOneWidget);
    expect(find.textContaining('게시됨'), findsNothing);
    semantics.dispose();
  });

  testWidgets(
    'localizes English chrome, date, weather, and status without translating user content',
    (tester) async {
      const locale = Locale('en', 'US');
      await tester.pumpWidget(
        subject(
          locale: locale,
          entry: _entry(dayKey),
          photoBytesLoader: (_) async => _onePixelPng,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today’s record'), findsOneWidget);
      expect(
        find.text('Saved on this device · edit history preserved'),
        findsOneWidget,
      );
      expect(find.text('Draft'), findsOneWidget);
      expect(
        find.text(NamuFormatters.fullDate(dayKey.labelDate, locale)),
        findsOneWidget,
      );
      expect(find.text('Entered manually · 맑음 21°'), findsOneWidget);
      expect(find.text('Today in one line'), findsOneWidget);
      expect(find.text('차분함'), findsOneWidget);
      expect(find.text('조금 느려도, 오늘은 충분히 좋았다.'), findsOneWidget);
      expect(find.text('오늘은 평소보다 천천히 하루를 시작했다.'), findsOneWidget);
    },
  );

  testWidgets(
    'shows every long ordered block across swipeable 4:5 pages without ellipsis',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const finalMarker = '오늘 기록의 마지막 문장';
      final longOpening = List<String>.filled(
        42,
        '천천히 걸으며 하루를 정리했다.',
      ).join(' ');
      final longEnding = List<String>.filled(
        36,
        '바람과 나무를 보며 마음을 돌봤다.',
      ).join(' ');

      await tester.pumpWidget(
        subject(
          entry: _entry(
            dayKey,
            blocks: <DiaryBlock>[
              DiaryTextBlock(text: longOpening),
              const DiaryPhotoBlock(photoAssetId: 'photo-1'),
              DiaryTextBlock(text: '$longEnding $finalMarker'),
            ],
          ),
          photoBytesLoader: (_) async => _onePixelPng,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('diary.entry.pages')), findsOneWidget);
      final firstIndicator = tester.widget<Text>(
        find.byKey(const Key('diary.page.indicator')),
      );
      final pageCount = int.parse(firstIndicator.data!.split('/').last.trim());
      expect(pageCount, greaterThan(1));

      final firstSegment = tester.widget<Text>(
        find.byKey(const Key('diary.block.0.segment.0')),
      );
      expect(firstSegment.maxLines, isNull);
      expect(firstSegment.overflow, isNot(TextOverflow.ellipsis));

      for (var page = 1; page < pageCount; page += 1) {
        await tester.drag(
          find.byKey(const Key('diary.entry.pages')),
          const Offset(-340, 0),
        );
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('diary.page.indicator')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('diary.page.indicator'))).data,
        '$pageCount / $pageCount',
      );
      expect(find.textContaining(finalMarker), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('gives photo blocks a large carousel treatment', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      subject(
        entry: _entry(
          dayKey,
          blocks: const <DiaryBlock>[DiaryPhotoBlock(photoAssetId: 'photo-1')],
        ),
        photoBytesLoader: (_) async => _onePixelPng,
      ),
    );
    await tester.pumpAndSettle();

    final photo = find.byKey(const Key('diary.photo.photo-1'));
    expect(photo, findsOneWidget);
    expect(tester.getSize(photo).height, greaterThanOrEqualTo(180));
    expect(tester.getSize(photo).width, greaterThan(250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a large-text preview operable without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      subject(entry: _entry(dayKey), textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('diary.entry.pages')), findsOneWidget);
    expect(find.byKey(const Key('diary.page.indicator')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draft actions only forward explicit user intent', (
    tester,
  ) async {
    var finalizeCount = 0;
    var editCount = 0;
    await tester.pumpWidget(
      subject(
        entry: _entry(dayKey),
        onFinalize: () => finalizeCount += 1,
        onEdit: () => editCount += 1,
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('diary.edit')));
    await tester.tap(find.byKey(const Key('diary.edit')));
    await tester.ensureVisible(find.byKey(const Key('diary.finalize')));
    await tester.tap(find.byKey(const Key('diary.finalize')));

    expect(editCount, 1);
    expect(finalizeCount, 1);
    expect(find.byKey(const Key('diary.share')), findsNothing);
  });

  testWidgets('a finalized diary exposes the user-driven share action', (
    tester,
  ) async {
    var shareCount = 0;
    await tester.pumpWidget(
      subject(
        entry: _entry(dayKey)
            .finalize(updatedAtUtc: DateTime.utc(2026, 10, 4, 11)),
        onShare: () => shareCount += 1,
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('diary.share')));
    await tester.tap(find.byKey(const Key('diary.share')));

    expect(shareCount, 1);
    expect(find.text('공유하기'), findsOneWidget);
  });

  testWidgets('only shows the back control when a callback is provided', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    expect(find.byKey(const Key('diary.preview.back')), findsNothing);

    var backCount = 0;
    await tester.pumpWidget(subject(onBack: () => backCount += 1));
    await tester.tap(find.byKey(const Key('diary.preview.back')));

    expect(backCount, 1);
  });

  testWidgets('fits a 360 by 720 viewport without layout overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      subject(entry: _entry(dayKey), onBack: () {}, onEdit: () {}),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byKey(const Key('diary.preview.panel')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    expect(find.text('수정하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
  'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

DiaryEntry _entry(DiaryDayKey dayKey, {Iterable<DiaryBlock>? blocks}) {
  return DiaryEntry(
    id: 'diary-1',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: WeatherSnapshot.manual(condition: '맑음', temperatureCelsius: 21),
    mood: '차분함',
    oneLineSummary: '조금 느려도, 오늘은 충분히 좋았다.',
    theme: DiaryTheme.light,
    blocks:
        blocks ??
        const [
          DiaryTextBlock(text: '오늘은 평소보다 천천히 하루를 시작했다.'),
          DiaryPhotoBlock(photoAssetId: 'photo-1'),
          DiaryTextBlock(text: '저녁에는 잠깐 동네를 걸었다.'),
        ],
    memoryCandidates: const [],
    sourceMessageIds: const ['message-1'],
    generationId: 'generation-1',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 10),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 10),
  );
}
