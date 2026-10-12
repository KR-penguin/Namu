import 'dart:convert';

import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/diary/domain/diary_entry.dart';
import 'package:namu/features/diary/domain/diary_generation_output.dart';
import 'package:namu/features/diary/domain/weather_snapshot.dart';

/// Lossless, versioned persistence contract for a complete [DiaryEntry].
final class DiaryEntryJsonCodec {
  const DiaryEntryJsonCodec();

  static const int currentSchemaVersion = 1;

  static const Set<String> _entryFields = {
    'schemaVersion',
    'id',
    'dayKey',
    'version',
    'status',
    'weather',
    'mood',
    'oneLineSummary',
    'theme',
    'blocks',
    'memoryCandidates',
    'sourceMessageIds',
    'generationId',
    'generatedAtUtc',
    'updatedAtUtc',
  };

  static const Set<String> _dayKeyFields = {
    'labelDate',
    'timeZoneId',
    'cutoffMicros',
    'policyVersion',
  };

  static const Set<String> _weatherFields = {
    'provenance',
    'condition',
    'temperatureCelsius',
    'providerId',
    'observedAtUtc',
  };

  String encode(DiaryEntry entry) {
    return jsonEncode(<String, Object?>{
      'schemaVersion': currentSchemaVersion,
      'id': entry.id,
      'dayKey': <String, Object?>{
        'labelDate': entry.dayKey.labelDate.toString(),
        'timeZoneId': entry.dayKey.timeZoneId,
        'cutoffMicros': entry.dayKey.cutoff.inMicroseconds,
        'policyVersion': entry.dayKey.policyVersion,
      },
      'version': entry.version,
      'status': entry.status.name,
      'weather': _encodeWeather(entry.weather),
      'mood': entry.mood,
      'oneLineSummary': entry.oneLineSummary,
      'theme': entry.theme.name,
      'blocks': entry.blocks.map(_encodeBlock).toList(growable: false),
      'memoryCandidates': entry.memoryCandidates
          .map(
            (candidate) => <String, Object?>{
              'fact': candidate.fact,
              'sourceMessageIds': candidate.sourceMessageIds,
            },
          )
          .toList(growable: false),
      'sourceMessageIds': entry.sourceMessageIds,
      'generationId': entry.generationId,
      'generatedAtUtc': entry.generatedAtUtc.toIso8601String(),
      'updatedAtUtc': entry.updatedAtUtc.toIso8601String(),
    });
  }

  DiaryEntry decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Invalid diary snapshot JSON: ${error.message}');
    }

    try {
      final json = _requireObject(decoded, r'$');
      _requireExactFields(json, _entryFields, r'$');
      final schemaVersion = _requireInt(
        json['schemaVersion'],
        r'$.schemaVersion',
      );
      if (schemaVersion != currentSchemaVersion) {
        throw const FormatException('Unsupported diary snapshot schema.');
      }

      return DiaryEntry(
        id: _requireNonBlank(json['id'], r'$.id'),
        dayKey: _decodeDayKey(json['dayKey']),
        version: _requireInt(json['version'], r'$.version'),
        status: _decodeStatus(json['status']),
        weather: _decodeWeather(json['weather']),
        mood: _requireNonBlank(json['mood'], r'$.mood'),
        oneLineSummary: _requireNonBlank(
          json['oneLineSummary'],
          r'$.oneLineSummary',
        ),
        theme: _decodeTheme(json['theme']),
        blocks: _decodeBlocks(json['blocks']),
        memoryCandidates: _decodeMemoryCandidates(json['memoryCandidates']),
        sourceMessageIds: _requireUniqueStringList(
          json['sourceMessageIds'],
          r'$.sourceMessageIds',
        ),
        generationId: _requireNonBlank(json['generationId'], r'$.generationId'),
        generatedAtUtc: _requireUtcInstant(
          json['generatedAtUtc'],
          r'$.generatedAtUtc',
        ),
        updatedAtUtc: _requireUtcInstant(
          json['updatedAtUtc'],
          r'$.updatedAtUtc',
        ),
      );
    } on FormatException {
      rethrow;
    } on ArgumentError catch (error) {
      throw FormatException(error.message?.toString() ?? 'Invalid diary.');
    }
  }

  Map<String, Object?> _encodeWeather(WeatherSnapshot weather) {
    return <String, Object?>{
      'provenance': weather.provenance.name,
      'condition': weather.condition,
      'temperatureCelsius': weather.temperatureCelsius,
      'providerId': weather.providerId,
      'observedAtUtc': weather.observedAtUtc?.toIso8601String(),
    };
  }

  Map<String, Object?> _encodeBlock(DiaryBlock block) {
    return switch (block) {
      DiaryTextBlock(:final text) => <String, Object?>{
        'type': 'text',
        'text': text,
      },
      DiaryPhotoBlock(:final photoAssetId) => <String, Object?>{
        'type': 'photo',
        'photoAssetId': photoAssetId,
      },
    };
  }

  DiaryDayKey _decodeDayKey(Object? value) {
    final json = _requireObject(value, r'$.dayKey');
    _requireExactFields(json, _dayKeyFields, r'$.dayKey');
    final labelDate = _parseLocalDate(
      _requireNonBlank(json['labelDate'], r'$.dayKey.labelDate'),
    );

    return DiaryDayKey.restore(
      labelDate: labelDate,
      timeZoneId: _requireNonBlank(json['timeZoneId'], r'$.dayKey.timeZoneId'),
      cutoff: Duration(
        microseconds: _requireInt(
          json['cutoffMicros'],
          r'$.dayKey.cutoffMicros',
        ),
      ),
      policyVersion: _requireInt(
        json['policyVersion'],
        r'$.dayKey.policyVersion',
      ),
    );
  }

  LocalDate _parseLocalDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw const FormatException(r'$.dayKey.labelDate must use YYYY-MM-DD.');
    }
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  DiaryEntryStatus _decodeStatus(Object? value) {
    return switch (value) {
      'draft' => DiaryEntryStatus.draft,
      'finalized' => DiaryEntryStatus.finalized,
      _ => throw const FormatException(r'$.status is not supported.'),
    };
  }

  DiaryTheme _decodeTheme(Object? value) {
    return switch (value) {
      'light' => DiaryTheme.light,
      'dark' => DiaryTheme.dark,
      _ => throw const FormatException(r'$.theme is not supported.'),
    };
  }

  WeatherSnapshot _decodeWeather(Object? value) {
    final json = _requireObject(value, r'$.weather');
    _requireExactFields(json, _weatherFields, r'$.weather');
    final temperature = _optionalFiniteDouble(
      json['temperatureCelsius'],
      r'$.weather.temperatureCelsius',
    );

    switch (json['provenance']) {
      case 'noWeather':
        _requireNull(json['condition'], r'$.weather.condition');
        _requireNull(
          json['temperatureCelsius'],
          r'$.weather.temperatureCelsius',
        );
        _requireNull(json['providerId'], r'$.weather.providerId');
        _requireNull(json['observedAtUtc'], r'$.weather.observedAtUtc');
        return const WeatherSnapshot.noWeather();
      case 'manual':
        _requireNull(json['providerId'], r'$.weather.providerId');
        _requireNull(json['observedAtUtc'], r'$.weather.observedAtUtc');
        return WeatherSnapshot.manual(
          condition: _requireNonBlank(
            json['condition'],
            r'$.weather.condition',
          ),
          temperatureCelsius: temperature,
        );
      case 'provider':
        return WeatherSnapshot.provider(
          condition: _requireNonBlank(
            json['condition'],
            r'$.weather.condition',
          ),
          temperatureCelsius: temperature,
          providerId: _requireNonBlank(
            json['providerId'],
            r'$.weather.providerId',
          ),
          observedAtUtc: _requireUtcInstant(
            json['observedAtUtc'],
            r'$.weather.observedAtUtc',
          ),
        );
      default:
        throw const FormatException(r'$.weather.provenance is not supported.');
    }
  }

  List<DiaryBlock> _decodeBlocks(Object? value) {
    final values = _requireList(value, r'$.blocks');
    if (values.isEmpty) {
      throw const FormatException(r'$.blocks must not be empty.');
    }

    return <DiaryBlock>[
      for (var index = 0; index < values.length; index++)
        _decodeBlock(values[index], index),
    ];
  }

  DiaryBlock _decodeBlock(Object? value, int index) {
    final path =
        r'$.blocks['
        '$index]';
    final json = _requireObject(value, path);
    switch (json['type']) {
      case 'text':
        _requireExactFields(json, const {'type', 'text'}, path);
        return DiaryTextBlock(
          text: _requireNonBlank(json['text'], '$path.text'),
        );
      case 'photo':
        _requireExactFields(json, const {'type', 'photoAssetId'}, path);
        return DiaryPhotoBlock(
          photoAssetId: _requireNonBlank(
            json['photoAssetId'],
            '$path.photoAssetId',
          ),
        );
      default:
        throw FormatException('$path.type is not supported.');
    }
  }

  List<DiaryMemoryCandidate> _decodeMemoryCandidates(Object? value) {
    final values = _requireList(value, r'$.memoryCandidates');
    return <DiaryMemoryCandidate>[
      for (var index = 0; index < values.length; index++)
        _decodeMemoryCandidate(values[index], index),
    ];
  }

  DiaryMemoryCandidate _decodeMemoryCandidate(Object? value, int index) {
    final path =
        r'$.memoryCandidates['
        '$index]';
    final json = _requireObject(value, path);
    _requireExactFields(json, const {'fact', 'sourceMessageIds'}, path);
    return DiaryMemoryCandidate(
      fact: _requireNonBlank(json['fact'], '$path.fact'),
      sourceMessageIds: _requireUniqueStringList(
        json['sourceMessageIds'],
        '$path.sourceMessageIds',
      ),
    );
  }

  Map<String, Object?> _requireObject(Object? value, String path) {
    if (value is! Map) {
      throw FormatException('$path must be an object.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('$path keys must be strings.');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  List<Object?> _requireList(Object? value, String path) {
    if (value is! List) {
      throw FormatException('$path must be an array.');
    }
    return List<Object?>.from(value);
  }

  List<String> _requireUniqueStringList(Object? value, String path) {
    final values = _requireList(value, path);
    final result = <String>[];
    final seen = <String>{};
    for (var index = 0; index < values.length; index++) {
      final item = _requireNonBlank(values[index], '$path[$index]');
      if (!seen.add(item)) {
        throw FormatException('$path must not contain duplicates.');
      }
      result.add(item);
    }
    return result;
  }

  String _requireNonBlank(Object? value, String path) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$path must be a nonblank string.');
    }
    return value;
  }

  int _requireInt(Object? value, String path) {
    if (value is! int) {
      throw FormatException('$path must be an integer.');
    }
    return value;
  }

  double? _optionalFiniteDouble(Object? value, String path) {
    if (value == null) {
      return null;
    }
    if (value is! num || !value.isFinite) {
      throw FormatException('$path must be a finite number or null.');
    }
    return value.toDouble();
  }

  DateTime _requireUtcInstant(Object? value, String path) {
    if (value is! String || !value.endsWith('Z')) {
      throw FormatException('$path must be an explicit UTC instant.');
    }
    final instant = DateTime.tryParse(value);
    if (instant == null || !instant.isUtc) {
      throw FormatException('$path must be an explicit UTC instant.');
    }
    return instant;
  }

  void _requireNull(Object? value, String path) {
    if (value != null) {
      throw FormatException('$path must be null for this provenance.');
    }
  }

  void _requireExactFields(
    Map<String, Object?> value,
    Set<String> expected,
    String path,
  ) {
    for (final field in value.keys) {
      if (!expected.contains(field)) {
        throw FormatException('$path.$field is not allowed.');
      }
    }
    for (final field in expected) {
      if (!value.containsKey(field)) {
        throw FormatException('$path.$field is required.');
      }
    }
  }
}
