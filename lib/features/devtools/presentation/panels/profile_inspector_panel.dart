/// Profile Inspector Panel - View AI-visible profile signals.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Profile inspector showing AI-visible signals.
class ProfileInspectorPanel extends ConsumerStatefulWidget {
  const ProfileInspectorPanel({super.key});

  @override
  ConsumerState<ProfileInspectorPanel> createState() =>
      _ProfileInspectorPanelState();
}

class _ProfileInspectorPanelState extends ConsumerState<ProfileInspectorPanel> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _trustState;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        setState(() => _error = 'Not authenticated');
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final trust = await Supabase.instance.client
          .from('user_trust_state')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _trustState = trust;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Profile Signals (AI Input)', [
          _signalTile('Car Owner', _profile?['owns_car'] ?? false),
          _signalTile('Seats Available', _profile?['seats'] ?? 0),
          _signalTile('Car Condition', _profile?['car_condition'] ?? 'unknown'),
          _signalTile('Child Seat', _profile?['has_child_seat'] ?? false),
          _signalTile(
            'Verified Driver',
            _profile?['is_verified_driver'] ?? false,
          ),
          _signalTile('Khawi+', _profile?['subscription_tier'] ?? 'free'),
        ]),
        const SizedBox(height: 16),
        _buildSection('Role Flags', [
          _signalTile('Is Driver', _profile?['is_driver'] ?? false),
          _signalTile('Is Parent', _profile?['is_parent'] ?? false),
          _signalTile(
            'Is Family Driver',
            _profile?['is_family_driver'] ?? false,
          ),
        ]),
        const SizedBox(height: 16),
        _buildSection('Trust State', [
          _signalTile('Trust Tier', _trustState?['tier'] ?? 'bronze'),
          _signalTile(
            'Trust Score',
            _trustState?['score']?.toStringAsFixed(2) ?? 'N/A',
          ),
          _signalTile(
            'Confidence',
            _trustState?['confidence']?.toStringAsFixed(2) ?? 'N/A',
          ),
        ]),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _signalTile(String label, dynamic value) {
    String displayValue;
    Color? valueColor;

    if (value is bool) {
      displayValue = value ? '✓ Yes' : '✗ No';
      valueColor = value ? Colors.green : Colors.grey;
    } else {
      displayValue = value.toString();
    }

    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(
        displayValue,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
    );
  }
}
