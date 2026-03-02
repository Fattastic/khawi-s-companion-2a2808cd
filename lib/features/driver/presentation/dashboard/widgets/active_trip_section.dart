import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/driver/presentation/controllers/driver_dashboard_controller.dart';

class ActiveTripSection extends ConsumerWidget {
  const ActiveTripSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptedRequests = ref.watch(
      driverDashboardControllerProvider.select((s) => s.acceptedRequests),
    );
    final bundleResult = ref
        .watch(driverDashboardControllerProvider.select((s) => s.bundleResult));
    final isLoading =
        ref.watch(driverDashboardControllerProvider.select((s) => s.isLoading));
    final controller = ref.read(driverDashboardControllerProvider.notifier);

    if (acceptedRequests.isEmpty) return const SizedBox.shrink();

    if (bundleResult != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.driverAccent, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppTheme.driverAccent),
                const SizedBox(width: 8),
                Text(
                  "AI Optimized Route",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.clearBundle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...bundleResult.stops.map((stop) {
              final type = stop.type == 'pickup' ? "Pickup" : "Dropoff";
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      type == "Pickup"
                          ? Icons.person_pin_circle
                          : Icons.pin_drop,
                      size: 16,
                      color:
                          type == "Pickup" ? AppTheme.success : AppTheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text("$type: ${stop.label}")),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Live Trip
                  final tripId = acceptedRequests.first.tripId;
                  context.push(Routes.liveDriverPath(tripId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.driverAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Start Route"),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Active Passengers (${acceptedRequests.length})",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...acceptedRequests.map(
          (req) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                "Passenger ${req.passengerId.length > 4 ? req.passengerId.substring(0, 4) : req.passengerId}",
              ),
              subtitle: const Text("Status: Accepted"),
              trailing: const Icon(Icons.check_circle, color: AppTheme.success),
            ),
          ),
        ),
        if (acceptedRequests.length >= 2) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : controller.triggerBundle,
              icon: const Icon(Icons.auto_awesome),
              label: Text(isLoading ? "Optimizing..." : "Bundle Stops (AI)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.driverAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final tripId = acceptedRequests.first.tripId;
              context.push(Routes.liveDriverPath(tripId));
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Start Trip"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
