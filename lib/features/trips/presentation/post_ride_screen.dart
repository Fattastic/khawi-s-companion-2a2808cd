import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/features/gamification/presentation/post_trip_progress_card.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';
import 'package:khawi_flutter/features/ride_history/presentation/widgets/trip_receipt_sheet.dart';
import 'package:khawi_flutter/features/rating/presentation/rate_ride_sheet.dart';
import 'package:khawi_flutter/features/support/presentation/widgets/trip_issue_sheet.dart';
import 'package:khawi_flutter/state/providers.dart';

final _driverInfoProvider =
    FutureProvider.family<({String name, String id}), String>(
  (ref, tripId) async {
    final trip = await ref.watch(tripsRepoProvider).watchTrip(tripId).first;
    final profile =
        await ref.watch(profileRepoProvider).fetchProfileById(trip.driverId);
    final name = profile.fullName;
    return (name: name, id: trip.driverId);
  },
);

final _receiptEntryProvider =
    FutureProvider.family<RideHistoryEntry?, String>((ref, tripId) async {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return null;
  final entries = await ref
      .watch(rideHistoryRepoProvider)
      .fetchHistory(userId: uid, limit: 100);
  for (final entry in entries) {
    if (entry.tripId == tripId) return entry;
  }
  return null;
});

class PostRideScreen extends ConsumerWidget {
  final String tripId;
  const PostRideScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Fetch wallet to display real XP earned (fallback to '—')
    final walletAsync = ref.watch(walletSummaryProvider);
    final xpLabel = walletAsync.maybeWhen(
      data: (w) => '${w.availableBalance}',
      orElse: () => '—',
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.rideCompleted,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.postRideEarningsMessage(xpLabel),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // ── Gamification progress card ─────────────────────────────
              const PostTripProgressCard(),
              const SizedBox(height: 24),

              // Rate your ride button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ref.watch(_driverInfoProvider(tripId)).when(
                      data: (driver) => OutlinedButton.icon(
                        onPressed: () async {
                          final driverName = driver.name.isNotEmpty
                              ? driver.name
                              : l10n.driverLabel;
                          final result = await RateRideSheet.show(
                            context,
                            counterpartName: driverName,
                          );
                          if (result != null && context.mounted) {
                            final ratingRepo = ref.read(ratingRepoProvider);
                            await ratingRepo.submitRating(
                              tripId: tripId,
                              raterId: ref
                                      .read(authSessionProvider)
                                      .value
                                      ?.user
                                      .id ??
                                  '',
                              ratedId: driver.id,
                              score: result.score,
                              tags: result.tags,
                              comment: result.comment,
                            );
                            // Gamification: evaluate safety mission
                            unawaited(
                              ref
                                  .read(gamificationHookProvider)
                                  .onRatingSubmitted(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.ratingThanks),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.star, color: Colors.amber),
                        label: Text(l10n.rateYourRide),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      loading: () => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => OutlinedButton.icon(
                        onPressed: () async {
                          final result = await RateRideSheet.show(
                            context,
                            counterpartName: l10n.driverLabel,
                          );
                          if (result != null && context.mounted) {
                            final ratingRepo = ref.read(ratingRepoProvider);
                            await ratingRepo.submitRating(
                              tripId: tripId,
                              raterId: ref
                                      .read(authSessionProvider)
                                      .value
                                      ?.user
                                      .id ??
                                  '',
                              ratedId: '',
                              score: result.score,
                              tags: result.tags,
                              comment: result.comment,
                            );
                            unawaited(
                              ref
                                  .read(gamificationHookProvider)
                                  .onRatingSubmitted(),
                            );
                          }
                        },
                        icon: const Icon(Icons.star, color: Colors.amber),
                        label: Text(l10n.rateYourRide),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ref.watch(_receiptEntryProvider(tripId)).maybeWhen(
                      data: (entry) {
                        if (entry == null) return const SizedBox.shrink();
                        return OutlinedButton.icon(
                          onPressed: () =>
                              TripReceiptSheet.show(context, entry),
                          icon: const Icon(Icons.receipt_long),
                          label: Text(
                            Directionality.of(context) == TextDirection.rtl
                                ? 'عرض الإيصال'
                                : 'View Receipt',
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => TripIssueSheet.show(context, tripId: tripId),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(
                    Directionality.of(context) == TextDirection.rtl
                        ? 'إبلاغ عن مشكلة / مفقودات'
                        : 'Report issue / Lost & Found',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final location = GoRouterState.of(context).uri.toString();
                    final isDriverFlow = location.startsWith('/app/d/');
                    context.go(
                      isDriverFlow
                          ? Routes.driverDashboard
                          : Routes.passengerHome,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.backToHome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
