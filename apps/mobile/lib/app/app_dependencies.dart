import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../core/database/app_database.dart';
import '../core/id/random_id_generator.dart';
import '../core/storage/app_storage_paths.dart';
import '../core/storage/method_channel_app_storage_paths.dart';
import '../features/chat/data/drift_message_repository.dart';
import '../features/chat/data/in_memory_message_repository.dart';
import '../features/chat/domain/message_repository.dart';
import '../features/consent/data/file_ai_data_consent_repository.dart';
import '../features/consent/data/in_memory_ai_data_consent_repository.dart';
import '../features/consent/domain/ai_data_consent_repository.dart';
import '../features/diary/data/drift_diary_repository.dart';
import '../features/diary/data/in_memory_diary_repository.dart';
import '../features/diary/domain/diary_repository.dart';
import '../features/media/application/import_photo.dart';
import '../features/media/application/load_local_photo_bytes.dart';
import '../features/media/application/photo_selector.dart';
import '../features/media/application/pick_and_import_photo.dart';
import '../features/media/data/drift_media_repository.dart';
import '../features/media/data/image_picker_photo_selector.dart';
import '../features/media/data/in_memory_media_repository.dart';
import '../features/media/data/app_owned_media_reader.dart';
import '../features/media/data/native_media_file_store.dart';
import '../features/media/domain/media_repository.dart';
import '../features/memory/data/drift_memory_fact_repository.dart';
import '../features/memory/data/in_memory_memory_fact_repository.dart';
import '../features/memory/domain/memory_fact_repository.dart';
import '../features/onboarding/data/file_onboarding_repository.dart';
import '../features/onboarding/data/in_memory_onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/persona/data/drift_ai_persona_repository.dart';
import '../features/persona/data/in_memory_ai_persona_repository.dart';
import '../features/persona/domain/ai_persona_repository.dart';
import '../features/share/application/share_diary.dart';
import '../features/share/data/canvas_diary_share_renderer.dart';
import '../features/share/data/native_diary_share_output_store.dart';
import '../features/share/data/share_plus_sheet_launcher.dart';
import '../features/settings/data/platform_local_data_eraser.dart';
import '../features/settings/application/export_local_data.dart';
import '../features/settings/data/native_local_data_export_store.dart';
import '../features/settings/data/share_plus_local_data_export_launcher.dart';
import '../features/settings/domain/local_data_eraser.dart';

typedef NativeDatabaseFactory = AppDatabase Function(
  AppStoragePaths storagePaths,
);
typedef NativeDatabaseCloser = Future<void> Function(AppDatabase database);
typedef NativeStoragePathsFactory = AppStoragePaths Function();
typedef PhotoSelectorFactory = PhotoSelector Function();

/// Owns the production repository graph and any resource shared by its adapters.
final class AppDependencies {
  AppDependencies._({
    required this.messageRepository,
    required this.diaryRepository,
    required this.mediaRepository,
    required this.personaRepository,
    required this.memoryFactRepository,
    required this.aiDataConsentRepository,
    required this.onboardingRepository,
    required this.pickAndImportPhoto,
    required this.loadLocalPhotoBytes,
    required this.shareDiary,
    required this.localDataEraser,
    required this.exportLocalData,
    this._ownedDatabase,
    this._nativeDatabaseCloser,
  });

  factory AppDependencies.production() =>
      AppDependencies.forPlatform(isWeb: kIsWeb);

  @visibleForTesting
  factory AppDependencies.forPlatform({
    required bool isWeb,
    NativeDatabaseFactory? nativeDatabaseFactory,
    NativeDatabaseCloser? nativeDatabaseCloser,
    NativeStoragePathsFactory? nativeStoragePathsFactory,
    PhotoSelectorFactory? photoSelectorFactory,
    AiDataConsentRepository? aiDataConsentRepository,
    OnboardingRepository? onboardingRepository,
    LocalDataEraser? localDataEraser,
    DateTime Function()? utcNow,
    String Function()? nextId,
  }) {
    final clock = utcNow ?? _systemUtcNow;
    final generateId = nextId ?? RandomIdGenerator().next;
    final selector = (photoSelectorFactory ?? ImagePickerPhotoSelector.new)
        .call();

    if (isWeb) {
      final mediaRepository = InMemoryMediaRepository();
      const storagePaths = UnavailableAppStoragePaths();
      return AppDependencies._(
        messageRepository: InMemoryMessageRepository(),
        diaryRepository: InMemoryDiaryRepository(),
        mediaRepository: mediaRepository,
        personaRepository: InMemoryAiPersonaRepository(),
        memoryFactRepository: InMemoryMemoryFactRepository(),
        aiDataConsentRepository:
            aiDataConsentRepository ?? InMemoryAiDataConsentRepository(),
        onboardingRepository:
            onboardingRepository ?? InMemoryOnboardingRepository(),
        pickAndImportPhoto: PickAndImportPhoto(
          selector: selector,
          importPhoto: ImportPhoto(
            repository: mediaRepository,
            fileStore: NativeMediaFileStore(storagePaths),
          ),
          utcNow: clock,
          nextId: generateId,
        ),
        loadLocalPhotoBytes: LoadLocalPhotoBytes(
          repository: mediaRepository,
          reader: AppOwnedMediaReader(storagePaths),
        ),
        shareDiary: _createShareDiary(mediaRepository, storagePaths),
        localDataEraser: localDataEraser ?? const TransientLocalDataEraser(),
        exportLocalData: null,
      );
    }

    final storagePaths =
        (nativeStoragePathsFactory ?? createPlatformAppStoragePaths).call();
    final database = (nativeDatabaseFactory ?? _createNativeDatabase).call(
      storagePaths,
    );
    final messageRepository = DriftMessageRepository(database);
    final diaryRepository = DriftDiaryRepository(database);
    final mediaRepository = DriftMediaRepository(database);
    final personaRepository = DriftAiPersonaRepository(database);
    final memoryFactRepository = DriftMemoryFactRepository(database);
    final consentRepository =
        aiDataConsentRepository ??
        FileAiDataConsentRepository(storagePaths: storagePaths);
    return AppDependencies._(
      messageRepository: messageRepository,
      diaryRepository: diaryRepository,
      mediaRepository: mediaRepository,
      personaRepository: personaRepository,
      memoryFactRepository: memoryFactRepository,
      aiDataConsentRepository: consentRepository,
      onboardingRepository:
          onboardingRepository ??
          FileOnboardingRepository(storagePaths: storagePaths),
      pickAndImportPhoto: PickAndImportPhoto(
        selector: selector,
        importPhoto: ImportPhoto(
          repository: mediaRepository,
          fileStore: NativeMediaFileStore(storagePaths),
        ),
        utcNow: clock,
        nextId: generateId,
      ),
      loadLocalPhotoBytes: LoadLocalPhotoBytes(
        repository: mediaRepository,
        reader: AppOwnedMediaReader(storagePaths),
      ),
      shareDiary: _createShareDiary(mediaRepository, storagePaths),
      localDataEraser: localDataEraser ?? PlatformLocalDataEraser(storagePaths),
      exportLocalData: ExportLocalData(
        messageRepository: messageRepository,
        diaryRepository: diaryRepository,
        mediaRepository: mediaRepository,
        personaRepository: personaRepository,
        memoryFactRepository: memoryFactRepository,
        aiDataConsentRepository: consentRepository,
        store: NativeLocalDataExportStore(storagePaths),
        launcher: SharePlusLocalDataExportLauncher(),
        utcNow: clock,
      ),
      ownedDatabase: database,
      nativeDatabaseCloser: nativeDatabaseCloser ?? _closeDatabase,
    );
  }

  final MessageRepository messageRepository;
  final DiaryRepository diaryRepository;
  final MediaRepository mediaRepository;
  final AiPersonaRepository personaRepository;
  final MemoryFactRepository memoryFactRepository;
  final AiDataConsentRepository aiDataConsentRepository;
  final OnboardingRepository onboardingRepository;
  final PickAndImportPhoto pickAndImportPhoto;
  final LoadLocalPhotoBytes loadLocalPhotoBytes;
  final ShareDiary shareDiary;
  final LocalDataEraser localDataEraser;
  final ExportLocalData? exportLocalData;
  final AppDatabase? _ownedDatabase;
  final NativeDatabaseCloser? _nativeDatabaseCloser;
  final List<Future<void> Function()> _beforeClose = [];
  Future<void>? _closeOperation;

  @visibleForTesting
  bool get ownsDatabase => _ownedDatabase != null;

  /// Registers child resources that must stop before the owned database closes.
  ///
  /// Registration is intentionally limited to application composition. Calling
  /// it after shutdown starts would make the close order nondeterministic.
  void registerBeforeClose(Future<void> Function() shutdown) {
    if (_closeOperation != null) {
      throw StateError(
        'Cannot register shutdown work after close has started.',
      );
    }
    _beforeClose.add(shutdown);
  }

  Future<void> close() => _closeOperation ??= _close();

  Future<void> _close() async {
    for (final shutdown in _beforeClose.reversed) {
      await shutdown();
    }
    if ((_ownedDatabase, _nativeDatabaseCloser) case (
      final database?,
      final closer?,
    )) {
      await closer(database);
    }
  }

  static AppDatabase _createNativeDatabase(AppStoragePaths storagePaths) {
    return AppDatabase(
      driftDatabase(
        name: 'namu',
        native: DriftNativeOptions(
          databaseDirectory: storagePaths.appStorageRoot,
        ),
      ),
    );
  }

  static Future<void> _closeDatabase(AppDatabase database) => database.close();

  static ShareDiary _createShareDiary(
    MediaRepository mediaRepository,
    AppStoragePaths storagePaths,
  ) {
    return ShareDiary(
      renderer: CanvasDiaryShareRenderer(
        mediaRepository: mediaRepository,
        mediaReader: AppOwnedMediaReader(storagePaths),
        outputStore: NativeDiaryShareOutputStore(storagePaths),
      ),
      launcher: SharePlusSheetLauncher(),
    );
  }

  static DateTime _systemUtcNow() => DateTime.now().toUtc();
}
