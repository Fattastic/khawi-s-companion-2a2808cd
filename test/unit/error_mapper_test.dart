import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khawi_flutter/core/error/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('maps SocketException to no-internet message', () {
      final msg = ErrorMapper.map(
        const SocketException('Failed host lookup'),
      );
      expect(msg, contains('No internet'));
    });

    test('maps PostgrestException 23505 to duplicate message', () {
      final msg = ErrorMapper.map(
        const PostgrestException(message: 'duplicate key', code: '23505'),
      );
      expect(msg, contains('already exists'));
    });

    test('maps PostgrestException PGRST116 to not-found message', () {
      final msg = ErrorMapper.map(
        const PostgrestException(message: 'not found', code: 'PGRST116'),
      );
      expect(msg, contains('not found'));
    });

    test('maps PostgrestException 42501 (RLS) message', () {
      final msg = ErrorMapper.map(
        const PostgrestException(message: 'RLS violation', code: '42501'),
      );
      expect(msg, contains('feature'));
    });

    test('maps generic PostgrestException to server error', () {
      final msg = ErrorMapper.map(
        const PostgrestException(message: 'unknown', code: '99999'),
      );
      expect(msg, contains('Server error'));
    });

    test('maps AuthException to its own message', () {
      final msg = ErrorMapper.map(
        const AuthException('Invalid credentials'),
      );
      expect(msg, 'Invalid credentials');
    });

    test('maps timeout error via string heuristic', () {
      final msg = ErrorMapper.map(
        const TimeoutException('Connection timed out', Duration(seconds: 10)),
      );
      expect(msg, contains('timed out'));
    });

    test('maps unknown error to generic fallback', () {
      final msg = ErrorMapper.map(Exception('random'));
      expect(msg, contains('Something went wrong'));
    });
  });
}

class TimeoutException implements Exception {
  final String message;
  final Duration duration;
  const TimeoutException(this.message, this.duration);

  @override
  String toString() => 'TimeoutException: $message (after $duration)';
}
