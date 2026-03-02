import 'package:flutter/foundation.dart';

/// Typed analytics events tracked across the app.
///
/// Add new events here — never use raw strings in call sites.
enum AnalyticsEvent {
  appOpen,
  loginInitiated,
  loginSuccess,
  loginFailed,
  loggedOut,
  roleSelected,
  tripBooked,
  tripCancelled,
  qrScanned,
  notificationTapped,
  profileUpdated,
  subscriptionViewed,
  subscriptionPurchased,
  emergencyContactAdded,
  ratingSubmitted,
}

/// Abstract analytics service.
///
/// Implement this to swap analytics providers without touching call sites:
///
/// ```dart
/// // Future PostHog implementation:
/// class PostHogAnalyticsService extends AnalyticsService { ... }
///
/// // Future Firebase implementation:
/// class FirebaseAnalyticsService extends AnalyticsService { ... }
/// ```
abstract class AnalyticsService {
  const AnalyticsService();

  /// Track a user-action event with optional properties.
  Future<void> track(AnalyticsEvent event, {Map<String, Object?>? properties});

  /// Identify the current user (call after login).
  Future<void> identify({required String userId, Map<String, Object?>? traits});

  /// Clear user identity (call on logout).
  Future<void> reset();

  /// Log a named screen view.
  Future<void> screen(String screenName, {Map<String, Object?>? properties});

  /// A no-op service — safe default when no provider is configured.
  static const AnalyticsService none = _NoOpAnalyticsService();
}

// ─────────────────────────────────────────────────────────────────────────────
// Debug implementation — logs to the Flutter console
// ─────────────────────────────────────────────────────────────────────────────

/// Development implementation that prints structured analytics events to the
/// debug console. Useful for verifying event wiring during development.
class DebugAnalyticsService extends AnalyticsService {
  const DebugAnalyticsService();

  static const _tag = '[Analytics]';

  @override
  Future<void> track(
    AnalyticsEvent event, {
    Map<String, Object?>? properties,
  }) async {
    final props = properties?.isNotEmpty == true ? ' $properties' : '';
    debugPrint('$_tag track: ${event.name}$props');
  }

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object?>? traits,
  }) async {
    final t = traits?.isNotEmpty == true ? ' $traits' : '';
    debugPrint('$_tag identify: $userId$t');
  }

  @override
  Future<void> reset() async {
    debugPrint('$_tag reset');
  }

  @override
  Future<void> screen(
    String screenName, {
    Map<String, Object?>? properties,
  }) async {
    final props = properties?.isNotEmpty == true ? ' $properties' : '';
    debugPrint('$_tag screen: $screenName$props');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No-op implementation
// ─────────────────────────────────────────────────────────────────────────────

class _NoOpAnalyticsService extends AnalyticsService {
  const _NoOpAnalyticsService();

  @override
  Future<void> track(AnalyticsEvent _,
      {Map<String, Object?>? properties,}) async {}

  @override
  Future<void> identify(
      {required String userId, Map<String, Object?>? traits,}) async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> screen(String _, {Map<String, Object?>? properties}) async {}
}
