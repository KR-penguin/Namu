import 'package:flutter/foundation.dart';

import '../domain/ai_persona.dart';
import '../domain/ai_persona_repository.dart';

final class PersonaController extends ChangeNotifier {
  PersonaController({required this.repository, AiPersona? initialPersona})
    : _persona = initialPersona ?? AiPersona.safeDefault();

  final AiPersonaRepository repository;

  AiPersona _persona;
  bool _isLoading = false;
  bool _isSaving = false;
  Object? _error;

  AiPersona get persona => _persona;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  Object? get error => _error;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _persona = await repository.load() ?? _persona;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save({
    required String name,
    String? avatarSeed,
    required String tone,
    required String customInstructions,
    required ReactionLength reactionLength,
  }) async {
    if (_isSaving) {
      throw StateError('Persona is already being saved.');
    }
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = AiPersona(
        id: _persona.id,
        name: name,
        avatarSeed: avatarSeed ?? _persona.avatarSeed,
        tone: tone,
        customInstructions: customInstructions,
        reactionLength: reactionLength,
      );
      await repository.save(updated);
      _persona = updated;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
