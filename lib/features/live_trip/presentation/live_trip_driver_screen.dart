import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/features/trips/presentation/widgets/rating_dialog.dart';
import 'package:khawi_flutter/features/live_trip/presentation/live_tracking_controller.dart';
import 'package:khawi_flutter/features/live_trip/data/live_trip_counterpart_resolver.dart';
import 'package:khawi_flutter/features/live_trip/data/selected_rating_passenger_store.dart';
import 'package:khawi_flutter/features/live_trip/data/driver_navigation_links.dart';
import 'package:khawi_flutter/core/widgets/app_map.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/state/providers.dart';

final _selectedPassengerForRatingProvider =
    StateProvider.family<_TripPassengerItem?, String>(
  (ref, _) => null,
);

final _driverRouteRecalculatedAtProvider =
    StateProvider.family<DateTime?, String>((ref, _) => null);
final _driverZahmaWarningAtProvider =
    StateProvider.family<DateTime?, String>((ref, _) => null);

final _selectedRatingPassengerStoreProvider =
    Provider((ref) => SelectedRatingPassengerStore());

class _TripPassengerItem {
  final String id;
  final String name;
  final String status;

  const _TripPassengerItem({
    required this.id,
    required this.name,
    required this.status,
  });
}

final _selectedPassengerRestoreProvider =
    FutureProvider.family<_TripPassengerItem?, String>((ref, tripId) async {
  final raw =
      await ref.read(_selectedRatingPassengerStoreProvider).load(tripId);
  if (raw == null) return null;
  return _TripPassengerItem(
    id: raw['id']!,
    name: raw['name']!,
    status: raw['status']!,
  );
});

List<GeoPoint> _tripRoutePoints(Trip? trip) {
  if (trip == null) return const <GeoPoint>[];
  final route = <GeoPoint>[
    GeoPoint(trip.originLat, trip.originLng),
    ...trip.waypoints.map((stop) => GeoPoint(stop.lat, stop.lng)),
    GeoPoint(trip.destLat, trip.destLng),
  ];
  if (route.length < 2) return const <GeoPoint>[];

  final deduped = <GeoPoint>[];
  for (final point in route) {
    if (deduped.isEmpty || deduped.last != point) {
      deduped.add(point);
    }
  }
  return deduped;
}

String _tripRouteSignature(Trip trip) {
  final buffer = StringBuffer()
    ..write('${trip.originLat},${trip.originLng}|')
    ..write('${trip.destLat},${trip.destLng}|')
    ..write(trip.polyline ?? '');
  for (final stop in trip.waypoints) {
    buffer.write('|${stop.lat},${stop.lng}');
  }
  return buffer.toString();
}

/// Driver live trip view - shows real-time trip management.
/// This is a fullscreen experience outside the shell.
class LiveTripDriverScreen extends ConsumerWidget {
  final String tripId;
  const LiveTripDriverScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selectedPassenger =
        ref.watch(_selectedPassengerForRatingProvider(tripId));
    ref.listen<AsyncValue<_TripPassengerItem?>>(
      _selectedPassengerRestoreProvider(tripId),
      (_, next) {
        next.whenData((restored) {
          if (restored == null) return;
          final current = ref.read(_selectedPassengerForRatingProvider(tripId));
          if (current != null) return;
          ref.read(_selectedPassengerForRatingProvider(tripId).notifier).state =
              restored;
        });
      },
    );
    final streakAsync = ref.watch(streakProvider);
    final streakCount = streakAsync.value?.currentCount ?? 0;

    // Determine the glow color for the driver's map aura
    Color? auraColor;
    if (streakCount >= 7) {
      auraColor = Colors.purpleAccent; // Massive Streak
    } else if (streakCount >= 3) {
      auraColor = Colors.amber; // Fire Streak
    }

    final tripAsync = ref.watch(
      StreamProvider.family<Trip, String>(
        (ref, id) => ref.watch(tripsRepoProvider).watchTrip(id),
      )(tripId),
    );

    ref.listen<AsyncValue<Trip>>(
      StreamProvider.family<Trip, String>(
        (ref, id) => ref.watch(tripsRepoProvider).watchTrip(id),
      )(tripId),
      (previous, next) {
        final previousTrip = previous?.asData?.value;
        final nextTrip = next.asData?.value;
        if (previousTrip == null || nextTrip == null) return;
        if (_tripRouteSignature(previousTrip) !=
            _tripRouteSignature(nextTrip)) {
          final detectedAt = DateTime.now();
          ref.read(_driverRouteRecalculatedAtProvider(tripId).notifier).state =
              detectedAt;
          unawaited(
            Future<void>.delayed(const Duration(seconds: 6), () {
              final current =
                  ref.read(_driverRouteRecalculatedAtProvider(tripId));
              if (current == detectedAt) {
                ref
                    .read(_driverRouteRecalculatedAtProvider(tripId).notifier)
                    .state = null;
              }
            }),
          );
        }

        // Detect Zahma (Traffic) - ETA increase of > 3 mins
        final prevEta = previousTrip.etaMinutes;
        final nextEta = nextTrip.etaMinutes;
        if (prevEta != null && nextEta != null && nextEta > prevEta + 3) {
          final detectedAt = DateTime.now();
          ref.read(_driverZahmaWarningAtProvider(tripId).notifier).state =
              detectedAt;
          unawaited(
            Future<void>.delayed(const Duration(seconds: 10), () {
              final current = ref.read(_driverZahmaWarningAtProvider(tripId));
              if (current == detectedAt) {
                ref.read(_driverZahmaWarningAtProvider(tripId).notifier).state =
                    null;
              }
            }),
          );
        }
      },
    );

    // Start tracking location as a driver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveTrackingProvider(tripId).notifier).startDriverTracking();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'رحلتك المباشرة' : 'Your Live Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: isRtl ? 'إغلاق الخريطة' : 'Close map',
          onPressed: () => _confirmExit(context, isRtl),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos, color: Colors.red),
            tooltip: isRtl ? 'طوارئ' : 'Emergency',
            onPressed: () => _showEmergencyOptions(context, isRtl, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live Map
          ref.watch(liveTrackingProvider(tripId)).when(
                data: (pos) => AppMap(
                  initialCenter: pos != null
                      ? GeoPoint(pos.latitude, pos.longitude)
                      : const GeoPoint(24.7136, 46.6753),
                  initialZoom: 15,
                  recenterOnRouteChange: true,
                  routePoints: _tripRoutePoints(tripAsync.asData?.value),
                  markerPoints: pos != null
                      ? [GeoPoint(pos.latitude, pos.longitude)]
                      : [],
                  auraColor: auraColor,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

          // Trip Status Overlay
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_taxi,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isRtl ? 'أنت تقود الرحلة' : 'You\'re Driving',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          'ID: ${tripId.substring(0, 4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DriverTripStatusRow(
                      isRtl: isRtl,
                      trip: tripAsync.asData?.value,
                    ),
                    _DriverRouteRecalculatedHint(
                      isRtl: isRtl,
                      tripId: tripId,
                    ),
                    _DriverZahmaWarning(
                      isRtl: isRtl,
                      tripId: tripId,
                    ),
                    if (selectedPassenger != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_pin,
                              size: 16,
                              color: AppTheme.primaryGreenDark,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isRtl
                                    ? 'هدف التقييم: ${selectedPassenger.name}'
                                    : 'Rating target: ${selectedPassenger.name}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.primaryGreenDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(
                                      _selectedPassengerForRatingProvider(
                                        tripId,
                                      ).notifier,
                                    )
                                    .state = null;
                                unawaited(
                                  ref
                                      .read(
                                        _selectedRatingPassengerStoreProvider,
                                      )
                                      .clear(tripId),
                                );
                              },
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isRtl ? 'مسح' : 'Clear',
                                style: const TextStyle(
                                  color: AppTheme.primaryGreenDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push(Routes.chatPath(tripId)),
                            icon: const Icon(Icons.chat),
                            label: Text(isRtl ? 'المحادثة' : 'Chat'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmEndTrip(
                              context,
                              isRtl,
                              ref,
                              tripAsync.asData?.value,
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(isRtl ? 'إنهاء' : 'End'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () =>
                                _showPassengerList(context, isRtl, ref),
                            icon: const Icon(Icons.people_outline),
                            label: Text(isRtl ? 'قائمة الركاب' : 'Passengers'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _showTripDetails(
                              context,
                              isRtl,
                              tripAsync.asData?.value,
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: Text(isRtl ? 'التفاصيل' : 'Details'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _showNavigationOptions(
                          context,
                          isRtl,
                          tripAsync.asData?.value,
                        ),
                        icon: const Icon(Icons.navigation_outlined),
                        label: Text(isRtl ? 'الملاحة' : 'Navigate'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // FAB for quick chat
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.chatPath(tripId)),
        icon: const Icon(Icons.chat_bubble),
        label: Text(isRtl ? 'دردشة' : 'Chat'),
      ),
    );
  }

  void _confirmExit(BuildContext context, bool isRtl) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'مغادرة العرض؟' : 'Leave Trip View?'),
        content: Text(
          isRtl
              ? 'الرحلة ستستمر. يمكنك العودة من لوحة التحكم'
              : 'Trip will continue. You can return from Dashboard',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(Routes.driverDashboard);
            },
            child: Text(isRtl ? 'مغادرة' : 'Leave'),
          ),
        ],
      ),
    );
  }

  void _confirmEndTrip(
    BuildContext context,
    bool isRtl,
    WidgetRef ref,
    Trip? tripSnapshot,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'إنهاء الرحلة؟' : 'End Trip?'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد من إنهاء هذه الرحلة؟'
              : 'Are you sure you want to end this trip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              var selectedPassenger =
                  ref.read(_selectedPassengerForRatingProvider(tripId));
              if (selectedPassenger != null) {
                final stillActive = await _isPassengerStillInTrip(
                  ref,
                  selectedPassenger.id,
                );
                if (!stillActive) {
                  final stalePassengerId = selectedPassenger.id;
                  selectedPassenger = null;
                  ref
                      .read(
                        _selectedPassengerForRatingProvider(tripId).notifier,
                      )
                      .state = null;
                  await ref.read(_selectedRatingPassengerStoreProvider).clear(
                        tripId,
                      );
                  unawaited(
                    ref.read(eventLogProvider).logRatingTargetStaleCleared(
                          tripId: tripId,
                          passengerId: stalePassengerId,
                          source: 'end_trip_confirm',
                        ),
                  );
                  if (context.mounted) {
                    _showSelectionClearedSnackBar(
                      context,
                      isRtl,
                      ref,
                      previousPassengerId: stalePassengerId,
                    );
                  }
                }
              }

              // Call API to end trip
              try {
                // Call API to complete trip with explicit XP award
                await ref.read(tripsRepoProvider).completeTripV2(tripId);

                // Fire gamification lifecycle hook (fire-and-forget)
                unawaited(
                  ref.read(gamificationHookProvider).onTripCompleted(tripId),
                );

                final usedSelectedTarget = selectedPassenger != null;
                final passengerId = selectedPassenger?.id ??
                    await _resolvePassengerRateeId(ref);
                final passengerName = selectedPassenger?.name ??
                    (passengerId == null
                        ? null
                        : await resolveLiveTripProfileName(
                            ref.read(supabaseClientProvider),
                            passengerId,
                          ));

                if (context.mounted) {
                  if (passengerId == null || passengerId.isEmpty) {
                    unawaited(
                      ref.read(eventLogProvider).logRatingTargetMissing(
                            tripId: tripId,
                            source: 'end_trip_confirm',
                          ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isRtl
                              ? 'تعذر تحديد الراكب للتقييم'
                              : 'Could not determine passenger for rating',
                        ),
                      ),
                    );
                    return;
                  }

                  unawaited(
                    ref.read(eventLogProvider).logRatingTargetResolved(
                          tripId: tripId,
                          passengerId: passengerId,
                          resolutionSource:
                              usedSelectedTarget ? 'selected' : 'fallback',
                        ),
                  );

                  // For simplicity, we rate the "first" passenger or show a generic message
                  // In a real app, we would fetch the passenger list here
                  showRatingDialog(
                    context,
                    tripId: tripId,
                    rateeId: passengerId,
                    isRatingDriver: false,
                    rateeName: (passengerName != null &&
                            passengerName.trim().isNotEmpty)
                        ? passengerName
                        : (isRtl ? 'الراكب' : 'Passenger'),
                    originLabel: tripSnapshot?.originLabel,
                    destinationLabel: tripSnapshot?.destLabel,
                    waypointLabels: tripSnapshot?.waypoints
                            .map((stop) => stop.label)
                            .toList() ??
                        const <String>[],
                  );
                  ref
                      .read(
                        _selectedPassengerForRatingProvider(tripId).notifier,
                      )
                      .state = null;
                  unawaited(
                    ref
                        .read(_selectedRatingPassengerStoreProvider)
                        .clear(tripId),
                  );

                  // We don't go(Routes.driverDashboard) immediately because dialog is showing
                  // Instead, we can navigate after dialog closes or just show it on the dashboard
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isRtl
                            ? 'فشل إنهاء الرحلة: $e'
                            : 'Failed to end trip: $e',
                      ),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: isRtl ? 'حاول مرة أخرى' : 'Retry',
                        textColor: Colors.white,
                        onPressed: () =>
                            _confirmEndTrip(context, isRtl, ref, tripSnapshot),
                      ),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text(isRtl ? 'إنهاء' : 'End Trip'),
          ),
        ],
      ),
    );
  }

  Future<String?> _resolvePassengerRateeId(WidgetRef ref) async {
    final row = await ref
        .read(supabaseClientProvider)
        .from('trip_requests')
        .select('passenger_id,status')
        .eq('trip_id', tripId)
        .inFilter('status', ['completed', 'dropped_off', 'accepted'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return null;
    return row['passenger_id'] as String?;
  }

  void _showEmergencyOptions(BuildContext context, bool isRtl, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRtl ? 'خيارات الطوارئ' : 'Emergency Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.red),
                title: Text(isRtl ? 'اتصال بالطوارئ' : 'Call Emergency'),
                onTap: () {
                  Navigator.pop(ctx);
                  // Call Saudi emergency number (911)
                  launchUrl(Uri.parse('tel:911'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.orange),
                title: Text(isRtl ? 'إلغاء الرحلة' : 'Cancel Trip'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmEndTrip(context, isRtl, ref, null);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isRtl ? 'إلغاء' : 'Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNavigationOptions(
    BuildContext context,
    bool isRtl,
    Trip? trip,
  ) async {
    if (trip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRtl
                ? 'لا توجد بيانات كافية للملاحة الآن'
                : 'Navigation details are not available yet',
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Google Maps'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _launchNavigationUri(
                  context,
                  isRtl,
                  buildGoogleMapsNavigationUri(trip),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation_outlined),
              title: const Text('Apple Maps'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _launchNavigationUri(
                  context,
                  isRtl,
                  buildAppleMapsNavigationUri(trip),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alt_route),
              title: const Text('Waze'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await _launchNavigationUri(
                  context,
                  isRtl,
                  buildWazeNavigationUri(trip),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _launchNavigationUri(
    BuildContext context,
    bool isRtl,
    Uri uri,
  ) async {
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

  Future<void> _showPassengerList(
    BuildContext context,
    bool isRtl,
    WidgetRef ref,
  ) async {
    final passengers = await _fetchTripPassengers(ref, isRtl);
    final selectedPassenger =
        ref.read(_selectedPassengerForRatingProvider(tripId));
    var selectedPassengerId = selectedPassenger?.id;
    var clearedStaleSelection = false;
    String? staleClearedPassengerId;
    if (selectedPassengerId != null &&
        passengers.every((p) => p.id != selectedPassengerId)) {
      final String stalePassengerId = selectedPassengerId;
      selectedPassengerId = null;
      ref.read(_selectedPassengerForRatingProvider(tripId).notifier).state =
          null;
      await ref.read(_selectedRatingPassengerStoreProvider).clear(tripId);
      unawaited(
        ref.read(eventLogProvider).logRatingTargetStaleCleared(
              tripId: tripId,
              passengerId: stalePassengerId,
              source: 'passenger_list_open',
            ),
      );
      clearedStaleSelection = true;
      staleClearedPassengerId = stalePassengerId;
    }
    if (!context.mounted) return;
    if (clearedStaleSelection) {
      _showSelectionClearedSnackBar(
        context,
        isRtl,
        ref,
        previousPassengerId: staleClearedPassengerId,
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRtl ? 'الركاب' : 'Passengers',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (passengers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    isRtl
                        ? 'لا يوجد ركاب نشطون لهذه الرحلة'
                        : 'No active passengers for this trip',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                )
              else
                ...passengers.map(
                  (_TripPassengerItem passenger) => ListTile(
                    onTap: () {
                      ref
                          .read(
                            _selectedPassengerForRatingProvider(tripId)
                                .notifier,
                          )
                          .state = passenger;
                      unawaited(
                        ref.read(eventLogProvider).logRatingTargetSelected(
                              tripId: tripId,
                              passengerId: passenger.id,
                              source: 'passenger_list',
                            ),
                      );
                      unawaited(
                        ref.read(_selectedRatingPassengerStoreProvider).save(
                              tripId,
                              id: passenger.id,
                              name: passenger.name,
                              status: passenger.status,
                            ),
                      );
                      Navigator.pop(ctx);
                    },
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    title: Text(passenger.name),
                    subtitle:
                        Text(_passengerStatusLabel(passenger.status, isRtl)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedPassengerId == passenger.id) ...[
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '#${passenger.id.substring(0, passenger.id.length > 4 ? 4 : passenger.id.length)}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isRtl ? 'إغلاق' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<_TripPassengerItem>> _fetchTripPassengers(
    WidgetRef ref,
    bool isRtl,
  ) async {
    final requestsRaw = await ref
        .read(supabaseClientProvider)
        .from('trip_requests')
        .select('passenger_id,status,created_at')
        .eq('trip_id', tripId)
        .inFilter('status', ['accepted', 'completed', 'dropped_off']).order(
      'created_at',
      ascending: false,
    );

    final requestRows = (requestsRaw as List)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final latestByPassenger = <String, String>{};
    for (final row in requestRows) {
      final passengerId = row['passenger_id'] as String?;
      final status = row['status'] as String?;
      if (passengerId == null || passengerId.isEmpty) continue;
      if (status == null || status.isEmpty) continue;
      latestByPassenger.putIfAbsent(passengerId, () => status);
    }

    if (latestByPassenger.isEmpty) return const <_TripPassengerItem>[];

    final passengerIds = latestByPassenger.keys.toList(growable: false);
    final profilesRaw = await ref
        .read(supabaseClientProvider)
        .from('profiles')
        .select('id,full_name')
        .inFilter('id', passengerIds);

    final namesById = <String, String>{};
    for (final row in (profilesRaw as List).whereType<Map<String, dynamic>>()) {
      final id = row['id'] as String?;
      final fullName = (row['full_name'] as String?)?.trim();
      if (id == null || id.isEmpty) continue;
      if (fullName == null || fullName.isEmpty) continue;
      namesById[id] = fullName;
    }

    return passengerIds
        .map(
          (id) => _TripPassengerItem(
            id: id,
            name: namesById[id] ?? (isRtl ? 'راكب' : 'Passenger'),
            status: latestByPassenger[id] ?? 'accepted',
          ),
        )
        .toList(growable: false);
  }

  Future<bool> _isPassengerStillInTrip(
    WidgetRef ref,
    String passengerId,
  ) async {
    final row = await ref
        .read(supabaseClientProvider)
        .from('trip_requests')
        .select('id')
        .eq('trip_id', tripId)
        .eq('passenger_id', passengerId)
        .inFilter('status', ['accepted', 'completed', 'dropped_off'])
        .limit(1)
        .maybeSingle();
    return row != null;
  }

  String _passengerStatusLabel(String status, bool isRtl) {
    switch (status) {
      case 'completed':
        return isRtl ? 'مكتمل' : 'Completed';
      case 'dropped_off':
        return isRtl ? 'تم الإنزال' : 'Dropped off';
      case 'accepted':
      default:
        return isRtl ? 'مقبول' : 'Accepted';
    }
  }

  void _showSelectionClearedSnackBar(
    BuildContext context,
    bool isRtl,
    WidgetRef ref, {
    String? previousPassengerId,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isRtl
              ? 'تمت إزالة الراكب المحدد لعدم توفره في الرحلة'
              : 'Selected rating passenger was cleared because they are no longer in this trip',
        ),
        action: SnackBarAction(
          label: isRtl ? 'إعادة الاختيار' : 'Re-select',
          onPressed: () {
            unawaited(
              ref.read(eventLogProvider).logRatingTargetReselectClicked(
                    tripId: tripId,
                    source: 'stale_selection_snackbar',
                    previousPassengerId: previousPassengerId,
                  ),
            );
            unawaited(_showPassengerList(context, isRtl, ref));
          },
        ),
      ),
    );
  }

  void _showTripDetails(BuildContext context, bool isRtl, Trip? trip) {
    final stops = trip?.waypoints ?? const <TripWaypoint>[];
    final origin = trip?.originLabel ?? (isRtl ? 'نقطة الانطلاق' : 'Origin');
    final destination = trip?.destLabel ?? (isRtl ? 'الوجهة' : 'Destination');

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRtl ? 'تفاصيل الرحلة' : 'Trip Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _detailRow(isRtl ? 'رقم الرحلة' : 'Trip ID', tripId),
              _detailRow(isRtl ? 'الحالة' : 'Status', isRtl ? 'نشط' : 'Active'),
              _detailRow(isRtl ? 'من' : 'From', origin),
              _detailRow(isRtl ? 'إلى' : 'To', destination),
              if (stops.isNotEmpty)
                _detailRow(
                  isRtl ? 'التوقفات' : 'Stops',
                  stops.map((stop) => stop.label).join(' • '),
                ),
              if (trip?.etaMinutes != null)
                _detailRow(
                  isRtl ? 'وقت الوصول المتوقع' : 'ETA',
                  isRtl
                      ? '${trip!.etaMinutes} دقيقة'
                      : '${trip!.etaMinutes} min',
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isRtl ? 'إغلاق' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DriverTripStatusRow extends StatelessWidget {
  const _DriverTripStatusRow({
    required this.isRtl,
    required this.trip,
  });

  final bool isRtl;
  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);

    final eta = trip?.etaMinutes;
    late final String statusKey;
    late final Widget statusChild;

    if (trip == null) {
      statusKey = 'driver_status_loading';
      statusChild = Text(
        isRtl ? 'جاري تحديث حالة الرحلة...' : 'Updating trip status...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      );
    } else if (eta == null) {
      statusKey = 'driver_status_pending';
      statusChild = Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: AppTheme.info),
          const SizedBox(width: 6),
          Text(
            isRtl ? 'ETA: قريباً' : 'ETA: pending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    } else if (eta > 0) {
      statusKey = 'driver_status_eta_$eta';
      statusChild = Row(
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.info),
          const SizedBox(width: 6),
          Text(
            isRtl ? 'الوجهة خلال $eta دقيقة' : 'Destination in $eta min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    } else {
      statusKey = 'driver_status_arrived';
      statusChild = Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.success),
          const SizedBox(width: 6),
          Text(
            isRtl ? 'وصلت إلى الوجهة' : 'Arrived at destination',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    }

    return RepaintBoundary(
      child: AnimatedSize(
        duration: duration,
        alignment: Alignment.centerLeft,
        curve: Curves.easeOutCubic,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(statusKey),
            child: statusChild,
          ),
        ),
      ),
    );
  }
}

class _DriverRouteRecalculatedHint extends ConsumerWidget {
  const _DriverRouteRecalculatedHint({
    required this.isRtl,
    required this.tripId,
  });

  final bool isRtl;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final recalculatedAt =
        ref.watch(_driverRouteRecalculatedAtProvider(tripId));
    final showHint = recalculatedAt != null &&
        DateTime.now().difference(recalculatedAt).inSeconds < 6;

    return RepaintBoundary(
      child: AnimatedSize(
        duration: duration,
        alignment: Alignment.centerLeft,
        curve: Curves.easeOutCubic,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: showHint
              ? Padding(
                  key: const ValueKey('driver_route_recalc_hint'),
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alt_route,
                        size: 16,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRtl ? 'تم تحديث المسار' : 'Route updated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(
                  key: ValueKey('driver_route_recalc_empty'),
                ),
        ),
      ),
    );
  }
}

class _DriverZahmaWarning extends ConsumerWidget {
  const _DriverZahmaWarning({
    required this.isRtl,
    required this.tripId,
  });

  final bool isRtl;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const duration = Duration(milliseconds: 200);
    final zahmaAt = ref.watch(_driverZahmaWarningAtProvider(tripId));
    final showWarning = zahmaAt != null;

    return RepaintBoundary(
      child: AnimatedSize(
        duration: duration,
        alignment: Alignment.centerLeft,
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: duration,
          child: showWarning
              ? Padding(
                  key: const ValueKey('driver_zahma_warning'),
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRtl
                              ? 'تنبيه: زحمة مفاجئة'
                              : 'Zahma Warning: Traffic',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
