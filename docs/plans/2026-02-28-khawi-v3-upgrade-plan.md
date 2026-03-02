# Khawi v3 UI/UX Upgrade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan
> task-by-task.

**Goal:** Execute a comprehensive facelift of the Khawi app (version 3) focusing
on total UX improvement, flawless state wiring without dead ends, and a modern
reductive interface.

**Architecture:** We are applying the "Unidirectional Hub" approach. State is
fully centralized via Riverpod, guaranteeing that the UI remains a pure function
of strict data models. Views are highly optimized, avoiding deep nesting, and
components are cleanly separated allowing rigorous testability.

**Strict Continuity Constraint:** All existing core functionalities and feature
flows from V2 must absolutely remain intact. This V3 upgrade is strictly a UX/UI
structural facelift to improve stability and UX wiring—_no active feature or
logical pathway is to be dropped, orphaned, or left unwired._

**Tech Stack:** Flutter, Riverpod (State Management), Supabase (Backend/Auth)

---

## Task 1: Fix Android Worktree Conflict & Secure Git State

**Goal:** Resolve the Android duplicate root issue to ensure the IDE operates
cleanly.

**Files:**

- Create/Modify: `.vscode/settings.json` (or `.idea/workspace.xml` depending on
  IDE)

**Step 1: Write the git ignore for worktrees** Ensure `.worktrees/` is firmly
excluded from the IDE watchers.

**Step 2: Verify git status** Run: `git status` Expected: Clean working tree on
the v3 upgrade branch.

**Step 3: Commit structural setup**

```bash
git add .vscode/settings.json
git commit -m "chore: exclude worktrees from IDE indexing to fix android duplicate root"
```

---

## Task 2: Establish Khawi v3 Base Typography & Core Theme

**Goal:** Lock in the foundational colors, text scales, and structural
boundaries.

**Files:**

- Modify: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';

void main() {
  test('AppTheme defines v3 core colors', () {
    expect(AppTheme.primaryGreen.value, isNotNull);
    expect(AppTheme.surfaceGlassLight.value, isNotNull); // New property test
  });
}
```

**Step 2: Run test to verify it fails** Run:
`flutter test test/core/theme_test.dart` Expected: FAIL (Missing
surfaceGlassLight getter)

**Step 3: Write minimal implementation**

```dart
// In app_theme.dart
static const Color surfaceGlassLight = Color(0xCCFFFFFF);
static const Color surfaceGlassDark = Color(0xCC1A1A1A);
// Update typography logic for v3 constraints here.
```

**Step 4: Run test to verify it passes** Run:
`flutter test test/core/theme_test.dart` Expected: PASS

**Step 5: Commit**

```bash
git add test/core/theme_test.dart lib/core/theme/app_theme.dart
git commit -m "feat: establish V3 foundational theme and typography constraints"
```

---

## Task 3: Implement V3 Uni-card Component (Reductive Design)

**Goal:** Create a hyper-reusable, fully wired card component that will replace
all disparate containers in the app, eliminating edge-case UI bugs.

**Files:**

- Modify: `lib/core/widgets/app_card.dart`
- Test: `test/core/widgets/app_card_test.dart`

**Step 1: Write the failing test** Test that `AppCard` manages its semantic
label and handles `onTap` flawlessly without state leakage.

**Step 2: Run test to verify it fails** Run:
`flutter test test/core/widgets/app_card_test.dart`

**Step 3: Write minimal implementation** Refactor `AppCard` to ensure it
dynamically scales and relies purely on `AppTheme` parameters without hardcoded
overrides.

**Step 4: Run test to verify it passes** Run:
`flutter test test/core/widgets/app_card_test.dart`

**Step 5: Commit**

```bash
git add lib/core/widgets/app_card.dart test/core/widgets/app_card_test.dart
git commit -m "feat: implement highly robust V3 uni-card component"
```

---

## Task 4: Refactor Passenger Hub - Decluttering & Flow Wiring

**Goal:** Strip away the noise from the Passenger Home screen and perfectly wire
the primary CTA logic into the `RideMarketplaceController`.

**Files:**

- Modify:
  `lib/features/passenger/presentation/home/widgets/passenger_primary_ctas.dart`
- Modify:
  `lib/features/trips/presentation/controllers/ride_marketplace_controller.dart`

**Step 1: Write the failing test** Create a test ensuring `PassengerPrimaryCtas`
correctly invokes the `rideMarketplaceControllerProvider` actions.

**Step 2: Run test to verify it fails** Run:
`flutter test test/features/passenger/home_ctas_test.dart`

**Step 3: Write minimal implementation** Wire the new V3 `AppCard`
implementations to explicitly dispatch state events to the Riverpod controller,
guaranteeing no lost clicks.

**Step 4: Run test to verify it passes** Run:
`flutter test test/features/passenger/home_ctas_test.dart`

**Step 5: Commit**

```bash
git add .
git commit -m "refactor: restructure passenger CTAs and wire perfectly to RideMarketplace"
```

---

## Task 5: Refactor Gamification Lists (No Dead Ends Validation)

**Goal:** Upgrade the Gamification UI to use the new structural constraints,
proving the "Unidirectional Hub" doesn't drop state.

**Files:**

- Modify: `lib/features/gamification/presentation/mission_card_list.dart`

**Step 1: Write the failing test** Assert that the mission list correctly
handles empty, loading, and populated states from the `weeklyChallengesProvider`
without throwing layout exceptions.

**Step 2: Run test to verify it fails** Run:
`flutter test test/features/gamification/mission_card_list_test.dart`

**Step 3: Write minimal implementation** Integrate `AppCard` safely around the
mission items. Ensure all data objects are immutable.

**Step 4: Run test to verify it passes** Run:
`flutter test test/features/gamification/mission_card_list_test.dart`

**Step 5: Commit**

```bash
git add .
git commit -m "refactor: safe gamification list UI wired to central state"
```
