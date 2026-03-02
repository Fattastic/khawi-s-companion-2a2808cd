import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:latlong2/latlong.dart';

/// Controller for managing live tracking state for a specific trip.
class LiveTrackingController extends FamilyAsyncNotifier<LatLng?, String> {
  late final String _tripId;
  StreamSubscription<Map<String, double>>? _locationSub;
  Timer? _pushTimer;

  @override
  Future<LatLng?> build(String arg) async {
    _tripId = arg;

    // Auto-cleanup on dispose
    ref.onDispose(() {
      _locationSub?.cancel();
      _pushTimer?.cancel();
    });

    // Start listening to trip location updates from backend
    _locationSub =
        ref.read(tripsRepoProvider).watchTripLocation(_tripId).listen((loc) {
      if (loc.containsKey('lat') && loc.containsKey('lng')) {
        state = AsyncData(LatLng(loc['lat']!, loc['lng']!));
      }
    });

    return null;
  }

  /// Starts pushing driver location periodically.
  /// Only call this if the current user IS the driver.
  Future<void> startDriverTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return;
      }
    }

    _pushTimer?.cancel();
    int pushCount = 0;

    // Fetch trip details to get destination
    final trip = await ref.read(tripsRepoProvider).watchTrip(_tripId).first;
    final destLat = trip.destLat;
    final destLng = trip.destLng;

    _pushTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition();
        await ref.read(tripsRepoProvider).pushLocation(
              tripId: _tripId,
              lat: pos.latitude,
              lng: pos.longitude,
              heading: pos.heading,
              speed: pos.speed,
            );

        // Smart ETA: Recalculate every 30 seconds (6 pushes)
        pushCount++;
        if (pushCount % 6 == 0) {
          final eta = await ref.read(tripsRepoProvider).estimateEta(
                originLat: pos.latitude,
                originLng: pos.longitude,
                destLat: destLat,
                destLng: destLng,
              );
          if (eta != null) {
            await ref.read(tripsRepoProvider).updateTripEta(_tripId, eta);
          }
        }
      } catch (e) {
        // Silently fail location/ETA push
      }
    });
  }

  void stopDriverTracking() {
    _pushTimer?.cancel();
    _pushTimer = null;
  }
}

final liveTrackingProvider =
    AsyncNotifierProvider.family<LiveTrackingController, LatLng?, String>(
  LiveTrackingController.new,
);
