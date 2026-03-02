import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_providers.dart';
import 'package:khawi_flutter/state/providers.dart';

class AppointedDriverDashScreen extends ConsumerStatefulWidget {
  const AppointedDriverDashScreen({super.key});

  @override
  ConsumerState<AppointedDriverDashScreen> createState() =>
      _AppointedDriverDashScreenState();
}

class _AppointedDriverDashScreenState
    extends ConsumerState<AppointedDriverDashScreen> {
  int _modeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final assignedRunsAsync = ref.watch(assignedJuniorRunsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(title: Text(l10n?.familyDriverTitle ?? 'Family Driver')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          KhawiMotion.slideUpFadeIn(
            _InviteHero(
              onRedeem: () => _showRedeemInviteDialog(context, ref),
            ),
            index: 0,
          ),
          const SizedBox(height: 12),
          KhawiMotion.slideUpFadeIn(
            const Row(
              children: [
                Text(
                  'Assigned Runs',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.task_alt,
                  size: 18,
                  color: AppTheme.primaryGreenDark,
                ),
              ],
            ),
            index: 1,
          ),
          const SizedBox(height: 8),
          assignedRunsAsync.when(
            data: (runs) {
              final counts = _RunCounts.from(runs);
              final filtered = _filterRuns(runs, _modeIndex);
              return Column(
                children: [
                  KhawiMotion.slideUpFadeIn(
                    _DriverModeSwitch(
                      selected: _modeIndex,
                      counts: counts,
                      onChanged: (idx) => setState(() => _modeIndex = idx),
                    ),
                    index: 2,
                  ),
                  const SizedBox(height: 8),
                  KhawiMotion.slideUpFadeIn(
                    const _DriverReadinessCard(),
                    index: 3,
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    _EmptyModeState(modeIndex: _modeIndex)
                  else
                    ...filtered.map((r) => _RunCard(run: r)),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$e',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.invalidate(assignedJuniorRunsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<JuniorRun> _filterRuns(List<JuniorRun> runs, int modeIndex) {
    final now = DateTime.now();
    switch (modeIndex) {
      case 1:
        return runs
            .where(
              (r) =>
                  r.status == 'planned' ||
                  (r.status == 'driver_assigned' && r.pickupTime.isAfter(now)),
            )
            .toList();
      case 2:
        return runs.where((r) => r.status == 'completed').toList();
      case 0:
      default:
        return runs
            .where(
              (r) =>
                  r.status == 'driver_assigned' ||
                  r.status == 'picked_up' ||
                  r.status == 'arrived',
            )
            .toList();
    }
  }

  static Future<void> _showRedeemInviteDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ctl = TextEditingController();
    bool loading = false;
    String? error;

    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Redeem invite code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctl,
                  decoration: const InputDecoration(
                    labelText: 'Invite code',
                    hintText: 'Example: AB12CD',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: loading
                        ? null
                        : () async {
                            final data = await Clipboard.getData('text/plain');
                            final text = data?.text?.trim() ?? '';
                            if (text.isEmpty) return;
                            ctl.text =
                                text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                          },
                    icon: const Icon(Icons.content_paste_go_outlined),
                    label: const Text('Paste code'),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          final result = await ref
                              .read(juniorRepoProvider)
                              .redeemInviteCode(
                                code: ctl.text.trim(),
                              );
                          if ((result['success'] as bool?) != true) {
                            throw Exception('Invalid or expired invite code');
                          }
                          ref.invalidate(assignedJuniorRunsProvider);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invite confirmed. You can now receive assigned runs.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!ctx.mounted) return;
                          setState(() {
                            loading = false;
                            error = e.toString();
                          });
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Redeem'),
              ),
            ],
          ),
        ),
      );
    } finally {
      ctl.dispose();
    }
  }
}

class _InviteHero extends StatelessWidget {
  const _InviteHero({required this.onRedeem});

  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowColored(AppTheme.primaryGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite-Only Confirmation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the guardian invite code to activate your family-driver access.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onRedeem,
              icon: const Icon(Icons.verified_user),
              label: const Text('Redeem invite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreenDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunCounts {
  const _RunCounts({
    required this.now,
    required this.scheduled,
    required this.completed,
  });

  final int now;
  final int scheduled;
  final int completed;

  factory _RunCounts.from(List<JuniorRun> runs) {
    final nowCount = runs
        .where(
          (r) =>
              r.status == 'driver_assigned' ||
              r.status == 'picked_up' ||
              r.status == 'arrived',
        )
        .length;
    final scheduledCount = runs
        .where((r) => r.status == 'planned' || r.status == 'driver_assigned')
        .length;
    final completedCount = runs.where((r) => r.status == 'completed').length;
    return _RunCounts(
      now: nowCount,
      scheduled: scheduledCount,
      completed: completedCount,
    );
  }
}

class _DriverModeSwitch extends StatelessWidget {
  const _DriverModeSwitch({
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final int selected;
  final _RunCounts counts;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Now', 'Scheduled', 'Completed'];
    final values = [counts.now, counts.scheduled, counts.completed];

    return Semantics(
      label: 'Run mode selector',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final isActive = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryGreen.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${labels[i]} (${values[i]})',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isActive
                              ? AppTheme.primaryGreenDark
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DriverReadinessCard extends StatelessWidget {
  const _DriverReadinessCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _ReadinessRow(
              icon: Icons.verified_user_outlined,
              title: 'Invite confirmation required',
            ),
            SizedBox(height: 8),
            _ReadinessRow(
              icon: Icons.location_on_outlined,
              title: 'Live location is shared during active runs',
            ),
            SizedBox(height: 8),
            _ReadinessRow(
              icon: Icons.support_agent_outlined,
              title: 'SOS escalation remains active for guardians',
            ),
          ],
        ),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run});

  final JuniorRun run;

  @override
  Widget build(BuildContext context) {
    final runShortId = run.id.length > 6 ? run.id.substring(0, 6) : run.id;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(Routes.liveAppointedPath(run.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.directions_car,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Run $runShortId',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        _RunStatusBadge(status: run.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pickup: ${run.pickupTime.toLocal().toString().split(".").first}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _RunTimeline(status: run.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyModeState extends StatelessWidget {
  const _EmptyModeState({required this.modeIndex});

  final int modeIndex;

  @override
  Widget build(BuildContext context) {
    final text = switch (modeIndex) {
      0 => 'No active runs at the moment.',
      1 => 'No scheduled runs yet.',
      2 => 'No completed runs yet.',
      _ => 'No runs available.',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _RunStatusBadge extends StatelessWidget {
  const _RunStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final color = switch (lower) {
      'planned' => AppTheme.info,
      'driver_assigned' => AppTheme.warning,
      'picked_up' => AppTheme.primaryGreenDark,
      'arrived' => AppTheme.primaryGreen,
      'completed' => AppTheme.success,
      'cancelled' => AppTheme.error,
      _ => AppTheme.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _RunTimeline extends StatelessWidget {
  const _RunTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    const steps = ['planned', 'picked_up', 'arrived', 'completed'];
    final currentIndex = steps.indexOf(status.toLowerCase());

    return Row(
      children: List.generate(steps.length, (i) {
        final isReached = currentIndex >= i && currentIndex != -1;
        final isLast = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isReached
                      ? AppTheme.primaryGreenDark
                      : AppTheme.borderColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 2,
                    color: isReached
                        ? AppTheme.primaryGreenDark.withValues(alpha: 0.6)
                        : AppTheme.borderColor,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppTheme.backgroundNeutral,
          child: Icon(icon, size: 15, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
