import 'dart:typed_data';

enum DiaryShareOutputFailure {
  unsupportedPlatform,
  invalidRoot,
  invalidRequest,
  writeFailed,
}

final class DiaryShareOutputException implements Exception {
  const DiaryShareOutputException(this.reason);

  final DiaryShareOutputFailure reason;

  @override
  String toString() => 'Diary share output failed (${reason.name})';
}

/// Atomically commits an encoded PNG into app-owned export staging.
abstract interface class DiaryShareOutputStore {
  Future<String> writePng({
    required String entryId,
    required int version,
    required DateTime updatedAtUtc,
    required int pageNumber,
    required Uint8List bytes,
  });
}
