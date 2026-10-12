import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_file_store.dart';

final class FakeMediaFileStore implements MediaFileStore {
  FakeMediaFileStore({this.trace});

  final Set<String> storedKeys = <String>{};
  final List<String> events = <String>[];
  final List<String>? trace;

  Object? persistError;
  Object? deleteError;
  String storageKey = 'media/asset-1.jpg';

  @override
  String storageKeyFor({
    required String assetId,
    required MediaMimeType mimeType,
  }) {
    _record('key:$assetId:${mimeType.name}');
    return storageKey;
  }

  @override
  Future<void> persist({
    required String assetId,
    required String storageKey,
    required String sourceToken,
  }) async {
    _record('persist:$assetId:$storageKey:$sourceToken');
    final error = persistError;
    if (error != null) {
      throw error;
    }
    storedKeys.add(storageKey);
  }

  @override
  Future<void> deleteIfExists({
    required String assetId,
    required String storageKey,
  }) async {
    _record('delete:$assetId:$storageKey');
    final error = deleteError;
    if (error != null) {
      throw error;
    }
    storedKeys.remove(storageKey);
  }

  void _record(String event) {
    events.add(event);
    trace?.add('fileStore:$event');
  }
}
