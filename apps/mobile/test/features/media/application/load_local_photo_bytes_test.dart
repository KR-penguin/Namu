import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/application/load_local_photo_bytes.dart';
import 'package:namu/features/media/data/in_memory_media_repository.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';

void main() {
  late InMemoryMediaRepository repository;
  late _RecordingMediaBytesReader reader;
  late LoadLocalPhotoBytes loadPhoto;

  setUp(() {
    repository = InMemoryMediaRepository();
    reader = _RecordingMediaBytesReader(Uint8List.fromList(<int>[1, 2, 3]));
    loadPhoto = LoadLocalPhotoBytes(repository: repository, reader: reader);
  });

  test(
    'resolves a ready asset id through metadata before reading bytes',
    () async {
      final asset = _asset();
      await repository.insert(asset);
      await repository.update(asset.withLifecycle(MediaLifecycle.ready));

      final bytes = await loadPhoto('photo-1');

      expect(bytes, <int>[1, 2, 3]);
      expect(reader.assets, hasLength(1));
      expect(reader.assets.single.id, 'photo-1');
    },
  );

  test('reports missing metadata without asking storage for bytes', () async {
    await expectLater(
      loadPhoto('deleted-photo'),
      throwsA(
        isA<MediaBytesReadException>().having(
          (error) => error.reason,
          'reason',
          MediaBytesReadFailure.missing,
        ),
      ),
    );

    expect(reader.assets, isEmpty);
  });

  test('rejects a non-ready asset before asking storage for bytes', () async {
    await repository.insert(_asset());

    await expectLater(
      loadPhoto('photo-1'),
      throwsA(
        isA<MediaBytesReadException>().having(
          (error) => error.reason,
          'reason',
          MediaBytesReadFailure.notReady,
        ),
      ),
    );

    expect(reader.assets, isEmpty);
  });

  test('rejects a blank opaque id before repository access', () async {
    await expectLater(loadPhoto('   '), throwsArgumentError);
    expect(reader.assets, isEmpty);
  });
}

MediaAsset _asset() {
  return MediaAsset(
    id: 'photo-1',
    dayKey: DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4, 8),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    ),
    storageKey: 'media/photo-1.jpg',
    mimeType: MediaMimeType.jpeg,
    byteLength: 3,
    createdAtUtc: DateTime.utc(2026, 10, 4, 8),
    lifecycle: MediaLifecycle.staging,
  );
}

final class _RecordingMediaBytesReader implements MediaBytesReader {
  _RecordingMediaBytesReader(this.bytes);

  final Uint8List bytes;
  final List<MediaAsset> assets = <MediaAsset>[];

  @override
  Future<Uint8List> read(MediaAsset asset) async {
    assets.add(asset);
    return bytes;
  }
}
