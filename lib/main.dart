import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/analytics/analytics_service.dart';

import 'app/app.dart';
import 'core/env/env.dart';
import 'package:khawi_flutter/core/backend/schema_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:khawi_flutter/features/error/presentation/fatal_error_app.dart';
import 'package:khawi_flutter/testing/test_overrides.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/models/user_role.dart';

void main() {
  // Sentry wraps runZonedGuarded internally when a DSN is provided.
  // When the DSN is empty, it falls back to a plain runZonedGuarded.
  if (Env.sentryDsn.isNotEmpty) {
    SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
        options.release = '0.1.0+1'; // keep in sync with pubspec.yaml
        options.dist = '1'; // build number
        options.environment = kReleaseMode ? 'production' : 'development';
        options.tracesSampleRate = kReleaseMode ? 0.2 : 0.0;
        options.attachScreenshot = true; // attach screenshot to crash reports
        options.attachViewHierarchy =
            true; // attach widget tree to crash reports
        options.sendDefaultPii = false; // GDPR: no IP / email without consent
        options.enableAutoSessionTracking = true;
      },
      appRunner: () => runZonedGuarded<Future<void>>(
        () async => _initAndRunApp(),
        (error, stackTrace) {
          if (kDebugMode) {
            debugPrint('=== UNCAUGHT ASYNC ERROR === $error');
          }
          Sentry.captureException(error, stackTrace: stackTrace);
        },
      ),
    );
  } else {
    // No Sentry DSN — run with local-only error logging
    runZonedGuarded<Future<void>>(
      () async {
        await _initAndRunApp();
      },
      (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('=== UNCAUGHT ASYNC ERROR ===');
          debugPrint('Error: $error');
          debugPrint('Stack: $stackTrace');
        }
      },
    );
  }
}

Future<void> _initAndRunApp() async {
  // Keep native splash visible until we finish initialising
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  GoogleFonts.config.allowRuntimeFetching = false;

  // Catch Flutter framework errors (rendering, gestures etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); // keep default red-screen in debug
    if (kDebugMode) {
      debugPrint('=== FLUTTER ERROR ===');
      debugPrint(details.exceptionAsString());
      debugPrint(details.stack.toString());
    }
    if (Env.sentryDsn.isNotEmpty) {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  };

  // Catch platform-dispatcher errors (e.g. unhandled Future errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('=== PLATFORM DISPATCHER ERROR ===');
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    }
    if (Env.sentryDsn.isNotEmpty) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true; // handled
  };

  try {
    if (kDebugMode) {
      debugPrint('Initializing Supabase...');
    }
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    ).timeout(
      const Duration(seconds: 15),
    );
    if (kDebugMode) {
      debugPrint('Supabase initialized successfully.');
    }

    // Sync Sentry user scope whenever auth state changes.
    // This makes every crash report searchable by user ID.
    if (Env.sentryDsn.isNotEmpty) {
      Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
        final user = event.session?.user;
        if (user != null) {
          await Sentry.configureScope((scope) {
            scope.setUser(SentryUser(id: user.id));
          });
          await Sentry.addBreadcrumb(
            Breadcrumb(
              category: 'analytics',
              message: AnalyticsEvent.loginSuccess.name,
              type: 'user',
              level: SentryLevel.info,
              data: {'provider': event.event.name},
            ),
          );
        } else {
          // User signed out
          await Sentry.configureScope((scope) => scope.setUser(null));
          await Sentry.addBreadcrumb(
            Breadcrumb(
              category: 'analytics',
              message: AnalyticsEvent.loggedOut.name,
              type: 'user',
              level: SentryLevel.info,
            ),
          );
        }
      });
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to initialize Supabase: $e');
    }
    runApp(
      FatalErrorApp(
        error: e,
        onRetry: () {
          // Restart the app from main
          main();
        },
      ),
    );
    return;
  }

  // In debug mode, run schema guard after any successful login to detect DB drift.
  if (kDebugMode) {
    // We can safely access instance here because we are past the try-catch block
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null) {
        try {
          final errors = await performSchemaGuard(Supabase.instance.client);
          if (errors.isNotEmpty) {
            for (final e in errors) {
              debugPrint('SchemaGuard: $e');
            }
          } else {
            debugPrint('SchemaGuard: all tables match expected columns');
          }
        } catch (e) {
          debugPrint('SchemaGuard failed: $e');
        }
      }
    });
  }

  // Dismiss native splash — app is ready to render
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: TestOverrides.enabled
          ? [
              if (TestOverrides.onboardingDone != null)
                onboardingDoneProvider.overrideWith(
                  () => MockOnboardingNotifier(TestOverrides.onboardingDone!),
                ),
              if (TestOverrides.isAuthed != null)
                authSessionProvider.overrideWith(
                  (ref) => Stream.value(
                    TestOverrides.isAuthed!
                        ? Session(
                            accessToken: 'test_token',
                            tokenType: 'bearer',
                            user: User(
                              id: 'test_user',
                              appMetadata: const {},
                              userMetadata: const {},
                              aud: 'authenticated',
                              createdAt: DateTime.now().toIso8601String(),
                            ),
                          )
                        : null,
                  ),
                ),
              if (TestOverrides.testRole != null)
                activeRoleProvider.overrideWith(
                  () => MockActiveRoleNotifier(
                    UserRole.values.firstWhere(
                      (r) => r.name == TestOverrides.testRole,
                      orElse: () => UserRole.passenger,
                    ),
                  ),
                ),
            ]
          : [],
      child: const KhawiApp(),
    ),
  );
}
