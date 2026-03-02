import 'package:khawi_flutter/features/circles/domain/entities/seat_commitment.dart';
import 'package:khawi_flutter/features/profile/domain/trust_tier.dart';

class CommuteCircle {
  final String id;
  final String neighborhoodId;
  final String destinationId; // District or cluster
  final String routeId;
  final String title;
  final List<String> memberIds;
  final List<SeatCommitment> commitments;
  final Map<int, List<TimeOfDayRange>>
      schedule; // DayOfWeek -> List of TimeRanges
  final bool womenOnly;
  final bool isPrivate;
  final double reliabilityScore;
  final TrustTier requiredTier;

  bool get isPink => requiredTier.index >= TrustTier.silver.index;

  const CommuteCircle({
    required this.id,
    required this.neighborhoodId,
    required this.destinationId,
    required this.routeId,
    required this.title,
    required this.memberIds,
    required this.commitments,
    required this.schedule,
    this.womenOnly = false,
    this.isPrivate = false,
    this.reliabilityScore = 1.0,
    this.requiredTier = TrustTier.bronze,
  });

  bool hasOverlap(CommuteCircle other) {
    // Basic schedule overlap check logic
    for (var day in schedule.keys) {
      if (other.schedule.containsKey(day)) {
        final myRanges = schedule[day]!;
        final otherRanges = other.schedule[day]!;
        for (var myRange in myRanges) {
          for (var otherRange in otherRanges) {
            if (myRange.overlaps(otherRange)) return true;
          }
        }
      }
    }
    return false;
  }
}

class TimeOfDayRange {
  final int startMinutes; // Minutes from midnight
  final int endMinutes;

  const TimeOfDayRange({required this.startMinutes, required this.endMinutes});

  bool overlaps(TimeOfDayRange other) {
    return startMinutes < other.endMinutes && other.startMinutes < endMinutes;
  }
}
