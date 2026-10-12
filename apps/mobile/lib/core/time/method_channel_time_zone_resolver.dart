import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

import 'time_zone_resolver.dart';
import 'time_zone_snapshot.dart';

final class MethodChannelTimeZoneResolver implements TimeZoneResolver {
  MethodChannelTimeZoneResolver() : _channel = const MethodChannel(channelName);

  @visibleForTesting
  MethodChannelTimeZoneResolver.withChannel(this._channel);

  static const String channelName = 'namu/time_zone';
  static const String idMethod = 'getTimeZoneId';

  static bool _databaseInitialized = false;

  final MethodChannel _channel;
  time_zone.Location? _location;
  Future<void>? _activeRefresh;

  @override
  Future<void> initialize() {
    if (_location != null) {
      return Future<void>.value();
    }
    return _refreshOnceAtATime();
  }

  @override
  Future<void> refresh() => _refreshOnceAtATime();

  @override
  TimeZoneSnapshot snapshotAt(DateTime instantUtc) {
    _requireUtc(instantUtc);
    final location = _location;
    if (location == null) {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.notInitialized,
      );
    }

    final localInstant = time_zone.TZDateTime.from(instantUtc, location);
    return TimeZoneSnapshot(
      timeZoneId: location.name,
      utcOffset: localInstant.timeZoneOffset,
    );
  }

  Future<void> _refreshOnceAtATime() {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) {
      return activeRefresh;
    }

    late final Future<void> refresh;
    refresh = _loadNativeTimeZone().whenComplete(() {
      if (identical(_activeRefresh, refresh)) {
        _activeRefresh = null;
      }
    });
    _activeRefresh = refresh;
    return refresh;
  }

  Future<void> _loadNativeTimeZone() async {
    final Object? channelResult;
    try {
      channelResult = await _channel.invokeMethod<Object?>(idMethod);
    } on MissingPluginException {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.platformFailure,
      );
    } on PlatformException {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.platformFailure,
      );
    }

    if (channelResult is! String ||
        channelResult.isEmpty ||
        channelResult != channelResult.trim() ||
        channelResult.length > 128) {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.invalidIdentifier,
      );
    }

    try {
      _ensureTimeZoneDatabase();
      // Assign only after validation so a failed foreground refresh keeps the
      // last internally consistent ID/rule pair available to the schedule.
      final location = time_zone.getLocation(channelResult);
      _location = location;
    } on time_zone.LocationNotFoundException {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.invalidIdentifier,
      );
    } on time_zone.TimeZoneInitException {
      throw const TimeZoneResolverException(
        TimeZoneResolverFailureReason.rulesUnavailable,
      );
    }
  }

  static void _ensureTimeZoneDatabase() {
    if (_databaseInitialized) {
      return;
    }
    time_zone_data.initializeTimeZones();
    _databaseInitialized = true;
  }

  static void _requireUtc(DateTime instantUtc) {
    if (!instantUtc.isUtc) {
      throw ArgumentError.value(instantUtc, 'instantUtc', 'must be in UTC');
    }
  }
}

TimeZoneResolver createPlatformTimeZoneResolver() {
  if (kIsWeb) {
    return WebPreviewTimeZoneResolver();
  }
  return MethodChannelTimeZoneResolver();
}
