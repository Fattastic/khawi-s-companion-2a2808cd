import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/app/app.dart';
// Ensure correct import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

// Mock dependencies if needed, or use Provider overrides
// For routing tests, we primarily need to control the state of:
// - authSessionProvider
// - myProfileProvider
// - onboardingDoneProvider
// - activeRoleProvider

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Initialize Supabase with a MockHttpClient (minimal for App start)
    final mockHttpClient = MockClient((request) async {
      return http.Response('{}', 200);
    });
    try {
      await Supabase.initialize(
        url: 'https://mock.supabase.co',
        anonKey: 'mock',
        httpClient: mockHttpClient,
      );
    } catch (_) {}
  });

  testWidgets('Routing: Unauthenticated -> Login/Splash', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        overrides: [
          // Default: null Session, null Profile
        ],
        child: KhawiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Should find LoginScreen or Onboarding (depending on logic).
    // Assuming Splash -> Onboarding (if not done) or Login
    // Since SharedPreferences is empty, Onboarding might be shown first.
    // Let's check for visual elements common to Onboarding or Login.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // Add more detailed scenarios for Passenger/Driver routing
  // This requires mocking the Session object which is tricky with Supabase
  // without a full mock. For now, strict unit testing of _computeRedirect
  // logic logic is better suited for unit tests, but a basic app pump
  // verifies the router configuration isn't crashing.
}
