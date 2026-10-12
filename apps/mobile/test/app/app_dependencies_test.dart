import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/app/app_dependencies.dart';
import 'package:namu/app/namu_bootstrap.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/chat/data/drift_message_repository.dart';
import 'package:namu/features/chat/data/in_memory_message_repository.dart';
import 'package:namu/features/consent/data/file_ai_data_consent_repository.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/diary/data/drift_diary_repository.dart';
import 'package:namu/features/diary/data/in_memory_diary_repository.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/features/media/data/drift_media_repository.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/memory/data/drift_memory_fact_repository.dart';
import 'package:namu/features/memory/data/in_memory_memory_fact_repository.dart';
import 'package:namu/features/onboarding/data/file_onboarding_repository.dart';
import 'package:namu/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:namu/features/persona/data/drift_ai_persona_repository.dart';
import 'package:namu/features/persona/data/in_memory_ai_persona_repository.dart';

void main() {
  group('AppDependencies', () {
    test('web selects only transient repositories', () async {
      var nativeDatabaseRequested = false;
      var nativeStorageRequested = false;

      final dependencies = AppDependencies.forPlatform(
        isWeb: true,
        nativeDatabaseFactory: (_) {
          nativeDatabaseRequested = true;
          throw StateError('web must not open SQLite');
        },
        nativeStoragePathsFactory: () {
          nativeStorageRequested = true;
          throw StateError('web must not request a platform storage channel');
        },
        photoSelectorFactory: () => const _NoPhotoSelector(),
      );

      expect(dependencies.messageRepository, isA<InMemoryMessageRepository>());
      expect(dependencies.diaryRepository, isA<InMemoryDiaryRepository>());
      expect(dependencies.mediaRepository, isA<InMemoryMediaRepository>());
      expect(
        dependencies.personaRepository,
        isA<InMemoryAiPersonaRepository>(),
      );
      expect(
        dependencies.memoryFactRepository,
        isA<InMemoryMemoryFactRepository>(),
      );
      expect(
        dependencies.aiDataConsentRepository,
        isA<InMemoryAiDataConsentRepository>(),
      );
      expect(
        dependencies.onboardingRepository,
        isA<InMemoryOnboardingRepository>(),
      );
      expect(dependencies.ownsDatabase, isFalse);
      expect(dependencies.exportLocalData, isNull);
      expect(nativeDatabaseRequested, isFalse);
      expect(nativeStorageRequested, isFalse);

      await dependencies.close();
    });

    test(
      'native shares one owned database across Drift repositories',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        final storagePaths = _FakeStoragePaths();
        var closeCount = 0;

        final dependencies = AppDependencies.forPlatform(
          isWeb: false,
          nativeDatabaseFactory: (_) => database,
          nativeDatabaseCloser: (ownedDatabase) async {
            expect(identical(ownedDatabase, database), isTrue);
            closeCount += 1;
            await ownedDatabase.close();
          },
          nativeStoragePathsFactory: () => storagePaths,
          photoSelectorFactory: () => const _NoPhotoSelector(),
        );

        expect(dependencies.messageRepository, isA<DriftMessageRepository>());
        expect(dependencies.diaryRepository, isA<DriftDiaryRepository>());
        expect(dependencies.mediaRepository, isA<DriftMediaRepository>());
        expect(dependencies.personaRepository, isA<DriftAiPersonaRepository>());
        expect(
          dependencies.memoryFactRepository,
          isA<DriftMemoryFactRepository>(),
        );
        expect(
          dependencies.aiDataConsentRepository,
          isA<FileAiDataConsentRepository>(),
        );
        expect(
          dependencies.onboardingRepository,
          isA<FileOnboardingRepository>(),
        );
        expect(dependencies.ownsDatabase, isTrue);
        expect(dependencies.exportLocalData, isNotNull);

        await dependencies.close();
        expect(closeCount, 1);
      },
    );

    test('close is idempotent', () async {
      final database = AppDatabase(NativeDatabase.memory());
      var closeCount = 0;
      final dependencies = AppDependencies.forPlatform(
        isWeb: false,
        nativeDatabaseFactory: (_) => database,
        nativeDatabaseCloser: (ownedDatabase) async {
          closeCount += 1;
          await ownedDatabase.close();
        },
        nativeStoragePathsFactory: _FakeStoragePaths.new,
        photoSelectorFactory: _NoPhotoSelector.new,
      );

      await Future.wait(<Future<void>>[
        dependencies.close(),
        dependencies.close(),
      ]);

      expect(closeCount, 1);
    });

    test(
      'close awaits registered lifecycle shutdown before the database',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        final shutdownGate = Completer<void>();
        final events = <String>[];
        final dependencies = AppDependencies.forPlatform(
          isWeb: false,
          nativeDatabaseFactory: (_) => database,
          nativeDatabaseCloser: (ownedDatabase) async {
            events.add('database');
            await ownedDatabase.close();
          },
          nativeStoragePathsFactory: _FakeStoragePaths.new,
          photoSelectorFactory: _NoPhotoSelector.new,
        );
        dependencies.registerBeforeClose(() async {
          events.add('lifecycle-start');
          await shutdownGate.future;
          events.add('lifecycle-end');
        });

        final close = dependencies.close();
        await Future<void>.delayed(Duration.zero);
        expect(events, ['lifecycle-start']);

        shutdownGate.complete();
        await close;
        expect(events, ['lifecycle-start', 'lifecycle-end', 'database']);
      },
    );

    testWidgets('bootstrap closes its dependency graph when removed', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());
      var closeCount = 0;
      final dependencies = AppDependencies.forPlatform(
        isWeb: false,
        nativeDatabaseFactory: (_) => database,
        nativeDatabaseCloser: (ownedDatabase) async {
          closeCount += 1;
          await ownedDatabase.close();
        },
        nativeStoragePathsFactory: _FakeStoragePaths.new,
        photoSelectorFactory: _NoPhotoSelector.new,
        aiDataConsentRepository: InMemoryAiDataConsentRepository(),
        onboardingRepository: InMemoryOnboardingRepository(),
      );

      await tester.pumpWidget(
        NamuBootstrap.testing(dependenciesFactory: () => dependencies),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await dependencies.close();

      expect(closeCount, 1);
    });
  });
}

final class _NoPhotoSelector implements PhotoSelector {
  const _NoPhotoSelector();

  @override
  Future<PhotoImportSelection?> selectFromGallery() async => null;
}

final class _FakeStoragePaths implements AppStoragePaths {
  @override
  Future<String> appStorageRoot() async => '/tmp/namu-composition-test';
}
