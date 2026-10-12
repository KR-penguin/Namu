import 'package:namu/core/storage/app_storage_paths.dart';

import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_storage_exception.dart';

/// Browser preview state is intentionally transient and composed in memory.
final class FileOnboardingRepository implements OnboardingRepository {
  factory FileOnboardingRepository({required AppStoragePaths storagePaths}) =>
      const FileOnboardingRepository._();

  const FileOnboardingRepository._();

  @override
  Future<OnboardingStatus> load() async {
    throw const OnboardingStorageException();
  }

  @override
  Future<void> save(OnboardingStatus status) async {
    throw const OnboardingStorageException();
  }
}
