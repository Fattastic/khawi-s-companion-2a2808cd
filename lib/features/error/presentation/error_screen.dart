import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/state/providers.dart';

/// A graceful error/not-found screen with Material 3 styling.
/// Shows a friendly message and a "Go Home" button that navigates
/// based on the user's role.
class ErrorScreen extends ConsumerWidget {
  final String? errorMessage;
  final bool isNotFound;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.isNotFound = false,
  });

  /// Factory for 404 Not Found pages.
  const ErrorScreen.notFound({super.key})
      : errorMessage = null,
        isNotFound = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final profileAsync = ref.watch(myProfileProvider);
    final theme = Theme.of(context);

    final title = isNotFound
        ? (isRtl ? 'الصفحة غير موجودة' : 'Page Not Found')
        : (isRtl ? 'حدث خطأ' : 'Something Went Wrong');

    final subtitle = isNotFound
        ? (isRtl
            ? 'عذراً، لم نتمكن من العثور على الصفحة التي تبحث عنها.'
            : "Sorry, we couldn't find the page you're looking for.")
        : (errorMessage ??
            (isRtl
                ? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'
                : 'An unexpected error occurred. Please try again.'));

    final icon =
        isNotFound ? Icons.search_off_rounded : Icons.error_outline_rounded;
    final iconColor = isNotFound ? AppTheme.textSecondary : Colors.orange;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon with animated container
                KhawiMotion.slideUpFadeIn(
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 64,
                      color: iconColor,
                    ),
                  ),
                  index: 0,
                ),
                const SizedBox(height: 32),

                // Error Code Badge (for 404)
                if (isNotFound)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '404',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                if (isNotFound) const SizedBox(height: 16),

                // Title
                KhawiMotion.slideUpFadeIn(
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  index: 1,
                ),
                const SizedBox(height: 12),

                // Subtitle
                KhawiMotion.slideUpFadeIn(
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  index: 2,
                ),
                const SizedBox(height: 40),

                // Go Home Button
                KhawiMotion.slideUpFadeIn(
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goHome(context, ref, profileAsync),
                      icon: const Icon(Icons.home_rounded),
                      label: Text(
                        isRtl ? 'العودة للرئيسية' : 'Go Home',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  index: 3,
                ),
                const SizedBox(height: 16),

                // Back Button (if can pop)
                if (context.canPop())
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        isRtl ? Icons.arrow_forward : Icons.arrow_back,
                      ),
                      label: Text(
                        isRtl ? 'العودة' : 'Go Back',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Profile> profileAsync,
  ) {
    final profile = profileAsync.asData?.value;

    // If no profile or not authenticated, go to splash (router will redirect appropriately)
    if (profile == null) {
      context.go(Routes.splash);
      return;
    }

    // Navigate based on role
    final home = switch (profile.role) {
      UserRole.passenger => Routes.passengerHome,
      UserRole.driver => Routes.driverDashboard,
      UserRole.junior => Routes.juniorHub,
      null => Routes.authRole,
    };

    context.go(home);
  }
}
