/// Trace Logger - Structured logging with trace IDs for debugging.
///
/// This is a debug-only utility that provides:
/// - UUID trace IDs for request correlation
/// - PII-safe logging (no phone, full names, precise locations)
/// - Circular buffer of recent calls for inspection
library;

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Global trace logger instance (debug-only).
final traceLogger = TraceLogger._();

/// A single logged network call entry.
class TraceEntry {
  final String traceId;
  final String functionName;
  final int statusCode;
  final int durationMs;
  final DateTime timestamp;
  final String? payloadSummary;
  final String? errorMessage;

  const TraceEntry({
    required this.traceId,
    required this.functionName,
    required this.statusCode,
    required this.durationMs,
    required this.timestamp,
    this.payloadSummary,
    this.errorMessage,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> toJson() => {
        'traceId': traceId,
        'functionName': functionName,
        'statusCode': statusCode,
        'durationMs': durationMs,
        'timestamp': timestamp.toIso8601String(),
        'payloadSummary': payloadSummary,
        'errorMessage': errorMessage,
      };
}

/// Trace logger with circular buffer for recent calls.
class TraceLogger {
  TraceLogger._();

  static const _uuid = Uuid();
  static const _maxEntries = 100;

  final _entries = Queue<TraceEntry>();
  final _errorStack = <TraceEntry>[];

  /// Generate a new trace ID.
  String generateTraceId() => _uuid.v4();

  /// Log a network call (debug-only, no-op in release).
  void logCall({
    required String traceId,
    required String functionName,
    required int statusCode,
    required int durationMs,
    String? payloadSummary,
    String? errorMessage,
  }) {
    if (kReleaseMode) return;

    final entry = TraceEntry(
      traceId: traceId,
      functionName: functionName,
      statusCode: statusCode,
      durationMs: durationMs,
      timestamp: DateTime.now(),
      payloadSummary: _sanitizePayload(payloadSummary),
      errorMessage: errorMessage,
    );

    _entries.addLast(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeFirst();
    }

    if (!entry.isSuccess) {
      _errorStack.add(entry);
      if (_errorStack.length > 20) {
        _errorStack.removeAt(0);
      }
    }

    debugPrint('[TRACE] ${entry.functionName} | ${entry.statusCode} | '
        '${entry.durationMs}ms | ${entry.traceId}');
  }

  /// Get recent entries.
  List<TraceEntry> get recentEntries => _entries.toList();

  /// Get recent errors.
  List<TraceEntry> get recentErrors => List.unmodifiable(_errorStack);

  /// Export diagnostics as JSON.
  Map<String, dynamic> exportDiagnostics() => {
        'exportedAt': DateTime.now().toIso8601String(),
        'recentCalls': recentEntries.map((e) => e.toJson()).toList(),
        'recentErrors': recentErrors.map((e) => e.toJson()).toList(),
      };

  /// Clear all logs.
  void clear() {
    _entries.clear();
    _errorStack.clear();
  }

  /// Sanitize payload to remove PII.
  String? _sanitizePayload(String? payload) {
    if (payload == null) return null;
    // Remove phone numbers (Saudi format)
    var sanitized = payload.replaceAll(RegExp(r'\+966\d{9}'), '[PHONE]');
    sanitized = sanitized.replaceAll(RegExp(r'05\d{8}'), '[PHONE]');
    // Remove email addresses
    sanitized = sanitized.replaceAll(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      '[EMAIL]',
    );
    // Truncate if too long
    if (sanitized.length > 200) {
      sanitized = '${sanitized.substring(0, 200)}...';
    }
    return sanitized;
  }
}

/// Headers to attach to Edge Function requests for tracing.
class TraceHeaders {
  static const traceIdHeader = 'x-khawi-trace-id';
  static const clientVersionHeader = 'x-khawi-client-version';
  static const platformHeader = 'x-khawi-platform';
  static const localeHeader = 'x-khawi-locale';

  static Map<String, String> generate({
    required String traceId,
    String clientVersion = '1.0.0',
    String? locale,
  }) {
    return {
      traceIdHeader: traceId,
      clientVersionHeader: clientVersion,
      platformHeader: defaultTargetPlatform.name,
      if (locale != null) localeHeader: locale,
    };
  }
}
