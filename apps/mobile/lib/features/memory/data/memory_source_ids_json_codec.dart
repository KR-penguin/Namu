import 'dart:convert';

final class MemorySourceIdsJsonCodec {
  const MemorySourceIdsJsonCodec();

  static const int currentSchemaVersion = 1;
  static const Set<String> _fields = {'schemaVersion', 'sourceMessageIds'};

  String encode(Iterable<String> sourceMessageIds) {
    final normalized = _validate(sourceMessageIds.toList(growable: false));
    return jsonEncode(<String, Object?>{
      'schemaVersion': currentSchemaVersion,
      'sourceMessageIds': normalized,
    });
  }

  List<String> decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Invalid memory source JSON: ${error.message}');
    }
    if (decoded is! Map) {
      throw const FormatException('Memory source JSON must be an object.');
    }

    final json = <String, Object?>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        throw const FormatException('Memory source keys must be strings.');
      }
      json[entry.key as String] = entry.value;
    }
    for (final key in json.keys) {
      if (!_fields.contains(key)) {
        throw FormatException(
          r'$.'
          '$key is not allowed.',
        );
      }
    }
    for (final field in _fields) {
      if (!json.containsKey(field)) {
        throw FormatException(
          r'$.'
          '$field is required.',
        );
      }
    }
    if (json['schemaVersion'] != currentSchemaVersion) {
      throw const FormatException('Unsupported memory source schema.');
    }
    final values = json['sourceMessageIds'];
    if (values is! List) {
      throw const FormatException(r'$.sourceMessageIds must be an array.');
    }
    return _validate(List<Object?>.from(values));
  }

  List<String> _validate(List<Object?> values) {
    if (values.isEmpty) {
      throw const FormatException(
        r'$.sourceMessageIds must contain at least one item.',
      );
    }
    final result = <String>[];
    final seen = <String>{};
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          r'$.sourceMessageIds['
          '$index] must be a nonblank string.',
        );
      }
      final normalized = value.trim();
      if (!seen.add(normalized)) {
        throw const FormatException(
          r'$.sourceMessageIds must not contain duplicates.',
        );
      }
      result.add(normalized);
    }
    return List<String>.unmodifiable(result);
  }
}
