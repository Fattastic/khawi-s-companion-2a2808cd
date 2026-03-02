import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/driver/presentation/controllers/driver_dashboard_controller.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';

class IncomingRequestsList extends ConsumerWidget {
  const IncomingRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicit generic annotation
    final reqs = ref.watch(
      driverDashboardControllerProvider
          .select((DriverDashboardState s) => s.incomingRequests),
    );
    final controller = ref.read(driverDashboardControllerProvider.notifier);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (reqs.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Center(
          child: Text(
            isRtl ? "لا توجد طلبات منتظرة" : "No waiting requests",
            style: const TextStyle(color: AppTheme.textTertiary),
          ),
        ),
      );
    }

    return Column(
      children: reqs
          .map((req) => _RequestCard(req: req, controller: controller))
          .toList(),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TripRequest req;
  final DriverDashboardController controller;

  const _RequestCard({required this.req, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: AppTheme.driverAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Passenger Request",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Match Score: 94%",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.success),
                      ),
                    ],
                  ),
                ),
                Text(
                  "SAR 15.00",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.declineRequest(req.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptRequest(req.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
