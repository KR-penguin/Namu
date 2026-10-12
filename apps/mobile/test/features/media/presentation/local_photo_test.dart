import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/media/presentation/local_photo.dart';

void main() {
  testWidgets('renders decoded local bytes as an image', (tester) async {
    final requestedIds = <String>[];
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _subject(
        LocalPhoto(
          assetId: 'photo-1',
          loadBytes: (assetId) async {
            requestedIds.add(assetId);
            return _onePixelPng;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedIds, <String>['photo-1']);
    expect(find.byKey(const Key('localPhoto.image')), findsOneWidget);
    expect(find.byKey(const Key('localPhoto.fallback')), findsNothing);
    expect(find.bySemanticsLabel('첨부 사진'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('photo-1')), findsNothing);
    semantics.dispose();
  });

  testWidgets('uses a non-sensitive fallback when bytes are unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _subject(
        LocalPhoto(
          assetId: 'private-storage-id',
          loadBytes: (_) => Future<Uint8List>.error(StateError('missing')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('localPhoto.image')), findsNothing);
    expect(find.byKey(const Key('localPhoto.fallback')), findsOneWidget);
    expect(find.textContaining('private-storage-id'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not attempt a read when no loader is configured', (
    tester,
  ) async {
    await tester.pumpWidget(_subject(const LocalPhoto(assetId: 'photo-1')));
    await tester.pump();

    expect(find.byKey(const Key('localPhoto.fallback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _subject(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 240, height: 180, child: child)),
  );
}

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
  'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
);
