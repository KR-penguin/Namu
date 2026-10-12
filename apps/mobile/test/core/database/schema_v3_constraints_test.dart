import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'schema v3 creates media, persona, and memory tables and indexes',
    () async {
      final objects = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE name IN ("
            "'media_assets', 'media_assets_day_created_at_id_idx', "
            "'ai_persona', 'memory_facts', "
            "'memory_facts_updated_at_id_idx') ORDER BY name",
          )
          .get();

      expect(database.schemaVersion, 3);
      expect(objects.map((row) => row.read<String>('name')), [
        'ai_persona',
        'media_assets',
        'media_assets_day_created_at_id_idx',
        'memory_facts',
        'memory_facts_updated_at_id_idx',
      ]);
    },
  );

  test(
    'media constraints reject unsafe keys and unsupported metadata',
    () async {
      for (final invalid in <Map<String, Object?>>[
        {'storageKey': '../outside.jpg'},
        {'storageKey': r'media\..\outside.jpg'},
        {'mimeType': 'image/gif'},
        {'byteLength': 0},
        {'lifecycle': 'uploaded'},
        {'dayMonth': 2, 'dayDay': 30},
      ]) {
        expect(
          () => _insertMedia(
            database,
            id: 'asset-${invalid.hashCode}',
            storageKey: invalid['storageKey'] as String? ?? 'media/photo.jpg',
            mimeType: invalid['mimeType'] as String? ?? 'image/jpeg',
            byteLength: invalid['byteLength'] as int? ?? 10,
            lifecycle: invalid['lifecycle'] as String? ?? 'staging',
            dayMonth: invalid['dayMonth'] as int? ?? 10,
            dayDay: invalid['dayDay'] as int? ?? 4,
          ),
          throwsA(isA<Exception>()),
        );
      }
    },
  );

  test(
    'persona constraints enforce singleton, lengths, and enum values',
    () async {
      await _insertPersona(database);

      expect(
        () => _insertPersona(database, singletonKey: 2),
        throwsA(isA<Exception>()),
      );
      expect(
        () => _insertPersona(
          database,
          singletonKey: 1,
          reactionLength: 'unbounded',
        ),
        throwsA(isA<Exception>()),
      );

      await database.customStatement('DELETE FROM ai_persona');
      expect(
        () => _insertPersona(database, name: '가' * 41),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'memory constraints enforce enums, schema, and timestamp order',
    () async {
      for (final invalid in <Map<String, Object?>>[
        {'category': 'medical'},
        {'sensitivity': 'secret'},
        {'status': 'deleted'},
        {'sourceSchemaVersion': 2},
        {'createdAtUtc': 2, 'updatedAtUtc': 1},
      ]) {
        expect(
          () => _insertMemory(
            database,
            id: 'memory-${invalid.hashCode}',
            category: invalid['category'] as String? ?? 'preference',
            sensitivity: invalid['sensitivity'] as String? ?? 'standard',
            status: invalid['status'] as String? ?? 'candidate',
            sourceSchemaVersion: invalid['sourceSchemaVersion'] as int? ?? 1,
            createdAtUtc: invalid['createdAtUtc'] as int? ?? 1,
            updatedAtUtc: invalid['updatedAtUtc'] as int? ?? 1,
          ),
          throwsA(isA<Exception>()),
        );
      }
    },
  );
}

Future<void> _insertMedia(
  AppDatabase database, {
  required String id,
  required String storageKey,
  required String mimeType,
  required int byteLength,
  required String lifecycle,
  required int dayMonth,
  required int dayDay,
}) {
  return database.customStatement(
    'INSERT INTO media_assets ('
    'id, day_year, day_month, day_day, day_time_zone_id, day_cutoff_micros, '
    'day_policy_version, storage_key, mime_type, byte_length, created_at_utc, '
    'lifecycle) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      2026,
      dayMonth,
      dayDay,
      'Asia/Seoul',
      0,
      1,
      storageKey,
      mimeType,
      byteLength,
      1,
      lifecycle,
    ],
  );
}

Future<void> _insertPersona(
  AppDatabase database, {
  int singletonKey = 1,
  String name = '모아',
  String reactionLength = 'balanced',
}) {
  return database.customStatement(
    'INSERT INTO ai_persona ('
    'singleton_key, persona_id, persona_name, avatar_seed, tone, '
    'custom_instructions, reaction_length) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      singletonKey,
      'persona-$singletonKey',
      name,
      'leaf',
      '다정하게',
      '',
      reactionLength,
    ],
  );
}

Future<void> _insertMemory(
  AppDatabase database, {
  required String id,
  required String category,
  required String sensitivity,
  required String status,
  required int sourceSchemaVersion,
  required int createdAtUtc,
  required int updatedAtUtc,
}) {
  return database.customStatement(
    'INSERT INTO memory_facts ('
    'id, fact, source_ids_schema_version, source_ids_json, category, '
    'sensitivity, status, created_at_utc, updated_at_utc'
    ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      '사용자는 산책을 좋아한다.',
      sourceSchemaVersion,
      jsonEncode({
        'schemaVersion': 1,
        'sourceMessageIds': ['message-1'],
      }),
      category,
      sensitivity,
      status,
      createdAtUtc,
      updatedAtUtc,
    ],
  );
}
