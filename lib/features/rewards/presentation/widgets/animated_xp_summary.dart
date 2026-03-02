import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';

/// Animated XP summary surface used in rewards contexts.
///
/// It keeps motion subtle and state-driven:
/// - XP total and bar interpolate when total XP changes.
/// - A short +XP chip appears after gains.
/// - Level transitions pulse lightly.
class AnimatedXpSummary extends StatefulWidget {
  const AnimatedXpSummary({
    super.key,
    required this.totalXp,
    required this.isRtl,
    this.levelSpan = 1000,
  });

  final int totalXp;
  final bool isRtl;
  final int levelSpan;

  @override
  State<AnimatedXpSummary> createState() => _AnimatedXpSummaryState();
}

class _AnimatedXpSummaryState extends State<AnimatedXpSummary> {
  Timer? _deltaTimer;
  Timer? _pulseTimer;
  int _latestGain = 0;
  bool _levelPulse = false;

  @override
  void didUpdateWidget(covariant AnimatedXpSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.totalXp <= oldWidget.totalXp) return;

    final gain = widget.totalXp - oldWidget.totalXp;
    final oldLevel = oldWidget.totalXp ~/ widget.levelSpan;
    final newLevel = widget.totalXp ~/ widget.levelSpan;

    _deltaTimer?.cancel();
    _pulseTimer?.cancel();
    setState(() {
      _latestGain = gain;
      _levelPulse = newLevel > oldLevel;
    });

    _deltaTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _latestGain = 0);
    });
    if (_levelPulse) {
      _pulseTimer = Timer(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        setState(() => _levelPulse = false);
      });
    }
  }

  @override
  void dispose() {
    _deltaTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final standardDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 220);
    final emphasizedDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 320);
    final level = widget.totalXp ~/ widget.levelSpan + 1;
    final progress = (widget.totalXp % widget.levelSpan) / widget.levelSpan;
    final untilNext = widget.levelSpan - (widget.totalXp % widget.levelSpan);
    final showGainChip = !reduceMotion && _latestGain > 0;

    return Column(
      children: [
        Row(
          children: [
            AnimatedScale(
              scale: _levelPulse && !reduceMotion ? 1.08 : 1,
              duration: emphasizedDuration,
              curve: Curves.easeOutCubic,
              child: const Icon(
                Icons.stars_rounded,
                color: AppTheme.accentGold,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: widget.totalXp.toDouble(),
                    ),
                    duration: standardDuration,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final display = value.round();
                      return Text(
                        widget.isRtl ? '$display نقاط XP' : '$display Total XP',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                  AnimatedSwitcher(
                    duration: standardDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Text(
                      widget.isRtl
                          ? 'عضو المستوى $level'
                          : 'Level $level Member',
                      key: ValueKey(level),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: standardDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: showGainChip
                  ? Container(
                      key: ValueKey(_latestGain),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+$_latestGain XP',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryGreenDark,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('xp_gain_empty')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LevelProgressBar(
          value: progress,
          level: level,
          gradient: AppTheme.goldGradient,
          glowColor: AppTheme.accentGold,
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: standardDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Text(
            widget.isRtl
                ? '$untilNext XP للمستوى التالي'
                : '$untilNext XP until next level',
            key: ValueKey(untilNext),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
