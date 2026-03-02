# Animation and Motion Refinement Plan

## Scope

This plan defines elegant, performance-safe, state-driven motion for Khawi with
focus on XP progress and route tracking.

## App Context

- Framework: Flutter/Dart
- State management: Riverpod
- Mapping stack: `flutter_map` + OpenStreetMap tiles
- Existing motion base:
  - `lib/core/motion/motion_tokens.dart`
  - `lib/core/motion/khawi_motion.dart`
  - Global reduced motion via `MediaQuery.disableAnimations` in
    `lib/app/app.dart`
- Key screens:
  - XP: `PassengerHomeScreen`, `DriverDashboardScreen`, `RewardsScreen`,
    `PostRideScreen`, `XpLedgerScreen`
  - Live route: `LiveTripPassengerScreen`, `LiveTripDriverScreen`,
    `LiveTrackingScreen`, `ExploreMapScreen`

## Motion Principles

### Purpose Rules

- Animate when state changes need clarity:
  - XP gain, level-up, mission/streak progress, route status changes, route
    recalculation.
- Do not animate background noise:
  - Frequent telemetry ticks should be smoothed, not celebrated.
- Do not block primary actions:
  - Navigation, emergency actions, chat, and ride control remain instant.

### Timing and Easing

- Micro feedback: 100-180ms, ease out
- Inline state transition: 180-260ms, standard ease
- Emphasized success feedback: 260-360ms, emphasized in/out
- Reduce motion mode: zero duration or minimal fade only

### Choreography Rules

- One focus item per event.
- Keep motion local to changed component.
- Use subtle stagger only for entry groups.
- Preserve continuity only when it represents the same entity (example: shared
  map card to live trip).

## Motion Hierarchy

### Level 1: Micro Interaction

- Tap press, stat number updates, small status text swaps.
- Target: perceived responsiveness.

### Level 2: State Transition

- XP progress bars, ETA/status rows, mission row value changes.
- Target: clear understanding of change.

### Level 3: Feedback/Celebration

- Level-up pulse, milestone completion check.
- Target: reinforce progress without flow interruption.

## Animation Map by Feature

### XP Progress

- User moment: XP value changes after trip/challenge/reward action.
- Goal: immediate feedback and readable progress to next level.
- Pattern:
  - Animated number interpolation
  - Progress bar tween
  - Short `+XP` chip fade/scale
- Trigger: `newXp > oldXp`
- Do:
  - Coalesce quick consecutive updates.
  - Keep buttons enabled.
- Do not:
  - Trigger full-screen overlays for every gain.

### Level-Up

- User moment: XP crosses level threshold.
- Goal: celebrate briefly and return control.
- Pattern:
  - Icon/badge pulse
  - Optional subtle haptic
- Trigger: `newLevel > oldLevel`
- Do:
  - Show concise level jump if multiple levels crossed.
- Do not:
  - Block route or post-ride actions.

### Route Tracking Progress

- User moment: location/ETA updates on live trip.
- Goal: keep map readable and avoid jitter.
- Pattern:
  - Marker interpolation between points
  - Animated ETA/status row swap
  - Optional subtle route progress reveal
- Trigger: new tracking point or ETA/status change
- Do:
  - Interpolate marker motion.
  - Isolate map overlay repaints.
- Do not:
  - Animate entire map widget every tick.

### Milestone Reached

- User moment: mission complete, streak advanced, wallet update.
- Goal: reinforce achievement and show next action.
- Pattern:
  - Row value switch animation
  - Compact highlight state
- Trigger: `previousSnapshot != currentSnapshot`
- Do:
  - Pair motion with text and icon state changes.
- Do not:
  - Convey meaning with motion alone.

### Route Recalculation

- User moment: route path updates.
- Goal: communicate route update without disorientation.
- Pattern:
  - Previous path fade down
  - New path quick draw-in
- Trigger: polyline changed
- Do:
  - Show explicit "Route updated" text.
- Do not:
  - Jump camera unless required for safety/usability.

### Start/Stop Tracking and Errors

- User moment: tracking starts, permission denied, tracking paused, retry.
- Goal: trust and clarity.
- Pattern:
  - Status chip/icon swap
  - Inline banner with `AnimatedSize`
- Trigger: controller state transitions
- Do:
  - Keep controls immediately available.
- Do not:
  - Use aggressive repeating warning effects.

## Flutter Implementation Blueprint

### Preferred Widget Strategy

- Use implicit animation first:
  - `AnimatedSwitcher`, `AnimatedSize`, `TweenAnimationBuilder`, `AnimatedScale`
- Use explicit controllers only where needed:
  - Marker interpolation, sequenced celebration
- Use `Hero` only when continuity is meaningful.

### State-Driven Trigger Architecture

- Derive animation intent from state diffs, not fire-and-forget calls.
- Suggested derived model for each surface:
  - `xpDelta`
  - `leveledUp`
  - `milestoneUnlocked`
  - `routeRecalculated`
- Keep animation logic local to view components, not repository layer.

### Performance Guardrails

- Isolate frequently animated parts with `RepaintBoundary`.
- Avoid rebuilding parent trees for small animation updates.
- Use static `child` in `AnimatedBuilder` when possible.
- Avoid expensive opacity/clipping effects over large map areas.
- Validate frame pacing in profile mode and DevTools timeline.

### Accessibility Guardrails

- Respect reduced motion from app settings and platform.
- In reduced motion:
  - Prefer instant swap or short fade.
  - Disable pulse/bounce loops.
- Never encode required information with motion only.

## Current Implementation Status

All code batches are **complete**. `flutter analyze` passes with no errors, all
572 tests pass.

### Implemented

- Animated XP summary widget and integration in rewards
  (`animated_xp_summary.dart` → `rewards_screen.dart`).
- Animated stat number switches in passenger stats row.
- Animated passenger ETA/status row transitions.
- Animated driver trip status row transitions.
- Marker interpolation and marker-layer repaint isolation in app map
  (`_AnimatedMarkerLayer` in `app_map.dart`).
- Animated post-trip progress row value transitions
  (`post_trip_progress_card.dart`).
- Animated redeemable XP counter in XP ledger balance card.
- Route polyline progress reveal for live trip (`_AnimatedRouteLayer` in
  `app_map.dart`).
- Route morph/fade: previous route fades while new route reveals progressively.
- Soft camera recenter on route changes (`recenterOnRouteChange` in
  `app_map.dart`).
- Milestone completion micro-celebration (`progress_milestone_banner.dart` →
  `passenger_home_screen.dart`, `driver_dashboard_screen.dart`).
- "Route updated" animated hint in live trip overlays
  (`live_trip_passenger_screen.dart`, `live_trip_driver_screen.dart`).
- Consistent page transition policy in router (`router.dart` — shared-axis
  vertical for post-ride, fade-through for live trips).
- Motion QA diagnostics screen (`motion_diagnostics_screen.dart` at
  `/dev/motion-diagnostics`).

### Remaining (runtime / device-dependent)

- DevTools profile pass and jank triage on representative devices.
- Duration/curve tuning based on real-device telemetry.

## Verification and Acceptance Checklist

- [x] No animation blocks core actions
- [x] XP updates feel immediate and readable
- [x] Route tracking remains legible during motion
- [ ] Representative devices sustain 60fps in profile runs _(requires device
      profiling)_
- [x] No rebuild storms for simple state updates (`RepaintBoundary` isolates
      animated layers)
- [x] Reduced motion is consistently honored (`MediaQuery.disableAnimations`
      checked in all animated widgets)
- [x] Critical state changes are still clear with motion disabled

## Rollout Plan

1. ~~Land shared motion primitives and state-diff helpers.~~ ✅
2. ~~Complete XP and live-trip surfaces first.~~ ✅
3. ~~Add route recalculation and milestone feedback polish.~~ ✅
4. Run profile measurements on target devices. _(pending)_
5. Tune durations/curves based on telemetry and QA. _(pending)_
