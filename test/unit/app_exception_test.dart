import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/error/app_exception.dart';

void main() {
  group('AppException', () {
    test('stores message and optional code', () {
      final e = AppException('Something failed', code: 'ERR_001');
      expect(e.message, 'Something failed');
      expect(e.code, 'ERR_001');
    });

    test('toString includes message and code', () {
      final e = AppException('fail', code: 'E1');
      expect(e.toString(), contains('fail'));
      expect(e.toString(), contains('E1'));
    });

    test('toString works without code', () {
      final e = AppException('fail');
      expect(e.toString(), contains('fail'));
    });

    test('stores originalError', () {
      final orig = Exception('root cause');
      final e = AppException('wrapped', originalError: orig);
      expect(e.originalError, orig);
    });
  });

  group('AuthException', () {
    test('is an AppException', () {
      final e = AuthException('Invalid token');
      expect(e, isA<AppException>());
      expect(e.message, 'Invalid token');
    });
  });

  group('NetworkException', () {
    test('is an AppException', () {
      final e = NetworkException('No connection', code: 'NET_001');
      expect(e, isA<AppException>());
      expect(e.code, 'NET_001');
    });
  });

  group('ValidationException', () {
    test('is an AppException', () {
      final e = ValidationException('Email is required');
      expect(e, isA<AppException>());
      expect(e.message, 'Email is required');
    });
  });
}
