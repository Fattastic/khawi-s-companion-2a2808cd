import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/state/providers.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';

class JuniorDashboardState {
  final List<Kid> kids;
  final bool isLoading;
  final String? error;

  JuniorDashboardState({
    this.kids = const [],
    this.isLoading = true,
    this.error,
  });

  JuniorDashboardState copyWith({
    List<Kid>? kids,
    bool? isLoading,
    String? error,
  }) {
    return JuniorDashboardState(
      kids: kids ?? this.kids,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JuniorDashboardController
    extends AutoDisposeNotifier<JuniorDashboardState> {
  @override
  JuniorDashboardState build() {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return JuniorDashboardState(
        isLoading: false,
        error: "User not logged in",
      );
    }

    _initSubscription(userId);
    return JuniorDashboardState();
  }

  void _initSubscription(String parentId) {
    final sub = ref.watch(juniorRepoProvider).watchMyKids(parentId).listen(
      (kids) {
        state = state.copyWith(kids: kids, isLoading: false);
      },
      onError: (Object e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      },
    );
    ref.onDispose(() => sub.cancel());
  }

  Future<void> addKid(String name, int age) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    try {
      await ref
          .read(juniorRepoProvider)
          .addKid(parentId: userId, name: name, age: age);
    } catch (e) {
      state = state.copyWith(error: "Failed to add kid: $e");
    }
  }
}

final juniorDashboardControllerProvider = NotifierProvider.autoDispose<
    JuniorDashboardController, JuniorDashboardState>(
  JuniorDashboardController.new,
);
