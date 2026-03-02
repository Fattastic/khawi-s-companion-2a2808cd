import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/features/support/domain/support_ticket.dart';

class SupportRepo {
  final SupabaseClient _sb;

  SupportRepo(this._sb);

  Future<void> createTicket({
    required String subject,
    required String body,
    String? tripId,
  }) async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception("Not authenticated");

    await _sb.from(DbTable.supportTickets).insert({
      'created_by': uid,
      'subject': subject,
      'body': body,
      'trip_id': tripId,
      'status': 'open',
      'channel': 'in_app',
    });
  }

  Future<List<SupportTicket>> getMyTickets() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await _sb
        .from(DbTable.supportTickets)
        .select()
        .eq('created_by', uid)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => SupportTicket.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
