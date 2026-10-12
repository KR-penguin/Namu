import 'package:flutter/foundation.dart';

import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';

final class OnboardingController extends ChangeNotifier {
  OnboardingController({required this.repository, required this.utcNow});

  final OnboardingRepository repository;
  final DateTime Function() utcNow;

  OnboardingStatus _status = const OnboardingStatus.notCompleted();
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _error;

  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isComplete => _status.isComplete;
  Object? get error => _error;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _status = await repository.load();
      _hasLoaded = true;
    } catch (error) {
      _status = const OnboardingStatus.notCompleted();
      _hasLoaded = false;
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> complete() async {
    if (_isSaving) {
      throw StateError('Onboarding completion is already being saved.');
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
      final next = OnboardingStatus.completed(completedAtUtc: now);
      await repository.save(next);
      _status = next;
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
