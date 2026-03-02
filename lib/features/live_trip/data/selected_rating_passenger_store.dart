import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SelectedRatingPassengerStore {
  static const String _prefix = 'live_trip_selected_passenger_';

  String _key(String tripId) => '$_prefix$tripId';

  Future<Map<String, String>?> load(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(tripId));
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;

    final id = decoded['id'] as String?;
    final name = decoded['name'] as String?;
    final status = decoded['status'] as String?;
    if (id == null || id.isEmpty) return null;

    return {
      'id': id,
      'name': (name == null || name.isEmpty) ? 'Passenger' : name,
      'status': (status == null || status.isEmpty) ? 'accepted' : status,
    };
  }

  Future<void> save(
    String tripId, {
    required String id,
    required String name,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(tripId),
      jsonEncode({
        'id': id,
        'name': name,
        'status': status,
      }),
    );
  }

  Future<void> clear(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tripId));
  }
}
