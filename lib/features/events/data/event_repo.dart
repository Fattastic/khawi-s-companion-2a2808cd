import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/khawi_event.dart';

/// Repository for Khawi Event Rides CRUD.
class EventRepo {
  final SupabaseClient _client;
  EventRepo(this._client);

  static const _events = 'events';
  static const _rides = 'event_rides';
  static const _interest = 'event_interest';

  // ─────────────────────────────────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch upcoming active events, ordered by start time.
  Future<List<KhawiEvent>> fetchUpcoming({int limit = 50}) async {
    final data = await _client
        .from(_events)
        .select()
        .eq('is_active', true)
        .gte('start_time', DateTime.now().toIso8601String())
        .order('start_time')
        .limit(limit);
    return data.map((j) => KhawiEvent.fromJson(j)).toList();
  }

  /// Fetch featured events.
  Future<List<KhawiEvent>> fetchFeatured({int limit = 10}) async {
    final data = await _client
        .from(_events)
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .gte('start_time', DateTime.now().toIso8601String())
        .order('start_time')
        .limit(limit);
    return data.map((j) => KhawiEvent.fromJson(j)).toList();
  }

  /// Fetch events by category.
  Future<List<KhawiEvent>> fetchByCategory(
    EventCategory category, {
    int limit = 50,
  }) async {
    final data = await _client
        .from(_events)
        .select()
        .eq('is_active', true)
        .eq('category', category.key)
        .gte('start_time', DateTime.now().toIso8601String())
        .order('start_time')
        .limit(limit);
    return data.map((j) => KhawiEvent.fromJson(j)).toList();
  }

  /// Search events by title.
  Future<List<KhawiEvent>> search(String query, {int limit = 20}) async {
    final data = await _client
        .from(_events)
        .select()
        .eq('is_active', true)
        .or('title.ilike.%$query%,title_ar.ilike.%$query%,venue_name.ilike.%$query%')
        .order('start_time')
        .limit(limit);
    return data.map((j) => KhawiEvent.fromJson(j)).toList();
  }

  /// Fetch single event by ID.
  Future<KhawiEvent> fetchById(String eventId) async {
    final data =
        await _client.from(_events).select().eq('id', eventId).single();
    return KhawiEvent.fromJson(data);
  }

  /// Create a new event.
  Future<KhawiEvent> create(KhawiEvent event) async {
    final data = await _client
        .from(_events)
        .insert(event.toInsertJson())
        .select()
        .single();
    return KhawiEvent.fromJson(data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EVENT RIDES
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch rides for an event (with trip + poster profile).
  Future<List<EventRide>> fetchEventRides(
    String eventId, {
    EventRideDirection? direction,
    int limit = 50,
  }) async {
    var query = _client
        .from(_rides)
        .select(
          '*, trips!inner(id, origin_label, dest_label, departure_time, seats_available, status), profiles!inner(id, full_name, avatar_url)',
        )
        .eq('event_id', eventId);

    if (direction != null) {
      query = query.eq('direction', direction.key);
    }

    final data = await query.order('created_at', ascending: false).limit(limit);
    return data.map((j) => EventRide.fromJson(j)).toList();
  }

  /// Share a ride to an event.
  Future<void> shareRide({
    required String eventId,
    required String tripId,
    required String userId,
    EventRideDirection direction = EventRideDirection.to,
    int seatsOffered = 1,
    String? message,
  }) async {
    await _client.from(_rides).upsert({
      'event_id': eventId,
      'trip_id': tripId,
      'posted_by': userId,
      'direction': direction.key,
      'seats_offered': seatsOffered,
      if (message != null) 'message': message,
    });
  }

  /// Remove a shared event ride.
  Future<void> removeRide(String rideId) async {
    await _client.from(_rides).delete().eq('id', rideId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EVENT INTEREST
  // ─────────────────────────────────────────────────────────────────────────

  /// Mark interest in an event.
  Future<void> markInterest({
    required String eventId,
    required String userId,
    EventInterestStatus status = EventInterestStatus.interested,
    bool needsRide = true,
  }) async {
    await _client.from(_interest).upsert({
      'event_id': eventId,
      'user_id': userId,
      'status': status.key,
      'needs_ride': needsRide,
    });
  }

  /// Remove interest.
  Future<void> removeInterest(String eventId, String userId) async {
    await _client
        .from(_interest)
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  /// Check if user is interested.
  Future<EventInterest?> getInterest(String eventId, String userId) async {
    final data = await _client
        .from(_interest)
        .select()
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null ? EventInterest.fromJson(data) : null;
  }

  /// Count interested/going users for an event.
  Future<int> interestCount(String eventId) async {
    final data = await _client
        .from(_interest)
        .select('event_id')
        .eq('event_id', eventId);
    return (data as List).length;
  }
}
