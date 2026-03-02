/// XP Engine Inspector Panel - Debug XP calculations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// XP Engine debugger panel.
class XpEnginePanel extends ConsumerStatefulWidget {
  const XpEnginePanel({super.key});

  @override
  ConsumerState<XpEnginePanel> createState() => _XpEnginePanelState();
}

class _XpEnginePanelState extends ConsumerState<XpEnginePanel> {
  // Simulation inputs
  double _distanceKm = 10.0;
  bool _isDriver = true;
  bool _isKidsTrip = false;
  int _passengerCount = 1;
  bool _isPeakHour = false;
  int _streakDays = 0;
  bool _isFlagged = false;
  int _samePairTripsToday = 0;

  @override
  Widget build(BuildContext context) {
    final result = _calculateXp();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'XP Calculator Simulator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildInputs(),
        const Divider(height: 32),
        _buildResults(result),
      ],
    );
  }

  Widget _buildInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sliderTile(
              'Distance',
              '${_distanceKm.toStringAsFixed(1)} km',
              _distanceKm,
              1,
              50,
              (v) => setState(() => _distanceKm = v),
            ),
            _switchTile(
              'Is Driver',
              _isDriver,
              (v) => setState(() => _isDriver = v),
            ),
            _switchTile(
              'Kids Trip',
              _isKidsTrip,
              (v) => setState(() => _isKidsTrip = v),
            ),
            _sliderTile(
              'Passengers',
              '$_passengerCount',
              _passengerCount.toDouble(),
              1,
              4,
              (v) => setState(() => _passengerCount = v.round()),
            ),
            _switchTile(
              'Peak Hour',
              _isPeakHour,
              (v) => setState(() => _isPeakHour = v),
            ),
            _sliderTile(
              'Streak Days',
              '$_streakDays',
              _streakDays.toDouble(),
              0,
              30,
              (v) => setState(() => _streakDays = v.round()),
            ),
            _switchTile(
              'Flagged Behavior',
              _isFlagged,
              (v) => setState(() => _isFlagged = v),
            ),
            _sliderTile(
              'Same Pair Trips Today',
              '$_samePairTripsToday',
              _samePairTripsToday.toDouble(),
              0,
              10,
              (v) => setState(() => _samePairTripsToday = v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderTile(
    String label,
    String valueLabel,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              valueLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildResults(_XpResult result) {
    return Card(
      color: result.blocked ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calculated XP',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  result.blocked ? 'BLOCKED' : '${result.finalXp} XP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: result.blocked ? Colors.red : Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            _resultRow('Base XP', result.baseXp),
            _resultRow('Distance Bonus', result.distanceBonus),
            _resultRow(
              'Role Multiplier',
              '×${result.roleMultiplier.toStringAsFixed(2)}',
            ),
            _resultRow('Streak Bonus', result.streakBonus),
            _resultRow('Peak Bonus', result.peakBonus),
            if (result.diminishingPenalty > 0)
              _resultRow(
                'Anti-Abuse Penalty',
                '-${result.diminishingPenalty}',
                isWarning: true,
              ),
            if (result.blocked)
              _resultRow('Reason', result.blockReason, isWarning: true),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, dynamic value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isWarning ? Colors.red : null)),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isWarning ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  _XpResult _calculateXp() {
    // Base XP
    const baseXp = 50;

    // Distance bonus (5 XP per km)
    final distanceBonus = (_distanceKm * 5).round();

    // Role multiplier
    double roleMultiplier = 1.0;
    if (_isDriver) {
      roleMultiplier = 1.2;
      if (_isKidsTrip) roleMultiplier = 1.5; // Kids trips earn more
    }

    // Passenger bonus for drivers
    final passengerBonus = _isDriver ? (_passengerCount - 1) * 20 : 0;

    // Streak bonus
    int streakBonus = 0;
    if (_streakDays >= 7) {
      streakBonus = 50;
    } else if (_streakDays >= 3) {
      streakBonus = 20;
    }

    // Peak hour bonus
    final peakBonus = _isPeakHour ? 25 : 0;

    // Anti-abuse: diminishing returns
    int diminishingPenalty = 0;
    if (_samePairTripsToday > 5) {
      diminishingPenalty = 75; // 75% reduction
    } else if (_samePairTripsToday > 3) {
      diminishingPenalty = 50; // 50% reduction
    }

    // Check if blocked
    bool blocked = false;
    String blockReason = '';
    if (_isFlagged) {
      blocked = true;
      blockReason = 'Behavior flagged - XP paused';
    }

    // Calculate final
    final beforePenalty =
        ((baseXp + distanceBonus + passengerBonus + streakBonus + peakBonus) *
                roleMultiplier)
            .round();
    final afterPenalty =
        (beforePenalty * (100 - diminishingPenalty) / 100).round();

    return _XpResult(
      baseXp: baseXp,
      distanceBonus: distanceBonus,
      roleMultiplier: roleMultiplier,
      streakBonus: streakBonus,
      peakBonus: peakBonus,
      diminishingPenalty: diminishingPenalty,
      finalXp: blocked ? 0 : afterPenalty,
      blocked: blocked,
      blockReason: blockReason,
    );
  }
}

class _XpResult {
  final int baseXp;
  final int distanceBonus;
  final double roleMultiplier;
  final int streakBonus;
  final int peakBonus;
  final int diminishingPenalty;
  final int finalXp;
  final bool blocked;
  final String blockReason;

  const _XpResult({
    required this.baseXp,
    required this.distanceBonus,
    required this.roleMultiplier,
    required this.streakBonus,
    required this.peakBonus,
    required this.diminishingPenalty,
    required this.finalXp,
    required this.blocked,
    required this.blockReason,
  });
}
