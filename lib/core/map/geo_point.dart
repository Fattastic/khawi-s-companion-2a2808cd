/// A platform-agnostic latitude/longitude pair.
///
/// We keep this type out of any specific map package (google_maps_flutter,
/// flutter_map, etc.) so controllers/state can stay pure and testable.
class GeoPoint {
  final double lat;
  final double lng;

  const GeoPoint(this.lat, this.lng);

  @override
  String toString() => 'GeoPoint(lat: $lat, lng: $lng)';

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}
