import 'onboarding_status.dart';

abstract interface class OnboardingRepository {
  /// Missing or unrecognized state must restart the disclosure flow.
  Future<OnboardingStatus> load();

  Future<void> save(OnboardingStatus status);
}
