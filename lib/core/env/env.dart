class Env {
  Env._();

  // ─────────────────────────────────────────────
  // Supabase (HARDCODED - CLOUD)
  // ─────────────────────────────────────────────

  static const String supabaseUrl = 'https://oxcustajfzeqibnkjthp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94Y3VzdGFqZnplcWlibmtqdGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MzMzODEsImV4cCI6MjA4NTAwOTM4MX0.lyBeIVup_PBw4goIgt82C8O3I2eeDVVXTodx1JgLprU';

  // ─────────────────────────────────────────────
  // Google OAuth (HARDCODED)
  // Note: To work on native Android, the SHA-1 fingerprint of your keystore
  // MUST be added to the Google Cloud Console credential for this Client ID.
  // ─────────────────────────────────────────────

  /// Google OAuth Client ID
  static const String googleOAuthClientId =
      '129754711874-3mjqg3b9jdqff9f65mensv7u0maila8e.apps.googleusercontent.com';

  /// Google OAuth Client Secret
  static const String googleOAuthClientSecret =
      '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';

  static bool get hasGoogleOAuth => googleOAuthClientId.isNotEmpty;

  // ─────────────────────────────────────────────
  // Google Maps (HARDCODED)
  // ─────────────────────────────────────────────

  static const String googleMapsKey = '';

  // ─────────────────────────────────────────────
  // Sentry (Crash Reporting)
  // Set this to your Sentry DSN from https://sentry.io
  // Leave empty to disable crash reporting.
  // ─────────────────────────────────────────────
  static const String sentryDsn = '';
}

/// Fail-fast instead of silent misconfig
class MissingEnvException implements Exception {
  final String message;
  const MissingEnvException(this.message);

  @override
  String toString() => 'MissingEnvException: $message';
}
