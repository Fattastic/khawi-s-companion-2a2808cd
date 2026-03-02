import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/core/widgets/app_map.dart';
import 'package:khawi_flutter/state/realtime_providers.dart';
import 'package:khawi_flutter/features/trips/presentation/widgets/rating_dialog.dart';

import 'controllers/live_tracking_controller.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String runId;

  const LiveTrackingScreen({super.key, required this.runId});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();

    // Keep the map centered on the latest position.
    ref.listen(liveTrackingControllerProvider(widget.runId), (prev, next) {
      final controller = _mapController;
      final p = next.lastPosition;
      if (controller != null && p != null && mounted) {
        controller.move(ll.LatLng(p.lat, p.lng), 15);
      }
    });

    // Listen for completion to show rating dialog
    ref.listen(juniorRunProvider(widget.runId), (prev, next) {
      final run = next.asData?.value;
      if (run != null && run.status == 'completed' && mounted) {
        showRatingDialog(
          context,
          tripId: run.id,
          rateeId: run.assignedDriverId ?? '',
          isRatingDriver: true,
          rateeName: 'Family Driver',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final runAsync = ref.watch(juniorRunProvider(widget.runId));
    final trackingState = ref.watch(
      liveTrackingControllerProvider(widget.runId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Junior Live Tracking")),
      body: Stack(
        children: [
          AppMap(
            initialCenter:
                trackingState.lastPosition ?? const GeoPoint(24.7136, 46.6753),
            initialZoom: trackingState.lastPosition != null ? 15 : 13,
            markerPoints: trackingState.markerPoints,
            onMapCreated: (c) => _mapController = c,
          ),

          // Loading Overlay
          if (runAsync.isLoading || trackingState.isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Info Card
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Run Status: ${runAsync.asData?.value.status ?? 'Connecting...'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (trackingState.activeLocations.isNotEmpty)
                      Text(
                        "Speed: ${trackingState.activeLocations.first.speed?.toStringAsFixed(1) ?? '0'} m/s",
                      )
                    else
                      const Text("Waiting for location..."),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
