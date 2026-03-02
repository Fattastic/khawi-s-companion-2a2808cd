import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';
import 'package:khawi_flutter/state/providers.dart';

class PassengerStatsRow extends ConsumerWidget {
  const PassengerStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context);

    return profileAsync.when(
      data: (profile) => Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _StatCard(
              label: l10n?.xp ?? 'XP',
              value: _formatNumber(profile.totalXp),
              icon: Icons.bolt_rounded,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: isRtl ? "كم" : "KM",
              value: "—",
              icon: Icons.route_rounded,
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: _StatCard(
              label: "CO₂",
              value: "—",
              icon: Icons.eco_rounded,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
      loading: () => Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(child: _ShimmerStat()),
          SizedBox(width: 12),
          Expanded(child: _ShimmerStat()),
          SizedBox(width: 12),
          Expanded(child: _ShimmerStat()),
        ],
      ),
      error: (err, stack) => AppEmptyState(
        icon: Icons.insights_outlined,
        title: l10n?.couldNotLoadSummary ??
            (isRtl ? 'تعذر تحميل الملخص' : "Couldn't load your summary"),
        subtitle: l10n?.checkConnectionAndTryAgain ??
            (isRtl
                ? 'تحقق من الاتصال ثم حاول مرة ثانية.'
                : 'Check your connection and try again.'),
        ctaLabel: l10n?.retry ?? (isRtl ? 'إعادة المحاولة' : 'Retry'),
        onCta: () => ref.invalidate(myProfileProvider),
        isRtl: isRtl,
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}

class _ShimmerStat extends StatelessWidget {
  const _ShimmerStat();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
