import 'dart:async';

import 'package:flutter/material.dart';

import '../core/time/method_channel_time_zone_resolver.dart';
import '../core/time/time_zone_resolver.dart';
import '../features/diary/application/daily_close_coordinator.dart';
import '../l10n/app_localizations.dart';
import '../l10n/namu_localizations.dart';
import 'app_dependencies.dart';
import 'namu_app.dart';

typedef AppDependenciesFactory = AppDependencies Function();
typedef TimeZoneResolverFactory = TimeZoneResolver Function();

/// Creates and owns the dependency graph for one application lifetime.
final class NamuBootstrap extends StatefulWidget {
  const NamuBootstrap({super.key})
    : dependenciesFactory = null,
      timeZoneResolverFactory = null,
      foregroundEvents = null,
      dailyCloseTimerScheduler = null,
      dailyCloseEnabled = true;

  @visibleForTesting
  const NamuBootstrap.testing({
    required this.dependenciesFactory,
    this.timeZoneResolverFactory,
    this.foregroundEvents = const Stream<void>.empty(),
    this.dailyCloseTimerScheduler = const _NoopDailyCloseTimerScheduler(),
    this.dailyCloseEnabled = false,
    super.key,
  });

  final AppDependenciesFactory? dependenciesFactory;
  final TimeZoneResolverFactory? timeZoneResolverFactory;
  final Stream<void>? foregroundEvents;
  final DailyCloseTimerScheduler? dailyCloseTimerScheduler;
  final bool dailyCloseEnabled;

  @override
  State<NamuBootstrap> createState() => _NamuBootstrapState();
}

final class _NamuBootstrapState extends State<NamuBootstrap> {
  late AppDependencies _dependencies;
  late final TimeZoneResolver _timeZoneResolver;
  late Future<void> _timeZoneInitialization;
  AppDependencies? _resetSource;
  Future<void>? _resetOperation;
  Object? _resetError;
  var _resetGraphClosed = false;
  var _showResetFrame = false;

  @override
  void initState() {
    super.initState();
    _dependencies =
        widget.dependenciesFactory?.call() ?? AppDependencies.production();
    _timeZoneResolver =
        widget.timeZoneResolverFactory?.call() ??
        (widget.dependenciesFactory == null
            ? createPlatformTimeZoneResolver()
            : WebPreviewTimeZoneResolver());
    _timeZoneInitialization = _timeZoneResolver.initialize();
  }

  @override
  void dispose() {
    unawaited(_dependencies.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResetFrame) {
      return _BootstrapFrame(
        child: _resetError == null
            ? const _BootstrapResetProgress()
            : _BootstrapResetError(
                onRetry: () => unawaited(_resetAllLocalData()),
              ),
      );
    }

    return FutureBuilder<void>(
      future: _timeZoneInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapFrame(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          return _BootstrapFrame(
            child: _BootstrapTimeZoneError(onRetry: _retryTimeZone),
          );
        }
        return NamuApp(
          messageRepository: _dependencies.messageRepository,
          personaRepository: _dependencies.personaRepository,
          diaryRepository: _dependencies.diaryRepository,
          memoryFactRepository: _dependencies.memoryFactRepository,
          aiDataConsentRepository: _dependencies.aiDataConsentRepository,
          onboardingRepository: _dependencies.onboardingRepository,
          pickAndImportPhoto: _dependencies.pickAndImportPhoto,
          photoBytesLoader: _dependencies.loadLocalPhotoBytes.call,
          shareDiary: _dependencies.shareDiary,
          timeZoneAt: _timeZoneResolver.snapshotAt,
          refreshTimeZoneBeforeForeground: _timeZoneResolver.refresh,
          foregroundEvents: widget.foregroundEvents,
          dailyCloseTimerScheduler: widget.dailyCloseTimerScheduler,
          dailyCloseEnabled: widget.dailyCloseEnabled,
          registerBeforeStorageClose: _dependencies.registerBeforeClose,
          localDataResetKind: _dependencies.localDataEraser.resetKind,
          onResetAllLocalData: _resetAllLocalData,
          exportLocalData: _dependencies.exportLocalData,
        );
      },
    );
  }

  Future<void> _resetAllLocalData() {
    return _resetOperation ??= _performLocalDataReset().whenComplete(() {
      _resetOperation = null;
    });
  }

  Future<void> _performLocalDataReset() async {
    final source = _resetSource ??= _dependencies;
    if (mounted) {
      setState(() {
        _showResetFrame = true;
        _resetError = null;
      });
      await _waitForResetFrame();
    }

    try {
      if (!_resetGraphClosed) {
        await source.close();
        _resetGraphClosed = true;
      }
      await source.localDataEraser.erase();

      final fresh =
          widget.dependenciesFactory?.call() ?? AppDependencies.production();
      if (identical(fresh, source)) {
        throw StateError(
          'A local data reset requires a fresh dependency graph.',
        );
      }
      if (!mounted) {
        await fresh.close();
        return;
      }
      setState(() {
        _dependencies = fresh;
        _resetSource = null;
        _resetGraphClosed = false;
        _resetError = null;
        _showResetFrame = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _resetError = error;
          _showResetFrame = true;
        });
      }
      rethrow;
    }
  }

  Future<void> _waitForResetFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    return completer.future;
  }

  void _retryTimeZone() {
    setState(() {
      _timeZoneInitialization = _timeZoneResolver.refresh();
    });
  }
}

final class _BootstrapResetProgress extends StatelessWidget {
  const _BootstrapResetProgress();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator.adaptive(),
        const SizedBox(height: 18),
        Text(context.l10n.bootstrapResetDeleting),
      ],
    );
  }
}

final class _BootstrapResetError extends StatelessWidget {
  const _BootstrapResetError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.bootstrapResetFailedTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.bootstrapResetFailedBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('bootstrap.localDataResetRetry'),
          onPressed: onRetry,
          child: Text(context.l10n.bootstrapResetRetry),
        ),
      ],
    );
  }
}

final class _BootstrapTimeZoneError extends StatelessWidget {
  const _BootstrapTimeZoneError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.bootstrapTimeZoneFailedTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.bootstrapTimeZoneFailedBody,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('bootstrap.timeZoneRetry'),
          onPressed: onRetry,
          child: Text(context.l10n.commonRetry),
        ),
      ],
    );
  }
}

final class _NoopDailyCloseTimerScheduler implements DailyCloseTimerScheduler {
  const _NoopDailyCloseTimerScheduler();

  @override
  DailyCloseTimer schedule(Duration delay, Future<void> Function() callback) {
    return const _NoopDailyCloseTimer();
  }
}

final class _NoopDailyCloseTimer implements DailyCloseTimer {
  const _NoopDailyCloseTimer();

  @override
  void cancel() {}
}

final class _BootstrapFrame extends StatelessWidget {
  const _BootstrapFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, _) => resolveNamuLocale(locales),
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F1E9),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }
}
