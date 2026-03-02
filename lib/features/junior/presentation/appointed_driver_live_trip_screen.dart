import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/junior/presentation/junior_providers.dart';
import 'package:khawi_flutter/services/permission_service.dart';
import 'package:khawi_flutter/state/providers.dart';

class AppointedDriverLiveTripScreen extends ConsumerStatefulWidget {
  final String runId;
  const AppointedDriverLiveTripScreen({super.key, required this.runId});

  @override
  ConsumerState<AppointedDriverLiveTripScreen> createState() =>
      _AppointedDriverLiveTripScreenState();
}

class _AppointedDriverLiveTripScreenState
    extends ConsumerState<AppointedDriverLiveTripScreen> {
  Timer? _timer;
  bool _pushing = false;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 10), (_) => _pushLocation());
    // Kick a first push shortly after mount.
    Future<void>.delayed(const Duration(milliseconds: 400), _pushLocation);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pushLocation() async {
    if (_pushing) return;
    _pushing = true;
    try {
      // Check permission silently (no dialog) for background location updates
      final isGranted = await PermissionService.isLocationPermissionGranted();
      if (!isGranted) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await ref.read(juniorRepoProvider).driverPushJuniorLocation(
            runId: widget.runId,
            lat: pos.latitude,
            lng: pos.longitude,
            accuracy: pos.accuracy,
          );
    } catch (_) {
      // Don't surface noisy GPS/RLS issues; user can still operate status controls.
    } finally {
      _pushing = false;
    }
  }

  Future<void> _setStatus(String status) async {
    try {
      await ref.read(juniorRepoProvider).updateRunStatus(
            runId: widget.runId,
            newStatus: status,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated: $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final runsAsync = ref.watch(assignedJuniorRunsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: const Text('Live run'),
        actions: [
          IconButton(
            tooltip: 'Push location now',
            onPressed: _pushLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: runsAsync.when(
        data: (runs) {
          final run = runs.where((r) => r.id == widget.runId).firstOrNull;
          if (run == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Run not found or not assigned.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${run.status}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pickup: ${run.pickupTime.toLocal().toString().split(".").first}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pickup: (${run.pickupLat.toStringAsFixed(5)}, ${run.pickupLng.toStringAsFixed(5)})',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dropoff: (${run.dropoffLat.toStringAsFixed(5)}, ${run.dropoffLng.toStringAsFixed(5)})',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: 'En route',
                    onTap: () => _setStatus('en_route'),
                  ),
                  _StatusChip(
                    label: 'Arrived',
                    onTap: () => _setStatus('arrived'),
                  ),
                  _StatusChip(
                    label: 'Picked up',
                    onTap: () => _setStatus('picked_up'),
                  ),
                  _StatusChip(
                    label: 'Dropped off',
                    onTap: () => _setStatus('dropped_off'),
                  ),
                  _StatusChip(
                    label: 'Completed',
                    onTap: () => _setStatus('completed'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to runs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
