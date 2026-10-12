import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/id/random_id_generator.dart';
import '../core/l10n/ai_response_locale.dart';
import '../core/network/gateway_config.dart';
import '../core/network/gateway_development_auth_headers.dart';
import '../core/storage/method_channel_app_storage_paths.dart';
import '../core/time/diary_day_key.dart';
import '../core/time/time_zone_snapshot.dart';
import '../features/archive/application/archive_controller.dart';
import '../features/chat/application/chat_controller.dart';
import '../features/chat/application/send_message.dart';
import '../features/chat/data/http_chat_reply_gateway.dart';
import '../features/chat/data/in_memory_message_repository.dart';
import '../features/chat/domain/chat_reply_gateway.dart';
import '../features/chat/domain/message_repository.dart';
import '../features/consent/application/ai_data_consent_controller.dart';
import '../features/consent/application/consent_required_ai_gateways.dart';
import '../features/consent/data/in_memory_ai_data_consent_repository.dart';
import '../features/consent/domain/ai_data_consent.dart';
import '../features/consent/domain/ai_data_consent_repository.dart';
import '../features/diary/application/diary_controller.dart';
import '../features/diary/application/daily_close_coordinator.dart';
import '../features/diary/application/daily_close_schedule.dart';
import '../features/diary/data/http_diary_generation_gateway.dart';
import '../features/diary/data/in_memory_diary_repository.dart';
import '../features/diary/data/dart_daily_close_timer_scheduler.dart';
import '../features/diary/data/flutter_foreground_events.dart';
import '../features/diary/domain/diary_entry.dart';
import '../features/diary/domain/diary_generation_gateway.dart';
import '../features/diary/domain/diary_repository.dart';
import '../features/diary/domain/weather_snapshot.dart';
import '../features/media/application/import_photo.dart';
import '../features/media/application/pick_and_import_photo.dart';
import '../features/media/data/image_picker_photo_selector.dart';
import '../features/media/data/in_memory_media_repository.dart';
import '../features/media/data/native_media_file_store.dart';
import '../features/media/presentation/local_photo.dart';
import '../features/memory/application/create_memory_candidates.dart';
import '../features/memory/application/memory_management_controller.dart';
import '../features/memory/data/in_memory_memory_fact_repository.dart';
import '../features/memory/domain/memory_fact_repository.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/data/in_memory_onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_status.dart';
import '../features/onboarding/presentation/onboarding_gate.dart';
import '../features/persona/application/persona_controller.dart';
import '../features/persona/data/in_memory_ai_persona_repository.dart';
import '../features/persona/domain/ai_persona.dart';
import '../features/persona/domain/ai_persona_repository.dart';
import '../features/share/application/share_diary.dart';
import '../features/settings/domain/local_data_eraser.dart';
import '../features/settings/application/export_local_data.dart';
import '../features/today/presentation/today_screen.dart';
import '../l10n/app_localizations.dart';
import '../l10n/namu_localizations.dart';

class NamuApp extends StatefulWidget {
  const NamuApp({
    this.messageRepository,
    this.chatReplyGateway,
    this.gatewayConfig,
    this.gatewayHttpClient,
    this.gatewayAuthHeaders,
    this.gatewayConfigured,
    this.personaRepository,
    this.diaryRepository,
    this.diaryGenerationGateway,
    this.pickAndImportPhoto,
    this.photoBytesLoader,
    this.memoryFactRepository,
    this.aiDataConsentRepository,
    this.onboardingRepository,
    this.shareDiary,
    this.timeZoneAt,
    this.dailyCloseTimerScheduler,
    this.dailyCloseEnabled = true,
    this.foregroundEvents,
    this.refreshTimeZoneBeforeForeground,
    this.registerBeforeStorageClose,
    this.localDataResetKind = LocalDataResetKind.transientPreview,
    this.onResetAllLocalData,
    this.exportLocalData,
    this.utcNow,
    super.key,
  });

  final MessageRepository? messageRepository;
  final ChatReplyGateway? chatReplyGateway;
  final GatewayConfig? gatewayConfig;
  final http.Client? gatewayHttpClient;
  final Future<Map<String, String>> Function()? gatewayAuthHeaders;
  final bool? gatewayConfigured;
  final AiPersonaRepository? personaRepository;
  final DiaryRepository? diaryRepository;
  final DiaryGenerationGateway? diaryGenerationGateway;
  final PickAndImportPhoto? pickAndImportPhoto;
  final LocalPhotoBytesLoader? photoBytesLoader;
  final MemoryFactRepository? memoryFactRepository;
  final AiDataConsentRepository? aiDataConsentRepository;
  final OnboardingRepository? onboardingRepository;
  final ShareDiary? shareDiary;
  final TimeZoneAtInstant? timeZoneAt;
  final DailyCloseTimerScheduler? dailyCloseTimerScheduler;
  final bool dailyCloseEnabled;
  final Stream<void>? foregroundEvents;
  final Future<void> Function()? refreshTimeZoneBeforeForeground;
  final void Function(Future<void> Function())? registerBeforeStorageClose;
  final LocalDataResetKind localDataResetKind;
  final Future<void> Function()? onResetAllLocalData;
  final ExportLocalData? exportLocalData;
  final DateTime Function()? utcNow;

  @override
  State<NamuApp> createState() => _NamuAppState();
}

class _NamuAppState extends State<NamuApp> {
  http.Client? _ownedHttpClient;
  late final GatewayConfig _gatewayConfig;
  late final Future<Map<String, String>> Function() _gatewayAuthHeaders;
  late final ChatController _chatController;
  late final ArchiveController _archiveController;
  late final PersonaController _personaController;
  late final DiaryController _diaryController;
  late final PickAndImportPhoto _pickAndImportPhoto;
  late final CreateMemoryCandidates _createMemoryCandidates;
  late final MemoryManagementController _memoryManagementController;
  late final AiDataConsentController _aiDataConsentController;
  late final OnboardingController _onboardingController;
  late final bool _gatewayConfigured;
  DailyCloseCoordinator? _dailyCloseCoordinator;
  FlutterForegroundEvents? _ownedForegroundEvents;
  Future<void>? _dailyCloseShutdown;
  var _lastAiConsentAllowed = false;

  @override
  void initState() {
    super.initState();
    const allowInsecureLoopback = bool.fromEnvironment(
      'NAMU_ALLOW_INSECURE_LOOPBACK',
    );
    _gatewayConfig =
        widget.gatewayConfig ??
        GatewayConfig.fromEnvironment(
          allowInsecureLoopback: allowInsecureLoopback,
        );
    _gatewayAuthHeaders =
        widget.gatewayAuthHeaders ??
        GatewayDevelopmentAuthHeaders.fromEnvironment(config: _gatewayConfig)
            .call;

    final repository = widget.messageRepository ?? InMemoryMessageRepository();
    final consentRepository =
        widget.aiDataConsentRepository ??
        InMemoryAiDataConsentRepository(
          initial: AiDataConsent.accepted(
            decidedAtUtc: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
        );
    _aiDataConsentController = AiDataConsentController(
      repository: consentRepository,
      utcNow: widget.utcNow ?? _systemUtcNow,
    );
    _onboardingController = OnboardingController(
      repository:
          widget.onboardingRepository ??
          InMemoryOnboardingRepository(
            initial: OnboardingStatus.completed(
              completedAtUtc: DateTime.fromMillisecondsSinceEpoch(
                0,
                isUtc: true,
              ),
            ),
          ),
      utcNow: widget.utcNow ?? _systemUtcNow,
    );
    _aiDataConsentController.addListener(_onAiDataConsentChanged);
    final memoryFactRepository =
        widget.memoryFactRepository ?? InMemoryMemoryFactRepository();
    final personaRepository =
        widget.personaRepository ?? InMemoryAiPersonaRepository();
    final initialLocalizations = namuLocalizationsFor(
      resolveNamuLocale(WidgetsBinding.instance.platformDispatcher.locales),
    );
    _personaController = PersonaController(
      repository: personaRepository,
      initialPersona: AiPersona.safeDefault(
        name: initialLocalizations.personaDefaultName,
        tone: initialLocalizations.personaDefaultTone,
      ),
    );
    final rawGateway =
        widget.chatReplyGateway ??
        _buildHttpGateway(repository, memoryFactRepository);
    final gateway = ConsentRequiredChatReplyGateway(
      consentRepository: consentRepository,
      delegate: rawGateway,
    );
    _gatewayConfigured =
        widget.gatewayConfigured ??
        (widget.chatReplyGateway != null || _gatewayConfig.isConfigured);

    final now = (widget.utcNow ?? _systemUtcNow)();
    final localNow = now.toLocal();
    final timeZone =
        widget.timeZoneAt?.call(now) ??
        TimeZoneSnapshot(
          timeZoneId: localNow.timeZoneName,
          utcOffset: localNow.timeZoneOffset,
        );
    final dayKey = DiaryDayKey.fromInstant(instant: now, timeZone: timeZone);
    final idGenerator = RandomIdGenerator();
    final mediaRepository = InMemoryMediaRepository();

    _createMemoryCandidates = CreateMemoryCandidates(
      repository: memoryFactRepository,
      utcNow: widget.utcNow ?? _systemUtcNow,
    );
    _memoryManagementController = MemoryManagementController(
      repository: memoryFactRepository,
      utcNow: widget.utcNow ?? _systemUtcNow,
    );

    _pickAndImportPhoto =
        widget.pickAndImportPhoto ??
        PickAndImportPhoto(
          selector: ImagePickerPhotoSelector(),
          importPhoto: ImportPhoto(
            repository: mediaRepository,
            fileStore: NativeMediaFileStore(createPlatformAppStoragePaths()),
          ),
          utcNow: widget.utcNow ?? _systemUtcNow,
          nextId: idGenerator.next,
        );

    _chatController = ChatController(
      dayKey: dayKey,
      repository: repository,
      sendMessage: SendMessage(repository: repository, replyGateway: gateway),
      utcNow: widget.utcNow ?? _systemUtcNow,
      nextId: idGenerator.next,
    );
    final diaryRepository = widget.diaryRepository ?? InMemoryDiaryRepository();
    _archiveController = ArchiveController(repository: diaryRepository);
    final rawDiaryGateway =
        widget.diaryGenerationGateway ?? _buildHttpDiaryGateway();
    final diaryGateway = ConsentRequiredDiaryGenerationGateway(
      consentRepository: consentRepository,
      delegate: rawDiaryGateway,
    );
    _diaryController = DiaryController(
      dayKey: dayKey,
      diaryRepository: diaryRepository,
      messageRepository: repository,
      generationGateway: diaryGateway,
      responseLocaleProvider: _currentAiResponseLocale,
      personaProvider: () => _personaController.persona,
      weatherProvider: () async => const WeatherSnapshot.noWeather(),
      nextId: idGenerator.next,
      utcNow: widget.utcNow ?? _systemUtcNow,
    );
    _configureDailyClose(
      messageRepository: repository,
      diaryRepository: diaryRepository,
      personaRepository: personaRepository,
      generationGateway: diaryGateway,
    );
    widget.registerBeforeStorageClose?.call(_shutdownDailyClose);
    unawaited(_loadPersona());
    unawaited(_loadDiary());
  }

  void _configureDailyClose({
    required MessageRepository messageRepository,
    required DiaryRepository diaryRepository,
    required AiPersonaRepository personaRepository,
    required DiaryGenerationGateway generationGateway,
  }) {
    final timeZoneAt = widget.timeZoneAt;
    if (timeZoneAt == null || !widget.dailyCloseEnabled) {
      return;
    }
    final providedForegroundEvents = widget.foregroundEvents;
    if (providedForegroundEvents == null) {
      _ownedForegroundEvents = FlutterForegroundEvents();
    }
    final foregroundEvents =
        providedForegroundEvents ?? _ownedForegroundEvents!.stream;
    _dailyCloseCoordinator = DailyCloseCoordinator(
      messageRepository: messageRepository,
      diaryRepository: diaryRepository,
      generationGateway: generationGateway,
      responseLocaleProvider: _currentAiResponseLocale,
      personaRepository: personaRepository,
      weatherProvider: (_) async => const WeatherSnapshot.noWeather(),
      utcNow: widget.utcNow ?? _systemUtcNow,
      schedule: LocalMidnightDiarySchedule(timeZoneAt: timeZoneAt),
      timerScheduler:
          widget.dailyCloseTimerScheduler ??
          const DartDailyCloseTimerScheduler(),
      foregroundEvents: foregroundEvents,
      nextEntryId: RandomIdGenerator().next,
      onActiveDayChanged: _onActiveDayChanged,
      prepareForForeground: widget.refreshTimeZoneBeforeForeground,
    );
    unawaited(_startDailyClose());
  }

  Future<void> _startDailyClose() async {
    try {
      await _dailyCloseCoordinator?.start();
    } catch (_) {
      // Manual diary generation remains available when lifecycle setup fails.
    }
  }

  void _onAiDataConsentChanged() {
    final allowed = _aiDataConsentController.allowsAiRequests;
    final newlyAllowed = allowed && !_lastAiConsentAllowed;
    _lastAiConsentAllowed = allowed;
    if (newlyAllowed) {
      unawaited(_repairDailyCloseAfterConsent());
    }
  }

  Future<void> _repairDailyCloseAfterConsent() async {
    final coordinator = _dailyCloseCoordinator;
    if (coordinator == null) {
      return;
    }
    try {
      await coordinator.onForeground();
    } catch (_) {
      // A later foreground retries without changing local source records.
    }
  }

  void _onActiveDayChanged(DiaryDayKey activeDay) {
    if (_chatController.dayKey == activeDay &&
        _diaryController.dayKey == activeDay) {
      return;
    }
    final chatSwitch = _chatController.switchDay(activeDay);
    final diarySwitch = _diaryController.switchDay(activeDay);
    unawaited(
      Future.wait<void>([chatSwitch, diarySwitch])
          .then((_) async {
            await _archiveController.reload();
          })
          .catchError((_) {
            // Controllers keep the new day identity even if local reload fails.
          }),
    );
  }

  Future<void> _loadPersona() async {
    try {
      await _personaController.load();
    } catch (_) {
      // The safe default remains active and the settings sheet can retry a save.
    }
  }

  Future<void> _loadDiary() async {
    try {
      await _diaryController.load();
    } catch (_) {
      // The today screen exposes a retryable local error without inventing data.
    }
  }

  ChatReplyGateway _buildHttpGateway(
    MessageRepository messageRepository,
    MemoryFactRepository memoryFactRepository,
  ) {
    final client = _httpClient();
    return HttpChatReplyGateway(
      client: client,
      config: _gatewayConfig,
      authHeaders: _gatewayAuthHeaders,
      contextProvider: (pendingMessage) async {
        final recentMessages = await messageRepository.listForDay(
          pendingMessage.dayKey,
        );
        final memoryFacts = await memoryFactRepository.listAll();
        return ChatRequestContext(
          responseLocale: _currentAiResponseLocale(),
          persona: _personaController.persona,
          recentMessages: recentMessages,
          memoryFacts: memoryFacts,
        );
      },
    );
  }

  AiResponseLocale _currentAiResponseLocale() {
    return resolveNamuAiResponseLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
  }

  DiaryGenerationGateway _buildHttpDiaryGateway() {
    return HttpDiaryGenerationGateway(
      client: _httpClient(),
      config: _gatewayConfig,
      authHeaders: _gatewayAuthHeaders,
    );
  }

  Future<void> _pickPhotoAndSend() async {
    final asset = await _pickAndImportPhoto(_chatController.dayKey);
    if (asset == null) {
      return;
    }
    await _chatController.sendPhoto(asset.id);
  }

  Future<void> _publishMemoryCandidates(DiaryEntry entry) async {
    await _createMemoryCandidates(entry);
    if (_memoryManagementController.hasLoaded) {
      await _memoryManagementController.reload();
    }
  }

  http.Client _httpClient() =>
      widget.gatewayHttpClient ?? (_ownedHttpClient ??= http.Client());

  static DateTime _systemUtcNow() => DateTime.now().toUtc();

  Future<void> _shutdownDailyClose() {
    return _dailyCloseShutdown ??= () async {
      final coordinator = _dailyCloseCoordinator;
      if (coordinator != null) {
        await coordinator.dispose();
      }
      _ownedForegroundEvents?.dispose();
    }();
  }

  @override
  void dispose() {
    unawaited(_shutdownDailyClose());
    _chatController.dispose();
    _archiveController.dispose();
    _personaController.dispose();
    _diaryController.dispose();
    _memoryManagementController.dispose();
    _aiDataConsentController
      ..removeListener(_onAiDataConsentChanged)
      ..dispose();
    _onboardingController.dispose();
    _ownedHttpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF42634B);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, _) => resolveNamuLocale(locales),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFFFFDF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1E9),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF233229),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFFFFDF7),
          indicatorColor: Color(0xFFDDE9DE),
          height: 72,
        ),
        useMaterial3: true,
      ),
      home: OnboardingGate(
        controller: _onboardingController,
        aiDataConsentController: _aiDataConsentController,
        child: TodayScreen(
          chatController: _chatController,
          archiveController: _archiveController,
          diaryController: _diaryController,
          memoryController: _memoryManagementController,
          personaController: _personaController,
          aiDataConsentController: _aiDataConsentController,
          gatewayConfigured: _gatewayConfigured,
          onAttachPhoto: _pickPhotoAndSend,
          photoBytesLoader: widget.photoBytesLoader,
          onDiaryFinalized: _publishMemoryCandidates,
          onShareDiary: widget.shareDiary == null
              ? null
              : (entry, localizedCopy) => widget.shareDiary!.call(
                  entry,
                  localizedCopy: localizedCopy,
                ),
          localDataResetKind: widget.localDataResetKind,
          onResetAllLocalData: widget.onResetAllLocalData,
          onExportLocalData: widget.exportLocalData == null
              ? null
              : (shareText) =>
                    widget.exportLocalData!.call(shareText: shareText),
        ),
      ),
    );
  }
}
