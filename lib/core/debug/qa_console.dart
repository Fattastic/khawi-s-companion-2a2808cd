/// QA Console - Debug-only testing and inspection tool.
///
/// Access: Hidden behind compile-time flag `ENABLE_QA_CONSOLE=true`
/// or 5 taps on version label in settings.
///
/// NEVER included in release builds.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/devtools/presentation/panels/backend_health_panel.dart';
import '../../features/devtools/presentation/panels/feature_flags_panel.dart';
import '../../features/devtools/presentation/panels/profile_inspector_panel.dart';
import '../../features/devtools/presentation/panels/rewards_inspector_panel.dart';
import '../../features/devtools/presentation/panels/scenario_runner_panel.dart';
import '../../features/devtools/presentation/panels/state_log_viewer_panel.dart';
import '../../features/devtools/presentation/panels/trust_badges_panel.dart';
import '../../features/devtools/presentation/panels/xp_engine_panel.dart';

/// Check if QA Console is enabled.
bool get isQaConsoleEnabled {
  if (kReleaseMode) return false;
  const enabled = bool.fromEnvironment('ENABLE_QA_CONSOLE', defaultValue: true);
  return enabled || kDebugMode;
}

/// Show QA Console as a modal bottom sheet.
void showQaConsole(BuildContext context) {
  if (!isQaConsoleEnabled) return;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const QaConsoleSheet(),
  );
}

/// QA Console main widget.
class QaConsoleSheet extends StatefulWidget {
  const QaConsoleSheet({super.key});

  @override
  State<QaConsoleSheet> createState() => _QaConsoleSheetState();
}

class _QaConsoleSheetState extends State<QaConsoleSheet> {
  int _selectedIndex = 0;

  final _panels = <_PanelInfo>[
    const _PanelInfo(
      icon: Icons.health_and_safety,
      label: 'Health',
      panel: BackendHealthPanel(),
    ),
    const _PanelInfo(
      icon: Icons.flag,
      label: 'Flags',
      panel: FeatureFlagPanel(),
    ),
    const _PanelInfo(
      icon: Icons.person,
      label: 'Profile',
      panel: ProfileInspectorPanel(),
    ),
    const _PanelInfo(icon: Icons.stars, label: 'XP', panel: XpEnginePanel()),
    const _PanelInfo(
      icon: Icons.card_giftcard,
      label: 'Rewards',
      panel: RewardsInspectorPanel(),
    ),
    const _PanelInfo(
      icon: Icons.verified,
      label: 'Trust',
      panel: TrustBadgesPanel(),
    ),
    const _PanelInfo(
      icon: Icons.play_arrow,
      label: 'Scenarios',
      panel: ScenarioRunnerPanel(),
    ),
    const _PanelInfo(
      icon: Icons.terminal,
      label: 'Logs',
      panel: StateLogViewerPanel(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _panels.map((p) => p.panel).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'QA Console',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'DEBUG ONLY',
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _panels.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final panel = _panels[index];
          final selected = index == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: FilterChip(
              selected: selected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(panel.icon, size: 16),
                  const SizedBox(width: 4),
                  Text(panel.label),
                ],
              ),
              onSelected: (_) => setState(() => _selectedIndex = index),
            ),
          );
        },
      ),
    );
  }
}

class _PanelInfo {
  final IconData icon;
  final String label;
  final Widget panel;

  const _PanelInfo({
    required this.icon,
    required this.label,
    required this.panel,
  });
}
