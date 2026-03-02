import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/rating/domain/ride_rating.dart';
import 'package:khawi_flutter/state/providers.dart';

import 'written_review_preview.dart';

/// Displays driver's vehicle information with verification badge.
///
/// Shows vehicle model, plate number, and verification status.
class VehicleDetailsCard extends ConsumerWidget {
  final Profile driverProfile;

  /// Whether to show in compact (inline) or expanded (card) format.
  final bool compact;

  const VehicleDetailsCard({
    super.key,
    required this.driverProfile,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) return _buildCompact(context);
    return _buildFull(context, ref);
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final hasVehicle = driverProfile.vehicleModel != null;

    if (!hasVehicle) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.directions_car,
            size: 16, color: AppTheme.driverAccent,),
        const SizedBox(width: 4),
        Text(
          driverProfile.vehicleModel ?? '',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        if (driverProfile.vehiclePlateNumber != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              driverProfile.vehiclePlateNumber!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFull(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isVerified = driverProfile.vehicleVerificationStatus == 'approved';
    final reviewsAsync = ref.watch(_driverReviewsProvider(driverProfile.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.driverAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppTheme.driverAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRtl ? 'معلومات المركبة' : 'Vehicle details',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified,
                            size: 14, color: AppTheme.success,),
                        const SizedBox(width: 4),
                        Text(
                          isRtl ? 'موثقة' : 'Verified',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Vehicle model
            if (driverProfile.vehicleModel != null)
              _DetailRow(
                icon: Icons.car_rental,
                label: isRtl ? 'الطراز' : 'Model',
                value: driverProfile.vehicleModel!,
              ),

            // Plate number (large, prominent)
            if (driverProfile.vehiclePlateNumber != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundNeutral,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor, width: 2),
                  ),
                  child: Text(
                    driverProfile.vehiclePlateNumber!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],

            // Rating
            if (driverProfile.averageRating != null &&
                driverProfile.totalRatings > 0) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.star,
                iconColor: AppTheme.accentGold,
                label: isRtl ? 'التقييم' : 'Rating',
                value:
                    '${driverProfile.averageRating!.toStringAsFixed(1)} (${driverProfile.totalRatings})',
              ),
            ],

            // Trust badge
            if (driverProfile.trustBadge != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.shield,
                iconColor: _trustBadgeColor(driverProfile.trustBadge),
                label: isRtl ? 'مستوى الثقة' : 'Trust tier',
                value: _trustBadgeLabel(driverProfile.trustBadge, isRtl),
              ),
            ],

            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRtl ? 'المراجعات المكتوبة' : 'Written reviews',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...reviews.take(2).map(
                        (review) {
                          final preview = buildWrittenReviewPreview(
                            review,
                            isArabic: isRtl,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundNeutral,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preview.headline,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preview.body,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Color _trustBadgeColor(String? badge) => switch (badge) {
        'gold' => AppTheme.accentGold,
        'silver' => const Color(0xFFC0C0C0),
        'platinum' => const Color(0xFF8E44AD),
        _ => const Color(0xFFCD7F32), // bronze
      };

  String _trustBadgeLabel(String? badge, bool isRtl) => switch (badge) {
        'gold' => isRtl ? 'ذهبي' : 'Gold',
        'silver' => isRtl ? 'فضي' : 'Silver',
        'platinum' => isRtl ? 'بلاتيني' : 'Platinum',
        _ => isRtl ? 'برونزي' : 'Bronze',
      };
}

final _driverReviewsProvider =
    FutureProvider.family<List<RideRating>, String>((ref, driverId) async {
  return ref.read(ratingRepoProvider).fetchWrittenReviewsFor(
        driverId,
        limit: 2,
      );
});

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppTheme.textTertiary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
