import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility to retry a given asynchronous function with exponential backoff.
class RetryUtils {
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(Object)? retryIf,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      attempt++;
      try {
        return await fn();
      } catch (e) {
        if (attempt >= maxAttempts || (retryIf != null && !retryIf(e))) {
          rethrow;
        }

        debugPrint(
          'Retry attempt $attempt failed. Retrying in ${delay.inMilliseconds}ms... Error: $e',
        );

        await Future<void>.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }

  /// Predicate to decide if a Supabase error should be retried.
  /// Typically retries on network failures, timeout, or server-side transient errors.
  static bool shouldRetrySupabaseError(Object e) {
    // Basic heuristics for Supabase/Postgrest errors
    final msg = e.toString().toLowerCase();
    return msg.contains('timeout') ||
        msg.contains('503') || // Service Unavailable
        msg.contains('504') || // Gateway Timeout
        msg.contains('429') || // Too Many Requests
        msg.contains('network') ||
        msg.contains('connection');
  }
}
