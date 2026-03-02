import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';

import '../domain/ride_history_entry.dart';
import '../data/ride_history_repo.dart';
import '../../support/presentation/widgets/trip_issue_sheet.dart';
import 'widgets/trip_receipt_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_empty_state.dart';

/// Provider for ride history entries.
final rideHistoryProvider = FutureProvider.autoDispose
    .family<List<RideHistoryEntry>, String>((ref, userId) async {
  final repo = RideHistoryRepo(ref.read(supabaseClientProvider));
  return repo.fetchHistory(userId: userId);
});

/// Ride history screen showing past completed trips.
class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return Scaffold(
        body:
            Center(child: Text(isRtl ? 'يرجى تسجيل الدخول' : 'Please sign in')),
      );
    }

    final historyAsync = ref.watch(rideHistoryProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'سجل الرحلات' : 'Ride History'),
      ),
      body: historyAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const AppShimmer.card(height: 160),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(isRtl ? 'حدث خطأ: $err' : 'Error: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(rideHistoryProvider(userId)),
                child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return AppEmptyState(
              icon: Icons.history,
              title: isRtl ? 'لا توجد رحلات سابقة' : 'No ride history yet',
              subtitle: isRtl
                  ? 'ستظهر رحلاتك المكتملة هنا'
                  : 'Completed rides will appear here',
              isRtl: isRtl,
              ctaLabel: isRtl ? 'البحث عن رحلة' : 'Find a Ride',
              onCta: () => context.push(Routes.passengerSearch),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return KhawiMotion.slideUpFadeIn(
                _RideHistoryCard(entry: entries[index]),
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final RideHistoryEntry entry;

  const _RideHistoryCard({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.formattedDate} • ${entry.formattedTime}',
                  style: theme.textTheme.labelMedium,
                ),
                _StatusChip(status: entry.status),
              ],
            ),
            const SizedBox(height: 12),

            // Route info
            Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 10,
                      color: AppTheme.primaryGreen,
                    ),
                    Container(
                      width: 2,
                      height: 24,
                      color: AppTheme.borderColor,
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.error,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.originLabel ?? 'نقطة الانطلاق',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.destLabel ?? 'الوجهة',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (entry.waypointLabels.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.waypointLabels
                    .map(
                      (label) => Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.alt_route, size: 16),
                        label: Text(label),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (entry.counterpartName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${isRtl ? 'الطرف الآخر' : 'Counterpart'}: ${entry.counterpartName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),

            // Bottom: Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Distance
                if (entry.distanceKm != null)
                  _StatItem(
                    icon: Icons.straighten,
                    label: '${entry.distanceKm!.toStringAsFixed(1)} كم',
                    color: AppTheme.info,
                  ),

                // CO2
                if (entry.co2SavedKg != null && entry.co2SavedKg! > 0)
                  _StatItem(
                    icon: Icons.eco,
                    label: '${entry.co2SavedKg!.toStringAsFixed(1)} كغ CO₂',
                    color: AppTheme.success,
                  ),

                // Rating
                if (entry.ratingGiven != null)
                  _StatItem(
                    icon: Icons.star,
                    label: '${entry.ratingGiven}',
                    color: AppTheme.accentGold,
                  )
                else if (entry.canRate)
                  Chip(
                    avatar: const Icon(Icons.star_border, size: 16),
                    label: const Text('قيّم'),
                    backgroundColor: AppTheme.accentGoldLight,
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentGoldDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            // XP earned
            if (entry.xpEarned != null && entry.xpEarned! > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bolt, size: 16, color: AppTheme.accentGold),
                  const SizedBox(width: 4),
                  Text(
                    '+${entry.xpEarned} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentGoldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => TripIssueSheet.show(
                      context,
                      tripId: entry.tripId,
                    ),
                    icon: const Icon(Icons.report_gmailerrorred),
                    label: Text(isRtl ? 'إبلاغ' : 'Report'),
                  ),
                  TextButton.icon(
                    onPressed: () => TripReceiptSheet.show(context, entry),
                    icon: const Icon(Icons.receipt_long),
                    label: Text(isRtl ? 'عرض الإيصال' : 'View Receipt'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCompleted ? 'مكتملة' : 'قيد التنفيذ',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isCompleted ? AppTheme.success : AppTheme.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
