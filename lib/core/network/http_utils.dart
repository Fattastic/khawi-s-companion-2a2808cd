import 'dart:async';
import 'dart:io';

/// Result of a network operation with exponential backoff retry
class NetworkOperationResult<T> {
  final T? data;
  final Exception? error;
  final int attemptsUsed;
  final bool succeeded;

  NetworkOperationResult({
    this.data,
    this.error,
    required this.attemptsUsed,
    required this.succeeded,
  });
}

/// Retry network operations with exponential backoff
Future<T> retryNetworkOperation<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  double backoffMultiplier = 2.0,
  void Function(int attemptNumber)? onRetry,
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    try {
      attempt++;
      return await operation();
    } on SocketException {
      if (attempt >= maxRetries) {
        rethrow;
      }

      onRetry?.call(attempt);
      await Future<void>.delayed(delay);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * backoffMultiplier).toInt(),
      );
    } on TimeoutException {
      if (attempt >= maxRetries) {
        rethrow;
      }

      onRetry?.call(attempt);
      await Future<void>.delayed(delay);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * backoffMultiplier).toInt(),
      );
    }
  }
}
