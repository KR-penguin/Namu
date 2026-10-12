// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:namu/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 does not corrupt data', () async {
    const oldMessagesData = <v1.MessagesData>[
      v1.MessagesData(
        id: 'message-1',
        requestId: 'request-1',
        dayYear: 2026,
        dayMonth: 10,
        dayDay: 4,
        dayTimeZoneId: 'Asia/Seoul',
        dayCutoffMicros: 0,
        dayPolicyVersion: 1,
        role: 'user',
        messageText: '마이그레이션 전 메시지',
        createdAtUtc: 1791072000000000,
        status: 'sent',
      ),
    ];
    const expectedNewMessagesData = <v2.MessagesData>[
      v2.MessagesData(
        id: 'message-1',
        requestId: 'request-1',
        dayYear: 2026,
        dayMonth: 10,
        dayDay: 4,
        dayTimeZoneId: 'Asia/Seoul',
        dayCutoffMicros: 0,
        dayPolicyVersion: 1,
        role: 'user',
        messageText: '마이그레이션 전 메시지',
        createdAtUtc: 1791072000000000,
        status: 'sent',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.messages, oldMessagesData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewMessagesData,
          await newDb.select(newDb.messages).get(),
        );
        expect(await newDb.select(newDb.diaryEntries).get(), isEmpty);
      },
    );
  });

  test('a closed v1 file reopens as v3 with its messages intact', () async {
    final directory = await Directory.systemTemp.createTemp(
      'namu-v1-migration-',
    );
    final file = File('${directory.path}/namu.sqlite');
    try {
      final oldDatabase = v1.DatabaseAtV1(NativeDatabase(file));
      await oldDatabase
          .into(oldDatabase.messages)
          .insert(
            const v1.MessagesData(
              id: 'persisted-v1-message',
              requestId: 'persisted-v1-request',
              dayYear: 2026,
              dayMonth: 10,
              dayDay: 4,
              dayTimeZoneId: 'Asia/Seoul',
              dayCutoffMicros: 0,
              dayPolicyVersion: 1,
              role: 'user',
              messageText: '닫았다 다시 여는 데이터',
              createdAtUtc: 1791072000000000,
              status: 'sent',
            ),
          );
      await oldDatabase.close();

      final migrated = AppDatabase(NativeDatabase(file));
      final messages = await migrated.select(migrated.messageRecords).get();
      final diaries = await migrated.select(migrated.diaryEntries).get();

      expect(migrated.schemaVersion, 3);
      expect(messages.single.id, 'persisted-v1-message');
      expect(messages.single.messageText, '닫았다 다시 여는 데이터');
      expect(diaries, isEmpty);
      await migrated.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('a closed v2 file reopens as v3 without losing existing data', () async {
    final directory = await Directory.systemTemp.createTemp(
      'namu-v2-migration-',
    );
    final file = File('${directory.path}/namu.sqlite');
    try {
      final oldDatabase = v2.DatabaseAtV2(NativeDatabase(file));
      await oldDatabase
          .into(oldDatabase.messages)
          .insert(
            const v2.MessagesData(
              id: 'persisted-v2-message',
              requestId: 'persisted-v2-request',
              dayYear: 2026,
              dayMonth: 10,
              dayDay: 4,
              dayTimeZoneId: 'Asia/Seoul',
              dayCutoffMicros: 0,
              dayPolicyVersion: 1,
              role: 'user',
              messageText: 'v2 메시지',
              createdAtUtc: 1791072000000000,
              status: 'sent',
            ),
          );
      await oldDatabase
          .into(oldDatabase.diaryEntries)
          .insert(
            v2.DiaryEntriesData(
              id: 'persisted-v2-diary',
              dayYear: 2026,
              dayMonth: 10,
              dayDay: 4,
              dayTimeZoneId: 'Asia/Seoul',
              dayCutoffMicros: 0,
              dayPolicyVersion: 1,
              version: 1,
              status: 'draft',
              snapshotSchemaVersion: 1,
              snapshotJson: _v2DiarySnapshot(),
              generationId: 'persisted-v2-generation',
              generatedAtUtc: 1791072000000000,
              updatedAtUtc: 1791072000000000,
            ),
          );
      await oldDatabase.close();

      final migrated = AppDatabase(NativeDatabase(file));
      final messages = await migrated.select(migrated.messageRecords).get();
      final diaries = await migrated.select(migrated.diaryEntries).get();

      expect(migrated.schemaVersion, 3);
      expect(messages.single.id, 'persisted-v2-message');
      expect(diaries.single.id, 'persisted-v2-diary');
      expect(await migrated.select(migrated.mediaAssetRecords).get(), isEmpty);
      expect(await migrated.select(migrated.aiPersonaRecords).get(), isEmpty);
      expect(await migrated.select(migrated.memoryFactRecords).get(), isEmpty);
      await migrated.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

String _v2DiarySnapshot() {
  return jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'id': 'persisted-v2-diary',
    'dayKey': <String, Object?>{
      'labelDate': '2026-10-04',
      'timeZoneId': 'Asia/Seoul',
      'cutoffMicros': 0,
      'policyVersion': 1,
    },
    'version': 1,
    'status': 'draft',
    'weather': <String, Object?>{
      'provenance': 'noWeather',
      'condition': null,
      'temperatureCelsius': null,
      'providerId': null,
      'observedAtUtc': null,
    },
    'mood': '평온함',
    'oneLineSummary': '마이그레이션을 확인한 날',
    'theme': 'light',
    'blocks': <Object?>[
      <String, Object?>{'type': 'text', 'text': '기존 일기 본문'},
    ],
    'memoryCandidates': <Object?>[],
    'sourceMessageIds': <Object?>[],
    'generationId': 'persisted-v2-generation',
    'generatedAtUtc': '2026-10-04T15:00:00.000Z',
    'updatedAtUtc': '2026-10-04T15:00:00.000Z',
  });
}
