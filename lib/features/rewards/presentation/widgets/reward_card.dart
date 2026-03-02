import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/reward_item.dart';
import '../../../../features/profile/domain/trust_tier.dart';

class RewardCard extends StatelessWidget {
  final RewardItem item;
  final bool isRtl;
  final int userXp;
  final TrustTier userTier;
  final bool isSubscribed;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.item,
    required this.isRtl,
    required this.userXp,
    required this.userTier,
    required this.isSubscribed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLockedByTier = !userTier.isAtLeast(item.trustTierRequired);
    final isLockedBySubscription = item.subscriptionRequired && !isSubscribed;
    final canAfford = userXp >= item.xpCost;
    final isLocked = isLockedByTier || isLockedBySubscription;

    return AppCard(
      onTap: isLocked ? null : onTap,
      padding: EdgeInsets.zero,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Stack
            Stack(
              children: [
                if (item.imageUrl != null)
                  Image.network(
                    item.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 120,
                    color: AppTheme.backgroundGreen,
                    child: const Icon(Icons.redeem,
                        size: 48, color: AppTheme.primaryGreen,),
                  ),

                // Khawi+ Tag
                if (item.subscriptionRequired)
                  Positioned(
                    top: 8,
                    left: isRtl ? null : 8,
                    right: isRtl ? 8 : null,
                    child: _buildBadge(
                        context, 'Khawi+', AppTheme.accentGold, Colors.white,),
                  ),

                // Trust Tier Tag
                if (item.trustTierRequired != TrustTier.bronze)
                  Positioned(
                    bottom: 8,
                    left: isRtl ? null : 8,
                    right: isRtl ? 8 : null,
                    child: _buildBadge(
                        context,
                        isRtl
                            ? item.trustTierRequired.displayNameAr
                            : item.trustTierRequired.displayName,
                        Colors.black87,
                        Colors.white,),
                  ),

                // Locked Overlay
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black12,
                      child:
                          const Icon(Icons.lock, color: Colors.white, size: 32),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name(isRtl),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14,),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.bolt,
                          size: 14, color: AppTheme.primaryGreen,),
                      const SizedBox(width: 4),
                      Text(
                        '${item.xpCost} XP',
                        style: TextStyle(
                          color: canAfford ? AppTheme.primaryGreen : Colors.red,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, String text, Color bgColor, Color textColor,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
