import 'ai_data_consent.dart';

abstract interface class AiDataConsentRepository {
  /// Missing or unrecognized state must be returned as undecided, never allowed.
  Future<AiDataConsent> load();

  Future<void> save(AiDataConsent consent);
}
