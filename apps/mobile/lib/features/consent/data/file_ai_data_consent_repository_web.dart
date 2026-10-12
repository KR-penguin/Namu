import 'package:namu/core/storage/app_storage_paths.dart';

import '../domain/ai_data_consent.dart';
import '../domain/ai_data_consent_repository.dart';
import 'ai_data_consent_storage_exception.dart';

/// The browser is a transient review surface and must not mimic native consent
/// persistence. Composition should use InMemoryAiDataConsentRepository there.
final class FileAiDataConsentRepository implements AiDataConsentRepository {
  factory FileAiDataConsentRepository({
    required AppStoragePaths storagePaths,
  }) => const FileAiDataConsentRepository._();

  const FileAiDataConsentRepository._();

  @override
  Future<AiDataConsent> load() async {
    throw const AiDataConsentStorageException();
  }

  @override
  Future<void> save(AiDataConsent consent) async {
    throw const AiDataConsentStorageException();
  }
}
