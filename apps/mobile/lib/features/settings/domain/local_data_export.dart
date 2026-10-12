import 'dart:typed_data';

enum LocalDataExportFailure {
  unavailable,
  invalidSnapshot,
  collectFailed,
  unsafeStorage,
  writeFailed,
}

final class LocalDataExportException implements Exception {
  const LocalDataExportException(this.reason);

  final LocalDataExportFailure reason;

  @override
  String toString() => 'Local data export failed (${reason.name})';
}

/// The result only describes the operating-system share activity.
///
/// It never means that a destination saved, uploaded, or published the file.
enum LocalDataExportOutcome { opened, completed, dismissed, unavailable }

final class LocalDataExportArtifact {
  LocalDataExportArtifact({
    required this.path,
    required this.mimeType,
    required this.byteLength,
  }) {
    if (path.trim().isEmpty || mimeType != 'application/json') {
      throw ArgumentError('A JSON export artifact requires a valid path.');
    }
    if (byteLength <= 0) {
      throw ArgumentError.value(byteLength, 'byteLength', 'must be positive');
    }
  }

  final String path;
  final String mimeType;
  final int byteLength;
}

abstract interface class LocalDataExportStore {
  /// Atomically commits one app-owned JSON staging file.
  Future<LocalDataExportArtifact> write({
    required Uint8List bytes,
    required DateTime exportedAtUtc,
  });
}

abstract interface class LocalDataExportLauncher {
  /// Opens the platform share/save surface after the user explicitly exports.
  Future<LocalDataExportOutcome> launch(
    LocalDataExportArtifact artifact, {
    required String shareText,
  });
}
