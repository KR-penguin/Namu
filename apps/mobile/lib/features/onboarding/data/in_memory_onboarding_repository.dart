import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';

final class InMemoryOnboardingRepository implements OnboardingRepository {
  InMemoryOnboardingRepository({
    OnboardingStatus initial = const OnboardingStatus.notCompleted(),
  }) : _status = initial;

  OnboardingStatus _status;

  @override
  Future<OnboardingStatus> load() async => _status;

  @override
  Future<void> save(OnboardingStatus status) async {
    if (!status.isComplete) {
      throw ArgumentError.value(status, 'status', 'must be complete');
    }
    _status = status;
  }
}
