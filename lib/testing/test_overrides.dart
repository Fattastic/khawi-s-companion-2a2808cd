import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/models/user_role.dart';

class TestOverrides {
  static const bool enabled =
      bool.fromEnvironment('TEST_MODE', defaultValue: false);

  static const String? initialLocation =
      bool.hasEnvironment('TEST_INITIAL_LOCATION')
          ? String.fromEnvironment('TEST_INITIAL_LOCATION')
          : null;
  static const String? testRole = bool.hasEnvironment('TEST_ROLE')
      ? String.fromEnvironment('TEST_ROLE')
      : null; // "passenger" | "driver" | "junior"
  static const bool? isAuthed = bool.hasEnvironment('TEST_AUTHED')
      ? bool.fromEnvironment('TEST_AUTHED')
      : null;
  static const bool? onboardingDone =
      bool.hasEnvironment('TEST_ONBOARDING_DONE')
          ? bool.fromEnvironment('TEST_ONBOARDING_DONE')
          : null;
  static const bool? profileComplete =
      bool.hasEnvironment('TEST_PROFILE_COMPLETE')
          ? bool.fromEnvironment('TEST_PROFILE_COMPLETE')
          : null;
  static const bool? isVerified = bool.hasEnvironment('TEST_IS_VERIFIED')
      ? bool.fromEnvironment('TEST_IS_VERIFIED')
      : null;
  static const bool? isPremium = bool.hasEnvironment('TEST_IS_PREMIUM')
      ? bool.fromEnvironment('TEST_IS_PREMIUM')
      : null;
}

class MockOnboardingNotifier extends OnboardingDoneNotifier {
  final bool initialValue;
  MockOnboardingNotifier(this.initialValue);
  @override
  Future<bool> build() async => initialValue;
}

class MockActiveRoleNotifier extends ActiveRoleNotifier {
  final UserRole? initialValue;
  MockActiveRoleNotifier(this.initialValue);
  @override
  UserRole? build() => initialValue;
}

class MockLastSelectedRoleNotifier extends LastSelectedRoleNotifier {
  final UserRole? initialValue;
  MockLastSelectedRoleNotifier(this.initialValue);
  @override
  Future<UserRole?> build() async => initialValue;
}
