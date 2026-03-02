import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/trips/domain/trip.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/features/chat/domain/message.dart';

// Requests
final sentRequestsProvider = StreamProvider<List<TripRequest>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(requestsRepoProvider).watchSent(uid);
});

final incomingRequestsProvider = StreamProvider<List<TripRequest>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(requestsRepoProvider).watchIncomingForDriver(uid);
});

// Trips
final tripProvider = StreamProvider.family<Trip, String>((ref, tripId) {
  return ref.watch(tripsRepoProvider).watchTrip(tripId);
});

// Junior
final juniorRunProvider = StreamProvider.family<JuniorRun, String>((
  ref,
  runId,
) {
  return ref.watch(juniorRepoProvider).watchRun(runId);
});

final juniorRunEventsProvider =
    StreamProvider.family<List<JuniorRunEvent>, String>((ref, runId) {
  return ref.watch(juniorRepoProvider).watchRunEvents(runId);
});

final juniorRunLocationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, runId) {
  return ref.watch(juniorRepoProvider).watchRunLocationsRaw(runId);
});

// Chat
final chatMessagesProvider = StreamProvider.family<List<TripMessage>, String>((
  ref,
  tripId,
) {
  return ref.watch(chatRepoProvider).watchMessages(tripId);
});
