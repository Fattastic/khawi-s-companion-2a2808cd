import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/env/env.dart';
import 'analytics_service.dart';
import 'sentry_analytics_service.dart';

/// Provides the active [AnalyticsService] for the current environment.
///
/// Selection logic:
/// - **Debug mode** → [DebugAnalyticsService] (pretty-prints events to console)
/// - **Release + Sentry DSN set** → [SentryAnalyticsService] (events as breadcrumbs)
/// - **Release + no DSN** → [AnalyticsService.none] (silent no-op)
///
/// To add a second provider (e.g. PostHog or Firebase Analytics), create a
/// `CompositeAnalyticsService` that fans out to multiple [AnalyticsService]s
/// and return it here.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (kDebugMode) return const DebugAnalyticsService();
  if (Env.sentryDsn.isNotEmpty) return const SentryAnalyticsService();
  return AnalyticsService.none;
});
