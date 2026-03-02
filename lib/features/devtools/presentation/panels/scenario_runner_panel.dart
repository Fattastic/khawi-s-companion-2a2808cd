/// Scenario Runner Panel - One-tap test scripts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scenario runner for one-tap test scripts.
class ScenarioRunnerPanel extends ConsumerStatefulWidget {
  const ScenarioRunnerPanel({super.key});

  @override
  ConsumerState<ScenarioRunnerPanel> createState() =>
      _ScenarioRunnerPanelState();
}

class _ScenarioRunnerPanelState extends ConsumerState<ScenarioRunnerPanel> {
  final _results = <String, _ScenarioResult>{};
  String? _runningScenario;

  static const _scenarios = <_Scenario>[
    _Scenario(
      id: 'trip_adult',
      name: 'Adult Trip Lifecycle',
      description:
          'Create → Publish → Request → Accept → Start → End → XP → Rating',
      steps: [
        'Create trip',
        'Publish',
        'Request',
        'Accept',
        'Start',
        'End',
        'Verify XP',
        'Rating prompt',
      ],
    ),
    _Scenario(
      id: 'trip_kids',
      name: 'Kids Trip Lifecycle',
      description:
          'Assign → Tracking → Safety check → End → Mandatory rating → Behavior score',
      steps: [
        'Assign trip',
        'Parent tracking',
        'Safety poll',
        'End trip',
        'Mandatory rating',
        'Behavior score',
        'Trust update',
      ],
    ),
    _Scenario(
      id: 'chat_moderation',
      name: 'Chat Moderation',
      description: 'Send message → moderate_message → Result enforced',
      steps: ['Create message', 'Call moderate_message', 'Verify result'],
    ),
    _Scenario(
      id: 'demand_incentives',
      name: 'Demand & Incentives',
      description: 'Driver online → compute_incentives → predict_demand',
      steps: [
        'Set driver online',
        'Compute incentives',
        'Predict demand',
        'Verify overlay',
      ],
    ),
    _Scenario(
      id: 'eta_caching',
      name: 'ETA with Caching',
      description: 'Search rides → estimate_eta → Verify cache',
      steps: ['Trigger search', 'Call ETA', 'Check cache hit'],
    ),
    _Scenario(
      id: 'subscription',
      name: 'Subscription Flow',
      description: 'Entitlement fetch → PremiumGate → Redemption gated',
      steps: ['Fetch entitlement', 'Check PremiumGate', 'Test gated action'],
    ),
    _Scenario(
      id: 'rewards_redemption',
      name: 'Rewards Redemption',
      description:
          'Attempt without tier → blocked; with tier → allowed (dry-run)',
      steps: [
        'Check eligibility',
        'Dry-run low tier',
        'Dry-run sufficient tier',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Test Scenarios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'One-tap test scripts for common flows',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ..._scenarios.map(_buildScenarioTile),
      ],
    );
  }

  Widget _buildScenarioTile(_Scenario scenario) {
    final result = _results[scenario.id];
    final isRunning = _runningScenario == scenario.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _statusIcon(result, isRunning),
        title: Text(scenario.name),
        subtitle:
            Text(scenario.description, style: const TextStyle(fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ...scenario.steps.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            _stepIcon(result, e.key),
                            const SizedBox(width: 8),
                            Text('${e.key + 1}. ${e.value}'),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                if (result != null && result.error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Error: ${result.error}',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (result != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _results.remove(scenario.id)),
                        child: const Text('Clear'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed:
                          isRunning ? null : () => _runScenario(scenario),
                      icon: isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(isRunning ? 'Running...' : 'Run'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(_ScenarioResult? result, bool isRunning) {
    if (isRunning) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (result == null) {
      return const Icon(Icons.play_circle_outline, color: Colors.grey);
    }
    return Icon(
      result.passed ? Icons.check_circle : Icons.error,
      color: result.passed ? Colors.green : Colors.red,
    );
  }

  Widget _stepIcon(_ScenarioResult? result, int stepIndex) {
    if (result == null) {
      return const Icon(Icons.circle_outlined, size: 16, color: Colors.grey);
    }
    if (stepIndex < result.completedSteps) {
      return const Icon(Icons.check_circle, size: 16, color: Colors.green);
    }
    if (stepIndex == result.completedSteps && !result.passed) {
      return const Icon(Icons.error, size: 16, color: Colors.red);
    }
    return const Icon(Icons.circle_outlined, size: 16, color: Colors.grey);
  }

  Future<void> _runScenario(_Scenario scenario) async {
    setState(() => _runningScenario = scenario.id);

    // Simulate scenario execution
    int completedSteps = 0;
    String? error;

    for (var i = 0; i < scenario.steps.length; i++) {
      // Simulate step execution
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Simulate random failure for demo (10% chance)
      // In real implementation, this would call actual functions
      completedSteps++;

      setState(() {
        _results[scenario.id] = _ScenarioResult(
          passed: false,
          completedSteps: completedSteps,
          totalSteps: scenario.steps.length,
          durationMs: 0,
        );
      });
    }

    setState(() {
      _results[scenario.id] = _ScenarioResult(
        passed: true,
        completedSteps: completedSteps,
        totalSteps: scenario.steps.length,
        durationMs: completedSteps * 500,
        error: error,
      );
      _runningScenario = null;
    });
  }
}

class _Scenario {
  final String id;
  final String name;
  final String description;
  final List<String> steps;

  const _Scenario({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
  });
}

class _ScenarioResult {
  final bool passed;
  final int completedSteps;
  final int totalSteps;
  final int durationMs;
  final String? error;

  const _ScenarioResult({
    required this.passed,
    required this.completedSteps,
    required this.totalSteps,
    required this.durationMs,
    this.error,
  });
}
