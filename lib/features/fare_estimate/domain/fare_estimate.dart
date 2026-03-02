class FareEstimate {
  const FareEstimate({
    required this.baseFareSar,
    required this.distanceFareSar,
    required this.timeFareSar,
    required this.totalFareSar,
    required this.perPassengerFareSar,
    required this.seatCount,
  });

  final double baseFareSar;
  final double distanceFareSar;
  final double timeFareSar;
  final double totalFareSar;
  final double perPassengerFareSar;
  final int seatCount;
}

FareEstimate calculateFareEstimate({
  required double distanceKm,
  required int durationMinutes,
  required int seatCount,
  double baseFareSar = 5.0,
  double perKmSar = 1.15,
  double perMinuteSar = 0.25,
}) {
  final normalizedDistance = distanceKm < 0 ? 0.0 : distanceKm;
  final normalizedDuration = durationMinutes < 0 ? 0 : durationMinutes;
  final normalizedSeats = seatCount < 1 ? 1 : seatCount;

  final distanceFare = normalizedDistance * perKmSar;
  final timeFare = normalizedDuration * perMinuteSar;
  final total = baseFareSar + distanceFare + timeFare;
  final perPassenger = total / normalizedSeats;

  return FareEstimate(
    baseFareSar: baseFareSar,
    distanceFareSar: distanceFare,
    timeFareSar: timeFare,
    totalFareSar: total,
    perPassengerFareSar: perPassenger,
    seatCount: normalizedSeats,
  );
}
