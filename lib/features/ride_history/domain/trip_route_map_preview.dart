import 'dart:math' as math;

import 'ride_history_entry.dart';

class RouteCoordinate {
  final double lat;
  final double lng;

  const RouteCoordinate({
    required this.lat,
    required this.lng,
  });
}

class TripRouteMapPreview {
  final List<RouteCoordinate> path;
  final double centerLat;
  final double centerLng;
  final int waypointCount;
  final double initialZoom;

  const TripRouteMapPreview({
    required this.path,
    required this.centerLat,
    required this.centerLng,
    required this.waypointCount,
    required this.initialZoom,
  });
}

TripRouteMapPreview buildTripRouteMapPreview(RideHistoryEntry entry) {
  final origin = RouteCoordinate(lat: entry.originLat, lng: entry.originLng);
  final destination = RouteCoordinate(lat: entry.destLat, lng: entry.destLng);
  final centerLat = (origin.lat + destination.lat) / 2;
  final centerLng = (origin.lng + destination.lng) / 2;
  final deltaLat = (origin.lat - destination.lat).abs();
  final deltaLng = (origin.lng - destination.lng).abs();
  final maxDelta = math.max(deltaLat, deltaLng);

  return TripRouteMapPreview(
    path: [origin, destination],
    centerLat: centerLat,
    centerLng: centerLng,
    waypointCount: entry.waypointLabels.length,
    initialZoom: _zoomForDelta(maxDelta),
  );
}

double _zoomForDelta(double maxDelta) {
  if (maxDelta <= 0.01) return 13;
  if (maxDelta <= 0.05) return 12;
  if (maxDelta <= 0.15) return 11;
  return 10;
}
