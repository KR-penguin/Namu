import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/onboarding/data/file_onboarding_repository.dart';
import 'package:namu/features/onboarding/domain/onboarding_status.dart';

void main() {
  late Directory temporaryDirectory;
  late File statusFile;
  late FileOnboardingRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'namu-onboarding-',
    );
    statusFile = File('${temporaryDirectory.path}/settings/onboarding-v1.json');
    repository = FileOnboardingRepository(
      storagePaths: _FixedStoragePaths(temporaryDirectory.path),
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('missing state starts onboarding', () async {
    expect(await repository.load(), const OnboardingStatus.notCompleted());
  });

  test('round trips only versioned completion metadata', () async {
    final status = OnboardingStatus.completed(
      completedAtUtc: DateTime.utc(2026, 10, 10, 4, 5, 6),
    );

    await repository.save(status);

    expect(await repository.load(), status);
    final stored = await statusFile.readAsString();
    expect(stored, contains('completedAtUtc'));
    expect(stored, isNot(contains('conversation')));
  });

  test('malformed or unknown versions restart onboarding', () async {
    await statusFile.parent.create(recursive: true);
    await statusFile.writeAsString('{not json');
    expect(await repository.load(), const OnboardingStatus.notCompleted());

    await statusFile.writeAsString(
      '{"schemaVersion":999,"completedAtUtc":"2026-10-10T04:05:06.000Z"}',
    );
    expect(await repository.load(), const OnboardingStatus.notCompleted());
  });
}

final class _FixedStoragePaths implements AppStoragePaths {
  const _FixedStoragePaths(this.root);

  final String root;

  @override
  Future<String> appStorageRoot() async => root;
}
