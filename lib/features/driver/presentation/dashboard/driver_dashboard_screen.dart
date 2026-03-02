import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/core/widgets/slow_network_banner.dart';
import 'package:khawi_flutter/features/gamification/presentation/mission_card_list.dart';
import 'package:khawi_flutter/features/gamification/presentation/next_best_action_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/progress_milestone_banner.dart';
import 'package:khawi_flutter/features/gamification/presentation/streak_card.dart';
import 'package:khawi_flutter/features/gamification/presentation/wallet_summary_tile.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';
import 'package:khawi_flutter/core/widgets/app_map.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/core/widgets/app_shimmer.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';

// Required for Profile methods
import 'package:khawi_flutter/features/profile/presentation/trust_badge.dart';
import 'package:khawi_flutter/features/driver/presentation/controllers/driver_dashboard_controller.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/trips/presentation/incentive_chip.dart';
import 'package:khawi_flutter/state/providers.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      body: SlowNetworkBanner(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const _DashboardSliverHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KhawiMotion.slideUpFadeIn(
                      index: 0,
                      _DriverMilestoneBanner(isRtl: isRtl),
                    ),
                    KhawiMotion.slideUpFadeIn(
                      index: 1,
                      const _OnlineStatusSection(),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 2,
                      _DriverActions(isRtl: isRtl),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 3,
                      const _IncentiveSection(),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 4,
                      const _DemandHeatmapSection(),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 5,
                      const _DriverEarningsSection(),
                    ),
                    const SizedBox(height: 32),
                    KhawiMotion.slideUpFadeIn(
                      index: 6,
                      _StatsGrid(isRtl: isRtl),
                    ),
                    const SizedBox(height: 32),
                    KhawiMotion.slideUpFadeIn(
                      index: 7,
                      const _ActiveTripSection(),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 8,
                      const NextBestActionCard(),
                    ),
                    const SizedBox(height: 12),
                    KhawiMotion.slideUpFadeIn(
                      index: 9,
                      const StreakCard(),
                    ),
                    const SizedBox(height: 12),
                    KhawiMotion.slideUpFadeIn(
                      index: 10,
                      const MissionCardList(),
                    ),
                    const SizedBox(height: 12),
                    KhawiMotion.slideUpFadeIn(
                      index: 11,
                      const WalletSummaryTile(),
                    ),
                    const SizedBox(height: 24),
                    KhawiMotion.slideUpFadeIn(
                      index: 12,
                      Text(
                        isRtl ? "الطلبات الواردة" : "Incoming Requests",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KhawiMotion.slideUpFadeIn(
                      index: 13,
                      const _IncomingRequestsList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), // SlowNetworkBanner
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.driverOfferRide),
        backgroundColor: AppTheme.driverAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isRtl ? "عرض رحلة جديدة" : "Offer New Ride",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DriverMilestoneBanner extends StatelessWidget {
  const _DriverMilestoneBanner({required this.isRtl});

  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return ProgressMilestoneBanner(isRtl: isRtl);
  }
}

class _DashboardSliverHeader extends ConsumerWidget {
  const _DashboardSliverHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.driverAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.driverGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (p) => Column(
                    crossAxisAlignment: isRtl
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRtl
                            ? 'كابتن ${p.fullName.split(' ')[0]}'
                            : 'Captain ${p.fullName.split(' ')[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // TrustBadge handles nulls gracefully?
                      // If p.trustBadge is null, we show new driver
                      if (p.trustBadge != null)
                        TrustBadge(
                          score: (p.trustScore ?? 50).toInt(),
                          badge: p.trustBadge!,
                          isJuniorTrusted: p.isVerified,
                        )
                      else
                        Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRtl ? 'سائق جديد' : 'New Driver',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (err, stack) => Text(
                    isRtl ? 'كابتن' : 'Captain',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                profileAsync.when(
                  data: (p) => Text(
                    '${p.totalXp} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: AppShimmer.box(width: 120, height: 32),
                  ),
                  error: (_, __) => const Text(
                    '0 XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'Community XP',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnlineStatusSection extends ConsumerWidget {
  const _OnlineStatusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicit generic type to help analyzer
    final isOnline = ref.watch(
      driverDashboardControllerProvider
          .select((DriverDashboardState s) => s.isOnline),
    );
    final controller = ref.read(driverDashboardControllerProvider.notifier);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      hasBorder: true,
      hasShadow: true,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.success : AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isOnline
                ? (isRtl ? "أنت متصل" : "You are Online")
                : (isRtl ? "أنت غير متصل" : "You are Offline"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Switch(
            value: isOnline,
            onChanged: (_) => controller.toggleOnline(),
            // ignore: deprecated_member_use
            activeColor: AppTheme.driverAccent,
          ),
        ],
      ),
    );
  }
}

class _DriverActions extends StatelessWidget {
  final bool isRtl;
  const _DriverActions({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                Icons.timeline,
                isRtl ? 'المخطط' : 'Planner',
                () => context.go(Routes.driverPlanner),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                context,
                Icons.qr_code_2,
                isRtl ? 'QR سريع' : 'Instant QR',
                () => context.go(Routes.driverInstantQr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                Icons.inbox_outlined,
                isRtl ? 'الطلبات' : 'Queue',
                () => context.go(Routes.driverQueue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                context,
                Icons.event_repeat,
                isRtl ? 'المعتادة' : 'Regular',
                () => context.go(Routes.driverRegularTrips),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.driverAccent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _IncentiveSection extends ConsumerWidget {
  const _IncentiveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incentives = ref
        .watch(driverDashboardControllerProvider.select((s) => s.incentives));
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (incentives.isEmpty) return const SizedBox.shrink();

    final main = incentives.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                isRtl ? "مكافأة ساعة الذروة!" : "Peak Hour Bonus!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IncentiveChip(
                multiplier: main.multiplier,
                reason: main.reasonTag,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? "مفعل في ${main.areaKey}: مضاعف XP ${main.multiplier}x."
                : "Active in ${main.areaKey}: ${main.multiplier}x XP Multiplier.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          if (incentives.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                isRtl
                    ? "+${incentives.length - 1} مناطق أخرى نشطة"
                    : "+${incentives.length - 1} other active zones",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isRtl;
  const _StatsGrid({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final summaryAsync = ref.watch(_driverEarningsProvider);
        final profileAsync = ref.watch(myProfileProvider);

        final rides = summaryAsync.maybeWhen(
          data: (v) => v.totalRides.toString(),
          orElse: () => '--',
        );
        final xp = summaryAsync.maybeWhen(
          data: (v) => '+${v.totalXp}',
          orElse: () => '--',
        );
        final rating = profileAsync.maybeWhen(
          data: (p) => p.averageRating?.toStringAsFixed(1) ?? '--',
          orElse: () => '--',
        );

        return Row(
          children: [
            Expanded(
              child: _DriverStatCard(
                label: isRtl ? "الرحلات" : "Rides",
                value: rides,
                icon: Icons.drive_eta_rounded,
                color: AppTheme.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DriverStatCard(
                label: isRtl ? "التقييم" : "Rating",
                value: rating,
                icon: Icons.star_rounded,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DriverStatCard(
                label: "XP",
                value: xp,
                icon: Icons.bolt_rounded,
                color: AppTheme.warning,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DriverEarningsSection extends ConsumerWidget {
  const _DriverEarningsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final earningsAsync = ref.watch(_driverEarningsProvider);

    return earningsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        return AppCard(
          padding: const EdgeInsets.all(16),
          hasBorder: true,
          hasShadow: true,
          child: Column(
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isRtl ? 'لوحة الأرباح' : 'Earnings Dashboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EarningMetricCard(
                      title: isRtl ? 'اليوم' : 'Today',
                      rides: summary.todayRides,
                      xp: summary.todayXp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _EarningMetricCard(
                      title: isRtl ? 'هذا الأسبوع' : 'This Week',
                      rides: summary.weekRides,
                      xp: summary.weekXp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _EarningMetricCard(
                      title: isRtl ? 'هذا الشهر' : 'This Month',
                      rides: summary.monthRides,
                      xp: summary.monthXp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EarningMetricCard extends StatelessWidget {
  final String title;
  final int rides;
  final int xp;

  const _EarningMetricCard({
    required this.title,
    required this.rides,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      color: AppTheme.backgroundNeutral,
      hasBorder: true,
      hasShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '$rides',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '+$xp XP',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryGreenDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripSection extends ConsumerWidget {
  const _ActiveTripSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptedRequests = ref.watch(
      driverDashboardControllerProvider.select((s) => s.acceptedRequests),
    );
    final bundleResult = ref
        .watch(driverDashboardControllerProvider.select((s) => s.bundleResult));
    final isLoading =
        ref.watch(driverDashboardControllerProvider.select((s) => s.isLoading));
    final controller = ref.read(driverDashboardControllerProvider.notifier);

    if (acceptedRequests.isEmpty) return const SizedBox.shrink();

    if (bundleResult != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: AppCard(
          padding: const EdgeInsets.all(20),
          hasBorder: true,
          // Assuming we need driver accent border, we override the default logic, but since it's just AppCard, we might lose the explicit thick driverAccent border unless we allow side customization in AppCard.
          // Let's use pure AppCard with default properties to strictly enforce the reductive design uniformity across V3.
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, color: AppTheme.driverAccent),
                  const SizedBox(width: 8),
                  Text(
                    Directionality.of(context) == TextDirection.rtl
                        ? "مسار مُحسن بالذكاء الاصطناعي"
                        : "AI Optimized Route",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.clearBundle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...bundleResult.stops.map((BundleStop stop) {
                final type = stop.type == 'pickup' ? "Pickup" : "Dropoff";
                return Padding(
                  key: ValueKey('bundle_stop_${stop.lat}_${stop.lng}_$type'),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        type == "Pickup"
                            ? Icons.person_pin_circle
                            : Icons.pin_drop,
                        size: 16,
                        color: type == "Pickup"
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text("$type: ${stop.label}")),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _showNavigationOptions(context, bundleResult),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.driverAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    Directionality.of(context) == TextDirection.rtl
                        ? "افتح الملاحة"
                        : "Open Navigation",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Directionality.of(context) == TextDirection.rtl
              ? "الركاب النشطون (${acceptedRequests.length})"
              : "Active Passengers (${acceptedRequests.length})",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...acceptedRequests.map(
          (req) => Card(
            key: ValueKey('accepted_req_${req.id}'),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                "Passenger ${req.passengerId.length > 4 ? req.passengerId.substring(0, 4) : req.passengerId}",
              ),
              subtitle: const Text("Status: Accepted"),
              trailing: const Icon(Icons.check_circle, color: AppTheme.success),
            ),
          ),
        ),
        if (acceptedRequests.length >= 2) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : controller.triggerBundle,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                isLoading
                    ? (Directionality.of(context) == TextDirection.rtl
                        ? "جاري التحسين..."
                        : "Optimizing...")
                    : (Directionality.of(context) == TextDirection.rtl
                        ? "تجميع المحطات (AI)"
                        : "Bundle Stops (AI)"),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.driverAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

Future<void> _showNavigationOptions(
  BuildContext context,
  BundleResult bundleResult,
) async {
  final routeStops = bundleResult.stops
      .where((stop) => stop.lat != null && stop.lng != null)
      .toList(growable: false);
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  if (routeStops.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRtl
              ? 'لا توجد إحداثيات كافية للملاحة'
              : 'No route coordinates available for navigation',
        ),
      ),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: Text(isRtl ? 'Google Maps' : 'Google Maps'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _openInGoogleMaps(context, routeStops);
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation_outlined),
              title: Text(isRtl ? 'Apple Maps' : 'Apple Maps'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _openInAppleMaps(context, routeStops);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alt_route),
              title: Text(isRtl ? 'Waze' : 'Waze'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _openInWaze(context, routeStops);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> _openInGoogleMaps(
  BuildContext context,
  List<BundleStop> routeStops,
) async {
  final destination = routeStops.last;
  final waypoints =
      routeStops.take(routeStops.length - 1).toList(growable: false);
  final uri = Uri.https(
    'www.google.com',
    '/maps/dir/',
    {
      'api': '1',
      'destination': '${destination.lat!},${destination.lng!}',
      'travelmode': 'driving',
      if (waypoints.isNotEmpty)
        'waypoints':
            waypoints.map((BundleStop s) => '${s.lat!},${s.lng!}').join('|'),
    },
  );
  await _launchNavigationUri(context, uri);
}

Future<void> _openInAppleMaps(
  BuildContext context,
  List<BundleStop> routeStops,
) async {
  final destination = routeStops.last;
  final uri = Uri.https(
    'maps.apple.com',
    '/',
    {
      'daddr': '${destination.lat!},${destination.lng!}',
      'dirflg': 'd',
    },
  );
  await _launchNavigationUri(context, uri);
}

Future<void> _openInWaze(
  BuildContext context,
  List<BundleStop> routeStops,
) async {
  final destination = routeStops.last;
  final uri = Uri.parse(
    'https://waze.com/ul?ll=${destination.lat!},${destination.lng!}&navigate=yes',
  );
  await _launchNavigationUri(context, uri);
}

Future<void> _launchNavigationUri(BuildContext context, Uri uri) async {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  if (await canLaunchUrl(uri)) {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (launched) return;
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isRtl ? 'تعذّر فتح تطبيق الملاحة' : 'Could not open navigation app',
      ),
    ),
  );
}

class _IncomingRequestsList extends ConsumerWidget {
  const _IncomingRequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicit generic annotation
    final reqs = ref.watch(
      driverDashboardControllerProvider
          .select((DriverDashboardState s) => s.incomingRequests),
    );
    final controller = ref.read(driverDashboardControllerProvider.notifier);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (reqs.isEmpty) {
      return AppEmptyState(
        icon: Icons.inbox_outlined,
        title: isRtl ? "لا توجد طلبات منتظرة" : "No waiting requests",
        subtitle: isRtl
            ? "ستظهر الطلبات الجديدة هنا"
            : "New requests will appear here",
        isRtl: isRtl,
        ctaLabel: isRtl ? "تقديم رحلة" : "Offer a Ride",
        onCta: () => context.push(Routes.driverOfferRide),
      );
    }

    return Column(
      children: reqs
          .map(
            (req) => _RequestCard(
              key: ValueKey('incoming_req_${req.id}'),
              req: req,
              controller: controller,
            ),
          )
          .toList(),
    );
  }
}

class _DriverStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DriverStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TripRequest req;
  final DriverDashboardController controller;

  const _RequestCard({super.key, required this.req, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundColor: AppTheme.driverAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Directionality.of(context) == TextDirection.rtl
                            ? "طلب راكب"
                            : "Passenger Request",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Match Score: 94%",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.success),
                      ),
                    ],
                  ),
                ),
                Text(
                  Directionality.of(context) == TextDirection.rtl
                      ? "+45 XP"
                      : "+45 XP",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.declineRequest(req.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptRequest(req.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DriverEarningsSummary {
  final int todayRides;
  final int weekRides;
  final int monthRides;
  final int todayXp;
  final int weekXp;
  final int monthXp;
  final int totalRides;
  final int totalXp;

  const DriverEarningsSummary({
    required this.todayRides,
    required this.weekRides,
    required this.monthRides,
    required this.todayXp,
    required this.weekXp,
    required this.monthXp,
    required this.totalRides,
    required this.totalXp,
  });
}

final _driverEarningsProvider =
    FutureProvider.autoDispose<DriverEarningsSummary>((ref) async {
  final uid = ref.watch(userIdProvider);
  if (uid == null) {
    return const DriverEarningsSummary(
      todayRides: 0,
      weekRides: 0,
      monthRides: 0,
      todayXp: 0,
      weekXp: 0,
      monthXp: 0,
      totalRides: 0,
      totalXp: 0,
    );
  }

  final entries = await ref.watch(rideHistoryRepoProvider).fetchHistory(
        userId: uid,
        limit: 300,
      );

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  int countSince(DateTime start) =>
      entries.where((e) => !e.departureTime.isBefore(start)).length;

  int xpSince(DateTime start) {
    return entries
        .where((e) => !e.departureTime.isBefore(start))
        .fold<int>(0, (sum, e) => sum + (e.xpEarned ?? 45));
  }

  final totalXp = entries.fold<int>(0, (sum, e) => sum + (e.xpEarned ?? 45));

  return DriverEarningsSummary(
    todayRides: countSince(todayStart),
    weekRides: countSince(weekStart),
    monthRides: countSince(monthStart),
    todayXp: xpSince(todayStart),
    weekXp: xpSince(weekStart),
    monthXp: xpSince(monthStart),
    totalRides: entries.length,
    totalXp: totalXp,
  );
});

class _DemandHeatmapSection extends ConsumerWidget {
  const _DemandHeatmapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandPoints = ref.watch(
      driverDashboardControllerProvider.select((s) => s.demandPoints),
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (demandPoints.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(16),
      hasBorder: true,
      hasShadow: true,
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                isRtl ? "توقعات الطلب" : "Demand Forecast",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRtl ? "مباشر" : "LIVE",
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  AppMap(
                    demandPoints: demandPoints,
                    initialZoom: 12,
                    // Center on the first high demand point if available
                    initialCenter: GeoPoint(
                      demandPoints.first.lat,
                      demandPoints.first.lng,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      heroTag: 'zoom_to_demand',
                      onPressed: () {
                        // Full screen heatmap navigation would go here
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.fullscreen,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isRtl
                ? "مناطق الطلب العالي متوقعة في الرياض."
                : "High demand areas predicted in Riyadh.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
