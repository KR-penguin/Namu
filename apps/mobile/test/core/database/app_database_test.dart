import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('schema v3 keeps message and diary tables with query indexes', () async {
    final objects = await database
        .customSelect(
          "SELECT name, type FROM sqlite_master "
          "WHERE name IN ('messages', 'messages_day_created_at_id_idx', "
          "'diary_entries', 'diary_entries_day_version_idx', "
          "'diary_entries_updated_at_id_idx') "
          'ORDER BY name',
        )
        .get();

    expect(database.schemaVersion, 3);
    expect(objects.map((row) => row.read<String>('name')), [
      'diary_entries',
      'diary_entries_day_version_idx',
      'diary_entries_updated_at_id_idx',
      'messages',
      'messages_day_created_at_id_idx',
    ]);
  });

  test('schema rejects an unsupported role', () async {
    expect(
      () => _insertRaw(database, role: 'system'),
      throwsA(isA<Exception>()),
    );
  });

  test('schema rejects a message without text or a photo', () async {
    expect(
      () => _insertRaw(database, text: null, photoAssetId: null),
      throwsA(isA<Exception>()),
    );
  });

  test('schema rejects an invalid calendar date', () async {
    expect(
      () => _insertRaw(database, dayMonth: 2, dayDay: 30),
      throwsA(isA<Exception>()),
    );
  });

  test('schema enforces one message for each request and role', () async {
    await _insertRaw(database, id: 'first');

    expect(() => _insertRaw(database, id: 'second'), throwsA(isA<Exception>()));
  });
}

Future<void> _insertRaw(
  AppDatabase database, {
  String id = 'message-1',
  String role = 'user',
  String? text = 'hello',
  String? photoAssetId,
  int dayMonth = 10,
  int dayDay = 4,
}) {
  return database.customStatement(
    'INSERT INTO messages ('
    'id, request_id, day_year, day_month, day_day, day_time_zone_id, '
    'day_cutoff_micros, day_policy_version, role, message_text, photo_asset_id, '
    'created_at_utc, status'
    ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      'request-1',
      2026,
      dayMonth,
      dayDay,
      'Asia/Seoul',
      0,
      1,
      role,
      text,
      photoAssetId,
      DateTime.utc(2026, 10, 4).microsecondsSinceEpoch,
      'pending',
    ],
  );
}
