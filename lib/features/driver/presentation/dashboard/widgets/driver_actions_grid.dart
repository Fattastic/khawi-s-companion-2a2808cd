import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';

class DriverActionsGrid extends StatelessWidget {
  const DriverActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.timeline,
                label: isRtl ? 'المخطط' : 'Planner',
                onTap: () => context.go(Routes.driverPlanner),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.qr_code_2,
                label: isRtl ? 'QR سريع' : 'Instant QR',
                onTap: () => context.go(Routes.driverInstantQr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.inbox_outlined,
                label: isRtl ? 'الطلبات' : 'Queue',
                onTap: () => context.go(Routes.driverQueue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_repeat,
                label: isRtl ? 'المعتادة' : 'Regular',
                onTap: () => context.go(Routes.driverRegularTrips),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.groups_2_outlined,
                label: isRtl ? 'المجتمعات' : 'Communities',
                onTap: () => context.push(Routes.communities),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_outlined,
                label: isRtl ? 'الفعاليات' : 'Events',
                onTap: () => context.push(Routes.events),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      hasBorder: true,
      hasShadow: false,
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.driverAccent),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.driverAccent,
            ),
          ),
        ],
      ),
    );
  }
}
