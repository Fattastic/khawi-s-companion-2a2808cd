import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import 'package:khawi_flutter/data/dto/edge/verify_identity_dto.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';
import 'package:khawi_flutter/features/profile/domain/profile_extension.dart';
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;

class ProfileRepo {
  ProfileRepo(this.sb);
  final SupabaseClient sb;
  final LRUTrustCache _trustCache = LRUTrustCache(maxSize: 50);
  bool _loggedViewBlocked = false;

  Profile _emptyProfile(String uid) {
    return Profile(
      id: uid,
      fullName: '',
      role: UserRole.passenger,
      isPremium: false,
      isVerified: false,
      totalXp: 0,
      redeemableXp: 0,
      avatarUrl: null,
    );
  }

  Future<Profile> _fetchProfileOnce(String uid) async {
    final viewResult = await _fetchProfileWithTrust(uid);
    final row = viewResult.data ??
        await sb.from(DbTable.profiles).select().eq('id', uid).maybeSingle();

    if (row == null) return _emptyProfile(uid);

    var profileData = row;
    final cachedTrust = _trustCache.get(uid);
    if (cachedTrust != null && cachedTrust.isFresh) {
      profileData = {
        ...profileData,
        if (cachedTrust.trustScore != null)
          'trust_score': cachedTrust.trustScore,
        if (cachedTrust.trustBadge != null)
          'trust_badge': cachedTrust.trustBadge,
      };
      return Profile.fromJson(profileData);
    }

    if (viewResult.blocked) {
      return Profile.fromJson(profileData);
    }

    try {
      // AI Module D: Fetch Trust Score (cached per session)
      final trustData = await sb
          .from(DbTable.trustProfiles)
          .select('trust_score, trust_badge')
          .eq('user_id', uid)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      _trustCache.set(
        uid,
        TrustCacheEntry(
          data: trustData,
          fetchedAt: DateTime.now(),
        ),
      );

      if (trustData != null) {
        profileData = {...profileData, ...trustData};
      }
    } catch (e) {
      // Ignore trust score errors
      if (kDebugMode) {
        debugPrint('Error fetching trust score: $e');
      }
    }

    return Profile.fromJson(profileData);
  }

  Future<_ViewFetchResult> _fetchProfileWithTrust(String uid) async {
    try {
      final data = await sb
          .from(DbTable.profileWithTrust)
          .select()
          .eq('id', uid)
          .maybeSingle();
      return _ViewFetchResult(data: data);
    } on PostgrestException {
      if (!_loggedViewBlocked) {
        _loggedViewBlocked = true;
        if (kDebugMode) {
          debugPrint(
            'profile_with_trust blocked; falling back to profiles table.',
          );
        }
      }
      return const _ViewFetchResult(data: null, blocked: true);
    } catch (_) {
      return const _ViewFetchResult(data: null, blocked: false);
    }
  }

  Stream<Profile> watchMyProfile(String uid) {
    // DEV MODE: Return mock profile
    if (kUseDevMode) {
      return Stream.value(
        const Profile(
          id: 'dev_user_id',
          fullName: 'Dev User',
          role: UserRole.driver,
          isPremium: true,
          isVerified: true,
          redeemableXp: 500,
          totalXp: 1500,
          avatarUrl: null,
        ),
      );
    }
    // Important: On some platforms/networks Realtime can fail to connect, and
    // `.stream()` may never emit. Start with a one-time fetch so the app can
    // leave the splash screen deterministically.
    final initial = Stream.fromFuture(
      _fetchProfileOnce(uid).timeout(
        const Duration(seconds: 10),
        onTimeout: () => _emptyProfile(uid),
      ),
    );

    final realtime = sb
        .from(DbTable.profiles)
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .asyncMap((rows) async {
          if (rows.isEmpty) return _emptyProfile(uid);
          return _fetchProfileOnce(uid);
        });

    return Stream.fromIterable([initial, realtime]).asyncExpand((s) => s);
  }

  Future<Profile> fetchProfileById(String uid) async {
    return _fetchProfileOnce(uid);
  }

  Future<void> setRole(String uid, UserRole role) {
    // DEV MODE: No-op
    if (kUseDevMode) return Future.value();
    return sb.from(DbTable.profiles).upsert(
      {
        'id': uid,
        'role': roleToString(role),
      },
      onConflict: 'id',
    );
  }

  Future<void> setVerificationStatus(String uid, {required bool isVerified}) {
    // DEV MODE: No-op
    if (kUseDevMode) return Future.value();
    return sb.from(DbTable.profiles).upsert(
      {
        'id': uid,
        'is_verified': isVerified,
      },
      onConflict: 'id',
    );
  }

  /// Verify identity through Edge Function (if deployed), then mark verified.
  /// Falls back to direct update only if the function is not deployed.
  Future<void> verifyIdentity(String uid) async {
    if (kUseDevMode) return;
    try {
      final res = await sb.functions.invoke(
        EdgeFn.verifyIdentity,
        body: VerifyIdentityRequest(userId: uid).toJson(),
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw StateError('Malformed verify_identity response');
      }
      final result = VerifyIdentityResponse.fromJson(data);
      if (!result.verified) {
        throw StateError('Identity verification not approved');
      }
      await setVerificationStatus(uid, isVerified: true);
      _trustCache.invalidate(uid);
    } on FunctionException catch (e) {
      if (e.status == 404) {
        // Safe fallback when edge function is not deployed.
        await setVerificationStatus(uid, isVerified: true);
        _trustCache.invalidate(uid);
        return;
      }
      rethrow;
    }
  }

  Future<ProfileExtension?> getExtensions(String uid) async {
    final row = await sb
        .from('profile_extensions')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return ProfileExtension.fromJson(row);
  }

  Future<void> updateExtensions(String uid, Map<String, dynamic> data) async {
    await sb.from('profile_extensions').upsert({
      'user_id': uid,
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

class _ViewFetchResult {
  const _ViewFetchResult({
    required this.data,
    this.blocked = false,
  });

  final Map<String, dynamic>? data;
  final bool blocked;
}

class TrustCacheEntry {
  TrustCacheEntry({
    required this.data,
    required this.fetchedAt,
  });

  final Map<String, dynamic>? data;
  final DateTime fetchedAt;

  bool get isFresh =>
      DateTime.now().difference(fetchedAt) < const Duration(minutes: 5);

  double? get trustScore => (data?['trust_score'] as num?)?.toDouble();
  String? get trustBadge => data?['trust_badge'] as String?;
}

class LRUTrustCache {
  final int _maxSize;
  final Map<String, TrustCacheEntry> _cache = {};
  final List<String> _accessOrder = [];

  LRUTrustCache({int maxSize = 50}) : _maxSize = maxSize;

  TrustCacheEntry? get(String uid) {
    if (_cache.containsKey(uid)) {
      _accessOrder.remove(uid);
      _accessOrder.add(uid);
      return _cache[uid];
    }
    return null;
  }

  void set(String uid, TrustCacheEntry entry) {
    if (_cache.containsKey(uid)) {
      _accessOrder.remove(uid);
    } else if (_cache.length >= _maxSize) {
      final lruUid = _accessOrder.removeAt(0);
      _cache.remove(lruUid);
      debugPrint('Evicted trust cache for $lruUid (LRU eviction)');
    }

    _cache[uid] = entry;
    _accessOrder.add(uid);
  }

  void invalidate(String uid) {
    _cache.remove(uid);
    _accessOrder.remove(uid);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  int get size => _cache.length;
}
