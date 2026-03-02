import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/utils/json_readers.dart';

void main() {
  group('readString', () {
    test('reads string value', () {
      expect(readString({'k': 'hello'}, 'k'), 'hello');
    });

    test('converts int to string', () {
      expect(readString({'k': 42}, 'k'), '42');
    });

    test('returns empty string for missing key', () {
      expect(readString({}, 'k'), '');
    });

    test('returns empty string for null value', () {
      expect(readString({'k': null}, 'k'), '');
    });
  });

  group('readNullableString', () {
    test('reads string value', () {
      expect(readNullableString({'k': 'hi'}, 'k'), 'hi');
    });

    test('returns null for missing key', () {
      expect(readNullableString({}, 'k'), isNull);
    });

    test('returns null for null value', () {
      expect(readNullableString({'k': null}, 'k'), isNull);
    });

    test('converts non-string to string', () {
      expect(readNullableString({'k': 123}, 'k'), '123');
    });
  });

  group('readBool', () {
    test('reads bool value', () {
      expect(readBool({'k': true}, 'k'), true);
      expect(readBool({'k': false}, 'k'), false);
    });

    test('reads num as bool (non-zero = true)', () {
      expect(readBool({'k': 1}, 'k'), true);
      expect(readBool({'k': 0}, 'k'), false);
      expect(readBool({'k': -1}, 'k'), true);
    });

    test('reads string as bool', () {
      expect(readBool({'k': 'true'}, 'k'), true);
      expect(readBool({'k': 'TRUE'}, 'k'), true);
      expect(readBool({'k': '1'}, 'k'), true);
      expect(readBool({'k': 'false'}, 'k'), false);
      expect(readBool({'k': '0'}, 'k'), false);
    });

    test('returns false for missing key', () {
      expect(readBool({}, 'k'), false);
    });
  });

  group('readDouble', () {
    test('reads num value as double', () {
      expect(readDouble({'k': 3.14}, 'k'), 3.14);
      expect(readDouble({'k': 42}, 'k'), 42.0);
    });

    test('parses string to double', () {
      expect(readDouble({'k': '3.14'}, 'k'), 3.14);
    });

    test('returns 0.0 for missing key', () {
      expect(readDouble({}, 'k'), 0.0);
    });

    test('returns 0.0 for unparseable string', () {
      expect(readDouble({'k': 'abc'}, 'k'), 0.0);
    });
  });

  group('readInt', () {
    test('reads num value as int', () {
      expect(readInt({'k': 42}, 'k'), 42);
      expect(readInt({'k': 3.9}, 'k'), 3); // truncates
    });

    test('parses string to int', () {
      expect(readInt({'k': '99'}, 'k'), 99);
    });

    test('returns 0 for missing key', () {
      expect(readInt({}, 'k'), 0);
    });

    test('returns 0 for unparseable string', () {
      expect(readInt({'k': 'abc'}, 'k'), 0);
    });
  });
}
