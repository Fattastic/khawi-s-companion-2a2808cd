import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/state/providers.dart';

class InstantRideScannerScreen extends ConsumerStatefulWidget {
  const InstantRideScannerScreen({super.key});

  @override
  ConsumerState<InstantRideScannerScreen> createState() =>
      _InstantRideScannerScreenState();
}

class _InstantRideScannerScreenState
    extends ConsumerState<InstantRideScannerScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Ride Scanner'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              final barcodes = capture.barcodes;
              final value =
                  barcodes.isNotEmpty ? barcodes.first.rawValue : null;
              if (value == null || value.isEmpty) return;

              setState(() => _handled = true);

              _handleScan(value);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Point your camera at the QR code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(String raw) async {
    String? tripId;
    final v = raw.trim();

    if (v.startsWith('khawi:trip:')) {
      tripId =
          v.split('khawi:trip:').last.trim(); // ignore: deprecated_member_use
    } else if (RegExp(r'^[0-9a-fA-F-]{20,} ?$').hasMatch(v)) {
      // allow scanning raw uuid-like values too
      tripId = v.replaceAll('\u0000', '');
    }

    if (tripId == null || tripId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported QR payload: $raw')),
      );
      setState(() => _handled = false);
      return;
    }

    try {
      await ref.read(requestsRepoProvider).sendJoinRequest(tripId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent')),
      );
      context.go(Routes.passengerBooking, extra: tripId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
      setState(() => _handled = false);
    }
  }
}
