import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

class PassengerQuickLinks extends StatelessWidget {
  const PassengerQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 10,
      runSpacing: 12,
      children: [
        _QuickAction(
          icon: Icons.history,
          label: l10n.tripHistory,
          onTap: () => context.push(Routes.passengerTrips),
        ),
        _QuickAction(
          icon: Icons.bolt_outlined,
          label: l10n.xpLedger,
          onTap: () => context.go(Routes.passengerXpLedger),
        ),
        _QuickAction(
          icon: Icons.groups_2_outlined,
          label: l10n.communities,
          onTap: () => context.push(Routes.communities),
        ),
        _QuickAction(
          icon: Icons.card_giftcard_outlined,
          label: l10n.rewards,
          onTap: () => context.go(Routes.passengerRewards),
        ),
        _QuickAction(
          icon: Icons.event_outlined,
          label: l10n.eventRides,
          onTap: () => context.push(Routes.events),
        ),
        _QuickAction(
          icon: Icons.price_check_outlined,
          label: isRtl ? 'تقدير الأجرة' : 'Fare Estimator',
          onTap: () => context.push(Routes.sharedFareEstimator),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: AppTheme.shadowSmall,
            ),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
          ),
        ],
      ),
    );
  }
}
