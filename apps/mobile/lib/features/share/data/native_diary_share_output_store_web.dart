import 'dart:typed_data';

import 'package:namu/core/storage/app_storage_paths.dart';
import 'package:namu/features/share/domain/diary_share_output_store.dart';

final class NativeDiaryShareOutputStore implements DiaryShareOutputStore {
  const NativeDiaryShareOutputStore(AppStoragePaths storagePaths);

  @override
  Future<String> writePng({
    required String entryId,
    required int version,
    required DateTime updatedAtUtc,
    required int pageNumber,
    required Uint8List bytes,
  }) async {
    throw const DiaryShareOutputException(
      DiaryShareOutputFailure.unsupportedPlatform,
    );
  }
}
