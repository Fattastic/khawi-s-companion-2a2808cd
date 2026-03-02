/// Rewards Inspector Panel - Rewards catalog and redemption debugger.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rewards economy inspector panel.
class RewardsInspectorPanel extends ConsumerStatefulWidget {
  const RewardsInspectorPanel({super.key});

  @override
  ConsumerState<RewardsInspectorPanel> createState() =>
      _RewardsInspectorPanelState();
}

class _RewardsInspectorPanelState extends ConsumerState<RewardsInspectorPanel> {
  List<Map<String, dynamic>>? _rewards;
  int? _xpBalance;
  String? _userTier;
  bool? _isKhawiPlus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      // Load rewards catalog
      final rewards = await Supabase.instance.client
          .from('rewards_catalog')
          .select()
          .eq('is_active', true)
          .order('xp_cost');

      // Load user state
      if (userId != null) {
        final gamification = await Supabase.instance.client
            .from('user_gamification')
            .select('xp_balance')
            .eq('user_id', userId)
            .maybeSingle();

        final trust = await Supabase.instance.client
            .from('user_trust_state')
            .select('tier')
            .eq('user_id', userId)
            .maybeSingle();

        final profile = await Supabase.instance.client
            .from('profiles')
            .select('subscription_tier')
            .eq('id', userId)
            .maybeSingle();

        if (!mounted) return;
        setState(() {
          _xpBalance = gamification?['xp_balance'] as int? ?? 0;
          _userTier = trust?['tier'] as String? ?? 'bronze';
          _isKhawiPlus = profile?['subscription_tier'] != 'free' &&
              profile?['subscription_tier'] != null;
        });
      }

      if (!mounted) return;
      setState(() => _rewards = List<Map<String, dynamic>>.from(rewards));
    } catch (e) {
      debugPrint('Error loading rewards: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _rewards == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUserStatus(),
        const SizedBox(height: 16),
        const Text(
          'Rewards Catalog',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...(_rewards ?? []).map(_buildRewardTile),
      ],
    );
  }

  Widget _buildUserStatus() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusChip('XP Balance', '${_xpBalance ?? 0}', Icons.stars),
            _statusChip('Trust Tier', _userTier ?? 'N/A', Icons.verified),
            _statusChip(
              'Khawi+',
              _isKhawiPlus == true ? '✓' : '✗',
              _isKhawiPlus == true ? Icons.check_circle : Icons.cancel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRewardTile(Map<String, dynamic> reward) {
    final eligibility = _checkEligibility(reward);

    return Card(
      child: ListTile(
        title: Text((reward['code'] as String?) ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost: ${reward['xp_cost']} XP | Min Tier: ${reward['min_trust_tier']}',
              style: const TextStyle(fontSize: 12),
            ),
            if (reward['requires_khawi_plus'] == true)
              const Text(
                'Requires Khawi+',
                style: TextStyle(fontSize: 11, color: Colors.purple),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              eligibility.eligible ? Icons.check_circle : Icons.block,
              color: eligibility.eligible ? Colors.green : Colors.red,
            ),
            Text(
              eligibility.eligible ? 'Eligible' : eligibility.reason,
              style: TextStyle(
                fontSize: 10,
                color: eligibility.eligible ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: () => _showDryRun(reward, eligibility),
      ),
    );
  }

  _EligibilityResult _checkEligibility(Map<String, dynamic> reward) {
    // Check XP balance
    final cost = reward['xp_cost'] as int? ?? 0;
    if ((_xpBalance ?? 0) < cost) {
      return const _EligibilityResult(false, 'Low XP');
    }

    // Check Khawi+
    if (reward['requires_khawi_plus'] == true && _isKhawiPlus != true) {
      return const _EligibilityResult(false, 'Need K+');
    }

    // Check tier
    final tierOrder = ['bronze', 'silver', 'gold', 'platinum'];
    final requiredTier = reward['min_trust_tier'] as String? ?? 'bronze';
    final userTierIndex = tierOrder.indexOf(_userTier ?? 'bronze');
    final requiredTierIndex = tierOrder.indexOf(requiredTier);
    if (userTierIndex < requiredTierIndex) {
      return const _EligibilityResult(false, 'Low tier');
    }

    return const _EligibilityResult(true, 'OK');
  }

  void _showDryRun(
    Map<String, dynamic> reward,
    _EligibilityResult eligibility,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dry Run: ${reward['code']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cost: ${reward['xp_cost']} XP'),
            Text('Min Tier: ${reward['min_trust_tier']}'),
            Text('Requires Khawi+: ${reward['requires_khawi_plus'] ?? false}'),
            const Divider(),
            Row(
              children: [
                Icon(
                  eligibility.eligible ? Icons.check_circle : Icons.error,
                  color: eligibility.eligible ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  eligibility.eligible
                      ? 'Would succeed (dry-run)'
                      : 'Would fail: ${eligibility.reason}',
                ),
              ],
            ),
            if (eligibility.eligible) ...[
              const SizedBox(height: 8),
              Text(
                'XP after: ${(_xpBalance ?? 0) - (reward['xp_cost'] as int? ?? 0)}',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EligibilityResult {
  final bool eligible;
  final String reason;
  const _EligibilityResult(this.eligible, this.reason);
}
