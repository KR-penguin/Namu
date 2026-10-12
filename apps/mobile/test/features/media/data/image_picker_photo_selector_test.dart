import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/features/media/data/image_picker_photo_selector.dart';

void main() {
  test('opens only the image gallery with full metadata disabled', () async {
    final picker = _FakeImagePicker(
      result: XFile.fromData(
        Uint8List.fromList(<int>[1, 2, 3]),
        path: '/picker/photo.jpg',
        mimeType: 'image/jpeg',
      ),
    );
    final selector = ImagePickerPhotoSelector.testing(picker);

    final selection = await selector.selectFromGallery();

    expect(picker.source, ImageSource.gallery);
    expect(picker.requestFullMetadata, isFalse);
    expect(selection?.token, '/picker/photo.jpg');
    expect(selection?.mimeType, 'image/jpeg');
    expect(selection?.byteLength, 3);
  });

  test('returns null when the user cancels', () async {
    final selector = ImagePickerPhotoSelector.testing(
      _FakeImagePicker(result: null),
    );

    expect(await selector.selectFromGallery(), isNull);
  });

  test('keeps unknown MIME explicit for ImportPhoto to reject', () async {
    final selector = ImagePickerPhotoSelector.testing(
      _FakeImagePicker(
        result: XFile.fromData(
          Uint8List.fromList(<int>[1]),
          path: '/picker/photo.unknown',
        ),
      ),
    );

    final selection = await selector.selectFromGallery();

    expect(selection?.mimeType, ImagePickerPhotoSelector.unknownMimeType);
  });

  test(
    'infers allowlisted MIME from picker paths when metadata is absent',
    () async {
      for (final testCase in <(String, String)>[
        ('/picker/photo.JPEG', 'image/jpeg'),
        ('/picker/photo.png', 'image/png'),
        ('/picker/photo.HEIC', 'image/heic'),
      ]) {
        final selector = ImagePickerPhotoSelector.testing(
          _FakeImagePicker(
            result: XFile.fromData(
              Uint8List.fromList(<int>[1]),
              path: testCase.$1,
            ),
          ),
        );

        expect((await selector.selectFromGallery())?.mimeType, testCase.$2);
      }
    },
  );

  test('maps picker failures to a redacted typed failure', () async {
    final selector = ImagePickerPhotoSelector.testing(
      _FakeImagePicker(
        error: PlatformException(
          code: 'denied',
          message: '/private/picker/path',
        ),
      ),
    );

    await expectLater(
      selector.selectFromGallery(),
      throwsA(
        isA<PhotoSelectionUnavailableException>()
            .having(
              (error) => error.reason,
              'reason',
              PhotoSelectionUnavailableReason.platformFailure,
            )
            .having(
              (error) => error.toString(),
              'redacted message',
              isNot(contains('/private/picker/path')),
            ),
      ),
    );
  });

  test('web is an explicit typed unavailable result', () async {
    final selector = ImagePickerPhotoSelector.testing(
      _FakeImagePicker(result: null),
      false,
    );

    await expectLater(
      selector.selectFromGallery(),
      throwsA(
        isA<PhotoSelectionUnavailableException>().having(
          (error) => error.reason,
          'reason',
          PhotoSelectionUnavailableReason.unsupportedPlatform,
        ),
      ),
    );
  });
}

final class _FakeImagePicker extends ImagePicker {
  _FakeImagePicker({this.result, this.error});

  final XFile? result;
  final Object? error;
  ImageSource? source;
  bool? requestFullMetadata;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    this.source = source;
    this.requestFullMetadata = requestFullMetadata;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return result;
  }
}
