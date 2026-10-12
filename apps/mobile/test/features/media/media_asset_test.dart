import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/domain/media_asset.dart';

void main() {
  test('keeps the exact diary day identity and accepted metadata', () {
    final dayKey = _dayKey();
    final asset = MediaAsset(
      id: 'asset-1',
      dayKey: dayKey,
      storageKey: 'media/asset-1.heic',
      mimeType: MediaMimeType.heic,
      byteLength: 42,
      createdAtUtc: DateTime.utc(2026, 10, 4, 9),
      lifecycle: MediaLifecycle.staging,
    );

    expect(asset.dayKey, same(dayKey));
    expect(asset.storageKey, 'media/asset-1.heic');
    expect(asset.mimeType.contentType, 'image/heic');
  });

  test('rejects absolute and traversing storage keys', () {
    for (final storageKey in <String>[
      '/private/photo.jpg',
      r'\private\photo.jpg',
      r'C:\photos\photo.jpg',
      'file:///private/photo.jpg',
      '../photo.jpg',
      'media/../photo.jpg',
    ]) {
      expect(
        () => _asset(storageKey: storageKey),
        throwsArgumentError,
        reason: storageKey,
      );
    }
  });

  test('requires a positive byte length and a UTC creation time', () {
    expect(() => _asset(byteLength: 0), throwsArgumentError);
    expect(
      () => _asset(createdAtUtc: DateTime(2026, 10, 4, 9)),
      throwsArgumentError,
    );
  });
}

MediaAsset _asset({
  String storageKey = 'media/asset-1.jpg',
  int byteLength = 1,
  DateTime? createdAtUtc,
}) {
  return MediaAsset(
    id: 'asset-1',
    dayKey: _dayKey(),
    storageKey: storageKey,
    mimeType: MediaMimeType.jpeg,
    byteLength: byteLength,
    createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 10, 4, 9),
    lifecycle: MediaLifecycle.ready,
  );
}

DiaryDayKey _dayKey() {
  return DiaryDayKey.fromInstant(
    instant: DateTime.utc(2026, 10, 4, 9),
    timeZone: TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: const Duration(hours: 9),
    ),
  );
}
