import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';

/// A reusable premium gate widget that blocks access to premium-only features.
///
/// Use this to wrap content or show a subscription CTA when user is not premium.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    this.showGateInline = true,
    this.onNonPremiumTap,
  });

  /// The child widget to show when user is premium.
  final Widget child;

  /// If true, shows the premium gate UI inline. If false, just disables the child.
  final bool showGateInline;

  /// Optional callback when non-premium user tries to interact.
  final VoidCallback? onNonPremiumTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);

    if (isPremium) {
      return child;
    }
    if (showGateInline) {
      return PremiumGateContent(onSubscribe: onNonPremiumTap);
    }
    return Opacity(
      opacity: 0.5,
      child: IgnorePointer(child: child),
    );
  }
}

/// The inline premium gate UI with subscription CTA.
class PremiumGateContent extends StatelessWidget {
  const PremiumGateContent({super.key, this.onSubscribe});

  final VoidCallback? onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isRtl ? 'يتطلب Khawi+' : 'Khawi+ Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              isRtl
                  ? 'اشترك في Khawi+ (30 ريال/شهر) لاستبدال نقاطك بمكافآت حقيقية.'
                  : 'Subscribe to Khawi+ (30 SAR/month) to redeem your XP for real rewards.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onSubscribe != null) {
                    onSubscribe!();
                  } else {
                    context.push(Routes.subscription);
                  }
                },
                icon: const Icon(Icons.star),
                label: Text(isRtl ? 'اشترك في Khawi+' : 'Subscribe to Khawi+'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(isRtl ? 'لاحقاً' : 'Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button wrapper that shows premium gate when tapped by non-premium users.
class PremiumGatedButton extends ConsumerWidget {
  const PremiumGatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.icon,
  });

  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Widget? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (isPremium) {
      if (icon != null) {
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon!,
          label: child,
          style: style,
        );
      }
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }

    // Non-premium: show disabled style + redirect to subscription
    final disabledStyle = (style ?? ElevatedButton.styleFrom()).copyWith(
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade300),
      foregroundColor: WidgetStateProperty.all(Colors.grey.shade600),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          ElevatedButton.icon(
            onPressed: () => _showPremiumRequired(context, isRtl),
            icon: icon!,
            label: child,
            style: disabledStyle,
          )
        else
          ElevatedButton(
            onPressed: () => _showPremiumRequired(context, isRtl),
            style: disabledStyle,
            child: child,
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => context.push(Routes.subscription),
          icon: const Icon(Icons.star, size: 16, color: AppTheme.accentGold),
          label: Text(
            isRtl
                ? 'اشترك في Khawi+ (30 ريال)'
                : 'Subscribe to Khawi+ (30 SAR)',
            style: const TextStyle(color: AppTheme.accentGold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showPremiumRequired(BuildContext context, bool isRtl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRtl
              ? 'يتطلب اشتراك Khawi+ لاستبدال النقاط'
              : 'Khawi+ subscription required to redeem XP',
        ),
        action: SnackBarAction(
          label: isRtl ? 'اشتراك' : 'Subscribe',
          onPressed: () => context.push(Routes.subscription),
        ),
      ),
    );
  }
}

/// Helper to check premium status and redirect if needed.
/// Returns true if user is premium, false otherwise.
bool checkPremiumOrRedirect(BuildContext context, WidgetRef ref) {
  final isPremium = ref.read(premiumProvider);
  if (!isPremium) {
    if (context.mounted) {
      context.push(Routes.subscription);
    }
    return false;
  }
  return true;
}
