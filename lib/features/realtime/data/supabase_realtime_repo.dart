import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import '../domain/trip_message.dart';
import '../domain/trip_location.dart';
import 'realtime_repo.dart';

class SupabaseRealtimeRepo implements RealtimeRepo {
  final SupabaseClient _db;
  SupabaseRealtimeRepo(this._db);

  @override
  Stream<List<TripMessage>> watchTripMessages(String tripId) {
    return _db
        .from(DbTable.tripMessages)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(TripMessage.fromJson).toList());
  }

  @override
  Future<void> sendMessage({
    required String tripId,
    required String body,
  }) async {
    await _db.from(DbTable.tripMessages).insert({
      'trip_id': tripId,
      'sender_id': _db.auth.currentUser!.id,
      'body': body,
    });
  }

  @override
  Stream<List<TripLocation>> watchTripLocations(String tripId) {
    return _db
        .from(DbTable.tripLocations)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(TripLocation.fromJson).toList());
  }

  @override
  Future<void> updateLocation({
    required String tripId,
    required double lat,
    required double lng,
    double heading = 0,
    double speed = 0,
  }) async {
    await _db.from(DbTable.tripLocations).insert({
      'trip_id': tripId,
      'user_id': _db.auth.currentUser!.id,
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
    });
  }
}
