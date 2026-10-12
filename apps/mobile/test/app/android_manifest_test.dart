import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'release manifest allows Gateway traffic without broad media access',
    () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();

      expect(
        manifest,
        contains(
          '<uses-permission android:name="android.permission.INTERNET"/>',
        ),
      );
      expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
      expect(manifest, isNot(contains('READ_MEDIA_IMAGES')));
      expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
    },
  );
}
