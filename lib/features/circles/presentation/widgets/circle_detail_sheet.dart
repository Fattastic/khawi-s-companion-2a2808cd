import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../state/providers.dart';
import '../../domain/entities/commute_circle.dart';
import '../../../profile/domain/trust_tier.dart';
import '../../../auth/presentation/nafath_verification_screen.dart';

class CircleDetailSheet extends ConsumerWidget {
  final CommuteCircle circle;

  const CircleDetailSheet({
    super.key,
    required this.circle,
  });

  static Future<void> show(BuildContext context, CommuteCircle circle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CircleDetailSheet(circle: circle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final userTier = profileAsync.maybeWhen(
      data: (p) => p.tier,
      orElse: () => TrustTier.bronze,
    );

    final isLocked = userTier.index < circle.requiredTier.index;
    final isPink = circle.isPink;

    final joinedCircles = ref.watch(joinedCirclesProvider);
    final isMember = joinedCircles.contains(circle.id);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPink
                      ? Colors.pink.withValues(alpha: 0.1)
                      : AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPink ? 'PINK CIRCLE' : 'RECURRING',
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (circle.womenOnly)
                const Icon(Icons.female, color: Colors.pink, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            circle.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${circle.neighborhoodId} → ${circle.destinationId}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            context,
            Icons.verified_user_outlined,
            'Trust Requirement',
            circle.requiredTier.name.toUpperCase(),
            isLocked ? AppTheme.warning : AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.people_outline,
            'Members',
            '${circle.memberIds.length} users active',
            AppTheme.textPrimary,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.speed_outlined,
            'Reliability Score',
            '${(circle.reliabilityScore * 100).toInt()}%',
            AppTheme.primaryGreen,
          ),
          const SizedBox(height: 32),
          if (isLocked) ...[
            AppCard(
              color: AppTheme.warning.withValues(alpha: 0.05),
              borderColor: AppTheme.warning.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppTheme.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You need ${circle.requiredTier.name} tier to join this circle.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Identity verification is required for all premium and high-trust circles to ensure community safety.',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const NafathVerificationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Verify Identity to Unlock',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(joinedCirclesProvider.notifier);
                  if (isMember) {
                    notifier.update((state) => {...state}..remove(circle.id));
                  } else {
                    notifier.update((state) => {...state}..add(circle.id));
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isMember
                            ? 'Left circle successfully'
                            : 'Joined circle successfully!',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMember ? AppTheme.warning : AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isMember ? 'Leave Circle' : 'Join Circle',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16,),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundNeutral,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
