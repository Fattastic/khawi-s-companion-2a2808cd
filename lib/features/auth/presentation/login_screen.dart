import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/features/auth/domain/social_provider.dart';
import 'package:khawi_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/motion/motion_tokens.dart';
import 'package:khawi_flutter/core/widgets/khawi_button.dart';
import 'package:khawi_flutter/core/widgets/app_text_field.dart';
import 'package:khawi_flutter/core/validation/validators.dart';
import 'package:khawi_flutter/services/biometric_service.dart';
import 'package:khawi_flutter/state/app_settings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final svc = ref.read(biometricServiceProvider);
    final available = await svc.isAvailable;
    final enabled = await svc.isEnabled;
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _biometricLoading = true);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final authenticated = await ref.read(biometricServiceProvider).authenticate(
          localizedReason: isRtl
              ? 'تحقق من هويتك لتسجيل الدخول'
              : 'Verify your identity to sign in',
        );
    setState(() => _biometricLoading = false);

    if (!mounted) return;
    if (authenticated) {
      // Biometric confirmed — re-enter app through splash so router
      // redirects to the correct role screen.
      context.go(Routes.splash);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl
                ? 'فشل التحقق — أدخل رقم هاتفك بدلاً من ذلك'
                : 'Biometric failed — use your phone number instead',
          ),
        ),
      );
    }
  }

  // Helper to parse auth errors into user-friendly messages
  String? _authHelpForError(Object? error) {
    if (error == null) return null;
    final msg = error.toString();
    final lower = msg.toLowerCase();

    if (lower.contains('unsupported provider') ||
        lower.contains('provider is not enabled') ||
        (lower.contains('validation_failed') && lower.contains('provider'))) {
      return 'This provider is not enabled on Supabase.\n'
          '- Local: edit supabase/config.toml (enable provider) then run supabase stop; supabase start.\n'
          '- Hosted: Supabase Dashboard → Authentication → Providers.';
    }

    if (lower.contains('anonymous') && lower.contains('disabled')) {
      return 'Anonymous sign-in is disabled on Supabase.\n'
          '- Local: set auth.enable_anonymous_sign_ins=true in supabase/config.toml, then restart Supabase.\n'
          '- Hosted: Supabase Dashboard → Authentication → Providers → Anonymous.';
    }

    if (lower.contains('google') &&
        (lower.contains('client_id') ||
            lower.contains('secret') ||
            lower.contains('oauth'))) {
      return 'Google OAuth is enabled but not configured.\n'
          'Set SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID and SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET, then restart Supabase.';
    }

    return msg;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final validationError = PhoneValidator.validatePhone(phone);
    if (validationError != null) {
      // Local check, no need for controller
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.phoneInvalidError ?? validationError,
          ),
        ),
      );
      return;
    }

    final normalized = PhoneValidator.normalize(phone);

    // Call controller
    await ref.read(authControllerProvider.notifier).signInWithOtp(normalized);

    // Check result
    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (!state.hasError) {
        context.go(Routes.authEmail, extra: phone);
      }
    }
  }

  Future<void> _handleDevLogin() async {
    await ref.read(authControllerProvider.notifier).signInAnonymously();

    if (mounted) {
      final state = ref.read(authControllerProvider);
      if (!state.hasError) {
        // Always re-enter through splash so centralized redirect enforces:
        // Profile -> Role -> Verification (if needed) without flashes/loops.
        context.go(Routes.splash);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    // Google Sign-In is now supported on native via Deep Links (io.supabase.khawi)

    // Note: This requires the SHA-1 fingerprint to be added to Google Cloud Console
    // and the redirect URL to be allowed in Supabase.

    String? redirectTo;
    if (kIsWeb) {
      redirectTo = '${Uri.base.origin}/auth/callback';
    } else if (Platform.isAndroid || Platform.isIOS) {
      redirectTo = 'io.supabase.khawi://login-callback';
    } else {
      // Desktop (Windows/Mac/Linux) uses local server, so redirectTo should be null
      redirectTo = null;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signInWithOAuth(SocialProvider.google, redirectTo: redirectTo);
    // OAuth redirects away, so no navigation needed on success usually
  }

  void _handleEmailLogin() {
    if (!mounted) return;
    context.go(Routes.authEmail);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = _authHelpForError(authState.error);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              KhawiMotion.slideUpFadeIn(
                index: 0,
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.loginTitle ?? 'Login',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)?.loginSubtitle ??
                            'Enter your phone number to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: KhawiMotion.slideUpFadeIn(
                  index: 2,
                  duration: MotionTokens.t4,
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.shadowMedium, // Consistent shadow
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppTextField(
                            label: AppLocalizations.of(context)?.phoneNumber ??
                                'Phone Number',
                            controller: _phoneController,
                            hint: '+966...',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            onSubmitted: (_) => _handleLogin(),
                            prefixIcon: const Icon(Icons.phone),
                            errorText: errorMessage,
                          ),

                          const SizedBox(height: 24), // Increased spacing

                          ShimmerEffect(
                            repeatCount: 1,
                            child: KhawiButton(
                              text: AppLocalizations.of(context)
                                      ?.continueAction ??
                                  'Continue',
                              onPressed: isLoading ? null : _handleLogin,
                              isLoading: isLoading,
                              isFullWidth: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              KhawiMotion.scaleIn(
                                duration: MotionTokens.t3,
                                curve: MotionTokens.entrance,
                                startScale: 0.85,
                                _buildSocialButton(
                                  icon: Icons.g_mobiledata,
                                  color: Colors.red,
                                  onTap: _handleGoogleLogin,
                                  tooltip: 'Google Sign-In',
                                ),
                              ),
                              const SizedBox(width: 14),
                              KhawiMotion.scaleIn(
                                duration: MotionTokens.t3,
                                curve: MotionTokens.entrance,
                                startScale: 0.85,
                                _buildSocialButton(
                                  icon: Icons.email_outlined,
                                  color: Colors.blue,
                                  onTap: _handleEmailLogin,
                                  tooltip: 'Email Sign-In',
                                ),
                              ),
                              if (kDebugMode) const SizedBox(width: 14),
                              if (kDebugMode)
                                KhawiMotion.scaleIn(
                                  duration: MotionTokens.t3,
                                  curve: MotionTokens.entrance,
                                  startScale: 0.85,
                                  _buildSocialButton(
                                    icon: Icons.developer_mode,
                                    color: Colors.grey,
                                    onTap: _handleDevLogin,
                                    tooltip: 'Dev Bypass (Anonymous)',
                                  ),
                                ),
                            ],
                          ),
                          // ── Biometric login button ──────────────────────
                          if (_biometricAvailable && _biometricEnabled) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            KhawiButton.outline(
                              text: Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? 'تسجيل الدخول ببصمتك'
                                  : 'Sign in with Biometrics',
                              onPressed: _biometricLoading
                                  ? null
                                  : _handleBiometricLogin,
                              isLoading: _biometricLoading,
                              isFullWidth: true,
                              icon: Icons.fingerprint,
                            ),
                          ],
                          const SizedBox(height: 8),
                          if (kDebugMode) const SizedBox(height: 16),
                          if (kDebugMode)
                            KhawiButton.text(
                              text: 'DEBUG: Reset Onboarding',
                              onPressed: () async {
                                await ref
                                    .read(onboardingDoneProvider.notifier)
                                    .setDone(false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Onboarding reset!'),
                                    ),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Tooltip(
        message: tooltip ?? "",
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
