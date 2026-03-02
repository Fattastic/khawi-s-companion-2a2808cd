import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/rewards/data/rewards_repo.dart';

/// Global reward details screen for all users.
class RewardDetailsScreen extends ConsumerWidget {
  const RewardDetailsScreen({super.key, required this.rewardId});

  final String rewardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    // Mock reward data (replace with provider)
    final reward = _getMockReward(rewardId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Details'),
        backgroundColor: AppTheme.backgroundGreen,
      ),
      body: reward == null
          ? const Center(child: Text('Reward not found'))
          : profileAsync.when(
              data: (profile) => _buildContent(
                context,
                ref,
                reward,
                profile.redeemableXp,
                profile.isPremium,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> reward,
    int userXp,
    bool isPremium,
  ) {
    final xpCost = reward['xpCost'] as int;
    final hasEnoughXp = userXp >= xpCost;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  reward['color'] as Color,
                  (reward['color'] as Color).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    reward['icon'] as IconData,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                if (reward['partner'] != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reward['partner'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  reward['title'] as String,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // XP Cost + User Balance
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$xpCost XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Your balance: $userXp XP',
                      style: TextStyle(
                        color: userXp >= xpCost
                            ? AppTheme.primaryGreen
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Premium Gate
                if (!isPremium)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              'Khawi+ Required',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Subscribe to Khawi+ to redeem your XP for rewards.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => context.push(Routes.subscription),
                          child: const Text('Upgrade to Khawi+'),
                        ),
                      ],
                    ),
                  ),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),

                // Terms & Conditions
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Terms & Conditions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        reward['terms'] as String? ??
                            '• Valid for 30 days after redemption\n'
                                '• Cannot be combined with other offers\n'
                                '• Subject to availability\n'
                                '• Non-transferable',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Redeem Button
                FilledButton.icon(
                  onPressed: isPremium
                      ? (hasEnoughXp
                          ? () => _handleRedeem(context, ref, reward)
                          : null)
                      : () => context.go(Routes.subscription),
                  icon: const Icon(Icons.redeem),
                  label: Text(
                    isPremium
                        ? (hasEnoughXp ? 'Redeem Now' : 'Not Enough XP')
                        : 'Subscribe to Redeem',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isPremium && hasEnoughXp
                        ? AppTheme.primaryGreen
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedeem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> reward,
  ) async {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }
    final repo = ref.read<RewardsRepo>(rewardsRepoProvider);
    final xpCost = reward['xpCost'] as int;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      ),
    );
    try {
      await repo.attemptRedeem(
        userId: userId,
        rewardId: reward['id'] as String? ?? '',
        xpCost: xpCost,
      );
      if (!context.mounted) return;
      Navigator.pop(context); // close progress
      await showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                'Reward Redeemed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Show this QR code at ${reward['partner'] ?? 'the partner store'} to claim your reward.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 100),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // close progress
      if (e is PremiumRequiredException) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium required to redeem this reward'),
          ),
        );
        context.go(Routes.subscription);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Redeem failed: $e')));
      }
    }
  }

  Map<String, dynamic>? _getMockReward(String id) {
    final rewards = {
      'half_million': {
        'title': 'Half Million Coffee Voucher',
        'description':
            'Enjoy a coffee voucher at Half Million. Valid up to 25 SAR.',
        'xpCost': 900,
        'icon': Icons.coffee,
        'color': Colors.brown,
        'partner': 'Half Million',
      },
      'barns': {
        'title': "Barn's Coffee Voucher",
        'description':
            "Redeem a Barn's drink voucher. Valid for any drink up to 20 SAR.",
        'xpCost': 800,
        'icon': Icons.local_cafe,
        'color': Colors.deepOrange,
        'partner': "Barn's",
      },
      'dunkin': {
        'title': 'Dunkin Donuts Voucher',
        'description':
            'Grab a Dunkin Donuts coffee and donut combo. Valid up to 22 SAR.',
        'xpCost': 850,
        'icon': Icons.local_cafe,
        'color': Colors.orange,
        'partner': 'Dunkin Donuts',
      },
      'fuel': {
        'title': 'Fuel Discount',
        'description':
            'Get 10 SAR off your next fuel purchase at any SASCO station.',
        'xpCost': 500,
        'icon': Icons.local_gas_station,
        'color': Colors.green,
        'partner': 'SASCO',
      },
      'cinema': {
        'title': 'Cinema Ticket',
        'description':
            'One free movie ticket at any AMC or VOX cinema in Saudi Arabia.',
        'xpCost': 800,
        'icon': Icons.movie,
        'color': Colors.purple,
        'partner': 'VOX Cinemas',
      },
    };
    return rewards[id];
  }
}
