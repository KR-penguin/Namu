enum ReactionLength { concise, balanced, expressive }

final class AiPersona {
  factory AiPersona({
    required String id,
    required String name,
    required String avatarSeed,
    required String tone,
    required String customInstructions,
    required ReactionLength reactionLength,
  }) {
    final normalizedId = id.trim();
    final normalizedName = name.trim();
    final normalizedAvatarSeed = avatarSeed.trim();
    final normalizedTone = tone.trim();
    final normalizedInstructions = customInstructions.trim();

    _requireText(normalizedId, 'id', maxIdLength);
    _requireText(normalizedName, 'name', maxNameLength);
    _requireText(normalizedAvatarSeed, 'avatarSeed', maxAvatarSeedLength);
    _requireText(normalizedTone, 'tone', maxToneLength);
    _requireWithinLimit(
      normalizedInstructions,
      'customInstructions',
      maxCustomInstructionsLength,
    );

    return AiPersona._(
      id: normalizedId,
      name: normalizedName,
      avatarSeed: normalizedAvatarSeed,
      tone: normalizedTone,
      customInstructions: normalizedInstructions,
      reactionLength: reactionLength,
    );
  }

  const AiPersona._({
    required this.id,
    required this.name,
    required this.avatarSeed,
    required this.tone,
    required this.customInstructions,
    required this.reactionLength,
  });

  factory AiPersona.safeDefault({
    String name = '모아',
    String tone = '따뜻하고 호기심 있게',
  }) {
    return AiPersona(
      id: 'default',
      name: name,
      avatarSeed: 'moa-default',
      tone: tone,
      customInstructions: '',
      reactionLength: ReactionLength.balanced,
    );
  }

  static const int maxIdLength = 128;
  static const int maxNameLength = 40;
  static const int maxAvatarSeedLength = 128;
  static const int maxToneLength = 160;
  static const int maxCustomInstructionsLength = 1000;

  final String id;
  final String name;
  final String avatarSeed;
  final String tone;
  final String customInstructions;
  final ReactionLength reactionLength;

  static void _requireText(String value, String name, int maxLength) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
    _requireWithinLimit(value, name, maxLength);
  }

  static void _requireWithinLimit(String value, String name, int maxLength) {
    if (value.length > maxLength) {
      throw ArgumentError.value(
        value,
        name,
        'must be at most $maxLength characters',
      );
    }
  }
}
