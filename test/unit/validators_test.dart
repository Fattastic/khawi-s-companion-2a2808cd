import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/validation/validators.dart';

void main() {
  group('PhoneValidator', () {
    test('validatePhone passes valid Saudi numbers', () {
      expect(PhoneValidator.validatePhone('0501234567'), isNull);
      expect(PhoneValidator.validatePhone('+966501234567'), isNull);
      expect(PhoneValidator.validatePhone('++966501234567'), isNotNull,
          reason: 'Invalid format',);
    });

    test('validatePhone fails on invalid numbers', () {
      expect(PhoneValidator.validatePhone(''), 'Phone required');
      expect(PhoneValidator.validatePhone('12345'),
          'Invalid phone format (+966 or 0)',);
      expect(PhoneValidator.validatePhone('apple'),
          'Invalid phone format (+966 or 0)',);
      expect(PhoneValidator.validatePhone('050123456789'),
          'Invalid phone format (+966 or 0)',); // Too long
    });

    test('normalize formats correctly to +966', () {
      expect(PhoneValidator.normalize('0501234567'), '+966501234567');
      expect(PhoneValidator.normalize('+966501234567'), '+966501234567');
    });
  });

  group('LocationValidator', () {
    test('validateLatitude passes valid ranges', () {
      expect(LocationValidator.validateLatitude(24.7136), isNull);
      expect(LocationValidator.validateLatitude(90.0), isNull);
      expect(LocationValidator.validateLatitude(-90.0), isNull);
    });

    test('validateLatitude fails invalid ranges', () {
      expect(LocationValidator.validateLatitude(91.0),
          'Latitude must be between -90 and 90',);
      expect(LocationValidator.validateLatitude(-91.0),
          'Latitude must be between -90 and 90',);
    });

    test('validateLongitude passes valid ranges', () {
      expect(LocationValidator.validateLongitude(46.6753), isNull);
      expect(LocationValidator.validateLongitude(180.0), isNull);
      expect(LocationValidator.validateLongitude(-180.0), isNull);
    });

    test('validateLongitude fails invalid ranges', () {
      expect(LocationValidator.validateLongitude(181.0),
          'Longitude must be between -180 and 180',);
      expect(LocationValidator.validateLongitude(-181.0),
          'Longitude must be between -180 and 180',);
    });
  });
}
