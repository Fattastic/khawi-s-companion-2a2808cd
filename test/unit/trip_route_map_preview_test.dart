import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/features/ride_history/domain/ride_history_entry.dart';
import 'package:khawi_flutter/features/ride_history/domain/trip_route_map_preview.dart';

void main() {
  RideHistoryEntry buildEntry({
    double originLat = 24.7136,
    double originLng = 46.6753,
    double destLat = 24.7746,
    double destLng = 46.7384,
    List<String> waypointLabels = const [],
  }) {
    return RideHistoryEntry(
      tripId: 'trip_1',
      requestId: 'req_1',
      originLabel: 'Origin',
      destLabel: 'Destination',
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      departureTime: DateTime(2026, 2, 16, 8),
      status: 'completed',
      waypointLabels: waypointLabels,
    );
  }

  group('buildTripRouteMapPreview', () {
    test('builds path with origin and destination in order', () {
      final preview = buildTripRouteMapPreview(buildEntry());

      expect(preview.path.length, 2);
      expect(preview.path.first.lat, 24.7136);
      expect(preview.path.first.lng, 46.6753);
      expect(preview.path.last.lat, 24.7746);
      expect(preview.path.last.lng, 46.7384);
    });

    test('computes center and includes waypoint count', () {
      final preview = buildTripRouteMapPreview(
        buildEntry(waypointLabels: const ['Stop A', 'Stop B']),
      );

      expect(preview.centerLat, closeTo((24.7136 + 24.7746) / 2, 0.000001));
      expect(preview.centerLng, closeTo((46.6753 + 46.7384) / 2, 0.000001));
      expect(preview.waypointCount, 2);
    });

    test('derives closer zoom for short routes', () {
      final short = buildTripRouteMapPreview(
        buildEntry(destLat: 24.716, destLng: 46.678),
      );
      final long = buildTripRouteMapPreview(
        buildEntry(destLat: 25.2, destLng: 47.1),
      );

      expect(short.initialZoom, greaterThan(long.initialZoom));
    });
  });
}
