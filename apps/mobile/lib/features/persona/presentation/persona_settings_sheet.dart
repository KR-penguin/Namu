import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/namu_localizations.dart';
import '../application/persona_controller.dart';
import '../domain/ai_persona.dart';
import 'persona_avatar.dart';

final class PersonaSettingsSheet extends StatefulWidget {
  const PersonaSettingsSheet({
    required this.controller,
    this.onOpenAiDataConsent,
    super.key,
  });

  final PersonaController controller;
  final VoidCallback? onOpenAiDataConsent;

  @override
  State<PersonaSettingsSheet> createState() => _PersonaSettingsSheetState();
}

final class _PersonaSettingsSheetState extends State<PersonaSettingsSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _toneController;
  late final TextEditingController _instructionsController;
  late String _avatarSeed;
  late ReactionLength _reactionLength;
  String? _validationMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final persona = widget.controller.persona;
    _nameController = TextEditingController(text: persona.name);
    _toneController = TextEditingController(text: persona.tone);
    _instructionsController = TextEditingController(
      text: persona.customInstructions,
    );
    _avatarSeed = PersonaAvatarPreset.resolve(persona.avatarSeed).seed;
    _reactionLength = persona.reactionLength;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _toneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
      _validationMessage = null;
    });

    try {
      await widget.controller.save(
        name: _nameController.text,
        avatarSeed: _avatarSeed,
        tone: _toneController.text,
        customInstructions: _instructionsController.text,
        reactionLength: _reactionLength,
      );
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    } on ArgumentError {
      if (mounted) {
        setState(
          () => _validationMessage = context.l10n.personaValidationError,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _validationMessage = context.l10n.personaSaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.personaSettingsTitle,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.personaSettingsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('persona.name.field'),
                controller: _nameController,
                maxLength: AiPersona.maxNameLength,
                decoration: InputDecoration(
                  labelText: context.l10n.personaNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.personaProfileLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in PersonaAvatarPreset.values)
                    ChoiceChip(
                      key: Key('persona.avatarOption.${preset.seed}'),
                      avatar: PersonaAvatar(avatarSeed: preset.seed, size: 28),
                      label: Text(_avatarLabel(preset, context.l10n)),
                      selected: _avatarSeed == preset.seed,
                      onSelected: _isSaving
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _avatarSeed = preset.seed);
                              }
                            },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('persona.tone.field'),
                controller: _toneController,
                maxLength: AiPersona.maxToneLength,
                decoration: InputDecoration(
                  labelText: context.l10n.personaToneLabel,
                  hintText: context.l10n.personaToneHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.personaReactionLengthLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ReactionLength>(
                segments: [
                  ButtonSegment(
                    value: ReactionLength.concise,
                    label: Text(context.l10n.personaReactionConcise),
                  ),
                  ButtonSegment(
                    value: ReactionLength.balanced,
                    label: Text(context.l10n.personaReactionBalanced),
                  ),
                  ButtonSegment(
                    value: ReactionLength.expressive,
                    label: Text(context.l10n.personaReactionExpressive),
                  ),
                ],
                selected: {_reactionLength},
                onSelectionChanged: _isSaving
                    ? null
                    : (selection) {
                        setState(() => _reactionLength = selection.single);
                      },
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('persona.instructions.field'),
                controller: _instructionsController,
                maxLength: AiPersona.maxCustomInstructionsLength,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.personaInstructionsLabel,
                  hintText: context.l10n.personaInstructionsHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_validationMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  _validationMessage!,
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (widget.onOpenAiDataConsent != null) ...[
                OutlinedButton.icon(
                  key: const Key('persona.aiDataConsent'),
                  onPressed: _isSaving ? null : widget.onOpenAiDataConsent,
                  icon: const Icon(Icons.shield_outlined),
                  label: Text(context.l10n.personaAiConsentAction),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton(
                key: const Key('persona.save'),
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _avatarLabel(
  PersonaAvatarPreset preset,
  AppLocalizations localizations,
) {
  return switch (preset.seed) {
    'forest-leaf' => localizations.personaAvatarLeaf,
    'sunny-spark' => localizations.personaAvatarSunlight,
    'quiet-moon' => localizations.personaAvatarMoonlight,
    _ => localizations.personaAvatarSprout,
  };
}
