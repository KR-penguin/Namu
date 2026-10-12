import 'dart:convert';
import 'dart:io';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

import '../domain/ai_data_consent.dart';
import '../domain/ai_data_consent_repository.dart';
import 'ai_data_consent_storage_exception.dart';

/// Stores only the consent decision in the app-owned, backup-excluded root.
final class FileAiDataConsentRepository implements AiDataConsentRepository {
  factory FileAiDataConsentRepository({
    required AppStoragePaths storagePaths,
  }) => FileAiDataConsentRepository._(storagePaths);

  const FileAiDataConsentRepository._(this._storagePaths);

  static const String relativePath = 'settings/ai-data-consent-v1.json';

  final AppStoragePaths _storagePaths;

  @override
  Future<AiDataConsent> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return const AiDataConsent.undecided();
      }
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, dynamic>) {
        return const AiDataConsent.undecided();
      }
      return _decode(value);
    } on FormatException {
      return const AiDataConsent.undecided();
    } on FileSystemException {
      throw const AiDataConsentStorageException();
    }
  }

  @override
  Future<void> save(AiDataConsent consent) async {
    if (consent.choice == AiDataConsentChoice.undecided ||
        consent.decidedAtUtc == null ||
        !consent.decidedAtUtc!.isUtc) {
      throw ArgumentError.value(consent, 'consent', 'must be a UTC decision');
    }

    File? staging;
    try {
      final target = await _file();
      await target.parent.create(recursive: true);
      staging = File('${target.path}.part');
      if (await staging.exists()) {
        await staging.delete();
      }
      await staging.writeAsString(
        jsonEncode(<String, Object>{
          'policyVersion': consent.policyVersion,
          'choice': consent.choice.name,
          'decidedAtUtc': consent.decidedAtUtc!.toIso8601String(),
        }),
        flush: true,
      );
      if (await target.exists()) {
        await target.delete();
      }
      await staging.rename(target.path);
    } on FileSystemException {
      if (staging != null && await staging.exists()) {
        await staging.delete();
      }
      throw const AiDataConsentStorageException();
    }
  }

  Future<File> _file() async {
    final root = p.normalize(await _storagePaths.appStorageRoot());
    if (!p.isAbsolute(root)) {
      throw const AiDataConsentStorageException();
    }
    return File(p.join(root, relativePath));
  }

  static AiDataConsent _decode(Map<String, dynamic> value) {
    if (value.length != 3 ||
        value['policyVersion'] != AiDataConsent.currentPolicyVersion ||
        value['choice'] is! String ||
        value['decidedAtUtc'] is! String) {
      return const AiDataConsent.undecided();
    }

    final decidedAt = DateTime.tryParse(value['decidedAtUtc'] as String);
    if (decidedAt == null || !decidedAt.isUtc) {
      return const AiDataConsent.undecided();
    }

    return switch (value['choice']) {
      'accepted' => AiDataConsent.accepted(decidedAtUtc: decidedAt),
      'declined' => AiDataConsent.declined(decidedAtUtc: decidedAt),
      'revoked' => AiDataConsent.revoked(decidedAtUtc: decidedAt),
      _ => const AiDataConsent.undecided(),
    };
  }
}
