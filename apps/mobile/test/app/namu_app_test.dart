import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:namu/app/namu_app.dart';
import 'package:namu/core/network/gateway_config.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/chat/domain/chat_reply_gateway.dart';
import 'package:namu/features/chat/domain/message.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';
import 'package:namu/features/archive/presentation/archive_screen.dart';
import 'package:namu/features/diary/application/daily_close_coordinator.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/diary_generation_gateway.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';
import 'package:namu/features/diary/presentation/diary_editor_sheet.dart';
import 'package:namu/features/media/application/import_photo.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/features/media/application/pick_and_import_photo.dart';
import 'package:namu/features/memory/data/in_memory_memory_fact_repository.dart';
import 'package:namu/features/memory/domain/memory_fact.dart';
import 'package:namu/features/memory/presentation/memory_management_screen.dart';
import 'package:namu/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:namu/features/share/application/share_diary.dart';
import 'package:namu/features/share/domain/diary_share_renderer.dart';
import 'package:namu/features/share/domain/share_sheet_launcher.dart';
import 'package:namu/l10n/app_localizations.dart';

import '../features/chat/support/fake_chat_reply_gateway.dart';
import '../features/chat/support/fake_message_repository.dart';
import '../features/media/support/fake_media_file_store.dart';
import '../features/media/support/fake_media_repository.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('ko', 'KR'),
    ];
  });

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
    binding.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets('configures all approved locales and strict fallback', (
    tester,
  ) async {
    await tester.pumpWidget(const NamuApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
    expect(
      app.localeListResolutionCallback?.call(const <Locale>[
        Locale('zh', 'TW'),
      ], app.supportedLocales),
      const Locale('en'),
    );
  });

  testWidgets('creates the first default persona from the resolved locale', (
    tester,
  ) async {
    binding.platformDispatcher.localeTestValue = const Locale('ja', 'JP');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('ja', 'JP'),
    ];

    await tester.pumpWidget(const NamuApp());
    await tester.pumpAndSettle();

    expect(find.text('モア'), findsAtLeastNWidgets(1));
    expect(find.text('모아'), findsNothing);

    binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];
    await tester.pumpAndSettle();

    expect(find.text('モア'), findsAtLeastNWidgets(1));
    expect(find.text('Moa'), findsNothing);
  });

  testWidgets('chat requests use the latest resolved platform locale', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final requestLocales = <String>[];
    var responseCount = 0;
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      requestLocales.add(body['responseLocale']! as String);
      responseCount += 1;
      return http.Response(
        jsonEncode(<String, Object>{
          'schemaVersion': 1,
          'messageId': 'assistant-$responseCount',
          'text': 'reply $responseCount',
          'createdAtUtc': '2026-10-04T08:00:00.000Z',
        }),
        200,
        headers: const <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
      );
    });
    binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];

    await tester.pumpWidget(
      NamuApp(
        gatewayConfig: GatewayConfig(
          baseUri: Uri.parse('https://gateway.example.com'),
        ),
        gatewayHttpClient: client,
        gatewayAuthHeaders: () async => const <String, String>{},
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    binding.platformDispatcher.localeTestValue = const Locale('ja', 'JP');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('ja', 'JP'),
    ];
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      'first',
    );
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    binding.platformDispatcher.localeTestValue = const Locale('es', 'MX');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('es', 'MX'),
    ];
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      'second',
    );
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(requestLocales, <String>['ja', 'es']);
    client.close();
  });

  testWidgets('first run can continue locally without deciding AI consent', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final consent = InMemoryAiDataConsentRepository();

    await tester.pumpWidget(
      NamuApp(
        aiDataConsentRepository: consent,
        onboardingRepository: InMemoryOnboardingRepository(),
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('시작하기 전에 알아두세요'), findsOneWidget);
    expect(find.byKey(const Key('conversation.live.panel')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('onboarding.startLocal')));
    await tester.tap(find.byKey(const Key('onboarding.startLocal')));
    await tester.pumpAndSettle();

    expect((await consent.load()).choice, AiDataConsentChoice.undecided);
    expect(find.byKey(const Key('conversation.live.panel')), findsOneWidget);
  });

  testWidgets('declining consent keeps chat local and skips the AI gateway', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final consent = InMemoryAiDataConsentRepository(
      initial: AiDataConsent.declined(decidedAtUtc: DateTime.utc(2026, 10, 4)),
    );
    final gateway = FakeChatReplyGateway(
      onReply: (_) => throw StateError('must not reach delegate'),
    );

    await tester.pumpWidget(
      NamuApp(
        aiDataConsentRepository: consent,
        chatReplyGateway: gateway,
        gatewayConfigured: true,
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '기기에만 남길 이야기',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(gateway.requests, isEmpty);
    expect(find.text('기기에만 남길 이야기'), findsOneWidget);
    expect(find.text('AI 답변을 받지 못했어요'), findsOneWidget);
  });

  testWidgets('accepting consent retries a missed closed-day diary', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final now = DateTime.utc(2026, 10, 4, 8);
    final zone = TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    );
    final pastDay = DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 3, 8),
      timeZone: zone,
    );
    final messages = FakeMessageRepository();
    await messages.upsert(
      Message(
        id: 'past-message',
        requestId: 'past-request',
        dayKey: pastDay,
        role: MessageRole.user,
        text: '어제의 기록',
        createdAtUtc: DateTime.utc(2026, 10, 3, 8),
        status: MessageStatus.sent,
      ),
    );
    final consent = InMemoryAiDataConsentRepository();
    final diaries = InMemoryDiaryRepository();

    await tester.pumpWidget(
      NamuApp(
        messageRepository: messages,
        diaryRepository: diaries,
        diaryGenerationGateway: _DailyCloseDiaryGateway(),
        aiDataConsentRepository: consent,
        onboardingRepository: InMemoryOnboardingRepository(),
        timeZoneAt: (_) => zone,
        dailyCloseTimerScheduler: _DailyCloseTimerScheduler(),
        foregroundEvents: const Stream<void>.empty(),
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();
    expect(await diaries.findLatestForDay(pastDay), isNull);

    await tester.ensureVisible(find.byKey(const Key('onboarding.acceptAi')));
    await tester.tap(find.byKey(const Key('onboarding.acceptAi')));
    await tester.pumpAndSettle();

    expect(await diaries.findLatestForDay(pastDay), isNotNull);
  });

  testWidgets('AI friend settings opens consent review and revoke controls', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final consent = InMemoryAiDataConsentRepository(
      initial: AiDataConsent.accepted(decidedAtUtc: DateTime.utc(2026, 10, 4)),
    );

    await tester.pumpWidget(
      NamuApp(
        aiDataConsentRepository: consent,
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('AI 친구 설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('persona.aiDataConsent')));
    await tester.pumpAndSettle();

    expect(find.text('AI 데이터 전송'), findsOneWidget);
    expect(find.byKey(const Key('ai-consent.revoke')), findsOneWidget);
  });

  testWidgets('wide layout shows conversation and diary together', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 900));

    await tester.pumpWidget(const NamuApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byKey(const Key('today.desktop')), findsOneWidget);
    expect(find.byKey(const Key('conversation.live.panel')), findsOneWidget);
    expect(find.byKey(const Key('diary.preview.panel')), findsOneWidget);
    expect(find.text('모아'), findsWidgets);

    await tester.tap(find.byKey(const Key('conversation.openDiary')));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 일기가 오른쪽에 열려 있어요.'), findsOneWidget);
  });

  testWidgets('wide layout enables diary generation after the first message', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 900));
    final messages = FakeMessageRepository();
    final gateway = FakeChatReplyGateway(
      onReply: (_) async => ChatReply(
        messageId: 'assistant-wide-reply',
        text: '오늘 이야기를 기록해둘게.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
      ),
    );

    await tester.pumpWidget(
      NamuApp(
        messageRepository: messages,
        chatReplyGateway: gateway,
        gatewayConfigured: true,
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    FilledButton generateButton() =>
        tester.widget<FilledButton>(find.byKey(const Key('diary.generate')));
    expect(generateButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('conversation.composer.field')),
      '오늘은 오래 산책했어.',
    );
    await tester.tap(find.byTooltip('메시지 보내기'));
    await tester.pumpAndSettle();

    expect(generateButton().onPressed, isNotNull);
  });

  testWidgets('mobile layout moves between conversation and diary', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));

    await tester.pumpWidget(const NamuApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today.mobile')), findsOneWidget);
    expect(find.byKey(const Key('conversation.live.panel')), findsOneWidget);
    expect(find.byKey(const Key('diary.preview.panel')), findsNothing);

    await tester.tap(find.byKey(const Key('conversation.openDiary')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversation.live.panel')), findsNothing);
    expect(find.byKey(const Key('diary.preview.panel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('diary.preview.back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversation.live.panel')), findsOneWidget);
    expect(find.byKey(const Key('diary.preview.panel')), findsNothing);
  });

  testWidgets('active app closes the old day and rotates chat at midnight', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    var now = DateTime.utc(2026, 10, 4, 14, 59, 59, 999);
    final zone = TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    );
    final closingDay = DiaryDayKey.fromInstant(instant: now, timeZone: zone);
    final messages = FakeMessageRepository();
    await messages.upsert(
      Message(
        id: 'before-midnight-message',
        requestId: 'before-midnight-request',
        dayKey: closingDay,
        role: MessageRole.user,
        text: '자정 전에 남긴 이야기',
        createdAtUtc: now,
        status: MessageStatus.sent,
      ),
    );
    final diaries = InMemoryDiaryRepository();
    final timers = _DailyCloseTimerScheduler();

    await tester.pumpWidget(
      NamuApp(
        messageRepository: messages,
        diaryRepository: diaries,
        diaryGenerationGateway: _DailyCloseDiaryGateway(),
        timeZoneAt: (_) => zone,
        dailyCloseTimerScheduler: timers,
        foregroundEvents: const Stream<void>.empty(),
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('자정 전에 남긴 이야기'), findsOneWidget);
    expect(timers.lastDelay, const Duration(milliseconds: 1));

    now = DateTime.utc(2026, 10, 4, 15);
    await timers.fireActive();
    await tester.pumpAndSettle();

    expect(find.text('자정 전에 남긴 이야기'), findsNothing);
    expect(await diaries.findLatestForDay(closingDay), isNotNull);
  });

  testWidgets('gallery photo is imported before its chat message is sent', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final messages = FakeMessageRepository();
    final media = FakeMediaRepository();
    final fileStore = FakeMediaFileStore();
    final gateway = FakeChatReplyGateway(
      onReply: (_) async => ChatReply(
        messageId: 'assistant-photo-reply',
        text: '사진도 오늘의 기록에 잘 담아둘게.',
        createdAtUtc: DateTime.utc(2026, 10, 4, 8, 1),
      ),
    );
    final picker = PickAndImportPhoto(
      selector: _PhotoSelector(
        const PhotoImportSelection(
          token: '/picked/sunset.jpg',
          mimeType: 'image/jpeg',
          byteLength: 2048,
        ),
      ),
      importPhoto: ImportPhoto(repository: media, fileStore: fileStore),
      utcNow: () => DateTime.utc(2026, 10, 4, 8),
      nextId: () => 'photo-1',
    );

    await tester.pumpWidget(
      NamuApp(
        messageRepository: messages,
        chatReplyGateway: gateway,
        gatewayConfigured: true,
        pickAndImportPhoto: picker,
        photoBytesLoader: (_) async => _onePixelPng,
        utcNow: () => DateTime.utc(2026, 10, 4, 8),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('사진 첨부'));
    await tester.pumpAndSettle();

    expect(media.assets['photo-1']?.lifecycle.name, 'ready');
    expect(messages.messages, hasLength(2));
    expect(messages.messages.first.photoAssetId, 'photo-1');
    expect(find.byKey(const Key('localPhoto.image')), findsOneWidget);
    expect(find.text('사진도 오늘의 기록에 잘 담아둘게.'), findsOneWidget);
  });

  testWidgets('edit action opens the editor for the stored diary', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 900));
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
      _diary(
        dayKey,
        blocks: const [
          DiaryTextBlock(text: '처음 만들어진 본문'),
          DiaryPhotoBlock(photoAssetId: 'private-photo-id'),
        ],
      ),
    );

    await tester.pumpWidget(
      NamuApp(
        diaryRepository: diaries,
        photoBytesLoader: (_) async => _onePixelPng,
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('diary.edit')));
    await tester.tap(find.byKey(const Key('diary.edit')));
    await tester.pumpAndSettle();

    expect(find.byType(DiaryEditorSheet), findsOneWidget);
    expect(find.text('오늘의 일기 수정'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('diary.editor.block.1.photo')),
        matching: find.byKey(const Key('localPhoto.image')),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('private-photo-id'), findsNothing);
  });

  testWidgets('mobile archive reopens a locally stored diary', (tester) async {
    _setSurfaceSize(tester, const Size(390, 844));
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
      _diary(dayKey).finalize(updatedAtUtc: DateTime.utc(2026, 10, 4, 9)),
    );

    await tester.pumpWidget(
      NamuApp(diaryRepository: diaries, utcNow: () => now),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('보관함'));
    await tester.pumpAndSettle();
    expect(find.byType(ArchiveScreen), findsOneWidget);
    expect(find.text('편집할 오늘의 기록'), findsOneWidget);

    await tester.tap(find.byKey(const Key('archive.entry.diary-for-edit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('diary.entry.card')), findsOneWidget);
    expect(find.text('처음 만들어진 본문'), findsOneWidget);
  });

  testWidgets('finalizing a diary creates user-approval memory candidates', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 900));
    final now = DateTime.utc(2026, 10, 4, 12);
    final localNow = now.toLocal();
    final dayKey = DiaryDayKey.fromInstant(
      instant: now,
      timeZone: TimeZoneSnapshot(
        timeZoneId: localNow.timeZoneName,
        utcOffset: localNow.timeZoneOffset,
      ),
    );
    final diaries = InMemoryDiaryRepository();
    final memories = InMemoryMemoryFactRepository();
    await diaries.save(
      _diary(
        dayKey,
        memoryCandidates: [
          DiaryMemoryCandidate(
            fact: '사용자는 재즈를 좋아한다.',
            sourceMessageIds: const ['message-1'],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      NamuApp(
        diaryRepository: diaries,
        memoryFactRepository: memories,
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('diary.finalize')));
    await tester.tap(find.byKey(const Key('diary.finalize')));
    await tester.pumpAndSettle();

    final saved = await memories.listAll();
    expect(saved, hasLength(1));
    expect(saved.single.fact, '사용자는 재즈를 좋아한다.');
    expect(saved.single.status, MemoryStatus.candidate);
  });

  testWidgets('sharing opens a user-controlled sheet without claiming a post', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(1200, 900));
    final now = DateTime.utc(2026, 10, 4, 12);
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
      _diary(dayKey).finalize(updatedAtUtc: DateTime.utc(2026, 10, 4, 11)),
    );
    final launcher = _ShareLauncher();

    await tester.pumpWidget(
      NamuApp(
        diaryRepository: diaries,
        shareDiary: ShareDiary(renderer: _ShareRenderer(), launcher: launcher),
        utcNow: () => now,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('diary.share')));
    await tester.tap(find.byKey(const Key('diary.share')));
    await tester.pumpAndSettle();

    expect(launcher.requests, hasLength(1));
    expect(find.textContaining('공유 화면을 열었어요'), findsOneWidget);
    expect(find.textContaining('게시됐어요'), findsNothing);
  });

  testWidgets('mobile memory destination shows locally stored candidates', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 844));
    final memories = InMemoryMemoryFactRepository();
    await memories.save(
      MemoryFact(
        id: 'memory-candidate-1',
        fact: '사용자는 재즈를 좋아한다.',
        sourceMessageIds: const ['message-1'],
        category: MemoryCategory.preference,
        sensitivity: MemorySensitivity.sensitive,
        status: MemoryStatus.candidate,
        createdAtUtc: DateTime.utc(2026, 10, 4, 11),
        updatedAtUtc: DateTime.utc(2026, 10, 4, 11),
      ),
    );

    await tester.pumpWidget(NamuApp(memoryFactRepository: memories));
    await tester.pumpAndSettle();

    await tester.tap(find.text('기억'));
    await tester.pumpAndSettle();

    expect(find.byType(MemoryManagementScreen), findsOneWidget);
    expect(find.text('사용자는 재즈를 좋아한다.'), findsOneWidget);
    expect(find.text('검토 필요'), findsOneWidget);
  });
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);

void _setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

final class _PhotoSelector implements PhotoSelector {
  const _PhotoSelector(this.selection);

  final PhotoImportSelection? selection;

  @override
  Future<PhotoImportSelection?> selectFromGallery() async => selection;
}

DiaryEntry _diary(
  DiaryDayKey dayKey, {
  List<DiaryMemoryCandidate> memoryCandidates = const [],
  List<DiaryBlock> blocks = const [DiaryTextBlock(text: '처음 만들어진 본문')],
}) {
  return DiaryEntry(
    id: 'diary-for-edit',
    dayKey: dayKey,
    version: 1,
    status: DiaryEntryStatus.draft,
    weather: const WeatherSnapshot.noWeather(),
    mood: '평온함',
    oneLineSummary: '편집할 오늘의 기록',
    theme: DiaryTheme.light,
    blocks: blocks,
    memoryCandidates: memoryCandidates,
    sourceMessageIds: const ['message-1'],
    generationId: 'generation-for-edit',
    generatedAtUtc: DateTime.utc(2026, 10, 4, 8),
    updatedAtUtc: DateTime.utc(2026, 10, 4, 8),
  );
}

final class _ShareRenderer implements DiaryShareRenderer {
  @override
  Future<DiaryShareRenderResult> render(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  ) async {
    return DiaryShareRenderResult(
      artifacts: const [
        DiaryShareArtifact(
          path: '/tmp/namu-share-test.png',
          mimeType: 'image/png',
          pixelWidth: 1080,
          pixelHeight: 1350,
          byteLength: 128,
        ),
      ],
      caption: entry.oneLineSummary,
    );
  }
}

final class _ShareLauncher implements ShareSheetLauncher {
  final List<ShareSheetRequest> requests = [];

  @override
  Future<ShareSheetOutcome> launch(ShareSheetRequest request) async {
    requests.add(request);
    return ShareSheetOutcome.opened;
  }
}

final class _DailyCloseDiaryGateway implements DiaryGenerationGateway {
  @override
  Future<DiaryGenerationOutput> generate(DiaryGenerationRequest request) async {
    return DiaryGenerationOutput(
      schemaVersion: DiaryGenerationOutput.currentSchemaVersion,
      mood: '차분함',
      oneLineSummary: '자정에 정리한 하루',
      theme: DiaryTheme.light,
      blocks: const [DiaryTextBlock(text: '하루를 잘 마무리했다.')],
      memoryCandidates: const [],
    );
  }
}

final class _DailyCloseTimerScheduler implements DailyCloseTimerScheduler {
  _DailyCloseScheduledTimer? _active;

  Duration? get lastDelay => _active?.delay;

  @override
  DailyCloseTimer schedule(Duration delay, Future<void> Function() callback) {
    _active?.cancel();
    return _active = _DailyCloseScheduledTimer(delay, callback);
  }

  Future<void> fireActive() async {
    final active = _active;
    if (active == null) {
      throw StateError('No active daily-close timer.');
    }
    await active.fire();
  }
}

final class _DailyCloseScheduledTimer implements DailyCloseTimer {
  _DailyCloseScheduledTimer(this.delay, this._callback);

  final Duration delay;
  final Future<void> Function() _callback;
  var _cancelled = false;

  @override
  void cancel() => _cancelled = true;

  Future<void> fire() async {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    await _callback();
  }
}
