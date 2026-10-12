import 'package:flutter/material.dart';

/// A deliberately small, code-owned set of profile choices.
///
/// The persisted seed is an opaque identifier. It never becomes a URL, file
/// path, or arbitrary icon name, and unknown legacy values render as the safe
/// default.
final class PersonaAvatarPreset {
  const PersonaAvatarPreset._({
    required this.seed,
    required this.icon,
    required this.seedColor,
  });

  static const PersonaAvatarPreset defaultPreset = PersonaAvatarPreset._(
    seed: 'moa-default',
    icon: Icons.eco_rounded,
    seedColor: Color(0xFF537A4B),
  );

  static const List<PersonaAvatarPreset> values = [
    defaultPreset,
    PersonaAvatarPreset._(
      seed: 'forest-leaf',
      icon: Icons.spa_rounded,
      seedColor: Color(0xFF25745A),
    ),
    PersonaAvatarPreset._(
      seed: 'sunny-spark',
      icon: Icons.wb_sunny_rounded,
      seedColor: Color(0xFF9A6200),
    ),
    PersonaAvatarPreset._(
      seed: 'quiet-moon',
      icon: Icons.dark_mode_rounded,
      seedColor: Color(0xFF555A9D),
    ),
  ];

  final String seed;
  final IconData icon;
  final Color seedColor;

  static PersonaAvatarPreset resolve(String seed) {
    for (final preset in values) {
      if (preset.seed == seed) {
        return preset;
      }
    }
    return defaultPreset;
  }
}

final class PersonaAvatar extends StatelessWidget {
  const PersonaAvatar({
    required this.avatarSeed,
    this.size = 44,
    this.semanticLabel,
    super.key,
  });

  final String avatarSeed;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final preset = PersonaAvatarPreset.resolve(avatarSeed);
    final palette = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Theme.of(context).brightness,
    );
    final avatar = ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            preset.icon,
            size: size * 0.52,
            color: palette.onPrimaryContainer,
          ),
        ),
      ),
    );
    final label = semanticLabel;
    if (label == null) {
      return avatar;
    }
    return Semantics(label: label, image: true, child: avatar);
  }
}
