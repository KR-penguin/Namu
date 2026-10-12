import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/consent/application/ai_data_consent_controller.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';
import 'package:namu/features/consent/domain/ai_data_consent_repository.dart';
import 'package:namu/features/onboarding/application/onboarding_controller.dart';
import 'package:namu/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:namu/features/onboarding/domain/onboarding_status.dart';
import 'package:namu/features/onboarding/presentation/onboarding_gate.dart';

void main() {
  final now = DateTime.utc(2026, 10, 10, 4, 5, 6);

  testWidgets(
    'explains local loss, AI identity, and optional transmission before entry',
    (tester) async {
      final onboarding = OnboardingController(
        repository: InMemoryOnboardingRepository(),
        utcNow: () => now,
      );
      final consent = AiDataConsentController(
        repository: InMemoryAiDataConsentRepository(),
        utcNow: () => now,
      );
      addTearDown(onboarding.dispose);
      addTearDown(consent.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingGate(
            controller: onboarding,
            aiDataConsentController: consent,
            child: const Text('오늘 화면'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('시작하기 전에 알아두세요'), findsOneWidget);
      expect(find.textContaining('앱을 삭제하거나 기기를 잃으면'), findsOneWidget);
      expect(find.textContaining('사람이 아닌 생성형 AI'), findsOneWidget);
      expect(find.textContaining('현재 사진 원본은 전송하지 않아요'), findsOneWidget);
      expect(find.text('오늘 화면'), findsNothing);
    },
  );

  testWidgets('local start completes onboarding but leaves consent undecided', (
    tester,
  ) async {
    final onboardingRepository = InMemoryOnboardingRepository();
    final consentRepository = InMemoryAiDataConsentRepository();
    final onboarding = OnboardingController(
      repository: onboardingRepository,
      utcNow: () => now,
    );
    final consent = AiDataConsentController(
      repository: consentRepository,
      utcNow: () => now,
    );
    addTearDown(onboarding.dispose);
    addTearDown(consent.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          controller: onboarding,
          aiDataConsentController: consent,
          child: const Text('오늘 화면'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('onboarding.startLocal')));
    await tester.tap(find.byKey(const Key('onboarding.startLocal')));
    await tester.pumpAndSettle();

    expect((await onboardingRepository.load()).isComplete, isTrue);
    expect(
      (await consentRepository.load()).choice,
      AiDataConsentChoice.undecided,
    );
    expect(find.text('오늘 화면'), findsOneWidget);
  });

  testWidgets('AI start explicitly accepts consent before entering', (
    tester,
  ) async {
    final onboardingRepository = InMemoryOnboardingRepository();
    final consentRepository = InMemoryAiDataConsentRepository();
    final onboarding = OnboardingController(
      repository: onboardingRepository,
      utcNow: () => now,
    );
    final consent = AiDataConsentController(
      repository: consentRepository,
      utcNow: () => now,
    );
    addTearDown(onboarding.dispose);
    addTearDown(consent.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          controller: onboarding,
          aiDataConsentController: consent,
          child: const Text('오늘 화면'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('onboarding.acceptAi')));
    await tester.tap(find.byKey(const Key('onboarding.acceptAi')));
    await tester.pumpAndSettle();

    expect((await onboardingRepository.load()).isComplete, isTrue);
    expect((await consentRepository.load()).allowsAiRequests, isTrue);
    expect(find.text('오늘 화면'), findsOneWidget);
  });

  testWidgets('a persisted completion enters with undecided consent', (
    tester,
  ) async {
    final onboarding = OnboardingController(
      repository: InMemoryOnboardingRepository(
        initial: OnboardingStatus.completed(completedAtUtc: now),
      ),
      utcNow: () => now,
    );
    final consent = AiDataConsentController(
      repository: InMemoryAiDataConsentRepository(),
      utcNow: () => now,
    );
    addTearDown(onboarding.dispose);
    addTearDown(consent.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          controller: onboarding,
          aiDataConsentController: consent,
          child: const Text('오늘 화면'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘 화면'), findsOneWidget);
    expect(consent.consent.choice, AiDataConsentChoice.undecided);
  });

  testWidgets('consent storage failure still permits local-only entry', (
    tester,
  ) async {
    final onboarding = OnboardingController(
      repository: InMemoryOnboardingRepository(),
      utcNow: () => now,
    );
    final consent = AiDataConsentController(
      repository: const _UnavailableConsentRepository(),
      utcNow: () => now,
    );
    addTearDown(onboarding.dispose);
    addTearDown(consent.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(
          controller: onboarding,
          aiDataConsentController: consent,
          child: const Text('오늘 화면'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('선택을 저장하지 못했어요'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('onboarding.startLocal')));
    await tester.tap(find.byKey(const Key('onboarding.startLocal')));
    await tester.pumpAndSettle();

    expect(find.text('오늘 화면'), findsOneWidget);
    expect(consent.allowsAiRequests, isFalse);
  });

  testWidgets('small screen and large text keep local start reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final onboarding = OnboardingController(
      repository: InMemoryOnboardingRepository(),
      utcNow: () => now,
    );
    final consent = AiDataConsentController(
      repository: InMemoryAiDataConsentRepository(),
      utcNow: () => now,
    );
    addTearDown(onboarding.dispose);
    addTearDown(consent.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: OnboardingGate(
            controller: onboarding,
            aiDataConsentController: consent,
            child: const Text('오늘 화면'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('onboarding.startLocal')));
    await tester.tap(find.byKey(const Key('onboarding.startLocal')));
    await tester.pumpAndSettle();

    expect(find.text('오늘 화면'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _UnavailableConsentRepository implements AiDataConsentRepository {
  const _UnavailableConsentRepository();

  @override
  Future<AiDataConsent> load() async => throw StateError('unavailable');

  @override
  Future<void> save(AiDataConsent consent) async {
    throw StateError('unavailable');
  }
}
