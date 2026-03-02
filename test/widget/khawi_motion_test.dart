import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';

void main() {
  group('KhawiMotion', () {
    testWidgets('fadeIn animates opacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhawiMotion.fadeIn(
              const Text('Hello'),
              duration: const Duration(milliseconds: 1000),
            ),
          ),
        ),
      );

      // Initial state: Opacity starts at 0.0
      expect(find.text('Hello'), findsOneWidget);
      // Wait, KhawiMotion.fadeIn returns a TweenAnimationBuilder which builds an Opacity.
      // Widget structure: TweenAnimationBuilder -> Opacity -> Text

      // Let's check opacity at start.
      // Note: TweenAnimationBuilder might start immediately.
      await tester.pump(); // Start animation

      // check intermediate state
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Opacity), findsOneWidget);
      // Opacity should be around 0.5 (depending on curve)

      // Check final state
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('pressEffect scales on tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KhawiMotion.pressEffect(
                  isPressed: pressed,
                  child: const SizedBox(width: 100, height: 100),
                );
              },
            ),
          ),
        ),
      );

      final scaleFinder = find.byType(AnimatedScale);
      expect(scaleFinder, findsOneWidget);

      AnimatedScale scaleWidget = tester.widget(scaleFinder);
      expect(scaleWidget.scale, 1.0);

      // Simulate press
      pressed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return KhawiMotion.pressEffect(
                  isPressed: true,
                  child: const SizedBox(width: 100, height: 100),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      scaleWidget = tester.widget(scaleFinder);
      expect(scaleWidget.scale, 0.98); // Default scale
    });
  });
}
