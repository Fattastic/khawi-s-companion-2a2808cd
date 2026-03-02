import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

FutureOr<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  // Mock connectivity_plus so SlowNetworkBanner doesn't throw
  // MissingPluginException in the test environment.
  _mockConnectivityPlugin();

  try {
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      anonKey: 'fakeAnonKey',
    );
  } catch (e) {
    // Already initialized or other non-fatal error in test environment
  }

  await testMain();
}

/// Installs a fake method channel handler for connectivity_plus.
/// Uses the raw binary messenger so it can be called outside of a test body.
void _mockConnectivityPlugin() {
  const methodChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );

  // checkConnectivity and any other method calls return ["wifi"].
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
    return ['wifi'];
  });

  // The EventChannel sends listen/cancel as method calls on a separate channel.
  // Intercept them so the platform stream never throws.
  const eventMethodChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity_status',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(eventMethodChannel, (MethodCall call) async {
    // Silently handle "listen" and "cancel" — no events emitted.
    return null;
  });
}
