import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

@DataClassName('MessageRow')
@TableIndex(
  name: 'messages_day_created_at_id_idx',
  columns: {
    #dayYear,
    #dayMonth,
    #dayDay,
    #dayTimeZoneId,
    #dayCutoffMicros,
    #dayPolicyVersion,
    #createdAtUtc,
    #id,
  },
)
class MessageRecords extends Table {
  @override
  String get tableName => 'messages';

  TextColumn get id => text()();
  TextColumn get requestId => text()();
  IntColumn get dayYear => integer()();
  IntColumn get dayMonth => integer()();
  IntColumn get dayDay => integer()();
  TextColumn get dayTimeZoneId => text()();
  IntColumn get dayCutoffMicros => integer()();
  IntColumn get dayPolicyVersion => integer()();
  TextColumn get role => text()();
  TextColumn get messageText => text().named('message_text').nullable()();
  TextColumn get photoAssetId => text().nullable()();

  /// UTC microseconds since Unix epoch, preserving deterministic subsecond order.
  IntColumn get createdAtUtc => integer()();

  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {requestId, role},
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim("id")) > 0)',
    'CHECK (length(trim("request_id")) > 0)',
    'CHECK (length(trim("day_time_zone_id")) > 0)',
    'CHECK ("day_year" BETWEEN 1 AND 9999)',
    'CHECK ("day_month" BETWEEN 1 AND 12)',
    'CHECK ("day_day" BETWEEN 1 AND CASE '
        'WHEN "day_month" IN (4, 6, 9, 11) THEN 30 '
        'WHEN "day_month" = 2 THEN CASE '
        'WHEN ("day_year" % 400 = 0 OR '
        '("day_year" % 4 = 0 AND "day_year" % 100 != 0)) THEN 29 '
        'ELSE 28 END ELSE 31 END)',
    'CHECK ("day_cutoff_micros" = 0)',
    'CHECK ("day_policy_version" = 1)',
    'CHECK ("role" IN (\'user\', \'assistant\'))',
    'CHECK ("status" IN (\'pending\', \'sent\', \'failed\'))',
    'CHECK ("message_text" IS NULL OR length(trim("message_text")) > 0)',
    'CHECK ("photo_asset_id" IS NULL OR '
        'length(trim("photo_asset_id")) > 0)',
    'CHECK ("message_text" IS NOT NULL OR "photo_asset_id" IS NOT NULL)',
  ];
}

@DataClassName('DiaryEntryRow')
@TableIndex(
  name: 'diary_entries_day_version_idx',
  columns: {
    #dayYear,
    #dayMonth,
    #dayDay,
    #dayTimeZoneId,
    #dayCutoffMicros,
    #dayPolicyVersion,
    IndexedColumn(#version, orderBy: OrderingMode.desc),
  },
)
@TableIndex(
  name: 'diary_entries_updated_at_id_idx',
  columns: {
    IndexedColumn(#updatedAtUtc, orderBy: OrderingMode.desc),
    #id,
  },
)
class DiaryEntries extends Table {
  TextColumn get id => text()();
  IntColumn get dayYear => integer()();
  IntColumn get dayMonth => integer()();
  IntColumn get dayDay => integer()();
  TextColumn get dayTimeZoneId => text()();
  IntColumn get dayCutoffMicros => integer()();
  IntColumn get dayPolicyVersion => integer()();
  IntColumn get version => integer()();
  TextColumn get status => text()();
  IntColumn get snapshotSchemaVersion => integer()();
  TextColumn get snapshotJson => text()();
  TextColumn get generationId => text()();
  IntColumn get generatedAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {generationId},
    {
      dayYear,
      dayMonth,
      dayDay,
      dayTimeZoneId,
      dayCutoffMicros,
      dayPolicyVersion,
      version,
    },
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim("id")) > 0)',
    'CHECK (length(trim("day_time_zone_id")) > 0)',
    'CHECK (length(trim("generation_id")) > 0)',
    'CHECK (length(trim("snapshot_json")) > 0)',
    'CHECK ("day_year" BETWEEN 1 AND 9999)',
    'CHECK ("day_month" BETWEEN 1 AND 12)',
    'CHECK ("day_day" BETWEEN 1 AND CASE '
        'WHEN "day_month" IN (4, 6, 9, 11) THEN 30 '
        'WHEN "day_month" = 2 THEN CASE '
        'WHEN ("day_year" % 400 = 0 OR '
        '("day_year" % 4 = 0 AND "day_year" % 100 != 0)) THEN 29 '
        'ELSE 28 END ELSE 31 END)',
    'CHECK ("day_cutoff_micros" = 0)',
    'CHECK ("day_policy_version" = 1)',
    'CHECK ("version" > 0)',
    'CHECK ("status" IN (\'draft\', \'finalized\'))',
    'CHECK ("snapshot_schema_version" = 1)',
    'CHECK ("updated_at_utc" >= "generated_at_utc")',
  ];
}

@DataClassName('MediaAssetRow')
@TableIndex(
  name: 'media_assets_day_created_at_id_idx',
  columns: {
    #dayYear,
    #dayMonth,
    #dayDay,
    #dayTimeZoneId,
    #dayCutoffMicros,
    #dayPolicyVersion,
    #createdAtUtc,
    #id,
  },
)
class MediaAssetRecords extends Table {
  @override
  String get tableName => 'media_assets';

  TextColumn get id => text()();
  IntColumn get dayYear => integer()();
  IntColumn get dayMonth => integer()();
  IntColumn get dayDay => integer()();
  TextColumn get dayTimeZoneId => text()();
  IntColumn get dayCutoffMicros => integer()();
  IntColumn get dayPolicyVersion => integer()();
  TextColumn get storageKey => text()();
  TextColumn get mimeType => text()();
  IntColumn get byteLength => integer()();
  IntColumn get createdAtUtc => integer()();
  TextColumn get lifecycle => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {storageKey},
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim("id")) > 0)',
    'CHECK (length(trim("day_time_zone_id")) > 0)',
    'CHECK (length(trim("storage_key")) > 0)',
    'CHECK (substr("storage_key", 1, 1) NOT IN (\'/\', char(92)))',
    'CHECK ("storage_key" NOT GLOB \'[A-Za-z]*:*\')',
    'CHECK (instr("storage_key", char(0)) = 0)',
    'CHECK ("storage_key" NOT IN (\'.\', \'..\'))',
    'CHECK ("storage_key" NOT GLOB \'./*\')',
    'CHECK ("storage_key" NOT GLOB \'../*\')',
    'CHECK ("storage_key" NOT GLOB \'*/./*\')',
    'CHECK ("storage_key" NOT GLOB \'*/../*\')',
    'CHECK ("storage_key" NOT GLOB \'*/.\')',
    'CHECK ("storage_key" NOT GLOB \'*/..\')',
    'CHECK ("storage_key" NOT GLOB \'*\\.\\*\')',
    'CHECK ("storage_key" NOT GLOB \'*\\..\\*\')',
    'CHECK ("storage_key" NOT GLOB \'*\\.\')',
    'CHECK ("storage_key" NOT GLOB \'*\\..\')',
    'CHECK ("day_year" BETWEEN 1 AND 9999)',
    'CHECK ("day_month" BETWEEN 1 AND 12)',
    'CHECK ("day_day" BETWEEN 1 AND CASE '
        'WHEN "day_month" IN (4, 6, 9, 11) THEN 30 '
        'WHEN "day_month" = 2 THEN CASE '
        'WHEN ("day_year" % 400 = 0 OR '
        '("day_year" % 4 = 0 AND "day_year" % 100 != 0)) THEN 29 '
        'ELSE 28 END ELSE 31 END)',
    'CHECK ("day_cutoff_micros" = 0)',
    'CHECK ("day_policy_version" = 1)',
    'CHECK ("mime_type" IN (\'image/jpeg\', \'image/png\', \'image/heic\'))',
    'CHECK ("byte_length" > 0)',
    'CHECK ("lifecycle" IN '
        '(\'staging\', \'ready\', \'deleting\', \'missing\'))',
  ];
}

@DataClassName('AiPersonaRow')
class AiPersonaRecords extends Table {
  @override
  String get tableName => 'ai_persona';

  IntColumn get singletonKey => integer()();
  TextColumn get personaId => text()();
  TextColumn get personaName => text()();
  TextColumn get avatarSeed => text()();
  TextColumn get tone => text()();
  TextColumn get customInstructions => text()();
  TextColumn get reactionLength => text()();

  @override
  Set<Column<Object>> get primaryKey => {singletonKey};

  @override
  List<String> get customConstraints => const [
    'CHECK ("singleton_key" = 1)',
    'CHECK (length("persona_id") BETWEEN 1 AND 128 '
        'AND "persona_id" = trim("persona_id"))',
    'CHECK (length("persona_name") BETWEEN 1 AND 40 '
        'AND "persona_name" = trim("persona_name"))',
    'CHECK (length("avatar_seed") BETWEEN 1 AND 128 '
        'AND "avatar_seed" = trim("avatar_seed"))',
    'CHECK (length("tone") BETWEEN 1 AND 160 AND "tone" = trim("tone"))',
    'CHECK (length("custom_instructions") <= 1000 '
        'AND "custom_instructions" = trim("custom_instructions"))',
    'CHECK ("reaction_length" IN '
        '(\'concise\', \'balanced\', \'expressive\'))',
  ];
}

@DataClassName('MemoryFactRow')
@TableIndex(
  name: 'memory_facts_updated_at_id_idx',
  columns: {
    IndexedColumn(#updatedAtUtc, orderBy: OrderingMode.desc),
    #id,
  },
)
class MemoryFactRecords extends Table {
  @override
  String get tableName => 'memory_facts';

  TextColumn get id => text()();
  TextColumn get fact => text()();
  IntColumn get sourceIdsSchemaVersion => integer()();
  TextColumn get sourceIdsJson => text()();
  TextColumn get category => text()();
  TextColumn get sensitivity => text()();
  TextColumn get status => text()();
  IntColumn get createdAtUtc => integer()();
  IntColumn get updatedAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim("id")) > 0)',
    'CHECK (length(trim("fact")) > 0)',
    'CHECK ("source_ids_schema_version" = 1)',
    'CHECK (length(trim("source_ids_json")) > 0)',
    'CHECK ("category" IN (\'preference\', \'routine\', \'relationship\', '
        '\'place\', \'milestone\', \'other\'))',
    'CHECK ("sensitivity" IN (\'standard\', \'sensitive\'))',
    'CHECK ("status" IN (\'candidate\', \'active\', \'inactive\'))',
    'CHECK ("updated_at_utc" >= "created_at_utc")',
  ];
}

@DriftDatabase(
  tables: [
    MessageRecords,
    DiaryEntries,
    MediaAssetRecords,
    AiPersonaRecords,
    MemoryFactRecords,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: stepByStep(
      from1To2: (migrator, schema) async {
        await migrator.createTable(schema.diaryEntries);
        await migrator.createIndex(schema.diaryEntriesDayVersionIdx);
        await migrator.createIndex(schema.diaryEntriesUpdatedAtIdIdx);
      },
      from2To3: (migrator, schema) async {
        await migrator.createTable(schema.mediaAssets);
        await migrator.createTable(schema.aiPersona);
        await migrator.createTable(schema.memoryFacts);
        await migrator.createIndex(schema.mediaAssetsDayCreatedAtIdIdx);
        await migrator.createIndex(schema.memoryFactsUpdatedAtIdIdx);
      },
    ),
  );
}
