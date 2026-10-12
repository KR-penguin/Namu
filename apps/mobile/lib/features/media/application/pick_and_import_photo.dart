import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/features/media/application/import_photo.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/features/media/domain/media_asset.dart';

typedef MediaUtcClock = DateTime Function();
typedef MediaIdGenerator = String Function();

final class PickAndImportPhoto {
  const PickAndImportPhoto({
    required this.selector,
    required this.importPhoto,
    required this.utcNow,
    required this.nextId,
  });

  final PhotoSelector selector;
  final ImportPhoto importPhoto;
  final MediaUtcClock utcNow;
  final MediaIdGenerator nextId;

  Future<MediaAsset?> call(DiaryDayKey dayKey) async {
    final selection = await selector.selectFromGallery();
    if (selection == null) {
      return null;
    }

    final createdAtUtc = utcNow();
    if (!createdAtUtc.isUtc) {
      throw StateError('utcNow must return a UTC instant.');
    }

    final assetId = nextId();
    if (assetId.trim().isEmpty || assetId != assetId.trim()) {
      throw StateError('nextId must return a nonblank canonical ID.');
    }

    return importPhoto(
      ImportPhotoCommand(
        assetId: assetId,
        dayKey: dayKey,
        selection: selection,
        createdAtUtc: createdAtUtc,
      ),
    );
  }
}
