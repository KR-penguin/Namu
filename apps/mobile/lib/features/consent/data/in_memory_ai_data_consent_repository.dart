import '../domain/ai_data_consent.dart';
import '../domain/ai_data_consent_repository.dart';

final class InMemoryAiDataConsentRepository implements AiDataConsentRepository {
  InMemoryAiDataConsentRepository({
    AiDataConsent initial = const AiDataConsent.undecided(),
  }) : _consent = initial;

  AiDataConsent _consent;

  @override
  Future<AiDataConsent> load() async => _consent;

  @override
  Future<void> save(AiDataConsent consent) async {
    _consent = consent;
  }
}
