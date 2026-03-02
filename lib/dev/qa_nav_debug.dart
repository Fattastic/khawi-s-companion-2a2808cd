import 'package:flutter/foundation.dart';

@immutable
class QaNavSnapshot {
  const QaNavSnapshot({
    required this.location,
    required this.redirectedTo,
    required this.lastNavEvent,
    required this.updatedAt,
  });

  final String location;
  final String? redirectedTo;
  final String? lastNavEvent;
  final DateTime updatedAt;

  QaNavSnapshot copyWith({
    String? location,
    String? redirectedTo,
    String? lastNavEvent,
    DateTime? updatedAt,
  }) {
    return QaNavSnapshot(
      location: location ?? this.location,
      redirectedTo: redirectedTo ?? this.redirectedTo,
      lastNavEvent: lastNavEvent ?? this.lastNavEvent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dev-only navigation snapshot to help QA diagnose broken buttons / redirects.
///
/// Enabled via `--dart-define=QA_NAV_OVERLAY=true`.
class QaNavDebug {
  static final ValueNotifier<QaNavSnapshot> notifier = ValueNotifier(
    QaNavSnapshot(
      location: '<boot>',
      redirectedTo: null,
      lastNavEvent: null,
      updatedAt: DateTime.now(),
    ),
  );

  static void updateRedirectDecision({
    required String location,
    required String? redirectedTo,
  }) {
    final prev = notifier.value;
    notifier.value = prev.copyWith(
      location: location,
      redirectedTo: redirectedTo,
      updatedAt: DateTime.now(),
    );
  }

  static void updateNavEvent(String event) {
    final prev = notifier.value;
    notifier.value = prev.copyWith(
      lastNavEvent: event,
      updatedAt: DateTime.now(),
    );
  }
}
