import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';
import 'package:khawi_flutter/core/widgets/app_section_header.dart';
import 'package:khawi_flutter/core/widgets/responsive_container.dart';
import 'package:khawi_flutter/core/widgets/slow_network_banner.dart';
import 'package:khawi_flutter/features/gamification/presentation/mission_card_list.dart';
import 'package:khawi_flutter/features/gamification/presentation/next_best_action_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/progress_milestone_banner.dart';
import 'package:khawi_flutter/features/gamification/presentation/streak_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/wallet_summary_tile.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_active_trip_banner.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_primary_ctas.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_quick_links.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_search_bar.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_sliver_header.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_stats_row.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/smart_match_promo.dart';
import 'package:khawi_flutter/features/circles/presentation/widgets/circle_navigator_card.dart';
import 'package:khawi_flutter/features/circles/data/mock_circles_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final l10n = AppLocalizations.of(context);
    final circles = ref.watch(mockCirclesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SlowNetworkBanner(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const PassengerSliverHeader(),
            SliverToBoxAdapter(
              child: ResponsiveContainer(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KhawiMotion.slideUpFadeIn(
                      ProgressMilestoneBanner(isRtl: isRtl),
                      index: 0,
                    ),
                    KhawiMotion.slideUpFadeIn(
                      _HeroCommandSurface(isRtl: isRtl),
                      index: 1,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    AppSectionHeader(
                      title: l10n?.regular ?? 'Your Routines',
                      actionLabel: l10n?.seeAll,
                      onAction: () {},
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: circles.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 300,
                            child: CircleNavigatorCard(circle: circles[index]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _LiveDemandBar(),
                      index: 2,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _QuickDestinationRow(),
                      index: 4,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _ServiceTierRow(),
                      index: 5,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _CommandShortcutRail(),
                      index: 6,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _RecentPlacesPanel(),
                      index: 7,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const NextBestActionCard(),
                      index: 8,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const StreakCard(),
                      index: 9,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      const WalletSummaryTile(),
                      index: 10,
                    ),
                    KhawiMotion.slideUpFadeIn(
                      const MissionCardList(),
                      index: 11,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const PassengerActiveTripBanner(),
                      index: 12,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const _EtaConfidenceRail(),
                      index: 13,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const PassengerSearchBar(),
                      index: 14,
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    KhawiMotion.slideUpFadeIn(
                      const _RoutePreviewStrip(),
                      index: 15,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      const _PrimaryRideActionBar(),
                      index: 16,
                    ),
                    const SizedBox(height: 8),
                    KhawiMotion.slideUpFadeIn(
                      const _ActionBarHint(),
                      index: 17,
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    KhawiMotion.slideUpFadeIn(
                      const PassengerPrimaryCtas(),
                      index: 18,
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    KhawiMotion.slideUpFadeIn(
                      const _PreferenceChipRow(),
                      index: 19,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      AppSectionHeader(
                        title: l10n?.quickActions ?? 'Quick Actions',
                        textAlign: TextAlign.start,
                      ),
                      index: 20,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const PassengerQuickLinks(),
                      index: 21,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      const SmartMatchPromo(),
                      index: 22,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      const _RideConfidencePanel(),
                      index: 23,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    KhawiMotion.slideUpFadeIn(
                      AppSectionHeader(
                        title: l10n?.todaySummary ?? 'Today',
                        textAlign: TextAlign.start,
                      ),
                      index: 24,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    KhawiMotion.slideUpFadeIn(
                      const PassengerStatsRow(),
                      index: 25,
                    ),
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

class _HeroCommandSurface extends ConsumerWidget {
  const _HeroCommandSurface({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = ref.watch(nowProvider);
    final greeting = _greeting(now.hour, l10n: l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C7043), Color(0xFF23A36A), Color(0xFF69D59A)],
        ),
        boxShadow: AppTheme.shadowColored(AppTheme.primaryGreenDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  greeting,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.passengerHeroTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.passengerHeroSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatusPill(
                  icon: Icons.bolt_rounded,
                  label: l10n.statusQuickPickup,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusPill(
                  icon: Icons.verified_user_outlined,
                  label: l10n.statusTrustedRides,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting(int hour, {required AppLocalizations l10n}) {
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickDestinationRow extends StatelessWidget {
  const _QuickDestinationRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _DestinationChip(
            icon: Icons.home_outlined,
            label: l10n.quickDestHome,
          ),
          const SizedBox(width: 8),
          _DestinationChip(icon: Icons.work_outline, label: l10n.quickDestWork),
          const SizedBox(width: 8),
          _DestinationChip(
            icon: Icons.school_outlined,
            label: l10n.quickDestSchool,
          ),
          const SizedBox(width: 8),
          _DestinationChip(
            icon: Icons.flight_takeoff,
            label: l10n.quickDestAirport,
          ),
        ],
      ),
    );
  }
}

class _LiveDemandBar extends StatelessWidget {
  const _LiveDemandBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsets.all(12),
      hasBorder: true,
      hasShadow: false,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.demandNormal,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              l10n.demandStatusStable,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryGreenDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandShortcutRail extends StatelessWidget {
  const _CommandShortcutRail();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CommandShortcut(
            icon: Icons.bookmark_border,
            title: l10n.shortcutSavedPlaces,
            subtitle: l10n.shortcutSavedPlacesSubtitle,
          ),
          const SizedBox(width: 10),
          _CommandShortcut(
            icon: Icons.history_toggle_off,
            title: l10n.shortcutRepeatLastTrip,
            subtitle: l10n.shortcutRepeatLastTripSubtitle,
          ),
          const SizedBox(width: 10),
          _CommandShortcut(
            icon: Icons.group_outlined,
            title: l10n.shortcutFamilyRide,
            subtitle: l10n.shortcutFamilyRideSubtitle,
          ),
        ],
      ),
    );
  }
}

class _CommandShortcut extends StatelessWidget {
  const _CommandShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      padding: const EdgeInsets.all(12),
      hasBorder: true,
      width: 156, // Apply width directly
      crossAxisAlignment: CrossAxisAlignment.start, // Optional, safe sizing
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.backgroundNeutral,
            child: Icon(icon, size: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPlacesPanel extends StatelessWidget {
  const _RecentPlacesPanel();

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Simulate an empty places list to show the empty state
    // In a real app, this would be an active check like `if (recentPlaces.isEmpty)`
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: AppEmptyState(
        icon: Icons.history_rounded,
        title: isRtl ? 'لا توجد أماكن حديثة' : 'No recent places',
        subtitle:
            isRtl ? 'ستظهر رحلاتك هنا' : 'Your recent trips will appear here',
        isRtl: isRtl,
      ),
    );
  }
}

class _ServiceTierRow extends StatefulWidget {
  const _ServiceTierRow();

  @override
  State<_ServiceTierRow> createState() => _ServiceTierRowState();
}

class _ServiceTierRowState extends State<_ServiceTierRow> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiers = [
      (
        title: l10n.serviceTierSaver,
        eta: l10n.serviceTierSaverEta,
        priceHint: l10n.serviceTierSaverHint,
        icon: Icons.local_taxi_outlined,
      ),
      (
        title: l10n.serviceTierComfort,
        eta: l10n.serviceTierComfortEta,
        priceHint: l10n.serviceTierComfortHint,
        icon: Icons.airline_seat_recline_normal_outlined,
      ),
      (
        title: l10n.serviceTierWomenPlus,
        eta: l10n.serviceTierWomenPlusEta,
        priceHint: l10n.serviceTierWomenPlusHint,
        icon: Icons.woman_2_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(tiers.length, (i) {
          final tier = tiers[i];
          final card = _ServiceTierCard(
            title: tier.title,
            eta: tier.eta,
            priceHint: tier.priceHint,
            icon: tier.icon,
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          );
          if (i == 0) return card;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 10),
            child: card,
          );
        }),
      ),
    );
  }
}

class _ServiceTierCard extends StatelessWidget {
  const _ServiceTierCard({
    required this.title,
    required this.eta,
    required this.priceHint,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String eta;
  final String priceHint;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        selected ? AppTheme.primaryGreen.withValues(alpha: 0.08) : Colors.white;

    return AppCard(
      onTap: onTap,
      color: bgColor,
      hasBorder: true,
      // Pass the visual selection down through a custom border/shadow logic wrapper or let AppCard handle tap states.
      // We keep the internal layout simple and structured.
      padding: const EdgeInsets.all(12),
      width: 140, // Move width to outer container
      crossAxisAlignment: CrossAxisAlignment.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  eta,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            priceHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (selected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'Recommended', // Or Localized
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EtaConfidenceRail extends StatelessWidget {
  const _EtaConfidenceRail();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _EtaMetricTile(
            icon: Icons.schedule_outlined,
            title: l10n.etaPickupTitle,
            value: l10n.etaPickupValue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EtaMetricTile(
            icon: Icons.route_outlined,
            title: l10n.routeReliabilityTitle,
            value: l10n.routeReliabilityValue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _EtaMetricTile(
            icon: Icons.security_outlined,
            title: l10n.safetyScoreTitle,
            value: l10n.safetyScoreValue,
          ),
        ),
      ],
    );
  }
}

class _EtaMetricTile extends StatelessWidget {
  const _EtaMetricTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      hasBorder: true,
      hasShadow: false, // Keep it flat as a rail item
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Preference { noConversation, coolAC, womenOnly, extraLuggage }

class _PreferenceChipRow extends StatefulWidget {
  const _PreferenceChipRow();

  @override
  State<_PreferenceChipRow> createState() => _PreferenceChipRowState();
}

class _PreferenceChipRowState extends State<_PreferenceChipRow> {
  final Set<_Preference> _selected = {
    _Preference.noConversation,
    _Preference.coolAC,
  };

  String _getLabel(BuildContext context, _Preference pref) {
    final l10n = AppLocalizations.of(context)!;
    switch (pref) {
      case _Preference.noConversation:
        return l10n.prefNoConversation;
      case _Preference.coolAC:
        return l10n.prefCoolAC;
      case _Preference.womenOnly:
        return l10n.prefWomenOnly;
      case _Preference.extraLuggage:
        return l10n.prefExtraLuggage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _Preference.values
          .map(
            (pref) => _PreferenceChip(
              label: _getLabel(context, pref),
              selected: _selected.contains(pref),
              onTap: () {
                setState(() {
                  if (_selected.contains(pref)) {
                    _selected.remove(pref);
                  } else {
                    _selected.add(pref);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    selected ? AppTheme.primaryGreenDark : AppTheme.textPrimary,
              ),
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: AppTheme.radiusFull,
      hasBorder: true,
      hasShadow: false,
      crossAxisAlignment:
          CrossAxisAlignment.center, // Make safe for wrap content
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RoutePreviewStrip extends StatelessWidget {
  const _RoutePreviewStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsets.all(12),
      hasBorder: true,
      hasShadow: false,
      child: Row(
        children: [
          const Column(
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 12,
                color: AppTheme.primaryGreenDark,
              ),
              SizedBox(height: 2),
              SizedBox(
                width: 2,
                height: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppTheme.borderColor),
                ),
              ),
              Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.routePreviewPickup,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  l10n.routePreviewDropoff,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '~14 SAR',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryRideActionBar extends StatelessWidget {
  const _PrimaryRideActionBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 52,
            child: PulseAnimation(
              minScale: 0.99,
              maxScale: 1.01,
              duration: const Duration(milliseconds: 1400),
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_taxi_outlined),
                label: Text(l10n.rideNowLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreenDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.schedule),
              label: Text(l10n.rideLaterLabel),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          width: 52,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}

class _ActionBarHint extends StatelessWidget {
  const _ActionBarHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 14,
          color: AppTheme.textSecondary.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l10n.rideNowHint,
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

class _RideConfidencePanel extends StatelessWidget {
  const _RideConfidencePanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConfidenceTile(
          icon: Icons.local_police_outlined,
          title: l10n.confidenceTrustedDriverTitle,
          subtitle: l10n.confidenceTrustedDriverSubtitle,
        ),
        const SizedBox(height: 12),
        _ConfidenceTile(
          icon: Icons.route_outlined,
          title: l10n.confidenceLiveRoutingTitle,
          subtitle: l10n.confidenceLiveRoutingSubtitle,
        ),
        const SizedBox(height: 12),
        _ConfidenceTile(
          icon: Icons.support_agent_outlined,
          title: l10n.confidenceFastSupportTitle,
          subtitle: l10n.confidenceFastSupportSubtitle,
        ),
      ],
    );
  }
}

class _ConfidenceTile extends StatelessWidget {
  const _ConfidenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
          child: Icon(icon, size: 18, color: AppTheme.primaryGreenDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
