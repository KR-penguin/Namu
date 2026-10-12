import '../../../core/storage/app_storage_paths.dart';
import '../domain/local_data_eraser.dart';

/// Web review uses transient repositories and has no native root to erase.
final class PlatformLocalDataEraser implements LocalDataEraser {
  const PlatformLocalDataEraser(AppStoragePaths storagePaths);

  @override
  LocalDataResetKind get resetKind => LocalDataResetKind.transientPreview;

  @override
  Future<void> erase() async {}
}
