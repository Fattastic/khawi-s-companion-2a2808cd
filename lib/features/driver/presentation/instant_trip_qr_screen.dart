import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/services/permission_service.dart';
import 'package:khawi_flutter/state/providers.dart';

class InstantTripQrScreen extends ConsumerWidget {
  const InstantTripQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userIdProvider);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final tripsAsync = ref.watch(_driverTripsProvider(uid));

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar:
          AppBar(title: Text(l10n?.instantTripQrTitle ?? 'Instant Trip QR')),
      body: tripsAsync.when(
        data: (trips) {
          final now = DateTime.now();
          final next = trips
              .where((t) => t.status == TripStatus.planned)
              .where(
                (t) => t.departureTime
                    .isAfter(now.subtract(const Duration(hours: 2))),
              )
              .toList()
            ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

          final trip = next.isNotEmpty ? next.first : null;
          final payload = trip == null ? null : 'khawi:trip:${trip.id}';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (payload != null) ...[
                    QrImageView(
                      data: payload,
                      size: 240,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Passengers can scan this QR to request joining your ride.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(payload, style: Theme.of(context).textTheme.bodySmall),
                  ] else ...[
                    const Icon(
                      Icons.qr_code_2,
                      size: 72,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No upcoming trip found.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a quick trip to generate a QR.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _createQuickTrip(context, ref, uid),
                        icon: const Icon(Icons.add),
                        label: const Text('Create quick trip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static Future<void> _createQuickTrip(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final destCtl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Quick trip'),
          content: TextField(
            controller: destCtl,
            decoration: const InputDecoration(labelText: 'Destination label'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      if (!context.mounted) return;

      try {
        // Try to get location with permission handling
        final pos = await PermissionService.getCurrentPositionWithPermission(
          context,
          showSettingsDialogIfDenied: true,
        );

        final Position finalPos;
        if (pos == null) {
          // Fall back to Riyadh center if location isn't available.
          finalPos = Position(
            longitude: 46.6753,
            latitude: 24.7136,
            timestamp: DateTime.now(),
            accuracy: 999,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        } else {
          finalPos = pos;
        }

        final trip = Trip(
          id: '',
          driverId: uid,
          originLat: finalPos.latitude,
          originLng: finalPos.longitude,
          destLat: finalPos.latitude,
          destLng: finalPos.longitude,
          originLabel: 'Pickup point',
          destLabel:
              destCtl.text.trim().isEmpty ? 'Destination' : destCtl.text.trim(),
          departureTime: DateTime.now().add(const Duration(minutes: 5)),
          seatsTotal: 1,
          seatsAvailable: 1,
          womenOnly: false,
          isKidsRide: false,
          tags: const ['instant'],
          status: TripStatus.planned,
          isRecurring: false,
        );

        await ref.read(tripsRepoProvider).createTrip(trip);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quick trip created')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      destCtl.dispose();
    }
  }
}

final _driverTripsProvider = StreamProvider.family<List<Trip>, String>(
  (ref, uid) => ref.watch(tripsRepoProvider).watchMyTrips(uid),
);
