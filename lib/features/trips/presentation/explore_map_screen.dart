import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:khawi_flutter/app/routes.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:khawi_flutter/core/map/geo_point.dart';
import 'package:khawi_flutter/core/widgets/app_map.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart';

import 'controllers/explore_map_controller.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const ExploreMapScreen({super.key, required this.role});

  bool get isDriver => role == UserRole.driver;

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
  }

  ll.LatLng llLatLng(GeoPoint p) => ll.LatLng(p.lat, p.lng);

  @override
  Widget build(BuildContext context) {
    // Keep the map centered on the current location when it updates.
    ref.listen<ExploreMapState>(exploreMapControllerProvider, (prev, next) {
      final controller = _mapController;
      final p = next.currentLocation;
      if (controller != null && p != null && mounted) {
        controller.move(llLatLng(p), 15);
      }
    });

    final mapState = ref.watch(exploreMapControllerProvider);
    final controller = ref.read(exploreMapControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          AppMap(
            initialCenter:
                mapState.currentLocation ?? const GeoPoint(24.7136, 46.6753),
            initialZoom: mapState.currentLocation != null ? 15 : 13,
            markerPoints: mapState.markerPoints,
            onMapCreated: (c) => _mapController = c,
          ),
          if (mapState.isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            right: 16,
            bottom: widget.isDriver ? 100 : 250,
            child: FloatingActionButton(
              heroTag: 'recenter_map_fab',
              onPressed: controller.recenter,
              backgroundColor: theme.colorScheme.surface,
              child: Icon(
                Icons.my_location,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (!widget.isDriver) _buildPassengerOverlay(context, theme),
          if (widget.isDriver) _buildDriverOverlay(context, theme),
        ],
      ),
    );
  }

  Widget _buildPassengerOverlay(BuildContext context, ThemeData theme) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          context.push(Routes.passengerMarketplace);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(
                isRtl ? 'إلى أين؟' : 'Where to?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverOverlay(BuildContext context, ThemeData theme) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(Routes.driverOfferRide);
        },
        icon: const Icon(Icons.add_circle_outline),
        label: Text(isRtl ? 'اعرض رحلة' : 'Offer a Ride'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
