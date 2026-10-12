import 'dart:async';

import '../application/daily_close_coordinator.dart';

final class DartDailyCloseTimerScheduler implements DailyCloseTimerScheduler {
  const DartDailyCloseTimerScheduler();

  @override
  DailyCloseTimer schedule(Duration delay, Future<void> Function() callback) {
    return _DartDailyCloseTimer(
      Timer(delay, () {
        unawaited(callback());
      }),
    );
  }
}

final class _DartDailyCloseTimer implements DailyCloseTimer {
  const _DartDailyCloseTimer(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
