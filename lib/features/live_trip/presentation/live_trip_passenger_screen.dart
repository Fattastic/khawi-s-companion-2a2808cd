import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/features/live_trip/presentation/live_tracking_controller.dart';
import 'package:khawi_flutter/core/widgets/app_map.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/features/gamification/data/gamification_providers.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/services/emergency_contacts_service.dart';

/// Passenger live trip view - shows real-time trip progress.
/// This is a fullscreen experience outside the shell.
final _autoSharedProvider =
    StateProvider.family<bool, String>((ref, _) => false);
final _arrivalDetectedAtProvider =
    StateProvider.family<DateTime?, String>((ref, _) => null);
final _routeRecalculatedAtProvider =
    StateProvider.family<DateTime?, String>((ref, _) => null);
final _clockTickerProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream.periodic(
    const Duration(seconds: 1),
    (tick) => tick,
  ),
);

DateTime? deriveArrivalDetectedAt({
  required int? etaMinutes,
  required DateTime? currentArrivalDetectedAt,
  required DateTime now,
}) {
  if (etaMinutes != null && etaMinutes <= 0) {
    return currentArrivalDetectedAt ?? now;
  }
  return null;
}

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

class LiveTripPassengerScreen extends ConsumerWidget {
  final String tripId;
  const LiveTripPassengerScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
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
        next.whenData((trip) {
          final current = ref.read(_arrivalDetectedAtProvider(tripId));
          final derived = deriveArrivalDetectedAt(
            etaMinutes: trip.etaMinutes,
            currentArrivalDetectedAt: current,
            now: DateTime.now(),
          );
          if (derived != current) {
            ref.read(_arrivalDetectedAtProvider(tripId).notifier).state =
                derived;
          }

          final previousTrip = previous?.asData?.value;
          if (previousTrip == null) return;
          if (_tripRouteSignature(previousTrip) != _tripRouteSignature(trip)) {
            final detectedAt = DateTime.now();
            ref.read(_routeRecalculatedAtProvider(tripId).notifier).state =
                detectedAt;
            unawaited(
              Future<void>.delayed(const Duration(seconds: 6), () {
                final current = ref.read(_routeRecalculatedAtProvider(tripId));
                if (current == detectedAt) {
                  ref
                      .read(_routeRecalculatedAtProvider(tripId).notifier)
                      .state = null;
                }
              }),
            );
          }
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

    // Listen for trip completion
    ref.listen<AsyncValue<TripStatus>>(
      StreamProvider.family<TripStatus, String>(
        (ref, id) => ref.watch(tripsRepoProvider).streamTripStatus(id),
      )(tripId),
      (previous, next) {
        next.whenData((status) {
          if (status == TripStatus.completed) {
            // Navigate to the post-ride screen (gamification + rating + receipt)
            if (context.mounted) {
              context.go(Routes.passengerPostRidePath(tripId));
            }
          }
          if (status == TripStatus.active) {
            final alreadyShared = ref.read(_autoSharedProvider(tripId));
            if (alreadyShared) return;
            ref.read(_autoSharedProvider(tripId).notifier).state = true;
            unawaited(_autoShareTripIfEnabled(ref, isRtl));
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'Ø±Ø­Ù„ØªÙƒ Ø§Ù„Ù…Ø¨Ø§Ø´Ø±Ø©' : 'Your Live Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: isRtl ? 'إغلاق الخريطة' : 'Close map',
          onPressed: () => _confirmExit(context, isRtl),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos, color: Colors.red),
            tooltip: isRtl ? 'Ø·ÙˆØ§Ø±Ø¦' : 'Emergency',
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
                          Icons.directions_car,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isRtl
                                ? 'Ø§Ù„Ø±Ø­Ù„Ø© Ù‚ÙŠØ¯ Ø§Ù„ØªÙ†ÙÙŠØ°'
                                : 'Trip in Progress',
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
                    _ArrivalStatusRow(
                      isRtl: isRtl,
                      tripId: tripId,
                      tripAsync: tripAsync,
                    ),
                    _RouteRecalculatedHint(
                      isRtl: isRtl,
                      tripId: tripId,
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push(Routes.chatPath(tripId)),
                            icon: const Icon(Icons.chat),
                            label: Text(
                              isRtl ? 'Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø©' : 'Chat',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showTripDetails(
                              context,
                              isRtl,
                              tripAsync.asData?.value,
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: Text(
                              isRtl ? 'Ø§Ù„ØªÙØ§ØµÙŠÙ„' : 'Details',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // FAB for quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.chatPath(tripId)),
        icon: const Icon(Icons.chat_bubble),
        label: Text(isRtl ? 'Ø¯Ø±Ø¯Ø´Ø©' : 'Chat'),
      ),
    );
  }

  void _confirmExit(BuildContext context, bool isRtl) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'Ù…ØºØ§Ø¯Ø±Ø© Ø§Ù„Ø±Ø­Ù„Ø©ØŸ' : 'Leave Trip View?'),
        content: Text(
          isRtl
              ? 'ÙŠÙ…ÙƒÙ†Ùƒ Ø§Ù„Ø¹ÙˆØ¯Ø© Ù…Ù† Ù‚Ø§Ø¦Ù…Ø© Ø±Ø­Ù„Ø§ØªÙŠ'
              : 'You can return from My Trips list',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'Ø¥Ù„ØºØ§Ø¡' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(Routes.passengerHome);
            },
            child: Text(isRtl ? 'Ù…ØºØ§Ø¯Ø±Ø©' : 'Leave'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmergencyOptions(
    BuildContext context,
    bool isRtl,
    WidgetRef ref,
  ) async {
    final contactsService = ref.read(emergencyContactsProvider);
    final eventLog = ref.read(eventLogProvider);
    var contacts = await contactsService.getContacts();
    var autoShareEnabled = await contactsService.getAutoShareEnabled();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRtl ? 'Ø®ÙŠØ§Ø±Ø§Øª Ø§Ù„Ø·ÙˆØ§Ø±Ø¦' : 'Emergency Options',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.red),
                  title: Text(
                    isRtl ? 'Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø·ÙˆØ§Ø±Ø¦' : 'Call Emergency',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    // Call Saudi emergency number (911)
                    unawaited(launchUrl(Uri.parse('tel:911')));
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.share_location, color: Colors.orange),
                  title:
                      Text(isRtl ? 'Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„Ø±Ø­Ù„Ø©' : 'Share Trip'),
                  subtitle: Text(
                    isRtl
                        ? 'Ø£Ø±Ø³Ù„ Ø±Ø§Ø¨Ø· Ø§Ù„Ø±Ø­Ù„Ø© Ù„Ø¬Ù‡Ø§Øª Ø§Ù„Ø§ØªØµØ§Ù„'
                        : 'Send trip link to your contacts',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    unawaited(
                      Share.share(_buildTripShareMessage(isRtl)),
                    );
                    unawaited(
                      eventLog.logTripShare(
                        tripId: tripId,
                        auto: false,
                        source: 'emergency_sheet',
                        contactsCount: contacts.length,
                      ),
                    );
                    unawaited(
                      ref.read(gamificationHookProvider).onTripShared(),
                    );
                  },
                ),
                SwitchListTile(
                  value: autoShareEnabled,
                  onChanged: (value) async {
                    await contactsService.setAutoShareEnabled(value);
                    setState(() => autoShareEnabled = value);
                  },
                  title: Text(
                    isRtl
                        ? 'Ù…Ø´Ø§Ø±ÙƒØ© ØªÙ„Ù‚Ø§Ø¦ÙŠØ© Ø¹Ù†Ø¯ Ø¨Ø¯Ø§ÙŠØ© Ø§Ù„Ø±Ø­Ù„Ø©'
                        : 'Auto-share when trip starts',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isRtl ? 'Ø¬Ù‡Ø§Øª Ø§Ù„Ø§ØªØµØ§Ù„' : 'Emergency Contacts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                if (contacts.isEmpty)
                  Text(
                    isRtl
                        ? 'Ø£Ø¶Ù Ø­ØªÙ‰ 3 Ø¬Ù‡Ø§Øª Ø§ØªØµØ§Ù„ Ù„Ù„Ø·ÙˆØ§Ø±Ø¦'
                        : 'Add up to 3 emergency contacts',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ...contacts.map(
                    (c) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(c.name),
                      subtitle: Text(c.phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone),
                            tooltip: isRtl ? 'اتصال' : 'Call',
                            onPressed: () => unawaited(
                              launchUrl(
                                Uri.parse('tel:${c.phone}'),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            tooltip:
                                isRtl ? 'مشاركة موقعي' : 'Share my location',
                            onPressed: () {
                              unawaited(
                                Share.share(
                                  _buildTripShareMessage(isRtl),
                                ),
                              );
                              unawaited(
                                eventLog.logTripShare(
                                  tripId: tripId,
                                  auto: false,
                                  source: 'contact_row',
                                  contactsCount: contacts.length,
                                ),
                              );
                              unawaited(
                                ref
                                    .read(gamificationHookProvider)
                                    .onTripShared(),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: isRtl ? 'إزالة' : 'Remove contact',
                            onPressed: () async {
                              await contactsService.removeContact(c.phone);
                              contacts = await contactsService.getContacts();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (contacts.length < EmergencyContactsService.maxContacts)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final newContact = await _showAddContactDialog(
                          ctx,
                          isRtl,
                        );
                        if (newContact == null) return;
                        await contactsService.addContact(newContact);
                        contacts = await contactsService.getContacts();
                        setState(() {});
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        isRtl ? 'Ø¥Ø¶Ø§ÙØ© Ø¬Ù‡Ø© Ø§ØªØµØ§Ù„' : 'Add Contact',
                      ),
                    ),
                  )
                else
                  Text(
                    isRtl
                        ? 'Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ 3 Ø¬Ù‡Ø§Øª Ø§ØªØµØ§Ù„'
                        : 'Max 3 contacts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isRtl ? 'Ø¥Ù„ØºØ§Ø¡' : 'Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildTripShareMessage(bool isRtl) {
    final link = 'https://khawi.app/trip/$tripId';
    return isRtl
        ? 'Ø£Ù†Ø§ ÙÙŠ Ø±Ø­Ù„Ø© Ù…Ø¹ Ø®Ø§ÙˆÙŠ. Ø±Ù‚Ù… Ø§Ù„Ø±Ø­Ù„Ø©: $tripId\n$link'
        : 'I am on a trip with Khawi. Trip ID: $tripId\n$link';
  }

  Future<void> _autoShareTripIfEnabled(WidgetRef ref, bool isRtl) async {
    final contactsService = ref.read(emergencyContactsProvider);
    final eventLog = ref.read(eventLogProvider);
    final autoShareEnabled = await contactsService.getAutoShareEnabled();
    if (!autoShareEnabled) return;
    final contacts = await contactsService.getContacts();
    if (contacts.isEmpty) return;
    unawaited(
      Share.share(_buildTripShareMessage(isRtl)),
    );
    unawaited(
      eventLog.logTripShare(
        tripId: tripId,
        auto: true,
        source: 'auto_share',
        contactsCount: contacts.length,
      ),
    );
    // Fire gamification social mission progress (fire-and-forget)
    unawaited(ref.read(gamificationHookProvider).onTripShared());
  }

  Future<EmergencyContact?> _showAddContactDialog(
    BuildContext context,
    bool isRtl,
  ) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog<EmergencyContact>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'Ø¥Ø¶Ø§ÙØ© Ø¬Ù‡Ø© Ø§ØªØµØ§Ù„' : 'Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: isRtl ? 'Ø§Ù„Ø§Ø³Ù…' : 'Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: isRtl ? 'Ø±Ù‚Ù… Ø§Ù„Ø¬ÙˆØ§Ù„' : 'Phone',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'Ø¥Ù„ØºØ§Ø¡' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) return;
              Navigator.pop(
                ctx,
                EmergencyContact(name: name, phone: phone),
              );
            },
            child: Text(isRtl ? 'Ø¥Ø¶Ø§ÙØ©' : 'Add'),
          ),
        ],
      ),
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
    });
  }

  void _showTripDetails(BuildContext context, bool isRtl, Trip? trip) {
    final stops = trip?.waypoints ?? const <TripWaypoint>[];
    final origin =
        trip?.originLabel ?? (isRtl ? 'Ù†Ù‚Ø·Ø© Ø§Ù„Ø§Ù†Ø·Ù„Ø§Ù‚' : 'Origin');
    final destination =
        trip?.destLabel ?? (isRtl ? 'Ø§Ù„ÙˆØ¬Ù‡Ø©' : 'Destination');

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
                isRtl ? 'ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø±Ø­Ù„Ø©' : 'Trip Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _detailRow(isRtl ? 'Ø±Ù‚Ù… Ø§Ù„Ø±Ø­Ù„Ø©' : 'Trip ID', tripId),
              _detailRow(
                isRtl ? 'Ø§Ù„Ø­Ø§Ù„Ø©' : 'Status',
                isRtl ? 'Ù†Ø´Ø·' : 'Active',
              ),
              _detailRow(isRtl ? 'Ù…Ù†' : 'From', origin),
              _detailRow(isRtl ? 'Ø¥Ù„Ù‰' : 'To', destination),
              if (stops.isNotEmpty)
                _detailRow(
                  isRtl ? 'Ø§Ù„ØªÙˆÙ‚ÙØ§Øª' : 'Stops',
                  stops.map((stop) => stop.label).join(' â€¢ '),
                ),
              if (trip?.etaMinutes != null)
                _detailRow(
                  isRtl ? 'ÙˆÙ‚Øª Ø§Ù„ÙˆØµÙˆÙ„ Ø§Ù„Ù…ØªÙˆÙ‚Ø¹' : 'ETA',
                  isRtl
                      ? '${trip!.etaMinutes} Ø¯Ù‚ÙŠÙ‚Ø©'
                      : '${trip!.etaMinutes} min',
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isRtl ? 'Ø¥ØºÙ„Ø§Ù‚' : 'Close'),
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

class _ArrivalStatusRow extends ConsumerWidget {
  final bool isRtl;
  final String tripId;
  final AsyncValue<Trip> tripAsync;

  const _ArrivalStatusRow({
    required this.isRtl,
    required this.tripId,
    required this.tripAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return tripAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (trip) {
        final eta = trip.etaMinutes;
        late final String statusKey;
        late final Widget statusChild;

        if (eta == null) {
          statusKey = 'eta_pending';
          statusChild = Text(
            isRtl ? 'ETA: قريباً' : 'ETA: pending',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          );
        } else if (eta > 0) {
          statusKey = 'eta_arriving_$eta';
          statusChild = Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppTheme.info),
              const SizedBox(width: 6),
              Text(
                isRtl
                    ? 'السائق يصل خلال $eta دقيقة'
                    : 'Driver arriving in $eta min',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          );
        } else {
          final arrivedAt = ref.watch(_arrivalDetectedAtProvider(tripId));
          if (arrivedAt == null) {
            statusKey = 'eta_arrived';
            statusChild = Text(
              isRtl ? 'السائق وصل' : 'Driver has arrived',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                  ),
            );
          } else {
            final elapsed = DateTime.now().difference(arrivedAt).inSeconds;
            final remaining = math.max(0, 300 - elapsed);
            final mm = (remaining ~/ 60).toString().padLeft(2, '0');
            final ss = (remaining % 60).toString().padLeft(2, '0');
            statusKey = 'eta_wait_${remaining > 0 ? '$mm:$ss' : 'ended'}';
            statusChild = Row(
              children: [
                const Icon(Icons.timer, size: 16, color: AppTheme.warning),
                const SizedBox(width: 6),
                Text(
                  remaining > 0
                      ? (isRtl
                          ? 'السائق وصل • مؤقت الانتظار $mm:$ss'
                          : 'Driver arrived • wait timer $mm:$ss')
                      : (isRtl ? 'انتهى مؤقت الانتظار' : 'Wait timer ended'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            );
          }
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
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slide,
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
      },
    );
  }
}

class _RouteRecalculatedHint extends ConsumerWidget {
  const _RouteRecalculatedHint({
    required this.isRtl,
    required this.tripId,
  });

  final bool isRtl;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_clockTickerProvider);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final recalculatedAt = ref.watch(_routeRecalculatedAtProvider(tripId));
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
                  key: const ValueKey('route_recalc_hint'),
                  padding: const EdgeInsets.only(top: 8),
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
              : const SizedBox.shrink(key: ValueKey('route_recalc_empty')),
        ),
      ),
    );
  }
}
