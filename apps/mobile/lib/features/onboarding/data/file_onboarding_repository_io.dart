import 'dart:convert';
import 'dart:io';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

import '../domain/onboarding_repository.dart';
import '../domain/onboarding_status.dart';
import 'onboarding_storage_exception.dart';

/// Stores disclosure completion in the app-owned, backup-excluded root.
final class FileOnboardingRepository implements OnboardingRepository {
  factory FileOnboardingRepository({required AppStoragePaths storagePaths}) =>
      FileOnboardingRepository._(storagePaths);

  const FileOnboardingRepository._(this._storagePaths);

  static const String relativePath = 'settings/onboarding-v1.json';

  final AppStoragePaths _storagePaths;

  @override
  Future<OnboardingStatus> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return const OnboardingStatus.notCompleted();
      }
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, dynamic>) {
        return const OnboardingStatus.notCompleted();
      }
      return _decode(value);
    } on FormatException {
      return const OnboardingStatus.notCompleted();
    } on FileSystemException {
      throw const OnboardingStorageException();
    }
  }

  @override
  Future<void> save(OnboardingStatus status) async {
    if (!status.isComplete || status.completedAtUtc == null) {
      throw ArgumentError.value(status, 'status', 'must be complete');
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
          'schemaVersion': status.schemaVersion,
          'completedAtUtc': status.completedAtUtc!.toIso8601String(),
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
      throw const OnboardingStorageException();
    }
  }

  Future<File> _file() async {
    final root = p.normalize(await _storagePaths.appStorageRoot());
    if (!p.isAbsolute(root)) {
      throw const OnboardingStorageException();
    }
    return File(p.join(root, relativePath));
  }

  static OnboardingStatus _decode(Map<String, dynamic> value) {
    if (value.length != 2 ||
        value['schemaVersion'] != OnboardingStatus.currentSchemaVersion ||
        value['completedAtUtc'] is! String) {
      return const OnboardingStatus.notCompleted();
    }
    final completedAt = DateTime.tryParse(value['completedAtUtc'] as String);
    if (completedAt == null || !completedAt.isUtc) {
      return const OnboardingStatus.notCompleted();
    }
    return OnboardingStatus.completed(completedAtUtc: completedAt);
  }
}
