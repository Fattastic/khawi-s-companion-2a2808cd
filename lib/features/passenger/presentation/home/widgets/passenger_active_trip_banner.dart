import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/state/providers.dart';

class PassengerActiveTripBanner extends ConsumerWidget {
  const PassengerActiveTripBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userIdProvider);
    if (uid == null) return const SizedBox.shrink();

    final requestsStream =
        ref.watch(requestsRepoProvider).watchSentRequests(uid);

    return StreamBuilder<List<TripRequest>>(
      stream: requestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final latest = snapshot.data!.first;

        // Check if "Active"
        final bool isActive = [
          RequestStatus.pending,
          RequestStatus.accepted,
          RequestStatus.pickedUp,
          RequestStatus.droppedOff,
        ].contains(latest.status);

        if (!isActive) return const SizedBox.shrink();

        final isRtl = Directionality.of(context) == TextDirection.rtl;

        Color bgColor;
        String title;
        String subtitle;
        IconData icon;

        switch (latest.status) {
          case RequestStatus.pending:
            bgColor = Colors.orange.shade100;
            title =
                isRtl ? 'جاري البحث عن كابتن...' : 'Searching for Captain...';
            subtitle = isRtl ? 'طلبك قيد الانتظار' : 'Your request is pending';
            icon = Icons.hourglass_top;
            break;
          case RequestStatus.accepted:
            bgColor = AppTheme.primaryGreen.withValues(alpha: 0.2);
            title = isRtl ? 'الكابتن في الطريق!' : 'Captain is on the way!';
            subtitle = isRtl ? 'تم قبول طلبك' : 'Request accepted';
            icon = Icons.directions_car;
            break;
          case RequestStatus.pickedUp:
            bgColor = AppTheme.primaryGreen.withValues(alpha: 0.2);
            title = isRtl ? 'رحلة ممتعة!' : 'Enjoy your ride!';
            subtitle =
                isRtl ? 'أنت في الطريق إلى وجهتك' : 'En route to destination';
            icon = Icons.handshake;
            break;
          default:
            bgColor = Colors.grey.shade100;
            title = isRtl ? 'الرحلة نشطة' : 'Trip Active';
            subtitle = isRtl ? 'انقر للمتابعة' : 'Tap to view';
            icon = Icons.info;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // If pending, maybe go to a "Waiting" screen?
              // For now, let's assume LiveTrip handles pending state or we have a specific screen.
              // Actually, `Routes.livePassenger(tripId)` is the right place usually.
              context.push(Routes.livePassengerPath(latest.tripId));
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(icon, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
