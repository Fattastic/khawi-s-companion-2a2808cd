import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/analytics/analytics_provider.dart';
import 'package:khawi_flutter/core/analytics/analytics_service.dart';
import 'package:khawi_flutter/features/auth/domain/social_provider.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Controller for Authentication related actions.
/// Uses [AsyncValue] to represent the state of the current operation (loading, error, data).
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is data(null)
    return;
  }

  /// Initiate OTP Login
  Future<void> signInWithOtp(String phone) async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics
        .track(AnalyticsEvent.loginInitiated, properties: {'method': 'otp'});
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepoProvider).signInWithOtp(phone: phone),
    );
    if (state.hasError) {
      await analytics
          .track(AnalyticsEvent.loginFailed, properties: {'method': 'otp'});
    }
  }

  /// Sign in Anonymously (Dev/Skip)
  Future<void> signInAnonymously() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.track(AnalyticsEvent.loginInitiated,
        properties: {'method': 'anonymous'},);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepoProvider).signInAnonymously(),
    );
  }

  /// Sign in with Social Provider
  Future<void> signInWithOAuth(
    SocialProvider provider, {
    String? redirectTo,
  }) async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.track(
      AnalyticsEvent.loginInitiated,
      properties: {'method': 'oauth', 'provider': provider.name},
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepoProvider).signInWithOAuth(
            provider,
            redirectTo: redirectTo,
          ),
    );
    if (state.hasError) {
      await analytics.track(
        AnalyticsEvent.loginFailed,
        properties: {'method': 'oauth', 'provider': provider.name},
      );
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);
