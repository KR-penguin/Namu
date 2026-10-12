import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/features/settings/domain/local_data_eraser.dart';
import 'package:namu/features/settings/domain/local_data_export.dart';
import 'package:namu/features/settings/presentation/settings_screen.dart';

void main() {
  Widget subject({
    required LocalDataResetKind resetKind,
    required Future<void> Function() onReset,
    Future<LocalDataExportOutcome> Function(String shareText)? onExport,
  }) {
    return MaterialApp(
      home: SettingsScreen(
        localDataResetKind: resetKind,
        onResetAllLocalData: onReset,
        onOpenAiPersona: () {},
        onOpenAiDataConsent: () {},
        onExportLocalData: onExport,
      ),
    );
  }

  testWidgets('requires confirmation and describes the complete native reset', (
    tester,
  ) async {
    var resetCalls = 0;
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.persistentNative,
        onReset: () async => resetCalls += 1,
      ),
    );

    expect(find.textContaining('기기에만 저장'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.deleteAll')));
    await tester.pumpAndSettle();

    expect(find.text('모든 로컬 데이터를 삭제할까요?'), findsOneWidget);
    expect(find.textContaining('대화, 일기, 사진, AI 친구 설정'), findsOneWidget);
    expect(find.textContaining('AI 전송 동의'), findsWidgets);
    expect(find.textContaining('외부 앱이나 파일로 내보낸 사본'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings.deleteAll.cancel')));
    await tester.pumpAndSettle();
    expect(resetCalls, 0);

    await tester.tap(find.byKey(const Key('settings.deleteAll')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.deleteAll.confirm')));
    await tester.pumpAndSettle();

    expect(resetCalls, 1);
  });

  testWidgets('exports JSON only after confirmation and explains exclusions', (
    tester,
  ) async {
    var exportCalls = 0;
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.persistentNative,
        onReset: () async {},
        onExport: (shareText) async {
          exportCalls += 1;
          expect(shareText, 'Namu 로컬 기록 JSON 내보내기');
          return LocalDataExportOutcome.opened;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('settings.exportJson')));
    await tester.pumpAndSettle();

    expect(find.text('기록 JSON을 내보낼까요?'), findsOneWidget);
    expect(find.textContaining('사진 원본과 게시용 이미지'), findsOneWidget);
    expect(find.textContaining('앱을 복원할 수 없어요'), findsOneWidget);
    expect(find.textContaining('앱에서 회수하거나 삭제할 수 없어요'), findsOneWidget);
    expect(exportCalls, 0);

    await tester.tap(find.byKey(const Key('settings.export.cancel')));
    await tester.pumpAndSettle();
    expect(exportCalls, 0);

    await tester.tap(find.byKey(const Key('settings.exportJson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.export.confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(exportCalls, 1);
    expect(find.text('공유·저장 화면을 열었어요.'), findsOneWidget);
  });

  testWidgets('disables data export in the transient browser preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.transientPreview,
        onReset: () async {},
      ),
    );

    expect(find.textContaining('브라우저 미리보기에서는 내보내기를 지원하지 않아요'), findsOneWidget);
    final tile = tester.widget<ListTile>(
      find.byKey(const Key('settings.exportJson')),
    );
    expect(tile.enabled, isFalse);
  });

  testWidgets('shows a redacted retryable export error', (tester) async {
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.persistentNative,
        onReset: () async {},
        onExport: (_) async => throw StateError('private export path'),
      ),
    );

    await tester.tap(find.byKey(const Key('settings.exportJson')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.export.confirm')));
    await tester.pumpAndSettle();

    expect(find.text('기록을 내보내지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('private export path'), findsNothing);
  });

  testWidgets('labels web reset as transient preview cleanup', (tester) async {
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.transientPreview,
        onReset: () async {},
      ),
    );

    expect(find.textContaining('브라우저 미리보기의 임시 데이터'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.deleteAll')));
    await tester.pumpAndSettle();

    expect(find.textContaining('기기 저장소 삭제를 검증하는 동작이 아니에요'), findsOneWidget);
  });

  testWidgets('keeps an explicit retryable error when reset fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        resetKind: LocalDataResetKind.persistentNative,
        onReset: () async => throw StateError('private storage detail'),
      ),
    );

    await tester.tap(find.byKey(const Key('settings.deleteAll')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.deleteAll.confirm')));
    await tester.pumpAndSettle();

    expect(find.text('데이터 삭제를 완료하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('private storage detail'), findsNothing);
  });
}
