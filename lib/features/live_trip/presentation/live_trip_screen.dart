import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;

import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/data/dto/edge/check_trip_safety_dto.dart';
import 'package:khawi_flutter/state/providers.dart';

class LiveTripScreen extends ConsumerStatefulWidget {
  final String tripId;
  const LiveTripScreen({super.key, required this.tripId});

  @override
  ConsumerState<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends ConsumerState<LiveTripScreen> {
  Timer? _safetyTimer;
  Map<String, dynamic>? _safetyStatus;
  bool _isChecking = false;
  bool _isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _safetyTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkSafety(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSafety());
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<Position> _getBestEffortPosition({
    required LocationAccuracy accuracy,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return (await Geolocator.getLastKnownPosition()) ??
          Position(
            latitude: 24.7136,
            longitude: 46.6753,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
    }
  }

  Future<void> _triggerSOS() async {
    if (_isSendingSOS) return;
    setState(() => _isSendingSOS = true);

    try {
      final position =
          await _getBestEffortPosition(accuracy: LocationAccuracy.high);
      final svc = ref.read(safetyServiceProvider);
      await svc.createSos(
        tripId: widget.tripId,
        lat: position.latitude,
        lng: position.longitude,
        message: 'Emergency SOS triggered by passenger',
        severity: 5,
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.liveTripSosSent ?? 'SOS sent! Emergency contacts notified.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, st) {
      debugPrint('SOS failed: $e\n$st');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.liveTripSosFailed('$e') ?? 'SOS failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingSOS = false);
    }
  }

  Future<void> _checkSafety() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final position =
          await _getBestEffortPosition(accuracy: LocationAccuracy.medium);
      final svc = ref.read(safetyServiceProvider);
      final req = CheckTripSafetyRequest(
        tripId: widget.tripId,
        currentLat: position.latitude,
        currentLng: position.longitude,
        unexpectedStopDuration: 0,
        speedKmh: position.speed * 3.6,
      );
      final resp = await svc.checkTripSafety(req);
      if (!mounted) return;
      setState(() {
        _safetyStatus = resp?.toJson();
      });
    } catch (e, st) {
      debugPrint('Safety check failed: $e\n$st');
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final risk = (_safetyStatus?['risk_score'] as num?) ?? 0;
    final isCritical = risk > 75;
    final isWarning = risk > 40;
    final flags = (_safetyStatus?['flags'] ?? 'unknown').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.liveTripTitle ?? 'Live Trip'),
        backgroundColor:
            isCritical ? Colors.red : (isWarning ? Colors.orange : null),
        foregroundColor: (isCritical || isWarning) ? Colors.white : null,
        actions: [
          if (_safetyStatus != null)
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16.0),
                child: Text(
                  l10n?.liveTripRiskLabel(risk.toInt().toString()) ??
                      'Risk: ${risk.toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: ll.LatLng(24.7136, 46.6753),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.khawi.app.khawi_app',
              ),
            ],
          ),
          if (isCritical || isWarning)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: isCritical ? Colors.red[50] : Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: isCritical ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isCritical
                                  ? (l10n?.liveTripCriticalAlertTitle ??
                                      'CRITICAL SAFETY ALERT')
                                  : (l10n?.liveTripSafetyWarningTitle ??
                                      'Safety Warning'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCritical
                                    ? Colors.red
                                    : Colors.orange[900],
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.liveTripUnusualActivityMessage(flags) ??
                            'Our system has detected unusual trip activity ($flags). Support has been notified.',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.start,
                      ),
                      if (isCritical) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSendingSOS ? null : _triggerSOS,
                            icon: _isSendingSOS
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.sos),
                            label: Text(
                              _isSendingSOS
                                  ? (l10n?.liveTripSending ?? 'Sending...')
                                  : (l10n?.liveTripSosCta ??
                                      'SOS - EMERGENCY HELP'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            bottom: 30,
            end: 16,
            child: FloatingActionButton(
              onPressed: () => context.push(Routes.chatPath(widget.tripId)),
              child: const Icon(Icons.chat),
            ),
          ),
        ],
      ),
    );
  }
}
