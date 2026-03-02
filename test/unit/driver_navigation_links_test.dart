import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/live_trip/data/driver_navigation_links.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

void main() {
  Trip buildTrip({List<TripWaypoint> waypoints = const []}) {
    return Trip(
      id: 't1',
      driverId: 'd1',
      originLat: 24.7136,
      originLng: 46.6753,
      destLat: 24.7746,
      destLng: 46.7384,
      departureTime: DateTime(2026, 2, 16, 8),
      isRecurring: false,
      seatsTotal: 4,
      seatsAvailable: 3,
      womenOnly: false,
      isKidsRide: false,
      tags: const [],
      status: TripStatus.active,
      waypoints: waypoints,
    );
  }

  group('driver navigation links', () {
    test('google maps uri includes destination and waypoints', () {
      final trip = buildTrip(
        waypoints: const [
          TripWaypoint(lat: 24.71, lng: 46.67, label: 'Stop A'),
          TripWaypoint(lat: 24.72, lng: 46.68, label: 'Stop B'),
        ],
      );

      final uri = buildGoogleMapsNavigationUri(trip);

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['destination'], '24.7746,46.7384');
      expect(uri.queryParameters['waypoints'], '24.71,46.67|24.72,46.68');
    });

    test('google maps uri omits waypoints when none are present', () {
      final uri = buildGoogleMapsNavigationUri(buildTrip());

      expect(uri.queryParameters.containsKey('waypoints'), isFalse);
    });

    test('apple and waze uris use destination coordinates', () {
      final trip = buildTrip();

      final apple = buildAppleMapsNavigationUri(trip);
      final waze = buildWazeNavigationUri(trip);

      expect(apple.host, 'maps.apple.com');
      expect(apple.queryParameters['daddr'], '24.7746,46.7384');
      expect(waze.toString(), contains('ll=24.7746,46.7384'));
      expect(waze.toString(), contains('navigate=yes'));
    });
  });
}
