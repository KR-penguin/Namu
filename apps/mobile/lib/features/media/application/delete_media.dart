import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_file_store.dart';
import 'package:namu/features/media/domain/media_repository.dart';

final class DeleteMedia {
  const DeleteMedia({required this.repository, required this.fileStore});

  final MediaRepository repository;
  final MediaFileStore fileStore;

  Future<void> call(String assetId) async {
    final asset = await repository.findById(assetId);
    if (asset == null) {
      return;
    }

    final deletingAsset = asset.lifecycle == MediaLifecycle.deleting
        ? asset
        : asset.withLifecycle(MediaLifecycle.deleting);
    if (asset.lifecycle != MediaLifecycle.deleting) {
      await repository.update(deletingAsset);
    }

    await fileStore.deleteIfExists(
      assetId: deletingAsset.id,
      storageKey: deletingAsset.storageKey,
    );
    await repository.removeById(deletingAsset.id);
  }
}
