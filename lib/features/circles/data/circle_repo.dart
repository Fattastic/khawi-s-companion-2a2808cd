import 'package:flutter_riverpod/flutter_riverpod.dart';

class CircleRepo {
  // In-memory set to track joined circles for v3 development/demo
  final Set<String> _joinedCircleIds = {};

  Future<void> joinCircle(String circleId) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _joinedCircleIds.add(circleId);
  }

  Future<void> leaveCircle(String circleId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _joinedCircleIds.remove(circleId);
  }

  bool isMember(String circleId) {
    return _joinedCircleIds.contains(circleId);
  }

  List<String> getJoinedCircleIds() {
    return _joinedCircleIds.toList();
  }
}

final circleRepoProvider = Provider((ref) => CircleRepo());

final joinedCirclesProvider = StateProvider<Set<String>>((ref) => {});
