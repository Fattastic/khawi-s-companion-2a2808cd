import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../state/providers.dart';
import '../../domain/entities/commute_circle.dart';
import '../../../profile/domain/trust_tier.dart';
import 'circle_detail_sheet.dart';

class CircleNavigatorCard extends ConsumerWidget {
  final CommuteCircle circle;
  final VoidCallback? onTap;

  const CircleNavigatorCard({
    super.key,
    required this.circle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final userTier = profileAsync.maybeWhen(
      data: (p) => p.tier,
      orElse: () => TrustTier.bronze,
    );

    final isLocked = userTier.index < circle.requiredTier.index;
    final isPink = circle.isPink;

    return AppCard(
      onTap: onTap ?? () => CircleDetailSheet.show(context, circle),
      padding: const EdgeInsets.all(16),
      color:
          isPink ? Colors.pink.withValues(alpha: 0.02) : AppTheme.surfaceWhite,
      borderColor: isPink
          ? Colors.pink.withValues(alpha: 0.2)
          : AppTheme.borderColor.withValues(alpha: 0.5),
      borderWidth: isPink ? 1.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPink
                      ? Colors.pink.withValues(alpha: 0.1)
                      : AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPink ? 'PINK CIRCLE' : 'RECURRING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isPink ? Colors.pink : AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              if (isLocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 10, color: AppTheme.warning),
                      const SizedBox(width: 4),
                      Text(
                        circle.requiredTier.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              if (circle.womenOnly)
                const Icon(Icons.female, color: Colors.pink, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            circle.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPink ? Colors.pink.shade900 : AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${circle.neighborhoodId} → ${circle.destinationId}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPink
                      ? Colors.pink.withValues(alpha: 0.7)
                      : AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          _buildScheduleRow(context, isPink),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14,
                color: isPink
                    ? Colors.pink.withValues(alpha: 0.5)
                    : AppTheme.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${circle.memberIds.length} members',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isPink
                            ? Colors.pink.withValues(alpha: 0.7)
                            : AppTheme.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rel: ${(circle.reliabilityScore * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: circle.reliabilityScore > 0.9
                          ? AppTheme.primaryGreen
                          : AppTheme.warning,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context, bool isPink) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isActive = circle.schedule.containsKey(dayNum);
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? (isPink ? Colors.pink : AppTheme.primaryGreen)
                : (isPink
                    ? Colors.pink.withValues(alpha: 0.05)
                    : AppTheme.borderColor.withValues(alpha: 0.2)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              days[index],
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : AppTheme.textTertiary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}
