import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/features/junior/domain/junior_invite_code.dart';
import 'package:khawi_flutter/features/junior/domain/trusted_driver.dart';

final myKidsProvider = StreamProvider<List<Kid>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  // Return mock data in dev mode
  if (kUseDevMode) {
    return Stream.value([
      Kid(
        id: 'kid_1',
        parentId: uid,
        name: 'Sarah',
        schoolName: 'Al-Yamamah International School',
        avatarUrl: null,
        notes: '5th Grade',
      ),
      Kid(
        id: 'kid_2',
        parentId: uid,
        name: 'Ahmed Jr.',
        schoolName: 'Al-Yamamah International School',
        avatarUrl: null,
        notes: '3rd Grade',
      ),
    ]);
  }

  return ref.watch(juniorRepoProvider).watchMyKids(uid);
});

final myJuniorRunsProvider = StreamProvider<List<JuniorRun>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  // Return mock data in dev mode
  if (kUseDevMode) {
    return Stream.value([
      JuniorRun(
        id: 'run_1',
        kidId: 'kid_1',
        parentId: uid,
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

  return ref.watch(juniorRepoProvider).watchRunsForParent(uid);
});

final assignedJuniorRunsProvider = StreamProvider<List<JuniorRun>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  // Return mock data in dev mode
  if (kUseDevMode) {
    return Stream.value([]);
  }

  return ref.watch(juniorRepoProvider).watchAssignedRunsForDriver(uid);
});

final myTrustedDriversProvider = StreamProvider<List<TrustedDriver>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  if (kUseDevMode) {
    return Stream.value([
      TrustedDriver(
        id: 'trusted_1',
        parentId: uid,
        driverId: 'driver_user_1',
        label: 'Uncle',
        isActive: true,
      ),
    ]);
  }

  return ref.watch(juniorRepoProvider).watchTrustedDriversForParent(uid);
});

final myJuniorInviteCodesProvider =
    StreamProvider<List<JuniorInviteCode>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();

  if (kUseDevMode) {
    return Stream.value([
      JuniorInviteCode(
        id: 'invite_1',
        code: 'AB12CD',
        parentId: uid,
        isUsed: false,
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 24)),
        createdAt: DateTime.now().toUtc(),
        invitedDriverName: 'Family Driver',
        invitedDriverPhone: '+966500000000',
        invitedDriverRelation: 'family_driver',
      ),
    ]);
  }

  return ref.watch(juniorRepoProvider).watchInviteCodesForParent(uid);
});
