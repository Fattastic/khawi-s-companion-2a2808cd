class SeatCommitment {
  final String id;
  final String circleId;
  final String userId;
  final List<int> daysOfWeek;
  final DateTime? pauseUntil;
  final bool isDriver;

  const SeatCommitment({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.daysOfWeek,
    this.pauseUntil,
    this.isDriver = false,
  });

  bool isActiveOn(DateTime date) {
    if (pauseUntil != null && date.isBefore(pauseUntil!)) return false;
    return daysOfWeek.contains(date.weekday);
  }
}
