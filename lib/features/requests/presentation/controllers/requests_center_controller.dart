import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';
import 'package:khawi_flutter/features/requests/presentation/requests_center_screen.dart';
import 'package:khawi_flutter/core/error/error_mapper.dart';

class RequestsCenterState {
  final List<TripRequest> requests;
  final bool isLoading;
  final String? error;

  RequestsCenterState({
    this.requests = const [],
    this.isLoading = true,
    this.error,
  });
}

class RequestsCenterController
    extends AutoDisposeFamilyNotifier<RequestsCenterState, RequestsMode> {
  @override
  RequestsCenterState build(RequestsMode arg) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return RequestsCenterState(
        isLoading: false,
        error: 'User not authenticated',
      );
    }

    _initSubscription(userId, arg);
    return RequestsCenterState();
  }

  void _initSubscription(String userId, RequestsMode mode) {
    Stream<List<TripRequest>> stream;
    final repo = ref.watch(requestsRepoProvider);

    if (mode == RequestsMode.sent) {
      stream = repo.watchSentRequests(userId);
    } else {
      stream = repo.watchIncomingRequestsForDriver(userId);
    }

    final sub = stream.listen(
      (data) {
        state = RequestsCenterState(requests: data, isLoading: false);
      },
      onError: (Object e) {
        state =
            RequestsCenterState(isLoading: false, error: ErrorMapper.map(e));
      },
    );
    ref.onDispose(() => sub.cancel());
  }

  // Actions
  Future<void> accept(String requestId) async {
    try {
      await ref.read(requestsRepoProvider).acceptRequest(requestId);
    } catch (e) {
      // Handle error (maybe toast)
    }
  }

  Future<void> decline(String requestId) async {
    try {
      await ref.read(requestsRepoProvider).declineRequest(requestId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> cancel(String requestId) async {
    try {
      await ref.read(requestsRepoProvider).cancelRequest(requestId);
    } catch (e) {
      // Handle error
    }
  }
}

// Family provider to handle different modes
final requestsCenterControllerProvider = NotifierProvider.autoDispose
    .family<RequestsCenterController, RequestsCenterState, RequestsMode>(
  RequestsCenterController.new,
);
