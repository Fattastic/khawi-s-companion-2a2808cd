import 'dart:math' as math;

class GeoUtils {
  // Radius of the earth in km
  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two points in kilometers
  static double distanceKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLat = _degreesToRadians(endLat - startLat);
    final dLon = _degreesToRadians(endLng - startLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Check if two routes overlap significantly (simplified logic)
  static bool checkOverlap({
    required double origin1Lat,
    required double origin1Lng,
    required double dest1Lat,
    required double dest1Lng,
    required double origin2Lat,
    required double origin2Lng,
    required double dest2Lat,
    required double dest2Lng,
    double thresholdKm = 2.0,
  }) {
    // Simple check: start is near start AND end is near end
    final startDist = distanceKm(
      origin1Lat,
      origin1Lng,
      origin2Lat,
      origin2Lng,
    );
    final endDist = distanceKm(dest1Lat, dest1Lng, dest2Lat, dest2Lng);

    return startDist <= thresholdKm && endDist <= thresholdKm;
  }
}
