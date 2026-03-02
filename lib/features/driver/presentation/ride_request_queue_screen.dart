import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'controllers/driver_dashboard_controller.dart';

class RideRequestQueueScreen extends ConsumerWidget {
  const RideRequestQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverDashboardControllerProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar:
          AppBar(title: Text(isRtl ? 'طلبات الرحلات' : 'Ride Request Queue')),
      body: state.incomingRequests.isEmpty
          ? _buildEmptyState(context, isRtl)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.incomingRequests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final req = state.incomingRequests[i];
                final shortId =
                    req.id.length > 6 ? req.id.substring(0, 6) : req.id;
                final flexLine = req.hasFlexOffer
                    ? (isRtl
                        ? 'خاوي فليكس: ${req.flexOfferSar?.toStringAsFixed(0)} ر.س'
                        : 'Khawi Flex: ${req.flexOfferSar?.toStringAsFixed(0)} SAR')
                    : null;
                final noteLine =
                    (req.flexNote?.isNotEmpty ?? false) ? req.flexNote : null;
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                    child:
                        const Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  title: Text('Request $shortId'),
                  subtitle: Text(
                    [
                      'Status: ${req.status.name}',
                      if (flexLine != null) flexLine,
                      if (noteLine != null) noteLine,
                    ].join('\n'),
                  ),
                  isThreeLine: flexLine != null || noteLine != null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryGreen,
                        ),
                        tooltip: isRtl ? 'قبول' : 'Accept',
                        onPressed: () {
                          ref
                              .read(driverDashboardControllerProvider.notifier)
                              .acceptRequest(req.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: isRtl ? 'رفض' : 'Decline',
                        onPressed: () {
                          ref
                              .read(driverDashboardControllerProvider.notifier)
                              .declineRequest(req.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isRtl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isRtl ? 'لا توجد طلبات حالياً' : 'No Ride Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'عندما يطلب الركاب الانضمام لرحلاتك، ستظهر الطلبات هنا'
                  : 'When passengers request to join your trips, requests will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            // Primary CTA: Offer a ride
            FilledButton.icon(
              onPressed: () => context.go(Routes.driverOfferRide),
              icon: const Icon(Icons.add_road),
              label: Text(isRtl ? 'اعرض رحلة' : 'Offer a Ride'),
            ),
            const SizedBox(height: 12),
            // Secondary: Back to dashboard
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.driverDashboard),
              icon: const Icon(Icons.dashboard),
              label: Text(isRtl ? 'لوحة التحكم' : 'Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
