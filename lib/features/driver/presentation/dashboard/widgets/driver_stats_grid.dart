import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';

class DriverStatsGrid extends StatelessWidget {
  const DriverStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        Expanded(
          child: _DriverStatCard(
            label: isRtl ? "الرحلات" : "Rides",
            value: "24",
            icon: Icons.drive_eta_rounded,
            color: AppTheme.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DriverStatCard(
            label: isRtl ? "التقييم" : "Rating",
            value: "4.9",
            icon: Icons.star_rounded,
            color: AppTheme.accentGold,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: _DriverStatCard(
            label: "XP",
            value: "+2.4k",
            icon: Icons.bolt_rounded,
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }
}

class _DriverStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DriverStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      hasBorder: true,
      hasShadow: true,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}
