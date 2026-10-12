enum LocalDataResetKind { persistentNative, transientPreview }

enum LocalDataEraseFailure { unavailable, unsafeRoot, deleteFailed }

final class LocalDataEraseException implements Exception {
  const LocalDataEraseException(this.reason);

  final LocalDataEraseFailure reason;

  @override
  String toString() => 'Local data erase failed (${reason.name})';
}

/// Erases the storage owned by one application dependency graph.
///
/// The caller must close that graph before invoking [erase]. Otherwise an open
/// SQLite handle or a late network response could recreate deleted content.
abstract interface class LocalDataEraser {
  LocalDataResetKind get resetKind;

  Future<void> erase();
}

/// Clears web review data by discarding and recreating its in-memory graph.
///
/// There is no persistent browser store to erase. This no-op is deliberately
/// identified as transient so the UI never presents it as native erasure.
final class TransientLocalDataEraser implements LocalDataEraser {
  const TransientLocalDataEraser();

  @override
  LocalDataResetKind get resetKind => LocalDataResetKind.transientPreview;

  @override
  Future<void> erase() async {}
}
