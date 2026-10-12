import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/consent/application/ai_data_consent_controller.dart';
import 'package:namu/features/consent/data/in_memory_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';

void main() {
  final decidedAt = DateTime.utc(2026, 10, 4, 3, 4, 5);

  test('starts undecided and blocks AI until explicit acceptance', () async {
    final repository = InMemoryAiDataConsentRepository();
    final controller = AiDataConsentController(
      repository: repository,
      utcNow: () => decidedAt,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.hasCompletedFirstRun, isFalse);
    expect(controller.allowsAiRequests, isFalse);

    await controller.accept();

    expect(controller.hasCompletedFirstRun, isTrue);
    expect(controller.allowsAiRequests, isTrue);
    expect(
      await repository.load(),
      AiDataConsent.accepted(decidedAtUtc: decidedAt),
    );
  });

  test('declining completes onboarding without allowing AI', () async {
    final repository = InMemoryAiDataConsentRepository();
    final controller = AiDataConsentController(
      repository: repository,
      utcNow: () => decidedAt,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.decline();

    expect(controller.hasCompletedFirstRun, isTrue);
    expect(controller.allowsAiRequests, isFalse);
    expect(controller.consent.choice, AiDataConsentChoice.declined);
  });

  test('revocation immediately blocks subsequent AI requests', () async {
    final repository = InMemoryAiDataConsentRepository(
      initial: AiDataConsent.accepted(decidedAtUtc: decidedAt),
    );
    final revokedAt = DateTime.utc(2026, 10, 5);
    final controller = AiDataConsentController(
      repository: repository,
      utcNow: () => revokedAt,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.revoke();

    expect(controller.allowsAiRequests, isFalse);
    expect(controller.consent.choice, AiDataConsentChoice.revoked);
    expect(controller.consent.decidedAtUtc, revokedAt);
  });

  test('rejects a clock that does not return UTC', () async {
    final controller = AiDataConsentController(
      repository: InMemoryAiDataConsentRepository(),
      utcNow: () => DateTime(2026, 10, 4),
    );
    addTearDown(controller.dispose);

    await controller.load();

    await expectLater(controller.accept(), throwsStateError);
    expect(controller.allowsAiRequests, isFalse);
  });
}
