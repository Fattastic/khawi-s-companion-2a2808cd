import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/state/providers.dart';

void main() {
  test('Dev mode flag is set correctly', () {
    // Verify the dev mode flag is accessible
    expect(kUseDevMode, isA<bool>());
  });

  test('Provider types are correctly defined', () {
    // These tests verify the providers are properly typed
    // In actual integration tests with Supabase, you would use overrides
    expect(tripsRepoProvider, isNotNull);
    expect(juniorRepoProvider, isNotNull);
    expect(profileRepoProvider, isNotNull);
  });
}
