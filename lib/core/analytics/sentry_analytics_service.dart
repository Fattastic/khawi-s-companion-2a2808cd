import 'package:sentry_flutter/sentry_flutter.dart';

import 'analytics_service.dart';

/// Analytics service backed by Sentry breadcrumbs + user scope.
///
/// Benefits:
/// - Every tracked event appears in Sentry's **Breadcrumbs** panel for each
///   issue, giving engineers context on what the user did before a crash.
/// - [identify] sets the Sentry user scope so issues are searchable by user ID.
/// - [screen] records navigation as `navigation` breadcrumbs (in addition to
///   the automatic [SentryNavigatorObserver] navigation tracking).
///
/// This implementation is automatically used in release builds when a Sentry
/// DSN is present. See [analyticsServiceProvider].
class SentryAnalyticsService extends AnalyticsService {
  const SentryAnalyticsService();

  @override
  Future<void> track(
    AnalyticsEvent event, {
    Map<String, Object?>? properties,
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'analytics',
        message: event.name,
        data: _stringify(properties),
        type: 'user',
        level: SentryLevel.info,
      ),
    );
  }

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?>? traits,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(
        SentryUser(
          id: userId,
          data: _stringify(traits),
        ),
      );
    });
  }

  @override
  Future<void> reset() async {
    await Sentry.configureScope((scope) => scope.setUser(null));
  }

  @override
  Future<void> screen(
    String screenName, {
    Map<String, Object?>? properties,
  }) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        message: screenName,
        data: _stringify(properties),
        type: 'navigation',
        level: SentryLevel.info,
      ),
    );
  }

  /// Converts nullable object values to strings so Sentry can serialize them.
  static Map<String, String>? _stringify(Map<String, Object?>? map) {
    if (map == null || map.isEmpty) return null;
    return map.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }
}
