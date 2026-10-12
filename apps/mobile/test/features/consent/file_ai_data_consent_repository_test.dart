import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/consent/data/file_ai_data_consent_repository.dart';
import 'package:namu/features/consent/domain/ai_data_consent.dart';

void main() {
  late Directory temporaryDirectory;
  late File consentFile;
  late FileAiDataConsentRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'namu-ai-consent-',
    );
    consentFile = File(
      '${temporaryDirectory.path}/settings/ai-data-consent-v1.json',
    );
    repository = FileAiDataConsentRepository(
      storagePaths: _FixedStoragePaths(temporaryDirectory.path),
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('missing file is fail-closed and undecided', () async {
    expect(await repository.load(), const AiDataConsent.undecided());
  });

  test('round trips an accepted decision without user content', () async {
    final consent = AiDataConsent.accepted(
      decidedAtUtc: DateTime.utc(2026, 10, 4, 5, 6, 7),
    );

    await repository.save(consent);

    expect(await repository.load(), consent);
    final stored = await consentFile.readAsString();
    expect(stored, contains('accepted'));
    expect(stored, isNot(contains('오늘')));
  });

  test('malformed or unknown policy data fails closed', () async {
    await consentFile.parent.create(recursive: true);
    await consentFile.writeAsString('{not json');
    expect(await repository.load(), const AiDataConsent.undecided());

    await consentFile.writeAsString(
      '{"policyVersion":999,"choice":"accepted",'
      '"decidedAtUtc":"2026-10-04T00:00:00.000Z"}',
    );
    expect(await repository.load(), const AiDataConsent.undecided());
  });
}

final class _FixedStoragePaths implements AppStoragePaths {
  const _FixedStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
