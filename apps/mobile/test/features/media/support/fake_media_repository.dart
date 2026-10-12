import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

final class FakeMediaRepository implements MediaRepository {
  FakeMediaRepository({this.trace});

  final Map<String, MediaAsset> assets = <String, MediaAsset>{};
  final List<String> events = <String>[];
  final List<String>? trace;

  bool failReadyUpdate = false;
  int removeFailuresRemaining = 0;

  @override
  Future<MediaAsset?> findById(String assetId) async => assets[assetId];

  @override
  Future<void> insert(MediaAsset asset) async {
    _record('insert:${asset.lifecycle.name}');
    if (assets.containsKey(asset.id)) {
      throw StateError('duplicate asset id');
    }
    assets[asset.id] = asset;
  }

  @override
  Future<void> removeById(String assetId) async {
    _record('remove:$assetId');
    if (removeFailuresRemaining > 0) {
      removeFailuresRemaining -= 1;
      throw StateError('remove failed');
    }
    assets.remove(assetId);
  }

  @override
  Future<void> update(MediaAsset asset) async {
    _record('update:${asset.lifecycle.name}');
    if (failReadyUpdate && asset.lifecycle == MediaLifecycle.ready) {
      throw StateError('ready update failed');
    }
    if (!assets.containsKey(asset.id)) {
      throw StateError('missing asset');
    }
    assets[asset.id] = asset;
  }

  void _record(String event) {
    events.add(event);
    trace?.add('repository:$event');
  }
}
