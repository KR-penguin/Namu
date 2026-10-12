import 'package:namu/core/time/diary_day_key.dart';

enum MessageRole { user, assistant }

enum MessageStatus { pending, sent, failed }

final class Message {
  Message({
    required this.id,
    required this.requestId,
    required this.dayKey,
    required this.role,
    required this.createdAtUtc,
    required this.status,
    this.text,
    this.photoAssetId,
  }) {
    _requireNonBlank(id, 'id');
    _requireNonBlank(requestId, 'requestId');
    _requireOptionalNonBlank(text, 'text');
    _requireOptionalNonBlank(photoAssetId, 'photoAssetId');

    if (text == null && photoAssetId == null) {
      throw ArgumentError('A message requires text, a photo, or both.');
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(createdAtUtc, 'createdAtUtc', 'must be in UTC');
    }
  }

  final String id;
  final String requestId;
  final DiaryDayKey dayKey;
  final MessageRole role;
  final String? text;
  final String? photoAssetId;
  final DateTime createdAtUtc;
  final MessageStatus status;

  Message withStatus(MessageStatus status) {
    return Message(
      id: id,
      requestId: requestId,
      dayKey: dayKey,
      role: role,
      text: text,
      photoAssetId: photoAssetId,
      createdAtUtc: createdAtUtc,
      status: status,
    );
  }

  static void _requireNonBlank(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not be blank');
    }
  }

  static void _requireOptionalNonBlank(String? value, String name) {
    if (value != null) {
      _requireNonBlank(value, name);
    }
  }
}
