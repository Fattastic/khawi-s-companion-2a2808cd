# Khawi v3 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan
> task-by-task.

**Goal:** Execute the "Dynamic Facelift" for Khawi v3 by decluttering main hubs,
elevating gamification, and applying a modern, glassmorphic visual theme without
altering underlying routing.

**Architecture:** We will implement a global theme update to introduce modern
typography and glassmorphism. Then, we will sequentially refactor the
`PassengerHomeScreen` and `DriverDashboardScreen` to simplify their layouts and
extract complex widgets into sleeker, floating "pill" components. Finally, we
will integrate dynamic micro-animations to highlight mode switches and
gamification milestones.

**Tech Stack:** Flutter, Dart, Riverpod (State Management)

---

## Task 1: Establish Khawi v3 Typography & Core Theme

**Files:**

- Modify: `lib/core/theme/khawi_theme.dart` (or wherever the global `ThemeData`
  is defined)

**Step 1: Write the failing test** _(Assuming a basic UI test structure exists
for theme validation, otherwise manual verification is prioritized for visual
changes)_

```dart
testWidgets('Khawi v3 Theme uses modern typography', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(theme: khawiV3Theme, home: Scaffold(body: Text('Test'))));
  final text = tester.widget<Text>(find.text('Test'));
  expect(text.style?.fontFamily, isNot('Roboto')); // Expecting a custom/modern font
});
```

**Step 2: Run test to verify it fails** Run:
`flutter test test/widget/theme_test.dart` (or visually verify current default
fonts via `flutter run`).

**Step 3: Write minimal implementation** Update the global `ThemeData` to
enforce a bright, hyper-clean aesthetic with modern typography and define
glassmorphic baseline colors (e.g., highly transparent surfaces).

**Step 4: Run test to verify it passes** Run:
`flutter test test/widget/theme_test.dart` (or verify UI visually).

**Step 5: Commit**

```bash
git commit -am "feat: apply Khawi v3 core typography and bright theme"
```

---

## Task 2: Implement Glassmorphic Container Widget

**Files:**

- Create: `lib/core/widgets/glass_container.dart`

**Step 1: Write the failing test**

```dart
testWidgets('GlassContainer renders with BackdropFilter', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: GlassContainer(child: SizedBox()))));
  expect(find.byType(BackdropFilter), findsOneWidget);
});
```

**Step 2: Run test to verify it fails** Run:
`flutter test test/widget/glass_container_test.dart` Expected: FAIL (File not
found).

**Step 3: Write minimal implementation** Create a reusable `GlassContainer`
using `BackdropFilter`, `ClipRRect`, and a semi-transparent `Container` with
subtle borders.

**Step 4: Run test to verify it passes** Run:
`flutter test test/widget/glass_container_test.dart` Expected: PASS.

**Step 5: Commit**

```bash
git add lib/core/widgets/glass_container.dart
git commit -m "feat: reusable glassmorphism container for v3 UI"
```

---

## Task 3: Refactor Passenger Hub - Decluttering & Floating UI

**Files:**

- Modify: `lib/features/passenger/presentation/home/passenger_home_screen.dart`

**Step 1: Write the failing test**

```dart
testWidgets('PassengerHomeScreen uses floating GlassContainer for actions', (WidgetTester tester) async {
  // Setup logic
  expect(find.byType(GlassContainer), findsWidgets);
});
```

**Step 2: Run test to verify it fails** Run corresponding tests or observe the
clutter visually.

**Step 3: Write minimal implementation** Strip out solid `Card` wrappers from
the `PassengerHomeScreen`. Move secondary buttons into a collapsible or compact
`GlassContainer` overlay at the bottom of the map. Reduce padding and text
sizes.

**Step 4: Run test to verify it passes** Verify tests pass and manually confirm
the visual simplification.

**Step 5: Commit**

```bash
git commit -am "refactor: declutter PassengerHomeScreen using glassmorphic overlays"
```

---

## Task 4: Refactor Driver Dashboard - Reductive Design

**Files:**

- Modify:
  `lib/features/driver/presentation/dashboard/driver_dashboard_screen.dart`

**Step 1: Write the failing test** _(Similar visual widget test setup as
Task 3)_

**Step 2: Run test to verify it fails** Verify current complex state.

**Step 3: Write minimal implementation** Apply the same reductive design to the
Driver Dashboard. Replace heavy solid blocks with grouped `GlassContainer`
elements. Ensure the Map is the absolute focal point.

**Step 4: Run test to verify it passes** Verify tests and UI.

**Step 5: Commit**

```bash
git commit -am "refactor: apply v3 reductive design to Driver Dashboard"
```

---

## Task 5: Integrate Dynamic Gamification Pulse

**Files:**

- Modify: `lib/features/passenger/presentation/home/passenger_home_screen.dart`
  (and Driver equivalent)
- Create/Modify:
  `lib/features/gamification/presentation/widgets/gamification_pulse.dart`

**Step 1: Write the failing test**

```dart
testWidgets('Gamification pulse indicator is visible on main hub', (WidgetTester tester) async {
  // Setup logic
  expect(find.byType(GamificationPulse), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

**Step 3: Write minimal implementation** Build a minimal, animated widget
(`GamificationPulse`) that shows a subtle glow or progress ring tied to the
user's current XP or active challenge. Integrate it non-intrusively onto the Map
layers in both hubs, acting as a gateway to the Khawi World tab.

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git commit -am "feat: add persistent gamification pulse to main hubs"
```
