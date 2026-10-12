import 'photo_import_selection.dart';

enum PhotoSelectionUnavailableReason { unsupportedPlatform, platformFailure }

final class PhotoSelectionUnavailableException implements Exception {
  const PhotoSelectionUnavailableException(this.reason);

  final PhotoSelectionUnavailableReason reason;

  @override
  String toString() => 'Photo selection is unavailable (${reason.name})';
}

abstract interface class PhotoSelector {
  /// Opens the image gallery. User cancellation is represented by `null`.
  Future<PhotoImportSelection?> selectFromGallery();
}
