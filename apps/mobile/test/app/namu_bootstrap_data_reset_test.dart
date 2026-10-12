import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/app/app_dependencies.dart';
import 'package:namu/app/namu_bootstrap.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';
import 'package:namu/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:namu/features/onboarding/domain/onboarding_status.dart';
import 'package:namu/features/settings/domain/local_data_eraser.dart';
import 'package:namu/l10n/namu_localizations.dart';

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

  testWidgets(
    'unmounts and closes the old graph before erase, then creates a fresh graph',
    (tester) async {
      final l10n = namuLocalizationsFor(const Locale('ko'));
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final events = <String>[];
      final first = AppDependencies.forPlatform(
        isWeb: true,
        aiDataConsentRepository: InMemoryAiDataConsentRepository(
          initial: AiDataConsent.accepted(
            decidedAtUtc: DateTime.utc(2026, 10, 4),
          ),
        ),
        onboardingRepository: InMemoryOnboardingRepository(
          initial: OnboardingStatus.completed(
            completedAtUtc: DateTime.utc(2026, 10, 4),
          ),
        ),
        localDataEraser: _RecordingEraser(events),
      );
      first.registerBeforeClose(() async => events.add('old-graph-closed'));
      final second = AppDependencies.forPlatform(
        isWeb: true,
        aiDataConsentRepository: InMemoryAiDataConsentRepository(),
        localDataEraser: _RecordingEraser(events),
      );
      var factoryCalls = 0;

      await tester.pumpWidget(
        NamuBootstrap.testing(
          dependenciesFactory: () {
            factoryCalls += 1;
            if (factoryCalls == 1) return first;
            events.add('fresh-graph-created');
            return second;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.todayNavSettings));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings.screen')), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings.deleteAll')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings.deleteAll.confirm')));
      await tester.pumpAndSettle();

      expect(events, [
        'old-graph-closed',
        'storage-erased',
        'fresh-graph-created',
      ]);
      expect(factoryCalls, 2);
      expect(find.text(l10n.onboardingTitle), findsOneWidget);
      expect(find.byKey(const Key('settings.screen')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await second.close();
    },
  );
}

final class _RecordingEraser implements LocalDataEraser {
  const _RecordingEraser(this.events);

  final List<String> events;

  @override
  LocalDataResetKind get resetKind => LocalDataResetKind.transientPreview;

  @override
  Future<void> erase() async {
    events.add('storage-erased');
  }
}
