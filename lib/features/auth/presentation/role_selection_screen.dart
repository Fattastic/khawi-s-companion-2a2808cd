import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/analytics/analytics_provider.dart';
import 'package:khawi_flutter/core/analytics/analytics_service.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/responsive_container.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/state/providers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _showAllRoles = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(l10n?.chooseYourRoleTitle ?? 'Choose your role'),
        backgroundColor: AppTheme.backgroundGreen,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n?.errorWithMessage('$err') ?? 'Error: $err',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => ref.invalidate(myProfileProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n?.retry ?? 'Retry'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authRepoProvider).signOut();
                    },
                    child: Text(l10n?.logout ?? 'Logout'),
                  ),
                ],
              ),
            ),
          ),
          data: (profile) => ResponsiveContainer(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KhawiMotion.slideUpFadeIn(
                        index: 0,
                        Text(
                          l10n?.roleSelectionWelcomeTitle ??
                              'Welcome! Choose how you want to use Khawi',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.roleSelectionSubtitle ??
                            'You can change your role later from your profile.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: KhawiMotion.scaleIn(
                          _buildQuickRideButton(context, profile),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildRoleSelectionBody(context, profile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionBody(BuildContext context, Profile profile) {
    final l10n = AppLocalizations.of(context);
    final lastRoleAsync = ref.watch(lastSelectedRoleProvider);
    final lastRole = lastRoleAsync.valueOrNull;

    final showAll = _showAllRoles || lastRole == null;

    if (showAll) {
      return Column(
        children: [
          KhawiMotion.slideUpFadeIn(
            _RoleCard(
              title: l10n?.iAmAPassenger ?? 'Passenger',
              subtitle:
                  l10n?.passengerDescription ?? "Joining a driver's route",
              icon: Icons.person_outline,
              onTap: () =>
                  _handleRoleSelect(context, profile, UserRole.passenger),
            ),
            index: 0,
          ),
          const SizedBox(height: 12),
          KhawiMotion.slideUpFadeIn(
            _RoleCard(
              title: l10n?.iAmADriver ?? 'Driver',
              subtitle:
                  l10n?.shareYourRegularRoute ?? 'Share your regular route',
              icon: Icons.directions_car_outlined,
              onTap: () => _handleRoleSelect(context, profile, UserRole.driver),
            ),
            index: 1,
          ),
          const SizedBox(height: 12),
          KhawiMotion.slideUpFadeIn(
            _RoleCard(
              title: l10n?.roleJuniorTitle ?? 'Khawi Junior',
              subtitle: l10n?.roleJuniorDescription ??
                  'Safe and trusted rides for your kids.',
              icon: Icons.shield_outlined,
              onTap: () => _handleRoleSelect(context, profile, UserRole.junior),
            ),
            index: 2,
          ),
        ],
      );
    }

    final title = switch (lastRole) {
      UserRole.passenger => l10n?.iAmAPassenger ?? 'Passenger',
      UserRole.driver => l10n?.iAmADriver ?? 'Driver',
      UserRole.junior => l10n?.roleJuniorTitle ?? 'Khawi Junior',
    };
    final subtitle = switch (lastRole) {
      UserRole.passenger =>
        l10n?.passengerDescription ?? "Joining a driver's route",
      UserRole.driver =>
        l10n?.shareYourRegularRoute ?? 'Share your regular route',
      UserRole.junior =>
        l10n?.roleJuniorDescription ?? 'Safe and trusted rides for your kids.',
    };
    final icon = switch (lastRole) {
      UserRole.passenger => Icons.person_outline,
      UserRole.driver => Icons.directions_car_outlined,
      UserRole.junior => Icons.shield_outlined,
    };

    return Column(
      children: [
        KhawiMotion.slideUpFadeIn(
          _RoleCard(
            title: '${l10n?.continueAs ?? 'Continue as'} $title',
            subtitle: subtitle,
            icon: icon,
            onTap: () => _handleRoleSelect(context, profile, lastRole),
            highlighted: true,
          ),
          index: 0,
        ),
        const SizedBox(height: 24),
        KhawiMotion.slideUpFadeIn(
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllRoles = true;
              });
            },
            icon: const Icon(Icons.swap_horiz),
            label: Text(l10n?.moreSwitchRole ?? 'Switch Role'),
          ),
          index: 1,
        ),
      ],
    );
  }

  Widget _buildQuickRideButton(
    BuildContext context,
    Profile profile,
  ) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: () {
          KhawiMotion.hapticSelection();
          _showQuickRideOptions(context, profile);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.instantRide ?? 'Instant Ride',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickRideOptions(
    BuildContext context,
    Profile profile,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.instantRide ?? 'Instant Ride',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.instantRideSheetDescription ??
                  'Scan a QR to join, or create your own code',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickRideOption(
                    icon: Icons.qr_code_scanner,
                    title: l10n?.scanQr ?? 'Scan QR',
                    subtitle: l10n?.joinRide ?? 'Join a ride',
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleRoleSelect(
                        context,
                        profile,
                        UserRole.passenger,
                        postRoute: Routes.passengerScan,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickRideOption(
                    icon: Icons.qr_code,
                    title: l10n?.createQr ?? 'Create QR',
                    subtitle: l10n?.shareRide ?? 'Share your ride',
                    color: AppTheme.accentGold,
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleCreateQr(context, profile);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Handles "Create QR" tap with role enforcement.
  /// - If not a driver: shows dialog prompting to select Driver role first.
  /// - If driver: navigates to QR creation screen.
  void _handleCreateQr(
    BuildContext context,
    Profile profile,
  ) {
    final l10n = AppLocalizations.of(context);

    // Case 1: User is not a driver.
    if (profile.role != UserRole.driver) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.driverRoleRequiredTitle ?? 'Driver Role Required'),
          content: Text(
            l10n?.driverRoleRequiredMessage ??
                'To create a ride QR code, you must be a verified driver. Select the "Driver" role to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleRoleSelect(
                  context,
                  profile,
                  UserRole.driver,
                  postRoute: Routes.driverInstantQr,
                );
              },
              child: Text(l10n?.driver ?? 'Driver'),
            ),
          ],
        ),
      );
      return;
    }

    context.push(Routes.driverInstantQr);
  }

  Future<void> _handleRoleSelect(
    BuildContext context,
    Profile profile,
    UserRole role, {
    String? postRoute,
  }) async {
    final l10n = AppLocalizations.of(context);

    // Always show the disclaimer when a role is selected.
    final accepted = await _showRoleDisclaimer(context, role);
    if (!context.mounted) return;
    if (!accepted) return;

    try {
      // Set activeRole synchronously before any async work.
      // Router listens to activeRoleProvider and will auto-redirect to the correct home screen.
      ref.read(activeRoleProvider.notifier).setRole(role);

      // Track role selection for product analytics.
      final roleFuture = ref.read(analyticsServiceProvider).track(
        AnalyticsEvent.roleSelected,
        properties: {'role': role.name},
      );
      unawaited(roleFuture);

      // Fire-and-forget DB update; realtime stream will propagate changes.
      unawaited(ref.read(profileActionsProvider).setRole(profile.id, role));

      // If a post-route was requested (e.g. instant QR), push it after router settles.
      if (postRoute != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.push(postRoute);
        });
      }
    } catch (e) {
      if (!context.mounted) return;

      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.errorTitle ?? 'Error'),
          content: Text(l10n?.errorWithMessage('$e') ?? 'Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.ok ?? 'OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _showRoleDisclaimer(BuildContext context, UserRole role) async {
    final l10n = AppLocalizations.of(context);
    final title = switch (role) {
      UserRole.passenger =>
        l10n?.passengerConductTitle ?? 'Passenger Code of Conduct',
      UserRole.driver => l10n?.driverConductTitle ?? 'Driver Code of Conduct',
      UserRole.junior => l10n?.juniorSafetyTitle ?? 'Khawi Junior Safety Rules',
    };

    final bullets = switch (role) {
      UserRole.passenger => [
          l10n?.passengerRule1 ?? 'Arrive on time and be respectful.',
          l10n?.passengerRule2 ??
              'Always verify the ride details before joining.',
          l10n?.zeroToleranceRule ??
              'Zero tolerance for harassment or unsafe behavior.',
        ],
      UserRole.driver => [
          l10n?.driverRule1 ?? 'This is a community ride-share (non-paid).',
          l10n?.driverRule2 ?? 'Follow traffic laws and keep safety first.',
          l10n?.zeroToleranceRule ??
              'Zero tolerance for harassment or unsafe behavior.',
        ],
      UserRole.junior => [
          l10n?.juniorRule1 ?? 'Safety comes first for every trip.',
          l10n?.juniorRule2 ??
              'Only approved guardians/family drivers should participate.',
          l10n?.juniorRule3 ?? 'Live tracking may be enabled for safety.',
        ],
    };

    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: 20,
            end: 20,
            top: 12,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 12),
              for (final b in bullets) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              Text(
                l10n?.rulesConsentText ??
                    'By continuing, you agree to follow these rules.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.backgroundGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n?.iAgreeContinue ?? 'I Agree & Continue'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
            ],
          ),
        );
      },
    );

    return res ?? false;
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: () {
        KhawiMotion.hapticLight();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing24),
        decoration: BoxDecoration(
          color: highlighted
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: highlighted ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: highlighted ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.textDark),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRideOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickRideOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          KhawiMotion.hapticSelection();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
