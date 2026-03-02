/// Trust & Badges Panel - Inspect trust tiers and badges.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Trust tiers and badges inspector panel.
class TrustBadgesPanel extends ConsumerStatefulWidget {
  const TrustBadgesPanel({super.key});

  @override
  ConsumerState<TrustBadgesPanel> createState() => _TrustBadgesPanelState();
}

class _TrustBadgesPanelState extends ConsumerState<TrustBadgesPanel> {
  Map<String, dynamic>? _trustState;
  List<Map<String, dynamic>>? _badges;
  List<Map<String, dynamic>>? _events;
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
      if (userId == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      // Load trust state
      final trust = await Supabase.instance.client
          .from('user_trust_state')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Load user badges with catalog join
      final badges = await Supabase.instance.client
          .from('user_badges_v2')
          .select('*, badges_catalog(*)')
          .eq('user_id', userId)
          .eq('status', 'earned')
          .order('earned_at', ascending: false);

      // Load recent trust events
      final events = await Supabase.instance.client
          .from('trust_events')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      setState(() {
        _trustState = trust;
        _badges = List<Map<String, dynamic>>.from(badges);
        _events = List<Map<String, dynamic>>.from(events);
      });
    } catch (e) {
      debugPrint('Error loading trust data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _trustState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTrustCard(),
        const SizedBox(height: 16),
        _buildBadgesSection(),
        const SizedBox(height: 16),
        _buildEventsSection(),
      ],
    );
  }

  Widget _buildTrustCard() {
    final tier = _trustState?['tier'] as String? ?? 'bronze';
    final score = (_trustState?['score'] as num?)?.toDouble() ?? 0.0;
    final confidence = (_trustState?['confidence'] as num?)?.toDouble() ?? 0.0;

    final tierColors = {
      'bronze': Colors.brown,
      'silver': Colors.grey,
      'gold': Colors.amber,
      'platinum': Colors.blueGrey,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 48, color: tierColors[tier]),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tierColors[tier],
                      ),
                    ),
                    Text(
                      'Trust Tier',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metricChip('Score', score.toStringAsFixed(1)),
                _metricChip(
                  'Confidence',
                  '${(confidence * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earned Badges',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_badges?.isEmpty ?? true)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No badges earned yet'),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _badges!.map((badge) {
              final catalog = badge['badges_catalog'] as Map<String, dynamic>?;
              return Chip(
                avatar: const Icon(Icons.star, size: 18),
                label: Text((catalog?['code'] as String?) ?? 'Unknown'),
                backgroundColor: _badgeColor(catalog?['visibility'] as String?),
              );
            }).toList(),
          ),
      ],
    );
  }

  Color _badgeColor(String? visibility) {
    switch (visibility) {
      case 'public':
        return Colors.blue.shade100;
      case 'kids_only':
        return Colors.pink.shade100;
      case 'private':
        return Colors.grey.shade200;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trust Events (Recent)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_events?.isEmpty ?? true)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No trust events'),
            ),
          )
        else
          ...(_events!.take(5).map(
                (event) => Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text((event['event_type'] as String?) ?? 'Unknown'),
                    subtitle: Text(
                      '${event['from_tier'] ?? '?'} → ${event['to_tier'] ?? '?'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      _formatDate(event['created_at']),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'N/A';
    }
  }
}
