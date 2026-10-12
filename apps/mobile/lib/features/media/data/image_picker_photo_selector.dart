import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:path/path.dart' as p;

final class ImagePickerPhotoSelector implements PhotoSelector {
  ImagePickerPhotoSelector()
    : _imagePicker = ImagePicker(),
      _platformSupported = !kIsWeb;

  @visibleForTesting
  ImagePickerPhotoSelector.testing(
    this._imagePicker, [
    this._platformSupported = true,
  ]);

  static const String unknownMimeType = 'application/octet-stream';

  final ImagePicker _imagePicker;
  final bool _platformSupported;

  @override
  Future<PhotoImportSelection?> selectFromGallery() async {
    if (!_platformSupported) {
      throw const PhotoSelectionUnavailableException(
        PhotoSelectionUnavailableReason.unsupportedPlatform,
      );
    }

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (file == null) {
        return null;
      }
      return PhotoImportSelection(
        token: file.path,
        mimeType: _mimeTypeFor(file),
        byteLength: await file.length(),
      );
    } catch (_) {
      throw const PhotoSelectionUnavailableException(
        PhotoSelectionUnavailableReason.platformFailure,
      );
    }
  }

  String _mimeTypeFor(XFile file) {
    final declaredMimeType = file.mimeType?.trim();
    if (declaredMimeType != null && declaredMimeType.isNotEmpty) {
      return declaredMimeType;
    }

    return switch (p.extension(file.path).toLowerCase()) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.heic' => 'image/heic',
      _ => unknownMimeType,
    };
  }
}
