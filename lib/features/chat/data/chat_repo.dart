import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import '../domain/message.dart';

class ChatRepo {
  final SupabaseClient _client;

  ChatRepo(this._client);

  /// Watches messages for a specific trip in realtime.
  Stream<List<TripMessage>> watchMessages(String tripId) {
    return _client
        .from(DbTable.tripMessages)
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at')
        .map(
          (data) => data
              .map((json) => TripMessage.fromJson(json))
              .where((m) => m.moderationStatus != 'blocked')
              .toList(),
        );
  }

  /// Sends a message to a trip.
  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String body,
  }) async {
    final inserted = await _client
        .from(DbTable.tripMessages)
        .insert({
          'trip_id': tripId,
          'sender_id': senderId,
          'body': body,
        })
        .select('id')
        .single();

    final messageId = inserted['id'] as String;

    // Server-side moderation (Edge Function)
    try {
      await _client.functions.invoke(
        EdgeFn.moderateMessage,
        body: {'message_id': messageId},
      );
    } catch (_) {
      // safe fallback: message stays pending/allowed; UI still works
    }
  }
}
