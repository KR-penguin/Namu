import 'package:drift/drift.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/features/persona/domain/ai_persona.dart';
import 'package:namu/features/persona/domain/ai_persona_repository.dart';

final class DriftAiPersonaRepository implements AiPersonaRepository {
  const DriftAiPersonaRepository(this._database);

  static const int _singletonKey = 1;
  final AppDatabase _database;

  @override
  Future<AiPersona?> load() async {
    final query = _database.select(_database.aiPersonaRecords)
      ..where((row) => row.singletonKey.equals(_singletonKey));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return AiPersona(
      id: row.personaId,
      name: row.personaName,
      avatarSeed: row.avatarSeed,
      tone: row.tone,
      customInstructions: row.customInstructions,
      reactionLength: _parseReactionLength(row.reactionLength),
    );
  }

  @override
  Future<void> save(AiPersona persona) async {
    await _database
        .into(_database.aiPersonaRecords)
        .insertOnConflictUpdate(
          AiPersonaRecordsCompanion.insert(
            singletonKey: const Value(_singletonKey),
            personaId: persona.id,
            personaName: persona.name,
            avatarSeed: persona.avatarSeed,
            tone: persona.tone,
            customInstructions: persona.customInstructions,
            reactionLength: persona.reactionLength.name,
          ),
        );
  }

  ReactionLength _parseReactionLength(String value) {
    return switch (value) {
      'concise' => ReactionLength.concise,
      'balanced' => ReactionLength.balanced,
      'expressive' => ReactionLength.expressive,
      _ => throw FormatException(
        'Unsupported persisted reaction length: $value',
      ),
    };
  }
}
