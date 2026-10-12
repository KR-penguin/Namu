final class OnboardingStorageException implements Exception {
  const OnboardingStorageException();

  @override
  String toString() => 'Onboarding status storage is unavailable';
}
