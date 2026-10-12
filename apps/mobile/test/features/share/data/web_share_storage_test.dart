import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/data/app_owned_media_reader_web.dart'
    as media_web;
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_bytes_reader.dart';
import 'package:namu/features/share/data/native_diary_share_output_store_web.dart'
    as share_web;
import 'package:namu/features/share/domain/diary_share_output_store.dart';

void main() {
  test('web media reader is explicitly unavailable', () async {
    const reader = media_web.AppOwnedMediaReader(_UnavailablePaths());

    await expectLater(
      reader.read(_asset()),
      throwsA(
        isA<MediaBytesReadException>().having(
          (error) => error.reason,
          'reason',
          MediaBytesReadFailure.unsupportedPlatform,
        ),
      ),
    );
  });

  test('web share output store is explicitly unavailable', () async {
    const store = share_web.NativeDiaryShareOutputStore(_UnavailablePaths());

    await expectLater(
      store.writePng(
        entryId: 'entry-1',
        version: 1,
        updatedAtUtc: DateTime.utc(2026, 10, 4),
        pageNumber: 1,
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      ),
      throwsA(
        isA<DiaryShareOutputException>().having(
          (error) => error.reason,
          'reason',
          DiaryShareOutputFailure.unsupportedPlatform,
        ),
      ),
    );
  });
}

MediaAsset _asset() {
  return MediaAsset(
    id: 'asset-1',
    dayKey: DiaryDayKey.fromInstant(
      instant: DateTime.utc(2026, 10, 4),
      timeZone: TimeZoneSnapshot(
        timeZoneId: 'Asia/Seoul',
        utcOffset: const Duration(hours: 9),
      ),
    ),
    storageKey: 'media/asset.png',
    mimeType: MediaMimeType.png,
    byteLength: 3,
    createdAtUtc: DateTime.utc(2026, 10, 4),
    lifecycle: MediaLifecycle.ready,
  );
}

final class _UnavailablePaths implements AppStoragePaths {
  const _UnavailablePaths();

  @override
  Future<String> appStorageRoot() => throw UnimplementedError();
}
