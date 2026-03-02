import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/backend/backend_contract.dart';
import '../domain/junior.dart';
import 'package:khawi_flutter/features/junior/domain/junior_invite_code.dart';
import 'package:khawi_flutter/features/junior/domain/junior_location.dart';
import 'package:khawi_flutter/features/junior/domain/trusted_driver.dart';
import 'package:khawi_flutter/state/providers.dart' show kUseDevMode;

class JuniorRepo {
  JuniorRepo(this.sb);
  final SupabaseClient sb;

  // Kids
  Stream<List<Kid>> watchMyKids(String parentId) {
    if (kUseDevMode) {
      return Stream.value([
        Kid(
          id: 'kid_1',
          parentId: parentId,
          name: 'Sarah',
          schoolName: 'Al-Yamamah International School',
        ),
        Kid(
          id: 'kid_2',
          parentId: parentId,
          name: 'Ahmed Jr.',
          schoolName: 'Al-Yamamah International School',
        ),
      ]);
    }
    return sb
        .from(DbTable.kids)
        .stream(primaryKey: ['id'])
        .eq('parent_id', parentId)
        .map((rows) => rows.map((r) => Kid.fromJson(r)).toList());
  }

  // Runs
  Stream<List<JuniorRun>> watchRunsForParent(String parentId) {
    if (kUseDevMode) {
      return Stream.value([
        JuniorRun(
          id: 'run_1',
          kidId: 'kid_1',
          parentId: parentId,
          assignedDriverId: 'driver_1',
          status: 'planned',
          pickupLat: 24.7136,
          pickupLng: 46.6753,
          dropoffLat: 24.7500,
          dropoffLng: 46.7000,
          pickupTime: DateTime.now().add(const Duration(hours: 1)),
        ),
      ]);
    }
    return sb
        .from(DbTable.juniorRuns)
        .stream(primaryKey: ['id'])
        .eq('parent_id', parentId)
        .order('pickup_time')
        .map((rows) => rows.map((r) => JuniorRun.fromJson(r)).toList());
  }

  Stream<List<JuniorRun>> watchAssignedRunsForDriver(String driverId) {
    if (kUseDevMode) {
      return Stream.value([]);
    }
    return sb
        .from(DbTable.juniorRuns)
        .stream(primaryKey: ['id'])
        .eq('assigned_driver_id', driverId)
        .order('pickup_time')
        .map((rows) => rows.map((r) => JuniorRun.fromJson(r)).toList());
  }

  Stream<List<TrustedDriver>> watchTrustedDriversForParent(String parentId) {
    if (kUseDevMode) {
      return Stream.value([
        TrustedDriver(
          id: 'trusted_1',
          parentId: parentId,
          driverId: 'driver_user_1',
          label: 'Uncle',
          isActive: true,
        ),
      ]);
    }
    return sb
        .from(DbTable.trustedDrivers)
        .stream(primaryKey: ['id'])
        .eq('parent_id', parentId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map(
                (r) => TrustedDriver.fromJson(
                  (r as Map).cast<String, dynamic>(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<JuniorInviteCode>> watchInviteCodesForParent(String parentId) {
    if (kUseDevMode) {
      return Stream.value([
        JuniorInviteCode(
          id: 'invite_1',
          code: 'AB12CD',
          parentId: parentId,
          isUsed: false,
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
          createdAt: DateTime.now().toUtc(),
          invitedDriverName: 'Family Driver',
          invitedDriverPhone: '+966500000000',
          invitedDriverRelation: 'family_driver',
        ),
      ]);
    }
    return sb
        .from(DbTable.juniorInviteCodes)
        .stream(primaryKey: ['id'])
        .eq('parent_id', parentId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map(
                (r) => JuniorInviteCode.fromJson(
                  (r as Map).cast<String, dynamic>(),
                ),
              )
              .toList(),
        );
  }

  Stream<JuniorRun> watchRun(String runId) {
    if (kUseDevMode) {
      return Stream.value(
        JuniorRun(
          id: runId,
          kidId: 'kid_1',
          parentId: 'dev_user_id',
          assignedDriverId: 'driver_1',
          status: 'planned',
          pickupLat: 24.7136,
          pickupLng: 46.6753,
          dropoffLat: 24.7500,
          dropoffLng: 46.7000,
          pickupTime: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
    }
    return sb
        .from(DbTable.juniorRuns)
        .stream(primaryKey: ['id'])
        .eq('id', runId)
        .map((rows) => JuniorRun.fromJson(rows.first));
  }

  Future<JuniorRun> createRun({
    required String parentId,
    required String kidId,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required DateTime pickupTime,
  }) async {
    final res = await sb
        .from(DbTable.juniorRuns)
        .insert({
          'parent_id': parentId,
          'kid_id': kidId,
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'dropoff_lat': dropoffLat,
          'dropoff_lng': dropoffLng,
          'pickup_time': pickupTime.toUtc().toIso8601String(),
          'status': 'planned',
        })
        .select()
        .single();
    return JuniorRun.fromJson((res as Map).cast<String, dynamic>());
  }

  Stream<List<JuniorRunEvent>> watchRunEvents(String runId) {
    if (kUseDevMode) {
      return Stream.value([]);
    }
    return sb
        .from(DbTable.juniorRunEvents)
        .stream(primaryKey: ['id'])
        .eq('run_id', runId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => JuniorRunEvent.fromJson(r)).toList());
  }

  Stream<List<Map<String, dynamic>>> watchRunLocationsRaw(String runId) {
    if (kUseDevMode) {
      return Stream.value([]);
    }
    return sb
        .from(DbTable.juniorRunLocations)
        .stream(primaryKey: ['id'])
        .eq('run_id', runId)
        .order('created_at', ascending: false);
  }

  // Appoint driver + grant
  Future<Map<String, dynamic>> appointDriverWithGrant({
    required String runId,
    required String driverId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    if (kUseDevMode) {
      return {'grant_id': 'mock_grant_id', 'run_id': runId};
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.createRunGrantAndAssignDriver,
      params: {
        'p_run_id': runId,
        'p_driver_id': driverId,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_ends_at': endsAt.toUtc().toIso8601String(),
      },
    );
    return res;
  }

  Future<void> revokeGrant(String grantId) {
    if (kUseDevMode) return Future.value();
    return sb
        .rpc<void>(DbRpc.revokeDriverGrant, params: {'p_grant_id': grantId});
  }

  // Status transitions
  Future<JuniorRun> updateRunStatus({
    required String runId,
    required String newStatus,
    double? lat,
    double? lng,
    Map<String, dynamic>? meta,
  }) async {
    if (kUseDevMode) {
      return JuniorRun(
        id: runId,
        kidId: 'kid_1',
        parentId: 'dev_user_id',
        status: newStatus,
        pickupLat: 24.7136,
        pickupLng: 46.6753,
        dropoffLat: 24.7500,
        dropoffLng: 46.7000,
        pickupTime: DateTime.now(),
      );
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.updateJuniorRunStatus,
      params: {
        'p_run_id': runId,
        'p_new_status': newStatus,
        'p_lat': lat,
        'p_lng': lng,
        'p_meta': meta,
      },
    );
    return JuniorRun.fromJson(res);
  }

  // SOS
  Future<SosEvent> createSos({
    String? runId,
    String? tripId,
    String kind = 'sos',
    int severity = 3,
    required double lat,
    required double lng,
    String? message,
    Map<String, dynamic>? meta,
  }) async {
    if (kUseDevMode) {
      return SosEvent(
        id: 'sos_mock',
        triggeredBy: 'dev_user_id',
        kind: kind,
        severity: severity,
        lat: lat,
        lng: lng,
        status: 'open',
        message: message,
        createdAt: DateTime.now(),
        meta: meta ?? {},
      );
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.createSos,
      params: {
        'p_run_id': runId,
        'p_trip_id': tripId,
        'p_kind': kind,
        'p_severity': severity,
        'p_lat': lat,
        'p_lng': lng,
        'p_message': message,
        'p_meta': meta,
      },
    );
    return SosEvent.fromJson(res);
  }

  Future<SosEvent> updateSosStatus({
    required String sosId,
    required String newStatus,
  }) async {
    if (kUseDevMode) {
      return SosEvent(
        id: sosId,
        triggeredBy: 'dev_user_id',
        kind: 'sos',
        severity: 3,
        lat: 24.7136,
        lng: 46.6753,
        status: newStatus,
        message: null,
        createdAt: DateTime.now(),
        meta: {},
      );
    }
    // Note: ensure update_sos_status endpoint exists in migration if used
    // Assuming trivial update or RPC if enforced.
    // If RPC is missing in migration for update_sos_status, this might fail unless implemented as update row.
    // For safety, let's assume it's an update query for now or RPC if exists.
    final res = await sb
        .from(DbTable.sosEvents)
        .update({'status': newStatus})
        .eq('id', sosId)
        .select()
        .single();
    return SosEvent.fromJson(res);
  }

  // Driver live location (Junior)
  Future<Map<String, dynamic>> driverPushJuniorLocation({
    required String runId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    double? accuracy,
  }) async {
    if (kUseDevMode) {
      return {'success': true, 'run_id': runId};
    }
    final res = await sb.rpc<Map<String, dynamic>>(
      DbRpc.driverPushJuniorLocation,
      params: {
        'p_run_id': runId,
        'p_lat': lat,
        'p_lng': lng,
        'p_heading': heading,
        'p_speed': speed,
        'p_accuracy': accuracy,
      },
    );
    return res;
  }

  // Compatibility aliases
  Stream<List<Kid>> watchKids(String pid) => watchMyKids(pid);

  // Invite codes (family-driver confirmation flow)
  Future<Map<String, dynamic>> createFamilyDriverInvite({
    required String invitedDriverName,
    required String invitedDriverPhone,
    required String invitedDriverRelation,
    int minutesValid = 24 * 60,
  }) async {
    if (kUseDevMode) {
      return {
        'id': 'invite_mock',
        'code': 'MOCK123',
        'is_used': false,
        'expires_at': DateTime.now()
            .toUtc()
            .add(Duration(minutes: minutesValid))
            .toIso8601String(),
        'invited_driver_name': invitedDriverName,
        'invited_driver_phone': invitedDriverPhone,
        'invited_driver_relation': invitedDriverRelation,
      };
    }

    try {
      final res = await sb.rpc<Map<String, dynamic>>(
        DbRpc.createJuniorInviteCode,
        params: {
          'p_invited_driver_name': invitedDriverName,
          'p_invited_driver_phone': invitedDriverPhone,
          'p_invited_driver_relation': invitedDriverRelation,
          'p_minutes_valid': minutesValid,
        },
      );
      return res;
    } on PostgrestException catch (e) {
      // Backward compatibility with older backend signature:
      // create_junior_invite_code() without parameters.
      final msg = e.message.toLowerCase();
      if (!msg.contains('create_junior_invite_code') ||
          !msg.contains('function')) {
        rethrow;
      }
      final res = await sb.rpc<Map<String, dynamic>>(
        DbRpc.createJuniorInviteCode,
      );
      return {
        ...res,
        'invited_driver_name': invitedDriverName,
        'invited_driver_phone': invitedDriverPhone,
        'invited_driver_relation': invitedDriverRelation,
      };
    }
  }

  /// Legacy-compatible helper currently called by run cards.
  Future<Map<String, dynamic>> createInviteCode({
    required String runId,
    int minutesValid = 30,
  }) async {
    final res = await createFamilyDriverInvite(
      invitedDriverName: 'Family Driver',
      invitedDriverPhone: '',
      invitedDriverRelation: 'family_driver',
      minutesValid: minutesValid,
    );
    return {...res, 'run_id': runId};
  }

  Future<Map<String, dynamic>> redeemInviteCode({
    required String code,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (kUseDevMode) {
      return {
        'success': true,
        'code': normalizedCode,
        'trusted_driver_created': true,
      };
    }

    final res = await sb.rpc<dynamic>(
      DbRpc.redeemJuniorInviteCode,
      params: {
        'p_code': normalizedCode,
      },
    );

    if (res is bool) {
      return {'success': res, 'code': normalizedCode};
    }
    if (res is Map) {
      return res.cast<String, dynamic>();
    }
    return {'success': false, 'code': normalizedCode};
  }

  Stream<List<JuniorLocation>> watchRunLocations(String runId) =>
      watchRunLocationsRaw(runId).map(
        (rows) => rows.map((row) {
          final m = (row as Map).cast<String, dynamic>();
          return JuniorLocation(
            id: (m['id'] ?? '') as String,
            runId: (m['run_id'] ?? runId) as String,
            userId: (m['user_id'] ?? '') as String,
            lat: (m['lat'] as num).toDouble(),
            lng: (m['lng'] as num).toDouble(),
            speed: (m['speed'] as num?)?.toDouble(),
            heading: (m['heading'] as num?)?.toDouble(),
            accuracy: (m['accuracy'] as num?)?.toDouble(),
            createdAt:
                DateTime.tryParse('${m['created_at'] ?? ''}') ?? DateTime.now(),
          );
        }).toList(),
      );
  Future<void> addKid({
    required String parentId,
    required String name,
    required int age,
  }) async {
    await sb.from(DbTable.kids).insert({
      'parent_id': parentId,
      'name': name,
      'notes': 'Age: $age',
    });
  }
}
