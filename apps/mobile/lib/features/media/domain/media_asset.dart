import 'package:namu/core/time/diary_day_key.dart';

enum MediaMimeType {
  jpeg(contentType: 'image/jpeg'),
  png(contentType: 'image/png'),
  heic(contentType: 'image/heic');

  const MediaMimeType({required this.contentType});

  final String contentType;

  static MediaMimeType? tryParse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final mimeType in values) {
      if (mimeType.contentType == normalized) {
        return mimeType;
      }
    }
    return null;
  }
}

enum MediaLifecycle { staging, ready, deleting, missing }

final class MediaAsset {
  MediaAsset({
    required this.id,
    required this.dayKey,
    required this.storageKey,
    required this.mimeType,
    required this.byteLength,
    required this.createdAtUtc,
    required this.lifecycle,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be blank');
    }
    _validateStorageKey(storageKey);
    if (byteLength <= 0) {
      throw ArgumentError.value(
        byteLength,
        'byteLength',
        'must be greater than zero',
      );
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(createdAtUtc, 'createdAtUtc', 'must be in UTC');
    }
  }

  final String id;
  final DiaryDayKey dayKey;

  /// Adapter-owned key relative to the app media root, never a filesystem path.
  final String storageKey;
  final MediaMimeType mimeType;
  final int byteLength;
  final DateTime createdAtUtc;
  final MediaLifecycle lifecycle;

  MediaAsset withLifecycle(MediaLifecycle lifecycle) {
    return MediaAsset(
      id: id,
      dayKey: dayKey,
      storageKey: storageKey,
      mimeType: mimeType,
      byteLength: byteLength,
      createdAtUtc: createdAtUtc,
      lifecycle: lifecycle,
    );
  }

  static void _validateStorageKey(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'storageKey', 'must not be blank');
    }
    if (value.startsWith('/') ||
        value.startsWith(r'\') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(value) ||
        RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(value) ||
        value.contains('\u0000')) {
      throw ArgumentError.value(
        value,
        'storageKey',
        'must be a relative opaque key',
      );
    }

    final segments = value.split(RegExp(r'[/\\]'));
    if (segments.any((segment) => segment == '.' || segment == '..')) {
      throw ArgumentError.value(
        value,
        'storageKey',
        'must not contain traversal segments',
      );
    }
  }
}
