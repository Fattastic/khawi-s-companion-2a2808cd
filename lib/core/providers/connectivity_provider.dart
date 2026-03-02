import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Watches the device's network connectivity and exposes a bool:
/// `true`  = device is offline (no usable connection)
/// `false` = device has at least one network interface
final isOfflineProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  // Emit the initial state immediately
  final controller = StreamController<bool>();

  connectivity.checkConnectivity().then((results) {
    if (!controller.isClosed) {
      controller.add(_isOffline(results));
    }
  });

  // Then stream changes
  final sub = connectivity.onConnectivityChanged.listen((results) {
    if (!controller.isClosed) {
      controller.add(_isOffline(results));
    }
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

bool _isOffline(List<ConnectivityResult> results) {
  return results.isEmpty || results.every((r) => r == ConnectivityResult.none);
}
