import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final double lat;
  final double lng;
  final String label;

  GeocodingResult({required this.lat, required this.lng, required this.label});
}

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Forward geocode: address text to coordinates
  Future<List<GeocodingResult>> search(
    String query, {
    String? countryCode = 'sa',
  }) async {
    if (query.trim().length < 3) return [];

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
          if (countryCode != null) 'countrycodes': countryCode,
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Khawi-App/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data.map((item) {
          final map = item as Map<String, dynamic>;
          return GeocodingResult(
            lat: double.parse(map['lat'] as String),
            lng: double.parse(map['lon'] as String),
            label: (map['display_name'] as String?) ?? query,
          );
        }).toList();
      }
    } catch (e) {
      // Silently fail, return empty list
    }
    return [];
  }

  /// Reverse geocode: coordinates to address
  Future<String?> reverse(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Khawi-App/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['display_name'] as String?;
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }
}
