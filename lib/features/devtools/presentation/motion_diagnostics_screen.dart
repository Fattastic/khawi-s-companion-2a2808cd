import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/state/app_settings.dart';
import 'package:khawi_flutter/core/widgets/level_progress_bar.dart';

/// Dev-only motion diagnostics screen used by QA and design reviews.
///
/// Goals:
/// - Validate reduced-motion behavior quickly.
/// - Exercise core animation primitives in isolation.
/// - Provide repeatable checks without external tooling.
class MotionDiagnosticsScreen extends ConsumerStatefulWidget {
  const MotionDiagnosticsScreen({super.key});

  @override
  ConsumerState<MotionDiagnosticsScreen> createState() =>
      _MotionDiagnosticsScreenState();
}

class _MotionDiagnosticsScreenState
    extends ConsumerState<MotionDiagnosticsScreen> {
  int _xp = 1200;
  bool _expanded = false;
  bool _pulse = false;
  bool _tickersEnabled = true;

  void _replayDemo() {
    setState(() {
      _xp += 65;
      _expanded = !_expanded;
      _pulse = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() => _pulse = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(reduceMotionProvider).maybeWhen(
          data: (v) => v,
          orElse: () => false,
        );
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final effectiveReduce = reduceMotion || disableAnimations;
    final duration =
        effectiveReduce ? Duration.zero : const Duration(milliseconds: 220);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Motion Diagnostics'),
      ),
      body: TickerMode(
        enabled: _tickersEnabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('App reduce motion: $reduceMotion'),
                    Text('MediaQuery.disableAnimations: $disableAnimations'),
                    Text('Effective reduced motion: $effectiveReduce'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Reduce motion (app setting)'),
                    subtitle: const Text('Should disable non-essential motion'),
                    value: reduceMotion,
                    onChanged: (v) async {
                      await ref
                          .read(reduceMotionProvider.notifier)
                          .setReduceMotion(v);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('TickerMode enabled'),
                    subtitle: const Text('Pause all tickers in this screen'),
                    value: _tickersEnabled,
                    onChanged: (v) => setState(() => _tickersEnabled = v),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _replayDemo,
                        child: const Text('Replay Demo'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XP Motion Sample',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        AnimatedScale(
                          duration: duration,
                          scale: _pulse ? 1.08 : 1.0,
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.stars_rounded,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: _xp.toDouble()),
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Text(
                              '${value.round()} XP',
                              style: Theme.of(context).textTheme.titleLarge,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LevelProgressBar(
                      value: (_xp % 1000) / 1000,
                      height: 10,
                      backgroundColor: AppTheme.borderLight,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Text(
                        '${1000 - (_xp % 1000)} XP until next level',
                        key: ValueKey(_xp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State Transition Sample',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(_expanded ? 'Collapse' : 'Expand'),
                    ),
                    AnimatedSize(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      child: _expanded
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Expanded content should animate in normal mode and snap/fade in reduced mode.',
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QA Checklist'),
                    SizedBox(height: 8),
                    Text('- Toggle reduce motion and replay demo'),
                    Text('- Confirm no essential info disappears'),
                    Text('- Confirm controls remain instantly usable'),
                    Text('- Confirm transitions are subtle and readable'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
