import 'package:flutter/foundation.dart';

import '../domain/ai_data_consent.dart';
import '../domain/ai_data_consent_repository.dart';

final class AiDataConsentController extends ChangeNotifier {
  AiDataConsentController({required this.repository, required this.utcNow});

  final AiDataConsentRepository repository;
  final DateTime Function() utcNow;

  AiDataConsent _consent = const AiDataConsent.undecided();
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _error;

  AiDataConsent get consent => _consent;
  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  Object? get error => _error;
  bool get hasCompletedFirstRun => _consent.hasCompletedFirstRun;
  bool get allowsAiRequests => _consent.allowsAiRequests;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _consent = await repository.load();
      _hasLoaded = true;
    } catch (error) {
      _consent = const AiDataConsent.undecided();
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> accept() => _save(AiDataConsent.accepted);

  Future<void> decline() => _save(AiDataConsent.declined);

  Future<void> revoke() => _save(AiDataConsent.revoked);

  Future<void> _save(
    AiDataConsent Function({required DateTime decidedAtUtc}) build,
  ) async {
    if (_isSaving) {
      throw StateError('An AI data consent decision is already being saved.');
    }
    final now = utcNow();
    if (!now.isUtc) {
      final error = StateError('utcNow must return a UTC instant.');
      _error = error;
      notifyListeners();
      throw error;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final next = build(decidedAtUtc: now);
      await repository.save(next);
      _consent = next;
      _hasLoaded = true;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
