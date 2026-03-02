import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/features/trips/presentation/ride_marketplace_screen.dart';

void main() {
  group('buildBookingPickupOptions', () {
    Trip buildTrip({List<TripWaypoint> waypoints = const []}) {
      return Trip(
        id: 't1',
        driverId: 'd1',
        originLat: 24.7136,
        originLng: 46.6753,
        destLat: 24.7746,
        destLng: 46.7384,
        departureTime: DateTime(2026, 2, 16, 8, 0),
        isRecurring: false,
        seatsTotal: 4,
        seatsAvailable: 3,
        womenOnly: false,
        isKidsRide: false,
        tags: const [],
        status: TripStatus.planned,
        waypoints: waypoints,
      );
    }

    test('includes default pickup as first option', () {
      final options = buildBookingPickupOptions(
        trip: buildTrip(),
        defaultPickupLat: 24.7,
        defaultPickupLng: 46.6,
        defaultPickupLabel: 'Custom pickup',
      );

      expect(options.length, 1);
      expect(options.first.label, 'Custom pickup');
      expect(options.first.isWaypoint, isFalse);
    });

    test('adds waypoint options and marks them as waypoints', () {
      final options = buildBookingPickupOptions(
        trip: buildTrip(
          waypoints: const [
            TripWaypoint(lat: 24.71, lng: 46.67, label: 'Stop A'),
            TripWaypoint(lat: 24.72, lng: 46.68, label: 'Stop B'),
          ],
        ),
        defaultPickupLat: 24.7,
        defaultPickupLng: 46.6,
        defaultPickupLabel: 'Custom pickup',
      );

      expect(options.length, 3);
      expect(options[1].label, 'Stop A');
      expect(options[1].isWaypoint, isTrue);
      expect(options[2].label, 'Stop B');
      expect(options[2].isWaypoint, isTrue);
    });

    test('deduplicates waypoints with same label as default pickup', () {
      final options = buildBookingPickupOptions(
        trip: buildTrip(
          waypoints: const [
            TripWaypoint(lat: 24.7, lng: 46.6, label: 'Custom pickup'),
          ],
        ),
        defaultPickupLat: 24.7,
        defaultPickupLng: 46.6,
        defaultPickupLabel: 'Custom pickup',
      );

      expect(options.length, 1);
      expect(options.single.label, 'Custom pickup');
    });
  });
}
