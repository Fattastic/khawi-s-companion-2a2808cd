import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/features/support/presentation/contact_support_sheet.dart';
import 'package:khawi_flutter/services/biometric_service.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/state/providers.dart';

// ── Local providers ──────────────────────────────────────────────────

/// Loads biometric availability + current opt-in state together.
final _biometricStateProvider =
    FutureProvider.autoDispose<({bool available, bool enabled})>((ref) async {
  final svc = ref.read(biometricServiceProvider);
  final available = await svc.isAvailable;
  final enabled = await svc.isEnabled;
  return (available: available, enabled: enabled);
});

/// Settings screen — §4.9 of the UX requirements.
///
/// Grouped sections:
///  1. Account
///  2. Ride Preferences
///  3. Notifications
///  4. Privacy
///  5. Accessibility
///  6. Subscription
///  7. Language
///  8. Help & Support
///  9. About
///  10. Danger zone (Sign Out / Delete Account)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Optimistically updated while the async toggle is in flight.
  bool? _biometricOverride;

  // ── Accessibility helpers ──────────────────────────────────────────────

  /// Text-scale steps exposed by [TextScaleNotifier].
  static const _scaleLabels = [
    ('S', 0.85),
    ('A', 1.0),
    ('A+', 1.15),
    ('A++', 1.3),
  ];

  void _showTextSizePicker(BuildContext ctx, bool isRtl, double current) {
    showModalBottomSheet<void>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'حجم الخط' : 'Text Size',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _scaleLabels.map((e) {
                final (label, scale) = e;
                final selected = (scale - current).abs() < 0.01;
                return GestureDetector(
                  onTap: () {
                    ref.read(textScaleProvider.notifier).setScale(scale);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryGreen
                            : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                isRtl
                    ? 'يُطبَّق فوراً على كل النصوص في التطبيق'
                    : 'Applied immediately across the entire app',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBiometric({
    required bool currentValue,
    required bool isRtl,
  }) async {
    final svc = ref.read(biometricServiceProvider);
    final targetValue = !currentValue;

    // Turning ON: require a successful biometric prompt first.
    if (targetValue) {
      final confirmed = await svc.authenticate(
        localizedReason: isRtl
            ? 'أكّد هويتك لتفعيل تسجيل الدخول بالبصمة'
            : 'Verify your identity to enable biometric login',
      );
      if (!confirmed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRtl
                    ? 'فشل التحقق — لم يتم تفعيل تسجيل الدخول بالبصمة'
                    : 'Verification failed — biometric login not enabled',
              ),
            ),
          );
        }
        return;
      }
    }

    // Optimistic update so the switch feels instant.
    setState(() => _biometricOverride = targetValue);
    await svc.setEnabled(enabled: targetValue);
    // Refresh the provider so future reads see the new value.
    ref.invalidate(_biometricStateProvider);
    setState(() => _biometricOverride = null);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = ref.watch(themeModeProvider).maybeWhen(
          data: (m) => m == ThemeMode.dark,
          orElse: () => false,
        );
    final bioState = ref.watch(_biometricStateProvider);
    final textScale = ref.watch(textScaleProvider).maybeWhen(
          data: (s) => s,
          orElse: () => 1.0,
        );
    final reduceMotion = ref.watch(reduceMotionProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );
    final highContrast = ref.watch(highContrastProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );

    final comfortPrefs = ref.watch(comfortPrefsProvider).maybeWhen(
          data: (p) => p,
          orElse: () => const ComfortPrefs(),
        );
    final notifPrefs = ref.watch(notifPrefsProvider).maybeWhen(
          data: (p) => p,
          orElse: () => const NotifPrefs(),
        );

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(isRtl ? 'الإعدادات' : 'Settings'),
        elevation: 0,
        // Back button navigates to prior step — never ejects to home (§1.2 back button contract).
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.passengerHome),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── 1. Account ───────────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'الحساب' : 'Account',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: isRtl ? 'المعلومات الشخصية' : 'Personal Information',
                  onTap: () => context.push(Routes.profileEnrichment),
                ),
                _SettingsTile(
                  icon: Icons.verified_outlined,
                  title: isRtl ? 'التحقق من الهوية' : 'Identity Verification',
                  onTap: () => context.push(Routes.verification),
                ),
                bioState.when(
                  loading: () => _SettingsTile(
                    icon: Icons.fingerprint,
                    title: isRtl ? 'تسجيل الدخول بالبصمة' : 'Biometric Login',
                    onTap: null,
                    trailing: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (state) {
                    if (!state.available) return const SizedBox.shrink();
                    final isOn = _biometricOverride ?? state.enabled;
                    return _SettingsTile(
                      icon: Icons.fingerprint,
                      title: isRtl ? 'تسجيل الدخول بالبصمة' : 'Biometric Login',
                      subtitle: isRtl
                          ? 'استخدم Face ID أو البصمة بدل الرقم السري'
                          : 'Use Face ID or fingerprint instead of OTP',
                      onTap: () => _toggleBiometric(
                        currentValue: isOn,
                        isRtl: isRtl,
                      ),
                      trailing: Switch(
                        value: isOn,
                        activeTrackColor: AppTheme.primaryGreen,
                        onChanged: (_) => _toggleBiometric(
                          currentValue: isOn,
                          isRtl: isRtl,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            index: 0,
          ),

          // ── 2. Ride Preferences ──────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'تفضيلات الرحلة' : 'Ride Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.tune,
                  title: isRtl ? 'إعدادات الراحة' : 'Comfort Settings',
                  subtitle: isRtl
                      ? 'موسيقى، تكييف، محادثة...'
                      : 'Music, AC, conversation...',
                  onTap: () => _showComfortSheet(context, isRtl, comfortPrefs),
                ),
              ],
            ),
            index: 1,
          ),

          // ── 3. Notifications ─────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'الإشعارات' : 'Notifications',
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: isRtl ? 'إعدادات الإشعارات' : 'Notification Settings',
                  subtitle: isRtl
                      ? 'تشغيل/إيقاف لكل فئة، وقت الهدوء'
                      : 'Per-category toggles, quiet hours',
                  onTap: () => _showNotifSheet(context, isRtl, notifPrefs),
                ),
              ],
            ),
            index: 2,
          ),

          // ── 4. Privacy ───────────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'الخصوصية' : 'Privacy',
              children: [
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: isRtl ? 'مشاركة الموقع' : 'Location Sharing',
                  onTap: () => _requestFeature(
                    context,
                    isRtl,
                    isRtl
                        ? 'تحكم في مشاركة الموقع'
                        : 'Location sharing controls',
                  ),
                ),
                _SettingsTile(
                  icon: Icons.visibility_outlined,
                  title: isRtl ? 'ظهور الملف الشخصي' : 'Profile Visibility',
                  onTap: () => _requestFeature(
                    context,
                    isRtl,
                    isRtl
                        ? 'خيارات ظهور الملف الشخصي'
                        : 'Profile visibility controls',
                  ),
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: isRtl ? 'تنزيل بياناتي' : 'Download My Data',
                  onTap: () => _requestFeature(
                    context,
                    isRtl,
                    isRtl ? 'تنزيل بياناتي' : 'Data export / download my data',
                  ),
                ),
              ],
            ),
            index: 3,
          ),

          // ── 5. Accessibility ─────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'سهولة الوصول' : 'Accessibility',
              children: [
                _SettingsTile(
                  icon: Icons.text_fields,
                  title: isRtl ? 'حجم الخط' : 'Text Size',
                  subtitle: _scaleLabels
                      .firstWhere(
                        (e) => (e.$2 - textScale).abs() < 0.01,
                        orElse: () => ('A', 1.0),
                      )
                      .$1,
                  onTap: () => _showTextSizePicker(context, isRtl, textScale),
                ),
                _SettingsTile(
                  icon: Icons.contrast,
                  title: isRtl ? 'تباين عالٍ' : 'High Contrast',
                  onTap: () => ref
                      .read(highContrastProvider.notifier)
                      .setHighContrast(!highContrast),
                  trailing: Switch(
                    value: highContrast,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (v) => ref
                        .read(highContrastProvider.notifier)
                        .setHighContrast(v),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.animation,
                  title: isRtl ? 'تقليل الحركة' : 'Reduce Motion',
                  onTap: () => ref
                      .read(reduceMotionProvider.notifier)
                      .setReduceMotion(!reduceMotion),
                  trailing: Switch(
                    value: reduceMotion,
                    activeTrackColor: AppTheme.primaryGreen,
                    onChanged: (v) => ref
                        .read(reduceMotionProvider.notifier)
                        .setReduceMotion(v),
                  ),
                ),
                // Dark Mode toggle (existing functionality, surfaced here)
                _DarkModeTile(isDark: isDark, isRtl: isRtl),
              ],
            ),
            index: 4,
          ),

          // ── 6. Subscription ──────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: 'Khawi+',
              children: [
                _SettingsTile(
                  icon: Icons.workspace_premium,
                  title: isRtl
                      ? 'حالة الاشتراك والمزايا'
                      : 'Subscription & Benefits',
                  onTap: () => context.push(Routes.subscription),
                ),
              ],
            ),
            index: 5,
          ),

          // ── 7. Language ──────────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'اللغة' : 'Language',
              children: [
                _LanguageTile(isRtl: isRtl),
              ],
            ),
            index: 5,
          ),

          // ── 8. Help & Support ────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'المساعدة والدعم' : 'Help & Support',
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: isRtl ? 'مركز المساعدة' : 'Help Center',
                  onTap: () => context.push(Routes.helpCenter),
                ),
                _SettingsTile(
                  icon: Icons.chat_outlined,
                  title: isRtl ? 'تحدث مع الدعم' : 'Chat with Support',
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const ContactSupportSheet(),
                  ),
                ),
              ],
            ),
            index: 5,
          ),

          // ── 9. About ─────────────────────────────────────────────────
          KhawiMotion.slideUpFadeIn(
            _SettingsGroup(
              label: isRtl ? 'حول التطبيق' : 'About',
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: isRtl ? 'حول خاوي' : 'About Khawi',
                  onTap: () => context.push(Routes.about),
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: isRtl ? 'الشروط والخصوصية' : 'Terms & Privacy Policy',
                  onTap: () async {
                    final uri = Uri.parse('https://khawi.app/terms-of-service');
                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isRtl
                                  ? 'تعذّر فتح الرابط'
                                  : 'Could not open link',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            index: 5,
          ),

          // ── 10. Danger Zone ──────────────────────────────────────────
          const SizedBox(height: 8),
          KhawiMotion.slideUpFadeIn(_DangerZone(isRtl: isRtl), index: 5),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Opens a pre-filled [ContactSupportSheet] to capture user intent for
  /// features that aren't built yet. Turns dead-end taps into actionable
  /// support tickets rather than silent "coming soon" snackbars.
  void _requestFeature(BuildContext ctx, bool isRtl, String featureName) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PrefilledSupportSheet(
        subject:
            isRtl ? 'طلب ميزة: $featureName' : 'Feature request: $featureName',
        body: isRtl
            ? 'أرغب في استخدام ميزة “$featureName”. يُرجى إبلاغي عند توفرها.'
            : 'I would like to use “$featureName”. Please notify me when it becomes available.',
      ),
    );
  }

  void _showComfortSheet(
    BuildContext ctx,
    bool isRtl,
    ComfortPrefs current,
  ) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ComfortSheet(initial: current, isRtl: isRtl),
    );
  }

  void _showNotifSheet(BuildContext ctx, bool isRtl, NotifPrefs current) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NotifSheet(initial: current, isRtl: isRtl),
    );
  }
}

// ── Group wrapper ─────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _SettingsGroup({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ── Tile variants ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final color = isDestructive ? AppTheme.error : AppTheme.primaryGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDestructive
                            ? AppTheme.error
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (!isDestructive)
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: AppTheme.textTertiary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkModeTile extends ConsumerWidget {
  final bool isDark;
  final bool isRtl;
  const _DarkModeTile({required this.isDark, required this.isRtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.dark_mode_outlined,
            color: AppTheme.primaryGreen,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isRtl ? 'الوضع الداكن' : 'Dark Mode',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: isDark,
            activeTrackColor: AppTheme.primaryGreen,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).setThemeMode(
                    v ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final bool isRtl;
  const _LanguageTile({required this.isRtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? 'اللغة' : 'Language',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isRtl ? 'العربية' : 'English',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Language switch — takes effect immediately, no restart required (§4.9)
          Switch(
            value: isRtl,
            activeTrackColor: AppTheme.primaryGreen,
            onChanged: (v) {
              ref.read(localeProvider.notifier).setLocale(
                    v ? const Locale('ar') : const Locale('en'),
                  );
            },
          ),
        ],
      ),
    );
  }
}

/// Danger-zone section with visual separation from safe actions (§4.9).
class _DangerZone extends ConsumerWidget {
  final bool isRtl;
  const _DangerZone({required this.isRtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.logout,
              title: isRtl ? 'تسجيل الخروج' : 'Sign Out',
              isDestructive: true,
              onTap: () => _confirmSignOut(context, ref, isRtl),
            ),
            Divider(height: 1, color: AppTheme.error.withValues(alpha: 0.15)),
            _SettingsTile(
              icon: Icons.delete_forever_outlined,
              title: isRtl ? 'حذف الحساب' : 'Delete Account',
              isDestructive: true,
              onTap: () => _confirmDelete(context, isRtl),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    bool isRtl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'تسجيل الخروج' : 'Sign Out'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
              : 'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isRtl ? 'خروج' : 'Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authRepoProvider).signOut();
    }
  }

  void _confirmDelete(BuildContext context, bool isRtl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRtl
              ? 'لحذف حسابك، تواصل مع الدعم'
              : 'To delete your account, contact support',
        ),
      ),
    );
  }
}

// ── Comfort Settings sheet ────────────────────────────────────────────────────

class _ComfortSheet extends ConsumerStatefulWidget {
  final ComfortPrefs initial;
  final bool isRtl;
  const _ComfortSheet({required this.initial, required this.isRtl});

  @override
  ConsumerState<_ComfortSheet> createState() => _ComfortSheetState();
}

class _ComfortSheetState extends ConsumerState<_ComfortSheet> {
  late ComfortPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  void _toggle(ComfortPrefs next) {
    setState(() => _prefs = next);
    ref.read(comfortPrefsProvider.notifier).save(next);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.isRtl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'إعدادات الراحة' : 'Comfort Settings',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl
                ? 'تُشارَك هذه التفضيلات مع السائق قبل بدء الرحلة'
                : 'These preferences are shared with your driver before the trip',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _PrefToggle(
            icon: Icons.music_note_outlined,
            label: isRtl ? 'موسيقى مسموح بها' : 'Music allowed',
            value: _prefs.musicAllowed,
            onChanged: (v) => _toggle(_prefs.copyWith(musicAllowed: v)),
          ),
          _PrefToggle(
            icon: Icons.ac_unit_outlined,
            label: isRtl ? 'تكييف مطلوب' : 'AC required',
            value: _prefs.acRequired,
            onChanged: (v) => _toggle(_prefs.copyWith(acRequired: v)),
          ),
          _PrefToggle(
            icon: Icons.chat_bubble_outline,
            label: isRtl ? 'محادثة مع السائق' : 'Conversation with driver',
            value: _prefs.conversationOk,
            onChanged: (v) => _toggle(_prefs.copyWith(conversationOk: v)),
          ),
        ],
      ),
    );
  }
}

// ── Notification Settings sheet ───────────────────────────────────────────────

class _NotifSheet extends ConsumerStatefulWidget {
  final NotifPrefs initial;
  final bool isRtl;
  const _NotifSheet({required this.initial, required this.isRtl});

  @override
  ConsumerState<_NotifSheet> createState() => _NotifSheetState();
}

class _NotifSheetState extends ConsumerState<_NotifSheet> {
  late NotifPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  void _toggle(NotifPrefs next) {
    setState(() => _prefs = next);
    ref.read(notifPrefsProvider.notifier).save(next);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.isRtl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'إعدادات الإشعارات' : 'Notification Settings',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _PrefToggle(
            icon: Icons.directions_car_outlined,
            label: isRtl ? 'تحديثات الرحلة' : 'Trip updates',
            value: _prefs.tripUpdates,
            onChanged: (v) => _toggle(_prefs.copyWith(tripUpdates: v)),
          ),
          _PrefToggle(
            icon: Icons.chat_outlined,
            label: isRtl ? 'رسائل المحادثة' : 'Chat messages',
            value: _prefs.chatMessages,
            onChanged: (v) => _toggle(_prefs.copyWith(chatMessages: v)),
          ),
          _PrefToggle(
            icon: Icons.local_offer_outlined,
            label: isRtl ? 'العروض والترقيات' : 'Promotions & offers',
            value: _prefs.promotions,
            onChanged: (v) => _toggle(_prefs.copyWith(promotions: v)),
          ),
          _PrefToggle(
            icon: Icons.alarm_outlined,
            label: isRtl ? 'تذكيرات الرحلة' : 'Trip reminders',
            value: _prefs.reminders,
            onChanged: (v) => _toggle(_prefs.copyWith(reminders: v)),
          ),
        ],
      ),
    );
  }
}

// ── Shared pref-toggle row ────────────────────────────────────────────────────

class _PrefToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PrefToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppTheme.primaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Pre-filled support-ticket sheet ──────────────────────────────────────────

/// Opens [ContactSupportSheet] with subject and body pre-filled so the user
/// can submit a feature request with one tap.
class _PrefilledSupportSheet extends ConsumerStatefulWidget {
  final String subject;
  final String body;
  const _PrefilledSupportSheet({required this.subject, required this.body});

  @override
  ConsumerState<_PrefilledSupportSheet> createState() =>
      _PrefilledSupportSheetState();
}

class _PrefilledSupportSheetState
    extends ConsumerState<_PrefilledSupportSheet> {
  bool _submitting = false;
  bool _submitted = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(supportRepoProvider).createTicket(
            subject: widget.subject,
            body: widget.body,
          );
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRtl
                  ? 'حدث خطأ — حاول مرة أخرى'
                  : 'Error submitting — please try again',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: _submitted ? _buildDone(isRtl) : _buildConfirm(isRtl),
      ),
    );
  }

  Widget _buildConfirm(bool isRtl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isRtl ? 'أبلغنا باهتمامك' : 'Express your interest',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          isRtl
              ? 'سنُبلغك عند إطلاق هذه الميزة'
              : "We'll notify you when this feature launches",
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Text(
            widget.subject,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isRtl ? 'أبلغني' : 'Notify me'),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(bool isRtl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.check_circle_outline,
          color: AppTheme.primaryGreen,
          size: 52,
        ),
        const SizedBox(height: 12),
        Text(
          isRtl ? 'تم التسجيل!' : 'Registered!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isRtl
              ? 'سنُخطرك عبر الإشعارات عند إطلاق الميزة.'
              : "You'll be notified when the feature launches.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
          child: Text(isRtl ? 'تم' : 'Done'),
        ),
      ],
    );
  }
}
