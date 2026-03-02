import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khawi_flutter/core/backend/backend_contract.dart';

class EventLogService {
  EventLogService(this._sb);

  final SupabaseClient _sb;

  Future<void> logTripShare({
    required String tripId,
    required bool auto,
    required String source,
    int? contactsCount,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'trip_share',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'trigger': auto ? 'auto' : 'manual',
          'source': source,
          if (contactsCount != null) 'contacts_count': contactsCount,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logTripShare failed: $e');
      }
    }
  }

  Future<void> logRatingTargetSelected({
    required String tripId,
    required String passengerId,
    required String source,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_target_selected',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'passenger_id': passengerId,
          'source': source,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingTargetSelected failed: $e');
      }
    }
  }

  Future<void> logRatingTargetStaleCleared({
    required String tripId,
    required String passengerId,
    required String source,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_target_stale_cleared',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'passenger_id': passengerId,
          'source': source,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingTargetStaleCleared failed: $e');
      }
    }
  }

  Future<void> logRatingTargetReselectClicked({
    required String tripId,
    required String source,
    String? previousPassengerId,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_target_reselect_clicked',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'source': source,
          if (previousPassengerId != null)
            'previous_passenger_id': previousPassengerId,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingTargetReselectClicked failed: $e');
      }
    }
  }

  Future<void> logRatingTargetResolved({
    required String tripId,
    required String passengerId,
    required String resolutionSource,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_target_resolved',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'passenger_id': passengerId,
          'resolution_source': resolutionSource,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingTargetResolved failed: $e');
      }
    }
  }

  Future<void> logRatingTargetMissing({
    required String tripId,
    required String source,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_target_missing',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'source': source,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingTargetMissing failed: $e');
      }
    }
  }

  Future<void> logRatingSubmitted({
    required String tripId,
    required String rateeId,
    required int stars,
    required int tagCount,
    required bool hasComment,
    required String source,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_submitted',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'ratee_id': rateeId,
          'stars': stars,
          'tag_count': tagCount,
          'has_comment': hasComment,
          'source': source,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingSubmitted failed: $e');
      }
    }
  }

  Future<void> logRatingSubmissionFailed({
    required String tripId,
    required String rateeId,
    required String source,
    required String error,
  }) async {
    final actorId = _sb.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _sb.from(DbTable.eventLog).insert({
        'actor_id': actorId,
        'event_type': 'rating_submission_failed',
        'entity_type': 'trip',
        'entity_id': tripId,
        'payload': {
          'ratee_id': rateeId,
          'source': source,
          'error': error.length > 200 ? error.substring(0, 200) : error,
        },
      });
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('EventLogService.logRatingSubmissionFailed failed: $e');
      }
    }
  }
}
