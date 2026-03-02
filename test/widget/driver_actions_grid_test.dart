import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khawi_flutter/app/routes.dart';
import 'package:khawi_flutter/features/driver/presentation/dashboard/widgets/driver_actions_grid.dart';

void main() {
  testWidgets('Driver actions navigate to communities', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: DriverActionsGrid()),
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
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Communities'), findsOneWidget);

    await tester.tap(find.text('Communities'));
    await tester.pumpAndSettle();

    expect(find.text('Communities Destination'), findsOneWidget);
  });

  testWidgets('Driver actions navigate to events', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: DriverActionsGrid()),
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
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Events'), findsOneWidget);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();

    expect(find.text('Events Destination'), findsOneWidget);
  });
}
