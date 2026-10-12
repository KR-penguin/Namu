import 'dart:convert';
import 'dart:typed_data';

import '../../chat/data/message_json_codec.dart';
import '../../chat/domain/message.dart';
import '../../chat/domain/message_repository.dart';
import '../../consent/domain/ai_data_consent.dart';
import '../../consent/domain/ai_data_consent_repository.dart';
import '../../diary/data/diary_entry_json_codec.dart';
import '../../diary/domain/diary_entry.dart';
import '../../diary/domain/diary_generation_output.dart';
import '../../diary/domain/diary_repository.dart';
import '../../media/domain/media_asset.dart';
import '../../media/domain/media_repository.dart';
import '../../memory/domain/memory_fact.dart';
import '../../memory/domain/memory_fact_repository.dart';
import '../../persona/domain/ai_persona.dart';
import '../../persona/domain/ai_persona_repository.dart';
import '../domain/local_data_export.dart';

/// Creates a user-triggered, machine-readable snapshot of local records.
///
/// V1 intentionally excludes photo bytes and rendered diary images. Choosing
/// between original EXIF preservation and privacy-scrubbed re-encoding is a
/// product privacy decision, so this slice records photo references without
/// silently making that choice. The document is not an app restore format.
final class ExportLocalData {
  ExportLocalData({
    required this.messageRepository,
    required this.diaryRepository,
    required this.mediaRepository,
    required this.personaRepository,
    required this.memoryFactRepository,
    required this.aiDataConsentRepository,
    required this.store,
    required this.launcher,
    required this.utcNow,
  });

  static const int schemaVersion = 1;

  final MessageRepository messageRepository;
  final DiaryRepository diaryRepository;
  final MediaRepository mediaRepository;
  final AiPersonaRepository personaRepository;
  final MemoryFactRepository memoryFactRepository;
  final AiDataConsentRepository aiDataConsentRepository;
  final LocalDataExportStore store;
  final LocalDataExportLauncher launcher;
  final DateTime Function() utcNow;

  Future<LocalDataExportOutcome> call({required String shareText}) async {
    final exportedAtUtc = utcNow();
    if (!exportedAtUtc.isUtc) {
      throw const LocalDataExportException(
        LocalDataExportFailure.invalidSnapshot,
      );
    }

    final Map<String, Object?> document;
    try {
      document = await _buildDocument(exportedAtUtc);
    } on LocalDataExportException {
      rethrow;
    } catch (_) {
      throw const LocalDataExportException(
        LocalDataExportFailure.collectFailed,
      );
    }

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(document)),
    );
    final artifact = await store.write(
      bytes: bytes,
      exportedAtUtc: exportedAtUtc,
    );
    return launcher.launch(artifact, shareText: shareText);
  }

  Future<Map<String, Object?>> _buildDocument(DateTime exportedAtUtc) async {
    final messages = await _loadMessages();
    final diaries = (await diaryRepository.listAll()).toList()
      ..sort(_compareDiaries);
    final memories = (await memoryFactRepository.listAll()).toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    final persona = await personaRepository.load();
    final consent = await aiDataConsentRepository.load();

    final referencedMediaIdSet = <String>{};
    for (final message in messages) {
      final photoAssetId = message.photoAssetId;
      if (photoAssetId != null) {
        referencedMediaIdSet.add(photoAssetId);
      }
    }
    for (final diary in diaries) {
      for (final block in diary.blocks) {
        if (block case DiaryPhotoBlock(:final photoAssetId)) {
          referencedMediaIdSet.add(photoAssetId);
        }
      }
    }
    final referencedMediaIds = referencedMediaIdSet.toList()..sort();

    final mediaAssets = <MediaAsset>[];
    final missingMediaAssetIds = <String>[];
    for (final id in referencedMediaIds) {
      final asset = await mediaRepository.findById(id);
      if (asset == null) {
        missingMediaAssetIds.add(id);
      } else {
        mediaAssets.add(asset);
      }
    }

    return <String, Object?>{
      'format': 'namu-local-data-export',
      'schemaVersion': schemaVersion,
      'exportedAtUtc': exportedAtUtc.toIso8601String(),
      'restoreSupported': false,
      'snapshotConsistency': 'bestEffort',
      'photoFilesIncluded': false,
      'renderedDiaryImagesIncluded': false,
      'messages': messages.map(const MessageJsonCodec().encode).toList(),
      'diaries': diaries.map(_encodeDiary).toList(),
      'mediaAssets': mediaAssets.map(_encodeMedia).toList(),
      'missingMediaAssetIds': missingMediaAssetIds,
      'persona': persona == null ? null : _encodePersona(persona),
      'memoryFacts': memories.map(_encodeMemory).toList(),
      'aiDataConsent': _encodeConsent(consent),
    };
  }

  Future<List<Message>> _loadMessages() async {
    final result = <Message>[];
    for (final dayKey in await messageRepository.listDayKeysOldestFirst()) {
      result.addAll(await messageRepository.listForDay(dayKey));
    }
    return result;
  }

  static int _compareDiaries(DiaryEntry left, DiaryEntry right) {
    final leftDate = left.dayKey.labelDate;
    final rightDate = right.dayKey.labelDate;
    final byYear = leftDate.year.compareTo(rightDate.year);
    if (byYear != 0) return byYear;
    final byMonth = leftDate.month.compareTo(rightDate.month);
    if (byMonth != 0) return byMonth;
    final byDay = leftDate.day.compareTo(rightDate.day);
    if (byDay != 0) return byDay;
    final byTimeZone = left.dayKey.timeZoneId.compareTo(
      right.dayKey.timeZoneId,
    );
    if (byTimeZone != 0) return byTimeZone;
    final byVersion = left.version.compareTo(right.version);
    return byVersion != 0 ? byVersion : left.id.compareTo(right.id);
  }

  static Map<String, Object?> _encodeDiary(DiaryEntry entry) {
    return jsonDecode(const DiaryEntryJsonCodec().encode(entry))
        as Map<String, Object?>;
  }

  static Map<String, Object?> _encodeMedia(MediaAsset asset) {
    return <String, Object?>{
      'id': asset.id,
      'dayKey': _encodeDayKey(asset),
      'mimeType': asset.mimeType.contentType,
      'byteLength': asset.byteLength,
      'createdAtUtc': asset.createdAtUtc.toIso8601String(),
      'lifecycle': asset.lifecycle.name,
      'fileIncluded': false,
    };
  }

  static Map<String, Object?> _encodeDayKey(MediaAsset asset) {
    return <String, Object?>{
      'labelDate': asset.dayKey.labelDate.toString(),
      'timeZoneId': asset.dayKey.timeZoneId,
      'cutoffMicros': asset.dayKey.cutoff.inMicroseconds,
      'policyVersion': asset.dayKey.policyVersion,
    };
  }

  static Map<String, Object?> _encodePersona(AiPersona persona) {
    return <String, Object?>{
      'id': persona.id,
      'name': persona.name,
      'avatarSeed': persona.avatarSeed,
      'tone': persona.tone,
      'customInstructions': persona.customInstructions,
      'reactionLength': persona.reactionLength.name,
    };
  }

  static Map<String, Object?> _encodeMemory(MemoryFact fact) {
    return <String, Object?>{
      'id': fact.id,
      'fact': fact.fact,
      'sourceMessageIds': fact.sourceMessageIds,
      'category': fact.category.name,
      'sensitivity': fact.sensitivity.name,
      'status': fact.status.name,
      'createdAtUtc': fact.createdAtUtc.toIso8601String(),
      'updatedAtUtc': fact.updatedAtUtc.toIso8601String(),
    };
  }

  static Map<String, Object?> _encodeConsent(AiDataConsent consent) {
    return <String, Object?>{
      'policyVersion': consent.policyVersion,
      'choice': consent.choice.name,
      'decidedAtUtc': consent.decidedAtUtc?.toIso8601String(),
    };
  }
}
