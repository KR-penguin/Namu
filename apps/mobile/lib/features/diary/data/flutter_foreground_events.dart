import 'dart:async';

import 'package:flutter/widgets.dart';

/// Converts Flutter lifecycle callbacks into the injected foreground stream.
final class FlutterForegroundEvents with WidgetsBindingObserver {
  FlutterForegroundEvents({WidgetsBinding? binding})
    : _binding = binding ?? WidgetsBinding.instance {
    _binding.addObserver(this);
  }

  final WidgetsBinding _binding;
  final StreamController<void> _controller = StreamController<void>.broadcast(
    sync: true,
  );
  bool _isDisposed = false;

  Stream<void> get stream => _controller.stream;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isDisposed && state == AppLifecycleState.resumed) {
      _controller.add(null);
    }
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _binding.removeObserver(this);
    unawaited(_controller.close());
  }
}
