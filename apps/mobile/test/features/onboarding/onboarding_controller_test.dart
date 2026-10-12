import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/onboarding/application/onboarding_controller.dart';
import 'package:namu/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:namu/features/onboarding/domain/onboarding_status.dart';

void main() {
  final completedAt = DateTime.utc(2026, 10, 10, 4, 5, 6);

  test('persists completion independently from AI consent', () async {
    final repository = InMemoryOnboardingRepository();
    final controller = OnboardingController(
      repository: repository,
      utcNow: () => completedAt,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.isComplete, isFalse);

    await controller.complete();

    expect(controller.isComplete, isTrue);
    expect(
      await repository.load(),
      OnboardingStatus.completed(completedAtUtc: completedAt),
    );
  });

  test('rejects a non-UTC completion clock', () async {
    final controller = OnboardingController(
      repository: InMemoryOnboardingRepository(),
      utcNow: () => DateTime(2026, 10, 10),
    );
    addTearDown(controller.dispose);

    await controller.load();

    await expectLater(controller.complete(), throwsStateError);
    expect(controller.isComplete, isFalse);
  });
}
