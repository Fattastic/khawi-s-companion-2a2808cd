import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> resolveLiveTripProfileName(
  SupabaseClient client,
  String userId,
) async {
  final row = await client
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .maybeSingle();
  return row?['full_name'] as String?;
}
