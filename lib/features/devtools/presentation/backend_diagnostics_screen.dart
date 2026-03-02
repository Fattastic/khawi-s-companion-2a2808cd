import 'package:flutter/material.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/backend_health_panel.dart';

import 'package:khawi_flutter/features/devtools/presentation/panels/feature_flags_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/persona_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/xp_engine_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/rewards_inspector_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/trust_badges_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/scenario_runner_panel.dart';
import 'package:khawi_flutter/features/devtools/presentation/panels/state_log_viewer_panel.dart';

class BackendDiagnosticsScreen extends StatelessWidget {
  const BackendDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: 'Health', icon: Icon(Icons.health_and_safety_outlined)),
      Tab(text: 'Flags', icon: Icon(Icons.toggle_on_outlined)),
      Tab(text: 'Persona', icon: Icon(Icons.people_outline)),
      Tab(text: 'XP', icon: Icon(Icons.star_outline)),
      Tab(text: 'Rewards', icon: Icon(Icons.card_giftcard_outlined)),
      Tab(text: 'Trust', icon: Icon(Icons.shield_outlined)),
      Tab(text: 'Scenarios', icon: Icon(Icons.play_circle_outline)),
      Tab(text: 'State', icon: Icon(Icons.data_object_outlined)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Khawi QA Console'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            BackendHealthPanel(),
            FeatureFlagPanel(),
            PersonaPanel(),
            XpEnginePanel(),
            RewardsInspectorPanel(),
            TrustBadgesPanel(),
            ScenarioRunnerPanel(),
            StateLogViewerPanel(),
          ],
        ),
      ),
    );
  }
}
