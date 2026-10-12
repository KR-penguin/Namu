import 'dart:convert';

import '../domain/diary_generation_output.dart';

enum DiaryGenerationContractError {
  malformedJson,
  expectedObject,
  expectedArray,
  missingField,
  unexpectedField,
  invalidFieldType,
  invalidFieldValue,
  unsupportedSchemaVersion,
  unsupportedTheme,
  unsupportedBlockType,
  emptyBlocks,
  unknownPhotoAssetId,
  unknownSourceMessageId,
}

final class DiaryGenerationContractException implements Exception {
  const DiaryGenerationContractException({
    required this.code,
    required this.path,
    required this.message,
  });

  final DiaryGenerationContractError code;
  final String path;
  final String message;

  @override
  String toString() {
    return 'DiaryGenerationContractException($code at $path: $message)';
  }
}

final class DiaryGenerationOutputDecoder {
  const DiaryGenerationOutputDecoder();

  static const _topLevelFields = {
    'schemaVersion',
    'mood',
    'oneLineSummary',
    'theme',
    'blocks',
    'memoryCandidates',
  };

  DiaryGenerationOutput decode(
    String source, {
    required Set<String> allowedPhotoAssetIds,
    required Set<String> allowedSourceMessageIds,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw DiaryGenerationContractException(
        code: DiaryGenerationContractError.malformedJson,
        path: r'$',
        message: error.message,
      );
    }

    final root = _requireObject(decoded, r'$');
    _requireExactFields(root, _topLevelFields, r'$');

    final schemaVersion = root['schemaVersion'];
    if (schemaVersion is! int ||
        schemaVersion != DiaryGenerationOutput.currentSchemaVersion) {
      _fail(
        DiaryGenerationContractError.unsupportedSchemaVersion,
        r'$.schemaVersion',
        'Expected schema version ${DiaryGenerationOutput.currentSchemaVersion}.',
      );
    }

    final mood = _requireNonEmptyString(root['mood'], r'$.mood');
    final oneLineSummary = _requireNonEmptyString(
      root['oneLineSummary'],
      r'$.oneLineSummary',
    );
    final theme = _decodeTheme(root['theme']);
    final blocks = _decodeBlocks(
      root['blocks'],
      allowedPhotoAssetIds: allowedPhotoAssetIds,
    );
    final memoryCandidates = _decodeMemoryCandidates(
      root['memoryCandidates'],
      allowedSourceMessageIds: allowedSourceMessageIds,
    );

    return DiaryGenerationOutput(
      schemaVersion: schemaVersion,
      mood: mood,
      oneLineSummary: oneLineSummary,
      theme: theme,
      blocks: blocks,
      memoryCandidates: memoryCandidates,
    );
  }

  DiaryTheme _decodeTheme(Object? value) {
    if (value is! String) {
      _fail(
        DiaryGenerationContractError.invalidFieldType,
        r'$.theme',
        'Expected a string.',
      );
    }

    return switch (value) {
      'light' => DiaryTheme.light,
      'dark' => DiaryTheme.dark,
      _ => throw DiaryGenerationContractException(
        code: DiaryGenerationContractError.unsupportedTheme,
        path: r'$.theme',
        message: 'Unsupported theme "$value".',
      ),
    };
  }

  List<DiaryBlock> _decodeBlocks(
    Object? value, {
    required Set<String> allowedPhotoAssetIds,
  }) {
    final values = _requireArray(value, r'$.blocks');
    if (values.isEmpty) {
      _fail(
        DiaryGenerationContractError.emptyBlocks,
        r'$.blocks',
        'At least one block is required.',
      );
    }

    return [
      for (var index = 0; index < values.length; index++)
        _decodeBlock(
          values[index],
          index: index,
          allowedPhotoAssetIds: allowedPhotoAssetIds,
        ),
    ];
  }

  DiaryBlock _decodeBlock(
    Object? value, {
    required int index,
    required Set<String> allowedPhotoAssetIds,
  }) {
    final path =
        r'$.blocks['
        '$index]';
    final block = _requireObject(value, path);
    final type = _requireNonEmptyString(block['type'], '$path.type');

    switch (type) {
      case 'text':
        _requireExactFields(block, const {'type', 'text'}, path);
        return DiaryTextBlock(
          text: _requireNonEmptyString(block['text'], '$path.text'),
        );
      case 'photo':
        _requireExactFields(block, const {'type', 'photoAssetId'}, path);
        final photoAssetId = _requireNonEmptyString(
          block['photoAssetId'],
          '$path.photoAssetId',
        );
        if (!allowedPhotoAssetIds.contains(photoAssetId)) {
          _fail(
            DiaryGenerationContractError.unknownPhotoAssetId,
            '$path.photoAssetId',
            'The photo asset was not supplied to this generation request.',
          );
        }
        return DiaryPhotoBlock(photoAssetId: photoAssetId);
      default:
        _fail(
          DiaryGenerationContractError.unsupportedBlockType,
          '$path.type',
          'Unsupported block type "$type".',
        );
    }
  }

  List<DiaryMemoryCandidate> _decodeMemoryCandidates(
    Object? value, {
    required Set<String> allowedSourceMessageIds,
  }) {
    final values = _requireArray(value, r'$.memoryCandidates');

    return [
      for (var index = 0; index < values.length; index++)
        _decodeMemoryCandidate(
          values[index],
          index: index,
          allowedSourceMessageIds: allowedSourceMessageIds,
        ),
    ];
  }

  DiaryMemoryCandidate _decodeMemoryCandidate(
    Object? value, {
    required int index,
    required Set<String> allowedSourceMessageIds,
  }) {
    final path =
        r'$.memoryCandidates['
        '$index]';
    final candidate = _requireObject(value, path);
    _requireExactFields(candidate, const {'fact', 'sourceMessageIds'}, path);

    final fact = _requireNonEmptyString(candidate['fact'], '$path.fact');
    final sourceValues = _requireArray(
      candidate['sourceMessageIds'],
      '$path.sourceMessageIds',
    );
    if (sourceValues.isEmpty) {
      _fail(
        DiaryGenerationContractError.invalidFieldValue,
        '$path.sourceMessageIds',
        'At least one source message is required.',
      );
    }

    final sourceMessageIds = <String>[];
    final seenSourceMessageIds = <String>{};
    for (
      var sourceIndex = 0;
      sourceIndex < sourceValues.length;
      sourceIndex++
    ) {
      final sourcePath = '$path.sourceMessageIds[$sourceIndex]';
      final sourceMessageId = _requireNonEmptyString(
        sourceValues[sourceIndex],
        sourcePath,
      );
      if (!allowedSourceMessageIds.contains(sourceMessageId)) {
        _fail(
          DiaryGenerationContractError.unknownSourceMessageId,
          sourcePath,
          'The source message was not supplied to this generation request.',
        );
      }
      if (!seenSourceMessageIds.add(sourceMessageId)) {
        _fail(
          DiaryGenerationContractError.invalidFieldValue,
          sourcePath,
          'Source message IDs must be unique within a candidate.',
        );
      }
      sourceMessageIds.add(sourceMessageId);
    }

    return DiaryMemoryCandidate(fact: fact, sourceMessageIds: sourceMessageIds);
  }

  Map<String, Object?> _requireObject(Object? value, String path) {
    if (value is! Map) {
      _fail(
        DiaryGenerationContractError.expectedObject,
        path,
        'Expected a JSON object.',
      );
    }

    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        _fail(
          DiaryGenerationContractError.invalidFieldType,
          path,
          'Object keys must be strings.',
        );
      }
      result[key] = entry.value;
    }
    return result;
  }

  List<Object?> _requireArray(Object? value, String path) {
    if (value is! List) {
      _fail(
        DiaryGenerationContractError.expectedArray,
        path,
        'Expected a JSON array.',
      );
    }
    return List<Object?>.from(value);
  }

  String _requireNonEmptyString(Object? value, String path) {
    if (value is! String) {
      _fail(
        DiaryGenerationContractError.invalidFieldType,
        path,
        'Expected a string.',
      );
    }
    if (value.isEmpty) {
      _fail(
        DiaryGenerationContractError.invalidFieldValue,
        path,
        'Expected a non-empty string.',
      );
    }
    return value;
  }

  void _requireExactFields(
    Map<String, Object?> value,
    Set<String> expectedFields,
    String path,
  ) {
    for (final field in value.keys) {
      if (!expectedFields.contains(field)) {
        _fail(
          DiaryGenerationContractError.unexpectedField,
          '$path.$field',
          'Field "$field" is not allowed.',
        );
      }
    }
    for (final field in expectedFields) {
      if (!value.containsKey(field)) {
        _fail(
          DiaryGenerationContractError.missingField,
          '$path.$field',
          'Required field "$field" is missing.',
        );
      }
    }
  }

  Never _fail(DiaryGenerationContractError code, String path, String message) {
    throw DiaryGenerationContractException(
      code: code,
      path: path,
      message: message,
    );
  }
}
