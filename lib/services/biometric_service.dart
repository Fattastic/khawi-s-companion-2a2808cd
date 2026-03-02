import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Provider ──────────────────────────────────────────────────────────────

/// Singleton provider — use `ref.watch(biometricServiceProvider)` instead of
/// constructing `BiometricService` directly so the instance is mockable in tests.
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(LocalAuthentication()),
);

/// Service for biometric (Face ID / fingerprint) authentication.
///
/// UX contract (§2.1 / FT-16):
///  - Returning users authenticate with one tap after the OS biometric prompt.
///  - Falls back to OTP if biometric is unavailable or fails.
///  - Biometric opt-in is persisted — user is not asked every launch.
class BiometricService {
  BiometricService(this._auth);

  final LocalAuthentication _auth;

  static const _kBiometricEnabledKey = 'biometric_auth_enabled';

  /// In-memory cache so `isEnabled` doesn't hit SharedPreferences on every
  /// build-cycle call.  Invalidated by [setEnabled].
  bool? _enabledCache;

  // ── Capability ──────────────────────────────────────────────────────────

  /// Whether the device supports and has enrolled biometrics.
  /// Runs both checks in parallel for minimal latency.
  Future<bool> get isAvailable async {
    try {
      final results = await Future.wait([
        _auth.canCheckBiometrics,
        _auth.isDeviceSupported(),
      ]);
      return results[0] && results[1];
    } catch (_) {
      // Catches PlatformException AND MissingPluginException (test/desktop).
      return false;
    }
  }

  /// Returns a human-readable label for the best available biometric type.
  Future<String> get biometricLabel async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return 'Face ID';
      if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (types.contains(BiometricType.iris)) return 'Iris';
      return 'Biometric';
    } catch (_) {
      return 'Biometric';
    }
  }

  // ── Preference ───────────────────────────────────────────────────────────

  /// Whether the user has opted in to biometric login.
  /// Result is cached in memory after the first read.
  Future<bool> get isEnabled async {
    if (_enabledCache != null) return _enabledCache!;
    final prefs = await SharedPreferences.getInstance();
    _enabledCache = prefs.getBool(_kBiometricEnabledKey) ?? false;
    return _enabledCache!;
  }

  /// Persist the user's opt-in/out preference and update the in-memory cache.
  Future<void> setEnabled({required bool enabled}) async {
    _enabledCache = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, enabled);
  }

  // ── Authentication ───────────────────────────────────────────────────────

  /// Attempt biometric authentication.
  ///
  /// [localizedReason] should be the UI-language string; pass both Arabic and
  /// English from the call site (see [LoginScreen._handleBiometricLogin]).
  ///
  /// Returns `true` on success, `false` on failure/cancellation.
  /// The caller should fall back to OTP on `false`.
  Future<bool> authenticate({String? localizedReason}) async {
    try {
      return await _auth.authenticate(
        // Default covers the case where the caller omits a reason entirely.
        localizedReason: localizedReason ??
            'أكّد هويتك للمتابعة / Confirm your identity to continue',
        options: const AuthenticationOptions(
          biometricOnly: true, // Biometric-only — no PIN fallback (prevents
          // silent bypass when the user cancels Face ID).
          stickyAuth: true, // Keep prompt if app goes to background.
        ),
      );
    } catch (_) {
      // Catches PlatformException AND MissingPluginException.
      return false;
    }
  }
}
