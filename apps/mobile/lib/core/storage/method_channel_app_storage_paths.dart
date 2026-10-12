import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

final class MethodChannelAppStoragePaths implements AppStoragePaths {
  MethodChannelAppStoragePaths() : _channel = const MethodChannel(channelName);

  @visibleForTesting
  MethodChannelAppStoragePaths.withChannel(this._channel);

  static const String channelName = 'namu/storage';
  static const String rootMethod = 'getRootPath';

  final MethodChannel _channel;

  @override
  Future<String> appStorageRoot() async {
    if (kIsWeb) {
      throw const AppStorageUnavailableException(
        AppStorageUnavailableReason.unsupportedPlatform,
      );
    }

    final Object? result;
    try {
      result = await _channel.invokeMethod<Object?>(rootMethod);
    } on MissingPluginException {
      throw const AppStorageUnavailableException(
        AppStorageUnavailableReason.platformFailure,
      );
    } on PlatformException {
      throw const AppStorageUnavailableException(
        AppStorageUnavailableReason.platformFailure,
      );
    }

    if (result is! String || result.trim().isEmpty || !p.isAbsolute(result)) {
      throw const AppStorageUnavailableException(
        AppStorageUnavailableReason.invalidRoot,
      );
    }
    return p.normalize(result);
  }
}

AppStoragePaths createPlatformAppStoragePaths() {
  if (kIsWeb) {
    return const UnavailableAppStoragePaths();
  }
  return MethodChannelAppStoragePaths();
}
