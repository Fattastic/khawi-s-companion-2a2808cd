import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';
import 'package:khawi_flutter/features/passenger/presentation/home/widgets/passenger_quick_links.dart';

void main() {
  testWidgets('Passenger quick links navigate to communities', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: PassengerQuickLinks()),
        ),
        GoRoute(
          path: Routes.communities,
          builder: (_, __) => const Scaffold(
            body: Text('Communities Destination'),
          ),
        ),
        GoRoute(
          path: Routes.events,
          builder: (_, __) => const Scaffold(
            body: Text('Events Destination'),
          ),
        ),
        GoRoute(
          path: Routes.sharedFareEstimator,
          builder: (_, __) => const Scaffold(
            body: Text('Fare Estimator Destination'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Communities'), findsOneWidget);

    await tester.tap(find.text('Communities'));
    await tester.pumpAndSettle();

    expect(find.text('Communities Destination'), findsOneWidget);
  });

  testWidgets('Passenger quick links navigate to events', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: PassengerQuickLinks()),
        ),
        GoRoute(
          path: Routes.events,
          builder: (_, __) => const Scaffold(
            body: Text('Events Destination'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Event Rides'), findsOneWidget);

    await tester.tap(find.text('Event Rides'));
    await tester.pumpAndSettle();

    expect(find.text('Events Destination'), findsOneWidget);
  });

  testWidgets('Passenger quick links navigate to fare estimator',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: PassengerQuickLinks()),
        ),
        GoRoute(
          path: Routes.sharedFareEstimator,
          builder: (_, __) => const Scaffold(
            body: Text('Fare Estimator Destination'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fare Estimator'), findsOneWidget);

    await tester.tap(find.text('Fare Estimator'));
    await tester.pumpAndSettle();

    expect(find.text('Fare Estimator Destination'), findsOneWidget);
  });
}
