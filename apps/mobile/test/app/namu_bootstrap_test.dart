import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namu/app/app_dependencies.dart';
import 'package:namu/app/namu_app.dart';
import 'package:namu/app/namu_bootstrap.dart';
import 'package:namu/core/time/time_zone_resolver.dart';
import 'package:namu/core/time/time_zone_snapshot.dart';
import 'package:namu/features/media/application/photo_import_selection.dart';
import 'package:namu/features/media/application/photo_selector.dart';
import 'package:namu/l10n/app_localizations.dart';
import 'package:namu/l10n/namu_localizations.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
    binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('ko', 'KR'),
    ];
  });

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
    binding.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets('blocks app startup until a stable time zone is available', (
    tester,
  ) async {
    final l10n = namuLocalizationsFor(const Locale('ko'));
    final resolver = _RetryingTimeZoneResolver();
    final dependencies = AppDependencies.forPlatform(
      isWeb: true,
      photoSelectorFactory: _NoPhotoSelector.new,
    );

    await tester.pumpWidget(
      NamuBootstrap.testing(
        dependenciesFactory: () => dependencies,
        timeZoneResolverFactory: () => resolver,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.bootstrapTimeZoneFailedTitle), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
    expect(find.byKey(const Key('bootstrap.timeZoneRetry')), findsOneWidget);
    expect(find.byKey(const Key('today.mobile')), findsNothing);

    await tester.tap(find.byKey(const Key('bootstrap.timeZoneRetry')));
    await tester.pumpAndSettle();

    expect(resolver.refreshCount, 1);
    expect(find.text(l10n.bootstrapTimeZoneFailedTitle), findsNothing);
    expect(find.byType(NamuApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await dependencies.close();
  });
}

final class _RetryingTimeZoneResolver implements TimeZoneResolver {
  var refreshCount = 0;
  var _ready = false;

  @override
  Future<void> initialize() async {
    throw const TimeZoneResolverException(
      TimeZoneResolverFailureReason.platformFailure,
    );
  }

  @override
  Future<void> refresh() async {
    refreshCount += 1;
    _ready = true;
  }

  @override
  TimeZoneSnapshot snapshotAt(DateTime instantUtc) {
    if (!_ready) {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.notInitialized,
      );
    }
    return TimeZoneSnapshot(
      timeZoneId: 'Asia/Seoul',
      utcOffset: Duration(hours: 9),
    );
  }
}

final class _NoPhotoSelector implements PhotoSelector {
  const _NoPhotoSelector();

  @override
  Future<PhotoImportSelection?> selectFromGallery() async => null;
}
