import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/providers.dart';

/// Screen shown when a user deep-links into another role's route.
/// Provides a friendly message and a safe path home.
class NotAuthorizedScreen extends ConsumerWidget {
  /// The route path the user tried to access.
  final String? attemptedRoute;

  /// The role required to access the attempted route.
  final UserRole? requiredRole;

  const NotAuthorizedScreen({
    super.key,
    this.attemptedRoute,
    this.requiredRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final profileAsync = ref.watch(myProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: profileAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (profile) {
                final currentRole = profile.role;
                final currentRoleName = currentRole != null
                    ? _roleDisplayName(currentRole, isRtl)
                    : (isRtl ? 'غير محدد' : 'Unassigned');
                final requiredRoleName = requiredRole != null
                    ? _roleDisplayName(requiredRole!, isRtl)
                    : (isRtl ? 'دور آخر' : 'another role');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        size: 64,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentRole != null
                                ? _roleIcon(currentRole)
                                : Icons.help_outline,
                            size: 18,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentRoleName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      isRtl ? 'صفحة غير متاحة' : 'Page Not Available',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Explanation
                    Text(
                      isRtl
                          ? 'أنت مسجل كـ $currentRoleName، لكن هذه الصفحة تتطلب حساب $requiredRoleName.'
                          : "You're signed in as a $currentRoleName, but this page requires a $requiredRoleName account.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Go Home Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (currentRole == null) {
                            context.go(Routes.authRole);
                            return;
                          }
                          final homePath = _homePathForRole(currentRole);
                          context.go(homePath);
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: Text(
                          isRtl ? 'العودة للرئيسية' : 'Go to My Home',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _roleDisplayName(UserRole role, bool isRtl) {
    return switch (role) {
      UserRole.passenger => isRtl ? 'راكب' : 'Passenger',
      UserRole.driver => isRtl ? 'سائق' : 'Driver',
      UserRole.junior => isRtl ? 'ولي أمر (جونيور)' : 'Junior Guardian',
    };
  }

  IconData _roleIcon(UserRole role) {
    return switch (role) {
      UserRole.passenger => Icons.person_outline,
      UserRole.driver => Icons.directions_car_outlined,
      UserRole.junior => Icons.family_restroom_outlined,
    };
  }

  String _homePathForRole(UserRole role) {
    return switch (role) {
      UserRole.passenger => Routes.passengerHome,
      UserRole.driver => Routes.driverDashboard,
      UserRole.junior => Routes.juniorHub,
    };
  }
}
