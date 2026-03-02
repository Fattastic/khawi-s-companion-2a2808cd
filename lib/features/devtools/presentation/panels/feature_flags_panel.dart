/// Feature Flag Inspector Panel - View and locally override feature flags.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Feature flag panel for viewing and locally overriding flags (debug-only).
class FeatureFlagPanel extends ConsumerStatefulWidget {
  const FeatureFlagPanel({super.key});

  @override
  ConsumerState<FeatureFlagPanel> createState() => _FeatureFlagPanelState();
}

class _FeatureFlagPanelState extends ConsumerState<FeatureFlagPanel> {
  List<_FlagEntry>? _flags;
  final _localOverrides = <String, bool>{};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('feature_flags')
          .select('name, enabled, rollout_percentage, description')
          .order('name');

      final list = (response as List)
          .map(
            (row) => _FlagEntry(
              name: row['name'] as String,
              enabled: row['enabled'] as bool? ?? false,
              rolloutPct: (row['rollout_percentage'] as num?)?.toInt() ?? 100,
              description: row['description'] as String? ?? '',
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() => _flags = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _flags = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _flags == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final flags = _flags ?? [];
    if (flags.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No flags found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFlags,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Feature Flags',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFlags,
            ),
          ],
        ),
        if (_localOverrides.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${_localOverrides.length} local override(s) active',
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _localOverrides.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ...flags.map(_buildFlagTile),
      ],
    );
  }

  Widget _buildFlagTile(_FlagEntry flag) {
    final hasOverride = _localOverrides.containsKey(flag.name);
    final effectiveValue = _localOverrides[flag.name] ?? flag.enabled;

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(flag.name, style: const TextStyle(fontSize: 14)),
            ),
            if (hasOverride)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('OVERRIDE', style: TextStyle(fontSize: 10)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (flag.description.isNotEmpty)
              Text(flag.description, style: const TextStyle(fontSize: 12)),
            Text(
              'Rollout: ${flag.rolloutPct}%',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Switch(
          value: effectiveValue,
          onChanged: (val) {
            setState(() {
              if (val == flag.enabled) {
                _localOverrides.remove(flag.name);
              } else {
                _localOverrides[flag.name] = val;
              }
            });
          },
        ),
      ),
    );
  }
}

class _FlagEntry {
  final String name;
  final bool enabled;
  final int rolloutPct;
  final String description;

  const _FlagEntry({
    required this.name,
    required this.enabled,
    required this.rolloutPct,
    required this.description,
  });
}
