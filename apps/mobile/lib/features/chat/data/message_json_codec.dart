import '../../../core/time/diary_day_key.dart';
import '../../../core/time/local_date.dart';
import '../domain/message.dart';

final class MessageJsonCodec {
  const MessageJsonCodec();

  static const _messageFields = <String>{
    'id',
    'requestId',
    'dayKey',
    'role',
    'text',
    'photoAssetId',
    'createdAtUtc',
    'status',
  };

  static const _dayKeyFields = <String>{
    'labelDate',
    'timeZoneId',
    'cutoffMinutes',
    'policyVersion',
  };

  Map<String, Object?> encode(Message message) {
    return <String, Object?>{
      'id': message.id,
      'requestId': message.requestId,
      'dayKey': <String, Object?>{
        'labelDate': message.dayKey.labelDate.toString(),
        'timeZoneId': message.dayKey.timeZoneId,
        'cutoffMinutes': message.dayKey.cutoff.inMinutes,
        'policyVersion': message.dayKey.policyVersion,
      },
      'role': message.role.name,
      'text': message.text,
      'photoAssetId': message.photoAssetId,
      'createdAtUtc': message.createdAtUtc.toIso8601String(),
      'status': message.status.name,
    };
  }

  Message decode(Map<String, Object?> json) {
    try {
      _requireExactFields(json, _messageFields, r'$');
      final dayKeyJson = _requireStringMap(json['dayKey'], r'$.dayKey');
      _requireExactFields(dayKeyJson, _dayKeyFields, r'$.dayKey');

      final createdAtUtc = DateTime.tryParse(
        _requireString(json['createdAtUtc'], r'$.createdAtUtc'),
      );
      if (createdAtUtc == null || !createdAtUtc.isUtc) {
        throw const FormatException(r'$.createdAtUtc must be a UTC instant.');
      }

      return Message(
        id: _requireString(json['id'], r'$.id'),
        requestId: _requireString(json['requestId'], r'$.requestId'),
        dayKey: _decodeDayKey(dayKeyJson),
        role: _decodeRole(json['role']),
        text: _optionalString(json['text'], r'$.text'),
        photoAssetId: _optionalString(json['photoAssetId'], r'$.photoAssetId'),
        createdAtUtc: createdAtUtc,
        status: _decodeStatus(json['status']),
      );
    } on FormatException {
      rethrow;
    } on ArgumentError catch (error) {
      throw FormatException(error.message?.toString() ?? 'Invalid message.');
    }
  }

  DiaryDayKey _decodeDayKey(Map<String, Object?> json) {
    final label = _requireString(json['labelDate'], r'$.dayKey.labelDate');
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(label);
    if (match == null) {
      throw const FormatException(r'$.dayKey.labelDate must use YYYY-MM-DD.');
    }

    return DiaryDayKey.restore(
      labelDate: LocalDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      ),
      timeZoneId: _requireString(json['timeZoneId'], r'$.dayKey.timeZoneId'),
      cutoff: Duration(
        minutes: _requireInt(json['cutoffMinutes'], r'$.dayKey.cutoffMinutes'),
      ),
      policyVersion: _requireInt(
        json['policyVersion'],
        r'$.dayKey.policyVersion',
      ),
    );
  }

  MessageRole _decodeRole(Object? value) {
    return switch (value) {
      'user' => MessageRole.user,
      'assistant' => MessageRole.assistant,
      _ => throw const FormatException(r'$.role is not supported.'),
    };
  }

  MessageStatus _decodeStatus(Object? value) {
    return switch (value) {
      'pending' => MessageStatus.pending,
      'sent' => MessageStatus.sent,
      'failed' => MessageStatus.failed,
      _ => throw const FormatException(r'$.status is not supported.'),
    };
  }

  Map<String, Object?> _requireStringMap(Object? value, String path) {
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

  String _requireString(Object? value, String path) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$path must be a nonblank string.');
    }
    return value;
  }

  String? _optionalString(Object? value, String path) {
    if (value == null) {
      return null;
    }
    return _requireString(value, path);
  }

  int _requireInt(Object? value, String path) {
    if (value is! int) {
      throw FormatException('$path must be an integer.');
    }
    return value;
  }

  void _requireExactFields(
    Map<String, Object?> json,
    Set<String> fields,
    String path,
  ) {
    for (final key in json.keys) {
      if (!fields.contains(key)) {
        throw FormatException('$path.$key is not allowed.');
      }
    }
    for (final field in fields) {
      if (!json.containsKey(field)) {
        throw FormatException('$path.$field is required.');
      }
    }
  }
}
