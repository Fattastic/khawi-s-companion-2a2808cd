import 'package:flutter/material.dart';
import 'package:khawi_flutter/features/junior/presentation/live_tracking_screen.dart';

/// Legacy wrapper kept for backwards compatibility.
///
/// Historically this screen took a `tripId`, but the Junior live tracking
/// feature is run-based. We treat the passed value as a `runId`.
class KidsLiveTripScreen extends StatelessWidget {
  final String tripId;
  const KidsLiveTripScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return LiveTrackingScreen(runId: tripId);
  }
}
