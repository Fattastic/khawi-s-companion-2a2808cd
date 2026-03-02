import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'qa_nav_debug.dart';

class QaNavOverlay extends StatefulWidget {
  const QaNavOverlay({super.key});

  @override
  State<QaNavOverlay> createState() => _QaNavOverlayState();
}

class _QaNavOverlayState extends State<QaNavOverlay> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder<QaNavSnapshot>(
            valueListenable: QaNavDebug.notifier,
            builder: (context, snap, _) {
              final redirect = snap.redirectedTo == null
                  ? 'ALLOW'
                  : 'REDIRECT -> ${snap.redirectedTo}';
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: _expanded ? 340 : 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.25,
                        fontFamily: 'monospace',
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('QA NAV'),
                          const SizedBox(height: 6),
                          Text('loc: ${snap.location}'),
                          Text('redir: $redirect'),
                          if (_expanded) ...[
                            const SizedBox(height: 6),
                            Text('nav: ${snap.lastNavEvent ?? '<none>'}'),
                            Text('ts: ${snap.updatedAt.toIso8601String()}'),
                            const SizedBox(height: 6),
                            const Text('(tap to collapse)'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

bool get qaNavOverlayEnabled =>
    !kReleaseMode && const bool.fromEnvironment('QA_NAV_OVERLAY');
