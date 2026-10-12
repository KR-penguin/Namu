import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

final class InMemoryMediaRepository implements MediaRepository {
  final Map<String, MediaAsset> _assets = <String, MediaAsset>{};

  @override
  Future<MediaAsset?> findById(String assetId) async => _assets[assetId];

  @override
  Future<void> insert(MediaAsset asset) async {
    if (_assets.containsKey(asset.id)) {
      throw const MediaRepositoryConflictException();
    }
    if (asset.lifecycle != MediaLifecycle.staging) {
      throw const InvalidMediaLifecycleTransitionException();
    }
    _assets[asset.id] = asset;
  }

  @override
  Future<void> removeById(String assetId) async {
    _assets.remove(assetId);
  }

  @override
  Future<void> update(MediaAsset asset) async {
    final existing = _assets[asset.id];
    if (existing == null) {
      throw const MediaRepositoryNotFoundException();
    }
    if (!hasSameMediaAssetIdentity(existing, asset)) {
      throw const MediaAssetIdentityMismatchException();
    }
    if (!isAllowedMediaLifecycleTransition(
      existing.lifecycle,
      asset.lifecycle,
    )) {
      throw const InvalidMediaLifecycleTransitionException();
    }
    _assets[asset.id] = asset;
  }
}
