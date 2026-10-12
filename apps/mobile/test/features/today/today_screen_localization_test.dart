import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/app/namu_app.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/share/application/share_diary.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';
import 'package:namu/l10n/namu_formatters.dart';

import '../chat/support/fake_message_repository.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
    binding.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets(
    'shows English Today navigation without translating saved messages',
    (tester) async {
      binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
      binding.platformDispatcher.localesTestValue = const <Locale>[
        Locale('en', 'US'),
      ];
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.utc(2026, 10, 4, 8);
      final localNow = now.toLocal();
      final dayKey = DiaryDayKey.fromInstant(
        instant: now,
        timeZone: TimeZoneSnapshot(
          timeZoneId: localNow.timeZoneName,
          utcOffset: localNow.timeZoneOffset,
        ),
      );
      final messages = FakeMessageRepository();
      await messages.upsert(
        Message(
          id: 'message-1',
          requestId: 'request-1',
          dayKey: dayKey,
          role: MessageRole.user,
          text: '노을이 예뻐던 퇴근길',
          createdAtUtc: now,
          status: MessageStatus.sent,
        ),
      );

      await tester.pumpWidget(
        NamuApp(
          messageRepository: messages,
          dailyCloseEnabled: false,
          utcNow: () => now,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Today’s diary'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('노을이 예뻐던 퇴근길'), findsOneWidget);
    },
  );

  testWidgets('builds share copy from the active locale and keeps diary data', (
    tester,
  ) async {
    binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.utc(2026, 10, 4, 8);
    final localNow = now.toLocal();
    final dayKey = DiaryDayKey.fromInstant(
      instant: now,
      timeZone: TimeZoneSnapshot(
        timeZoneId: localNow.timeZoneName,
        utcOffset: localNow.timeZoneOffset,
      ),
    );
    final diaries = InMemoryDiaryRepository();
    await diaries.save(
      DiaryEntry(
        id: 'diary-1',
        dayKey: dayKey,
        version: 1,
        status: DiaryEntryStatus.finalized,
        weather: WeatherSnapshot.manual(
          condition: '맑음',
          temperatureCelsius: 20.5,
        ),
        mood: '평온함',
        oneLineSummary: '내가 쓴 한 줄은 바꾸지 마',
        theme: DiaryTheme.light,
        blocks: const <DiaryBlock>[DiaryTextBlock(text: '내가 쓴 일기 본문도 그대로 두기.')],
        memoryCandidates: const <DiaryMemoryCandidate>[],
        sourceMessageIds: const <String>[],
        generationId: 'generation-1',
        generatedAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    final renderer = _CaptureShareRenderer();

    await tester.pumpWidget(
      NamuApp(
        diaryRepository: diaries,
        shareDiary: ShareDiary(
          renderer: renderer,
          launcher: const _OpenedShareLauncher(),
        ),
        dailyCloseEnabled: false,
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('내가 쓴 한 줄은 바꾸지 마'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('diary.share')));
    await tester.tap(find.byKey(const Key('diary.share')));
    await tester.pumpAndSettle();

    final copy = renderer.localizedCopy;
    expect(copy, isNotNull);
    expect(copy!.title, 'Today’s record');
    expect(
      copy.displayDate,
      NamuFormatters.fullDate(dayKey.labelDate, const Locale('en', 'US')),
    );
    expect(copy.displayWeather, '맑음 20.5°C');
    expect(copy.formatPageNumber(1, 3), '1 / 3');
    expect(copy.captionMetadata, 'Sunday, October 4, 2026 · 맑음 20.5°C · 평온함');
    expect(copy.photoUnavailableMessage, 'Photo unavailable');
    expect(find.text('내가 쓴 한 줄은 바꾸지 마'), findsOneWidget);
  });
}

final class _CaptureShareRenderer implements DiaryShareRenderer {
  DiaryShareLocalizedCopy? localizedCopy;

  @override
  Future<DiaryShareRenderResult> render(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  ) async {
    this.localizedCopy = localizedCopy;
    return DiaryShareRenderResult(
      artifacts: const <DiaryShareArtifact>[
        DiaryShareArtifact(
          path: '/tmp/namu-today-localization-share.png',
          mimeType: 'image/png',
          pixelWidth: 1080,
          pixelHeight: 1350,
          byteLength: 1,
        ),
      ],
      caption: entry.oneLineSummary,
    );
  }
}

final class _OpenedShareLauncher implements ShareSheetLauncher {
  const _OpenedShareLauncher();

  @override
  Future<ShareSheetOutcome> launch(ShareSheetRequest request) async {
    return ShareSheetOutcome.opened;
  }
}
