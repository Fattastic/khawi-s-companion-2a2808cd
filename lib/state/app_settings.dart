import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khawi_flutter/models/user_role.dart';

const _kOnboardingDoneKey = 'khawi_onboarding_done';
const _kJuniorOnboardingDoneKey = 'khawi_junior_onboarding_done';
const _kLocaleKey = 'khawi_locale';
const _kLastRoleKey = 'khawi_last_role';
const _kThemeModeKey = 'khawi_theme_mode';

class OnboardingDoneNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDoneKey) ?? false;
  }

  Future<void> setDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, done);
    // Explicitly invalidate and re-rebuild to ensure strict O(1) consistency for the Router
    ref.invalidateSelf();
    await future; // Wait for the new state to load from storage
  }
}

final onboardingDoneProvider =
    AsyncNotifierProvider<OnboardingDoneNotifier, bool>(
  OnboardingDoneNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// JUNIOR ONBOARDING (Intro → Safety → Role flow)
// ─────────────────────────────────────────────────────────────────────────────

/// Tracks whether the junior user has completed the Intro → Safety → Role flow.
/// When false, juniors are sent to juniorIntro; when true, to juniorHub.
class JuniorOnboardingDoneNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kJuniorOnboardingDoneKey) ?? false;
  }

  Future<void> setDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kJuniorOnboardingDoneKey, done);
    ref.invalidateSelf();
    await future;
  }
}

final juniorOnboardingDoneProvider =
    AsyncNotifierProvider<JuniorOnboardingDoneNotifier, bool>(
  JuniorOnboardingDoneNotifier.new,
);

class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code == 'en' || code == 'ar') return Locale(code!);
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode;
    if (code != 'ar' && code != 'en') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, code);
    state = AsyncData(Locale(code));
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// POST-VERIFICATION REDIRECT
// ─────────────────────────────────────────────────────────────────────────────
/// Stores the intended destination route after verification completes.
/// Set this before navigating to /verification, then clear it after use.
/// Example: User tries to access driver QR → verification → resume to QR screen.
final pendingVerificationRedirectProvider =
    StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// ROLE SELECTION (PERSISTED ACROSS RESTARTS)
// ─────────────────────────────────────────────────────────────────────────────

/// Active role for the current session, hydrated from SharedPreferences
/// on cold start / hot-restart / web refresh.
///
/// `build()` watches [lastSelectedRoleProvider] so the role auto-loads
/// from durable storage as soon as SharedPreferences resolves (~<10 ms).
/// The 2-second splash timer ([splashWaitProvider]) guarantees hydration
/// finishes before gate 7 (role-required) is reached.
class ActiveRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() {
    // Always start with no active role so the user is sent to role selection
    // on every cold start. The persisted lastSelectedRole is intentionally
    // NOT restored here — role selection is required each session.
    return null;
  }

  void setRole(UserRole role) {
    state = role;
    // Persist to SharedPreferences for next cold start / page refresh.
    ref.read(lastSelectedRoleProvider.notifier).setLastRole(role);
  }

  void clear() {
    state = null;
    // Also clear the persisted role so the next session starts fresh.
    _clearPersistedRole();
  }

  Future<void> _clearPersistedRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastRoleKey);
    ref.invalidate(lastSelectedRoleProvider);
  }
}

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, UserRole?>(
  ActiveRoleNotifier.new,
);

/// Persisted storage of the last chosen role (suggestion only).
class LastSelectedRoleNotifier extends AsyncNotifier<UserRole?> {
  @override
  Future<UserRole?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_kLastRoleKey);
    if (val == null) return null;
    return UserRole.values.where((e) => e.name == val).firstOrNull;
  }

  Future<void> setLastRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastRoleKey, role.name);
    state = AsyncData(role);
  }
}

final lastSelectedRoleProvider =
    AsyncNotifierProvider<LastSelectedRoleNotifier, UserRole?>(
  LastSelectedRoleNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// THEME MODE (DARK / LIGHT / SYSTEM)
// ─────────────────────────────────────────────────────────────────────────────

/// Persisted theme mode preference.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_kThemeModeKey);
    return switch (val) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeModeKey, key);
    state = AsyncData(mode);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// ACCESSIBILITY
// ─────────────────────────────────────────────────────────────────────────────

const _kTextScaleKey = 'khawi_text_scale';
const _kReduceMotionKey = 'khawi_reduce_motion';
const _kHighContrastKey = 'khawi_high_contrast';

// ── Text Scale ───────────────────────────────────────────────────────────────

/// Multiplier applied to the system text scale factor.
/// Stored as an int index: 0 = Small (0.85×), 1 = Normal (1.0×), 2 = Large (1.15×), 3 = XL (1.3×).
class TextScaleNotifier extends AsyncNotifier<double> {
  static const _steps = [0.85, 1.0, 1.15, 1.3];

  @override
  Future<double> build() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_kTextScaleKey) ?? 1;
    return _steps[idx.clamp(0, _steps.length - 1)];
  }

  Future<void> setScale(double scale) async {
    final idx = _steps.indexOf(scale);
    if (idx < 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTextScaleKey, idx);
    state = AsyncData(scale);
  }

  static List<double> get steps => _steps;
}

final textScaleProvider = AsyncNotifierProvider<TextScaleNotifier, double>(
  TextScaleNotifier.new,
);

// ── Reduce Motion ────────────────────────────────────────────────────────────

class ReduceMotionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kReduceMotionKey) ?? false;
  }

  Future<void> setReduceMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceMotionKey, value);
    state = AsyncData(value);
  }
}

final reduceMotionProvider =
    AsyncNotifierProvider<ReduceMotionNotifier, bool>(ReduceMotionNotifier.new);

// ── High Contrast ────────────────────────────────────────────────────────────

class HighContrastNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHighContrastKey) ?? false;
  }

  Future<void> setHighContrast(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrastKey, value);
    state = AsyncData(value);
  }
}

final highContrastProvider =
    AsyncNotifierProvider<HighContrastNotifier, bool>(HighContrastNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// COMFORT PREFERENCES
// ─────────────────────────────────────────────────────────────────────────────

/// In-ride comfort preferences stored locally (passenger-facing).
class ComfortPrefs {
  final bool musicAllowed;
  final bool acRequired;
  final bool conversationOk;

  const ComfortPrefs({
    this.musicAllowed = true,
    this.acRequired = false,
    this.conversationOk = true,
  });

  ComfortPrefs copyWith({
    bool? musicAllowed,
    bool? acRequired,
    bool? conversationOk,
  }) =>
      ComfortPrefs(
        musicAllowed: musicAllowed ?? this.musicAllowed,
        acRequired: acRequired ?? this.acRequired,
        conversationOk: conversationOk ?? this.conversationOk,
      );
}

const _kComfortMusicKey = 'comfort_music';
const _kComfortAcKey = 'comfort_ac';
const _kComfortConvoKey = 'comfort_convo';

class ComfortPrefsNotifier extends AsyncNotifier<ComfortPrefs> {
  @override
  Future<ComfortPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ComfortPrefs(
      musicAllowed: prefs.getBool(_kComfortMusicKey) ?? true,
      acRequired: prefs.getBool(_kComfortAcKey) ?? false,
      conversationOk: prefs.getBool(_kComfortConvoKey) ?? true,
    );
  }

  Future<void> save(ComfortPrefs next) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_kComfortMusicKey, next.musicAllowed),
      prefs.setBool(_kComfortAcKey, next.acRequired),
      prefs.setBool(_kComfortConvoKey, next.conversationOk),
    ]);
    state = AsyncData(next);
  }
}

final comfortPrefsProvider =
    AsyncNotifierProvider<ComfortPrefsNotifier, ComfortPrefs>(
  ComfortPrefsNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION PREFERENCES
// ─────────────────────────────────────────────────────────────────────────────

class NotifPrefs {
  final bool tripUpdates;
  final bool chatMessages;
  final bool promotions;
  final bool reminders;

  const NotifPrefs({
    this.tripUpdates = true,
    this.chatMessages = true,
    this.promotions = false,
    this.reminders = true,
  });

  NotifPrefs copyWith({
    bool? tripUpdates,
    bool? chatMessages,
    bool? promotions,
    bool? reminders,
  }) =>
      NotifPrefs(
        tripUpdates: tripUpdates ?? this.tripUpdates,
        chatMessages: chatMessages ?? this.chatMessages,
        promotions: promotions ?? this.promotions,
        reminders: reminders ?? this.reminders,
      );
}

const _kNotifTripKey = 'notif_trips';
const _kNotifChatKey = 'notif_chat';
const _kNotifPromoKey = 'notif_promo';
const _kNotifReminderKey = 'notif_reminder';

class NotifPrefsNotifier extends AsyncNotifier<NotifPrefs> {
  @override
  Future<NotifPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotifPrefs(
      tripUpdates: prefs.getBool(_kNotifTripKey) ?? true,
      chatMessages: prefs.getBool(_kNotifChatKey) ?? true,
      promotions: prefs.getBool(_kNotifPromoKey) ?? false,
      reminders: prefs.getBool(_kNotifReminderKey) ?? true,
    );
  }

  Future<void> save(NotifPrefs next) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_kNotifTripKey, next.tripUpdates),
      prefs.setBool(_kNotifChatKey, next.chatMessages),
      prefs.setBool(_kNotifPromoKey, next.promotions),
      prefs.setBool(_kNotifReminderKey, next.reminders),
    ]);
    state = AsyncData(next);
  }
}

final notifPrefsProvider =
    AsyncNotifierProvider<NotifPrefsNotifier, NotifPrefs>(
  NotifPrefsNotifier.new,
);
