import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/community.dart';

/// Repository for Khawi Communities CRUD.
class CommunityRepo {
  final SupabaseClient _client;
  CommunityRepo(this._client);

  static const _communities = 'communities';
  static const _members = 'community_members';
  static const _rides = 'community_rides';

  // ─────────────────────────────────────────────────────────────────────────
  // COMMUNITIES
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch all active communities, ordered by member count descending.
  Future<List<Community>> fetchAll({int limit = 50}) async {
    final data = await _client
        .from(_communities)
        .select()
        .eq('is_active', true)
        .order('member_count', ascending: false)
        .limit(limit);
    return data.map((j) => Community.fromJson(j)).toList();
  }

  /// Fetch communities by type.
  Future<List<Community>> fetchByType(
    CommunityType type, {
    int limit = 50,
  }) async {
    final data = await _client
        .from(_communities)
        .select()
        .eq('is_active', true)
        .eq('type', type.key)
        .order('member_count', ascending: false)
        .limit(limit);
    return data.map((j) => Community.fromJson(j)).toList();
  }

  /// Search communities by name.
  Future<List<Community>> search(String query, {int limit = 20}) async {
    final data = await _client
        .from(_communities)
        .select()
        .eq('is_active', true)
        .or('name.ilike.%$query%,name_ar.ilike.%$query%')
        .order('member_count', ascending: false)
        .limit(limit);
    return data.map((j) => Community.fromJson(j)).toList();
  }

  /// Fetch single community by ID.
  Future<Community> fetchById(String communityId) async {
    final data = await _client
        .from(_communities)
        .select()
        .eq('id', communityId)
        .single();
    return Community.fromJson(data);
  }

  /// Create a new community.
  Future<Community> create(Community community) async {
    final data = await _client
        .from(_communities)
        .insert(community.toInsertJson())
        .select()
        .single();
    return Community.fromJson(data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MEMBERSHIP
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch communities the user has joined (with community data).
  Future<List<CommunityMembership>> fetchMyCommunities(String userId) async {
    final data = await _client
        .from(_members)
        .select('*, communities!inner(*)')
        .eq('user_id', userId)
        .order('joined_at', ascending: false);
    return data.map((j) => CommunityMembership.fromJson(j)).toList();
  }

  /// Join a community.
  Future<void> join(String communityId, String userId) async {
    await _client.from(_members).upsert({
      'community_id': communityId,
      'user_id': userId,
      'role': 'member',
    });
  }

  /// Leave a community.
  Future<void> leave(String communityId, String userId) async {
    await _client
        .from(_members)
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', userId);
  }

  /// Check if user is a member.
  Future<bool> isMember(String communityId, String userId) async {
    final data = await _client
        .from(_members)
        .select('community_id')
        .eq('community_id', communityId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  /// Fetch members of a community with profile data.
  Future<List<Map<String, dynamic>>> fetchMembers(
    String communityId, {
    int limit = 50,
  }) async {
    final data = await _client
        .from(_members)
        .select('*, profiles!inner(id, full_name, avatar_url, average_rating)')
        .eq('community_id', communityId)
        .order('joined_at')
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMMUNITY RIDES
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch rides shared to a community.
  Future<List<CommunityRide>> fetchCommunityRides(
    String communityId, {
    int limit = 20,
  }) async {
    final data = await _client
        .from(_rides)
        .select(
          '*, trips!inner(id, origin_label, dest_label, departure_time, seats_available, status), profiles!inner(id, full_name, avatar_url)',
        )
        .eq('community_id', communityId)
        .order('created_at', ascending: false)
        .limit(limit);
    return data.map((j) => CommunityRide.fromJson(j)).toList();
  }

  /// Share a ride to a community.
  Future<void> shareRide({
    required String communityId,
    required String tripId,
    required String userId,
    String? message,
  }) async {
    await _client.from(_rides).upsert({
      'community_id': communityId,
      'trip_id': tripId,
      'posted_by': userId,
      if (message != null) 'message': message,
    });
  }

  /// Remove a shared ride.
  Future<void> removeRide(String rideId) async {
    await _client.from(_rides).delete().eq('id', rideId);
  }
}
