import 'package:drift/drift.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:namu/core/time/diary_day_key.dart';
import 'package:namu/core/time/local_date.dart';
import 'package:namu/features/media/domain/media_asset.dart';
import 'package:namu/features/media/domain/media_repository.dart';

final class DriftMediaRepository implements MediaRepository {
  const DriftMediaRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> insert(MediaAsset asset) async {
    if (asset.lifecycle != MediaLifecycle.staging) {
      throw const InvalidMediaLifecycleTransitionException();
    }
    await _database.transaction(() async {
      final duplicateQuery = _database.select(_database.mediaAssetRecords)
        ..where(
          (row) =>
              row.id.equals(asset.id) | row.storageKey.equals(asset.storageKey),
        )
        ..limit(1);
      if (await duplicateQuery.getSingleOrNull() != null) {
        throw const MediaRepositoryConflictException();
      }
      await _database
          .into(_database.mediaAssetRecords)
          .insert(_toCompanion(asset));
    });
  }

  @override
  Future<void> update(MediaAsset asset) {
    return _database.transaction(() async {
      final existing = await findById(asset.id);
      if (existing == null) {
        throw const MediaRepositoryNotFoundException();
      }
      if (!hasSameMediaAssetIdentity(existing, asset)) {
        throw const MediaAssetIdentityMismatchException();
      }
      if (!isAllowedMediaLifecycleTransition(
        existing.lifecycle,
        asset.lifecycle,
      )) {
        throw const InvalidMediaLifecycleTransitionException();
      }
      await (_database.update(
        _database.mediaAssetRecords,
      )..where((row) => row.id.equals(asset.id))).write(_toCompanion(asset));
    });
  }

  @override
  Future<MediaAsset?> findById(String assetId) async {
    final query = _database.select(_database.mediaAssetRecords)
      ..where((row) => row.id.equals(assetId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> removeById(String assetId) async {
    await (_database.delete(
      _database.mediaAssetRecords,
    )..where((row) => row.id.equals(assetId))).go();
  }

  MediaAssetRecordsCompanion _toCompanion(MediaAsset asset) {
    return MediaAssetRecordsCompanion.insert(
      id: asset.id,
      dayYear: asset.dayKey.labelDate.year,
      dayMonth: asset.dayKey.labelDate.month,
      dayDay: asset.dayKey.labelDate.day,
      dayTimeZoneId: asset.dayKey.timeZoneId,
      dayCutoffMicros: asset.dayKey.cutoff.inMicroseconds,
      dayPolicyVersion: asset.dayKey.policyVersion,
      storageKey: asset.storageKey,
      mimeType: asset.mimeType.contentType,
      byteLength: asset.byteLength,
      createdAtUtc: asset.createdAtUtc.microsecondsSinceEpoch,
      lifecycle: asset.lifecycle.name,
    );
  }

  MediaAsset _toDomain(MediaAssetRow row) {
    return MediaAsset(
      id: row.id,
      dayKey: DiaryDayKey.restore(
        labelDate: LocalDate(row.dayYear, row.dayMonth, row.dayDay),
        timeZoneId: row.dayTimeZoneId,
        cutoff: Duration(microseconds: row.dayCutoffMicros),
        policyVersion: row.dayPolicyVersion,
      ),
      storageKey: row.storageKey,
      mimeType: _parseMimeType(row.mimeType),
      byteLength: row.byteLength,
      createdAtUtc: DateTime.fromMicrosecondsSinceEpoch(
        row.createdAtUtc,
        isUtc: true,
      ),
      lifecycle: _parseLifecycle(row.lifecycle),
    );
  }

  MediaMimeType _parseMimeType(String value) {
    final parsed = MediaMimeType.tryParse(value);
    if (parsed == null || parsed.contentType != value) {
      throw FormatException('Unsupported persisted media MIME type: $value');
    }
    return parsed;
  }

  MediaLifecycle _parseLifecycle(String value) {
    return switch (value) {
      'staging' => MediaLifecycle.staging,
      'ready' => MediaLifecycle.ready,
      'deleting' => MediaLifecycle.deleting,
      'missing' => MediaLifecycle.missing,
      _ => throw FormatException(
        'Unsupported persisted media lifecycle: $value',
      ),
    };
  }
}
