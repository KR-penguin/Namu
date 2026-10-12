enum AppStorageUnavailableReason {
  unsupportedPlatform,
  platformFailure,
  invalidRoot,
}

final class AppStorageUnavailableException implements Exception {
  const AppStorageUnavailableException(this.reason);

  final AppStorageUnavailableReason reason;

  @override
  String toString() => 'App storage is unavailable (${reason.name})';
}

abstract interface class AppStoragePaths {
  /// Returns an absolute app-owned root that native code excludes from backup.
  Future<String> appStorageRoot();
}

final class UnavailableAppStoragePaths implements AppStoragePaths {
  const UnavailableAppStoragePaths();

  @override
  Future<String> appStorageRoot() async {
    throw const AppStorageUnavailableException(
      AppStorageUnavailableReason.unsupportedPlatform,
    );
  }
}
