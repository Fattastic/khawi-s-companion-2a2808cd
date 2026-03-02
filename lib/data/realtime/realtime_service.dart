import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';

/// Centralized service for managing Supabase realtime subscriptions.
///
/// This service prevents ghost listeners by:
/// 1. Tracking active subscriptions by key
/// 2. Reusing existing streams when same key is requested
/// 3. Providing cleanup methods for dispose
/// 4. Auto-cleanup when all listeners are gone (via broadcast stream)
///
/// Note: Lint ignores for close_sinks/cancel_subscriptions are intentional -
/// resources ARE properly cleaned up in dispose() and _cleanupSubscription().
// ignore_for_file: close_sinks, cancel_subscriptions
class RealtimeService {
  RealtimeService(this._sb);
  final SupabaseClient _sb;

  // Active subscription controllers keyed by unique identifier
  final Map<String, _ManagedSubscription<List<TripRequest>>> _requestSubs = {};
  final Map<String, _ManagedSubscription<Trip>> _tripSubs = {};
  final Map<String, _ManagedSubscription<List<TripRequest>>> _driverQueueSubs =
      {};

  /// Subscribe to booking/request updates for a specific trip.
  ///
  /// Returns a broadcast stream that can have multiple listeners.
  /// Automatically cleans up when all listeners are gone.
  Stream<List<TripRequest>> subscribeToBooking(String tripId) {
    final key = 'booking:$tripId';

    if (_requestSubs.containsKey(key)) {
      return _requestSubs[key]!.stream;
    }

    final controller = StreamController<List<TripRequest>>.broadcast(
      onCancel: () => _cleanupSubscription(key, _requestSubs),
    );

    final sourceStream = _sb
        .from(DbTable.tripRequests)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => TripRequest.fromJson(r)).toList());

    final subscription = sourceStream.listen(
      controller.add,
      onError: controller.addError,
    );

    _requestSubs[key] = _ManagedSubscription(
      controller: controller,
      subscription: subscription,
    );

    return controller.stream;
  }

  /// Subscribe to incoming requests for a driver (their queue).
  ///
  /// Returns a broadcast stream that can have multiple listeners.
  /// Automatically cleans up when all listeners are gone.
  Stream<List<TripRequest>> subscribeToDriverQueue(String driverId) {
    final key = 'driver_queue:$driverId';

    if (_driverQueueSubs.containsKey(key)) {
      return _driverQueueSubs[key]!.stream;
    }

    final controller = StreamController<List<TripRequest>>.broadcast(
      onCancel: () => _cleanupSubscription(key, _driverQueueSubs),
    );

    final sourceStream = _sb
        .from(DbTable.tripRequests)
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        // NOTE: Stream builder limited to simple eq. Optimization moved to client-side if needed.
        .order('created_at', ascending: false)
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.map((r) => TripRequest.fromJson(r)).toList(),
        );

    final subscription = sourceStream.listen(
      controller.add,
      onError: controller.addError,
    );

    _driverQueueSubs[key] = _ManagedSubscription(
      controller: controller,
      subscription: subscription,
    );

    return controller.stream;
  }

  /// Subscribe to trip updates.
  ///
  /// Returns a broadcast stream that can have multiple listeners.
  Stream<Trip> subscribeToTrip(String tripId) {
    final key = 'trip:$tripId';

    if (_tripSubs.containsKey(key)) {
      return _tripSubs[key]!.stream;
    }

    final controller = StreamController<Trip>.broadcast(
      onCancel: () => _cleanupSubscription(key, _tripSubs),
    );

    final sourceStream = _sb
        .from(DbTable.trips)
        .stream(primaryKey: ['id'])
        .eq('id', tripId)
        .map((rows) => Trip.fromJson(rows.first));

    final subscription = sourceStream.listen(
      controller.add,
      onError: controller.addError,
    );

    _tripSubs[key] = _ManagedSubscription(
      controller: controller,
      subscription: subscription,
    );

    return controller.stream;
  }

  /// Manually unsubscribe from a booking stream.
  void unsubscribeFromBooking(String tripId) {
    final key = 'booking:$tripId';
    _forceCleanup(key, _requestSubs);
  }

  /// Manually unsubscribe from a driver queue stream.
  void unsubscribeFromDriverQueue(String driverId) {
    final key = 'driver_queue:$driverId';
    _forceCleanup(key, _driverQueueSubs);
  }

  /// Manually unsubscribe from a trip stream.
  void unsubscribeFromTrip(String tripId) {
    final key = 'trip:$tripId';
    _forceCleanup(key, _tripSubs);
  }

  /// Clean up a subscription when no listeners remain.
  void _cleanupSubscription<T>(
    String key,
    Map<String, _ManagedSubscription<T>> map,
  ) {
    final sub = map[key];
    if (sub != null && !sub.controller.hasListener) {
      sub.subscription.cancel();
      sub.controller.close();
      map.remove(key);
    }
  }

  /// Force cleanup regardless of listeners.
  void _forceCleanup<T>(String key, Map<String, _ManagedSubscription<T>> map) {
    final sub = map.remove(key);
    if (sub != null) {
      sub.subscription.cancel();
      sub.controller.close();
    }
  }

  /// Dispose all active subscriptions.
  /// Call this when the service is no longer needed.
  void dispose() {
    for (final sub in _requestSubs.values) {
      sub.subscription.cancel();
      sub.controller.close();
    }
    _requestSubs.clear();

    for (final sub in _driverQueueSubs.values) {
      sub.subscription.cancel();
      sub.controller.close();
    }
    _driverQueueSubs.clear();

    for (final sub in _tripSubs.values) {
      sub.subscription.cancel();
      sub.controller.close();
    }
    _tripSubs.clear();
  }

  /// Get count of active subscriptions (for debugging/testing).
  int get activeSubscriptionCount =>
      _requestSubs.length + _driverQueueSubs.length + _tripSubs.length;
}

/// Internal class to track a managed subscription.
class _ManagedSubscription<T> {
  _ManagedSubscription({
    required this.controller,
    required this.subscription,
  });

  final StreamController<T> controller;
  final StreamSubscription<T> subscription;

  Stream<T> get stream => controller.stream;
}
