import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChallengeType {
  riyadhExplorer,
  ecoPioneer,
  safetyFirst,
}

class Challenge {
  final String id;
  final ChallengeType type;
  final double progress;

  const Challenge({
    required this.id,
    required this.type,
    required this.progress,
  });
}

class ChallengesRepository {
  // Simulating an API call to get weekly challenges
  Future<List<Challenge>> getWeeklyChallenges() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return [
      const Challenge(
        id: '1',
        type: ChallengeType.riyadhExplorer,
        progress: 0.6,
      ),
      const Challenge(id: '2', type: ChallengeType.ecoPioneer, progress: 0.3),
      const Challenge(id: '3', type: ChallengeType.safetyFirst, progress: 0.9),
    ];
  }
}

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) {
  return ChallengesRepository();
});

final weeklyChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengesRepositoryProvider);
  return repository.getWeeklyChallenges();
});
