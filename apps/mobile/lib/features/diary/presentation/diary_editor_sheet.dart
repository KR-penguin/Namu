import 'package:flutter/material.dart';

import '../../../l10n/namu_formatters.dart';
import '../../../l10n/namu_localizations.dart';
import '../../media/presentation/local_photo.dart';
import '../application/diary_controller.dart';
import '../domain/diary_generation_output.dart';
import '../domain/weather_snapshot.dart';

final class DiaryEditorSheet extends StatefulWidget {
  const DiaryEditorSheet({
    required this.controller,
    this.photoBytesLoader,
    super.key,
  });

  final DiaryController controller;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  State<DiaryEditorSheet> createState() => _DiaryEditorSheetState();
}

final class _DiaryEditorSheetState extends State<DiaryEditorSheet> {
  late final TextEditingController _moodController;
  late final TextEditingController _summaryController;
  late final TextEditingController _weatherConditionController;
  late final TextEditingController _weatherTemperatureController;
  late final List<_EditableBlock> _blocks;
  late final WeatherSnapshot _originalWeather;
  late bool _weatherEnabled;
  late DiaryTheme _theme;
  String? _validationMessage;
  bool _isSaving = false;
  bool _hasFormattedInitialTemperature = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.controller.entry;
    if (entry == null) {
      throw StateError('DiaryEditorSheet requires a loaded diary.');
    }
    _moodController = TextEditingController(text: entry.mood);
    _summaryController = TextEditingController(text: entry.oneLineSummary);
    _originalWeather = entry.weather;
    _weatherEnabled = entry.weather.provenance != WeatherProvenance.noWeather;
    _weatherConditionController = TextEditingController(
      text: entry.weather.condition ?? '',
    );
    _weatherTemperatureController = TextEditingController(text: '');
    _theme = entry.theme;
    _blocks = [for (final block in entry.blocks) _EditableBlock.from(block)];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasFormattedInitialTemperature) {
      return;
    }
    _hasFormattedInitialTemperature = true;
    final temperature = _originalWeather.temperatureCelsius;
    if (temperature != null) {
      _weatherTemperatureController.text = NamuFormatters.decimal(
        temperature,
        Localizations.localeOf(context),
      );
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _summaryController.dispose();
    _weatherConditionController.dispose();
    _weatherTemperatureController.dispose();
    for (final block in _blocks) {
      block.dispose();
    }
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
      final blocks = <DiaryBlock>[
        for (final block in _blocks) block.toDiaryBlock(),
      ];
      await widget.controller.edit(
        weather: _weatherForSave(),
        mood: _moodController.text.trim(),
        oneLineSummary: _summaryController.text.trim(),
        theme: _theme,
        blocks: blocks,
      );
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    } on ArgumentError {
      if (mounted) {
        setState(
          () => _validationMessage = context.l10n.diaryEditorValidationError,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _validationMessage = context.l10n.diaryEditorSaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  WeatherSnapshot _weatherForSave() {
    if (!_weatherEnabled) {
      return const WeatherSnapshot.noWeather();
    }

    final condition = _weatherConditionController.text.trim();
    final temperatureText = _weatherTemperatureController.text.trim();
    final temperature = temperatureText.isEmpty
        ? null
        : NamuFormatters.tryParseDecimal(
            temperatureText,
            Localizations.localeOf(context),
          );
    if (temperatureText.isNotEmpty && temperature == null) {
      throw ArgumentError.value(
        temperatureText,
        'temperatureCelsius',
        'must be a number',
      );
    }

    if (_originalWeather.provenance == WeatherProvenance.provider &&
        condition == _originalWeather.condition &&
        temperature == _originalWeather.temperatureCelsius) {
      return _originalWeather;
    }
    return WeatherSnapshot.manual(
      condition: condition,
      temperatureCelsius: temperature,
    );
  }

  void _move(int index, int offset) {
    final target = index + offset;
    if (target < 0 || target >= _blocks.length) {
      return;
    }
    setState(() {
      final block = _blocks.removeAt(index);
      _blocks.insert(target, block);
    });
  }

  void _remove(int index) {
    setState(() {
      final removed = _blocks.removeAt(index);
      removed.dispose();
    });
  }

  void _addParagraph() {
    setState(() => _blocks.add(_EditableTextBlock('')));
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
                context.l10n.diaryEditorTitle,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.diaryEditorSubtitle,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('diary.editor.mood'),
                controller: _moodController,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: context.l10n.diaryEditorMoodLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('diary.editor.summary'),
                controller: _summaryController,
                maxLength: 160,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.l10n.diaryEditorSummaryLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                key: const Key('diary.editor.weather.enabled'),
                contentPadding: EdgeInsets.zero,
                value: _weatherEnabled,
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _weatherEnabled = value),
                title: Text(context.l10n.diaryEditorWeatherTitle),
                subtitle: Text(context.l10n.diaryEditorWeatherSubtitle),
              ),
              if (_weatherEnabled) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        key: const Key('diary.editor.weather.condition'),
                        controller: _weatherConditionController,
                        enabled: !_isSaving,
                        maxLength: 40,
                        decoration: InputDecoration(
                          labelText:
                              context.l10n.diaryEditorWeatherConditionLabel,
                          hintText:
                              context.l10n.diaryEditorWeatherConditionHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        key: const Key('diary.editor.weather.temperature'),
                        controller: _weatherTemperatureController,
                        enabled: !_isSaving,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: context.l10n.diaryEditorTemperatureLabel,
                          hintText: context.l10n.diaryEditorOptionalHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                context.l10n.diaryEditorBackgroundLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<DiaryTheme>(
                segments: [
                  ButtonSegment(
                    value: DiaryTheme.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(context.l10n.diaryEditorLightBackground),
                  ),
                  ButtonSegment(
                    value: DiaryTheme.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(context.l10n.diaryEditorDarkBackground),
                  ),
                ],
                selected: {_theme},
                onSelectionChanged: _isSaving
                    ? null
                    : (selection) => setState(() => _theme = selection.single),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.diaryEditorContentTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isSaving ? null : _addParagraph,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.l10n.diaryEditorAddParagraph),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < _blocks.length; index++) ...[
                _BlockEditor(
                  index: index,
                  block: _blocks[index],
                  isFirst: index == 0,
                  isLast: index == _blocks.length - 1,
                  enabled: !_isSaving,
                  photoBytesLoader: widget.photoBytesLoader,
                  onMoveUp: () => _move(index, -1),
                  onMoveDown: () => _move(index, 1),
                  onRemove: () => _remove(index),
                ),
                const SizedBox(height: 10),
              ],
              if (_validationMessage != null) ...[
                const SizedBox(height: 2),
                Text(
                  _validationMessage!,
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('diary.editor.save'),
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
                    : Text(context.l10n.diaryEditorSaveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _BlockEditor extends StatelessWidget {
  const _BlockEditor({
    required this.index,
    required this.block,
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.photoBytesLoader,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  final int index;
  final _EditableBlock block;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final LocalPhotoBytesLoader? photoBytesLoader;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _content(context)),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: Key('diary.editor.block.$index.up'),
                  tooltip: context.l10n.diaryEditorMoveUpTooltip,
                  onPressed: enabled && !isFirst ? onMoveUp : null,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  key: Key('diary.editor.block.$index.down'),
                  tooltip: context.l10n.diaryEditorMoveDownTooltip,
                  onPressed: enabled && !isLast ? onMoveDown : null,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                IconButton(
                  key: Key('diary.editor.block.$index.remove'),
                  tooltip: context.l10n.diaryEditorRemoveBlockTooltip,
                  onPressed: enabled ? onRemove : null,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return switch (block) {
      _EditableTextBlock(:final controller) => TextField(
        key: Key('diary.editor.block.$index.text'),
        controller: controller,
        enabled: enabled,
        minLines: 3,
        maxLines: 6,
        maxLength: 1200,
        decoration: InputDecoration(
          labelText: context.l10n.diaryEditorParagraphLabel,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
      _EditablePhotoBlock(:final photoAssetId) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          key: Key('diary.editor.block.$index.photo'),
          height: 112,
          child: LocalPhoto(
            assetId: photoAssetId,
            loadBytes: photoBytesLoader,
            cacheWidth: 480,
          ),
        ),
      ),
    };
  }
}

sealed class _EditableBlock {
  const _EditableBlock();

  factory _EditableBlock.from(DiaryBlock block) {
    return switch (block) {
      DiaryTextBlock(:final text) => _EditableTextBlock(text),
      DiaryPhotoBlock(:final photoAssetId) => _EditablePhotoBlock(photoAssetId),
    };
  }

  DiaryBlock toDiaryBlock();

  void dispose() {}
}

final class _EditableTextBlock extends _EditableBlock {
  _EditableTextBlock(String text)
    : controller = TextEditingController(text: text);

  final TextEditingController controller;

  @override
  DiaryBlock toDiaryBlock() => DiaryTextBlock(text: controller.text.trim());

  @override
  void dispose() => controller.dispose();
}

final class _EditablePhotoBlock extends _EditableBlock {
  const _EditablePhotoBlock(this.photoAssetId);

  final String photoAssetId;

  @override
  DiaryBlock toDiaryBlock() => DiaryPhotoBlock(photoAssetId: photoAssetId);
}
