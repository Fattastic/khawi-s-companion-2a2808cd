import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:khawi_flutter/core/debug/logging/trace_logger.dart';
import 'package:khawi_flutter/core/backend/schema_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend_contract.dart';
import 'package:khawi_flutter/data/dto/edge/compute_incentives_dto.dart';
import 'package:khawi_flutter/data/dto/edge/check_trip_safety_dto.dart';
import 'package:khawi_flutter/data/dto/edge/verify_identity_dto.dart';
import 'package:khawi_flutter/data/dto/edge/xp_calculate_dto.dart';

/// Result of a backend health check ping
class PingResult {
  final bool success;
  final int? statusCode;
  final String? error;
  final Duration? latency;

  const PingResult({
    required this.success,
    this.statusCode,
    this.error,
    this.latency,
  });

  factory PingResult.ok({int? statusCode, Duration? latency}) => PingResult(
        success: true,
        statusCode: statusCode ?? 200,
        latency: latency,
      );

  factory PingResult.failed({int? statusCode, String? error}) => PingResult(
        success: false,
        statusCode: statusCode,
        error: error,
      );

  @override
  String toString() => success
      ? 'OK (${statusCode ?? 200}) ${latency?.inMilliseconds ?? 0}ms'
      : 'FAILED ($statusCode): $error';
}

/// Dev-only service to verify Edge Function deployment and auth wiring.
/// Only usable in debug mode.
class BackendDiagnostics {
  static const Duration _edgeFunctionTimeout = Duration(seconds: 12);
  static const int _maxPayloadSummaryChars = 300;

  /// Run schema guard and return any errors (debug only)
  Future<List<String>> runSchemaGuardChecks() async {
    return await performSchemaGuard(_sb);
  }

  final SupabaseClient _sb;

  BackendDiagnostics(this._sb);

  /// Returns true if diagnostics should be available (debug mode only)
  static bool get isAvailable => kDebugMode;

  /// Helper to invoke Edge Functions with tracing and logging.
  Future<FunctionResponse> _invoke(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final traceId = const Uuid().v4();
    final stopwatch = Stopwatch()..start();

    // Log request start
    traceLogger.logCall(
      traceId: traceId,
      functionName: functionName,
      statusCode:
          0, // 0 indicates pending/request start in this context or we could omit if API allowed
      durationMs: 0,
      payloadSummary: _safePayloadSummary(body),
    );

    try {
      final response = await _sb.functions.invoke(
        functionName,
        body: body,
        headers: {'X-Khawi-Trace-Id': traceId},
      ).timeout(_edgeFunctionTimeout);
      stopwatch.stop();

      // Log success
      traceLogger.logCall(
        traceId: traceId,
        functionName: functionName,
        statusCode: response.status,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return response;
    } on FunctionException catch (e) {
      stopwatch.stop();
      // Log error
      traceLogger.logCall(
        traceId: traceId,
        functionName: functionName,
        statusCode: e.status,
        durationMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.details?.toString() ?? e.toString(),
      );
      rethrow;
    } on TimeoutException catch (e) {
      stopwatch.stop();
      traceLogger.logCall(
        traceId: traceId,
        functionName: functionName,
        statusCode: 408,
        durationMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Timeout: ${e.message ?? _edgeFunctionTimeout}',
      );
      rethrow;
    } catch (e) {
      stopwatch.stop();
      // Log unexpected error
      traceLogger.logCall(
        traceId: traceId,
        functionName: functionName,
        statusCode: 500,
        durationMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  String? _safePayloadSummary(Map<String, dynamic>? body) {
    if (body == null) return null;
    try {
      final encoded = jsonEncode(body);
      if (encoded.length <= _maxPayloadSummaryChars) return encoded;
      return '${encoded.substring(0, _maxPayloadSummaryChars)}…';
    } catch (_) {
      return '<non-serializable-payload>';
    }
  }

  /// Ping the score_matches Edge Function with minimal safe payload.
  /// Tests: deployment + auth + basic response.
  Future<PingResult> pingSmartMatch() async {
    if (!isAvailable) {
      return PingResult.failed(
        error: 'Diagnostics only available in debug mode',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _invoke(
        EdgeFn.smartMatch,
        body: {
          'origin': {'lat': 24.7136, 'lng': 46.6753},
          'destination': {'lat': 24.7136, 'lng': 46.6753},
          'max_results': 1,
        },
      );
      stopwatch.stop();
      if (response.data != null) {
        try {
          final data = response.data as Map<String, dynamic>;
          final matches = data['matches'];
          if (matches is! List) {
            throw StateError('Missing matches list');
          }
          return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
        } catch (e) {
          return PingResult.failed(statusCode: 200, error: 'Parsing error: $e');
        }
      }
      return PingResult.failed(statusCode: 200, error: 'Empty response');
    } on FunctionException catch (e) {
      stopwatch.stop();
      final status = e.status;
      if (status == 401 || status == 403) {
        return PingResult.failed(
          statusCode: status,
          error: 'Auth error: ${e.reasonPhrase ?? 'Unauthorized'}',
        );
      }
      return PingResult.failed(
        statusCode: status,
        error: e.reasonPhrase ?? e.toString(),
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult.failed(error: e.toString());
    }
  }

  /// Ping the compute_incentives Edge Function with minimal safe payload.
  /// Tests: XP/incentive calculation system.
  Future<PingResult> pingXpCalculate() async {
    if (!isAvailable) {
      return PingResult.failed(
        error: 'Diagnostics only available in debug mode',
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final session = _sb.auth.currentSession;
      if (session == null) {
        return PingResult.failed(statusCode: 401, error: 'No active session');
      }
      final req = XpCalculateRequest(
        userId: session.user.id,
        baseXp: 1,
        occurredAt: DateTime.now(),
      );
      final response = await _invoke(
        EdgeFn.xpCalculate,
        body: req.toJson(),
      );
      stopwatch.stop();
      if (response.data != null) {
        try {
          XpCalculateResponse.fromJson(response.data as Map<String, dynamic>);
          return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
        } catch (e) {
          return PingResult.failed(statusCode: 200, error: 'Parsing error: $e');
        }
      }
      return PingResult.failed(statusCode: 200, error: 'Empty response');
    } on FunctionException catch (e) {
      stopwatch.stop();
      final status = e.status;
      if (status == 404) {
        return _pingComputeIncentivesFallback();
      }
      if (status == 401 || status == 403) {
        return PingResult.failed(
          statusCode: status,
          error: 'Auth error: ${e.reasonPhrase ?? 'Unauthorized'}',
        );
      }
      return PingResult.failed(
        statusCode: status,
        error: e.reasonPhrase ?? e.toString(),
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult.failed(error: e.toString());
    }
  }

  /// Ping a lightweight function to verify identity/auth is working.
  /// Uses check_trip_safety with minimal payload as a health check.
  Future<PingResult> pingVerifyIdentity() async {
    if (!isAvailable) {
      return PingResult.failed(
        error: 'Diagnostics only available in debug mode',
      );
    }

    // First verify we have a valid session
    final session = _sb.auth.currentSession;
    if (session == null) {
      return PingResult.failed(statusCode: 401, error: 'No active session');
    }

    final stopwatch = Stopwatch()..start();
    try {
      final req = VerifyIdentityRequest(
        userId: session.user.id,
        dryRun: true,
      );
      final response = await _invoke(
        EdgeFn.verifyIdentity,
        body: req.toJson(),
      );
      stopwatch.stop();
      if (response.data != null) {
        try {
          VerifyIdentityResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
        } catch (e) {
          return PingResult.failed(statusCode: 200, error: 'Parsing error: $e');
        }
      }
      return PingResult.failed(statusCode: 200, error: 'Empty response');
    } on FunctionException catch (e) {
      stopwatch.stop();
      final status = e.status;
      if (status == 404) {
        return _pingAuthFallback();
      }
      if (status == 401 || status == 403) {
        return PingResult.failed(
          statusCode: status,
          error: 'Auth error: ${e.reasonPhrase ?? 'Unauthorized'}',
        );
      }
      return PingResult.failed(
        statusCode: status,
        error: e.reasonPhrase ?? e.toString(),
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult.failed(error: e.toString());
    }
  }

  /// Run all health checks and return results map.
  Future<Map<String, dynamic>> runAllChecks() async {
    final results = <String, dynamic>{};
    results['Identity/Auth'] = await pingVerifyIdentity();
    results['Smart Match (AI)'] = await pingSmartMatch();
    results['XP Calculate'] = await pingXpCalculate();
    results['Schema Guard'] = await runSchemaGuardChecks();
    return results;
  }

  Future<PingResult> _pingAuthFallback() async {
    final session = _sb.auth.currentSession;
    if (session == null) {
      return PingResult.failed(statusCode: 401, error: 'No active session');
    }
    final stopwatch = Stopwatch()..start();
    try {
      final req = CheckTripSafetyRequest(
        tripId: '00000000-0000-0000-0000-000000000000',
        currentLat: 24.7136,
        currentLng: 46.6753,
        unexpectedStopDuration: 0,
        speedKmh: 0,
      );
      final response = await _invoke(
        EdgeFn.checkTripSafety,
        body: req.toJson(),
      );
      stopwatch.stop();
      if (response.data != null) {
        return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
      }
      return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
    } on FunctionException catch (e) {
      stopwatch.stop();
      final status = e.status;
      if (status == 401 || status == 403) {
        return PingResult.failed(
          statusCode: status,
          error: 'Auth error: ${e.reasonPhrase ?? 'Unauthorized'}',
        );
      }
      if (status == 404) {
        return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
      }
      return PingResult.failed(
        statusCode: status,
        error: e.reasonPhrase ?? e.toString(),
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult.failed(error: e.toString());
    }
  }

  Future<PingResult> _pingComputeIncentivesFallback() async {
    final stopwatch = Stopwatch()..start();
    try {
      final req = ComputeIncentivesRequest(
        lat: 24.7136,
        lng: 46.6753,
        time: DateTime.now(),
      );
      final response = await _invoke(
        EdgeFn.computeIncentives,
        body: req.toJson(),
      );
      stopwatch.stop();
      if (response.data != null) {
        return PingResult.ok(statusCode: 200, latency: stopwatch.elapsed);
      }
      return PingResult.failed(statusCode: 200, error: 'Empty response');
    } on FunctionException catch (e) {
      stopwatch.stop();
      final status = e.status;
      if (status == 401 || status == 403) {
        return PingResult.failed(
          statusCode: status,
          error: 'Auth error: ${e.reasonPhrase ?? 'Unauthorized'}',
        );
      }
      return PingResult.failed(
        statusCode: status,
        error: e.reasonPhrase ?? e.toString(),
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult.failed(error: e.toString());
    }
  }
}
