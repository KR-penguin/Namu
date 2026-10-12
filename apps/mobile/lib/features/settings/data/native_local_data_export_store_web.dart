import 'dart:typed_data';

import '../../../core/storage/app_storage_paths.dart';
import '../domain/local_data_export.dart';

/// Browser review has no persistent product storage and cannot claim export.
final class NativeLocalDataExportStore implements LocalDataExportStore {
  const NativeLocalDataExportStore(AppStoragePaths storagePaths);

  @override
  Future<LocalDataExportArtifact> write({
    required Uint8List bytes,
    required DateTime exportedAtUtc,
  }) {
    throw const LocalDataExportException(LocalDataExportFailure.unavailable);
  }
}
