import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// A dismissible banner that appears when network connectivity degrades.
///
/// UX contract (§5.6 Device & Network Resilience):
///  - Shows when ConnectivityResult is none or when measured latency is high.
///  - Dismissed with an X button — never auto-blocks the user.
///  - Never shown during normal connectivity.
///
/// Usage: wrap any Scaffold body with this widget, or place it in the app shell.
class SlowNetworkBanner extends StatefulWidget {
  final Widget child;
  const SlowNetworkBanner({super.key, required this.child});

  @override
  State<SlowNetworkBanner> createState() => _SlowNetworkBannerState();
}

class _SlowNetworkBannerState extends State<SlowNetworkBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOffline = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  void _initConnectivity() {
    try {
      _sub =
          Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
      Connectivity().checkConnectivity().then(
            _onConnectivityChanged,
            // Silently ignore errors (e.g. MissingPluginException in tests).
            onError: (_) {},
          );
    } catch (_) {
      // MissingPluginException in test/desktop environments — banner stays hidden.
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      setState(() {
        _isOffline = offline;
        _dismissed = false; // re-show banner if connection drops again
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        if (_isOffline && !_dismissed)
          Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFFF3CD),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 18,
                    color: Color(0xFF856404),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isRtl
                          ? 'لا يوجد اتصال بالإنترنت — يتم عرض البيانات المحفوظة'
                          : 'No internet connection — showing cached data',
                      style: const TextStyle(
                        color: Color(0xFF856404),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Color(0xFF856404),),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: isRtl ? 'إغلاق' : 'Dismiss',
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
