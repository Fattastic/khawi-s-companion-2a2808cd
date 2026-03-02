# Khawi Routing Debugger

This folder contains deterministic routing verification for the app's GoRouter configuration.
The intent is to catch redirect loops, broken aliases, missing canonical routes, and role-guard regressions.

## Canonicalization Rules

- Exactly one canonical path per screen.
- Aliases and legacy paths are redirect-only (no `builder`).
- Shell routes use `/app/p/...`, `/app/d/...`, `/app/j/...`.

## Entry Flow (Redirect Order)

The router redirect enforces this order:

1. Splash loading gate
2. Onboarding gate
3. Auth gate
4. Base profile gate (before role selection)
5. Role resolution (persisted last selected role when available)
6. Role guards (NotAuthorized)
7. Driver verification gate
8. Premium gate
9. Shared/legacy aliases

## State Matrix Expectations (High Level)

- Onboarding not done -> `/onboarding`
- Logged out (after onboarding) -> `/auth/login`
- Logged in + profile missing or base profile incomplete -> `/auth/enrichment`
- Base profile complete + no active role -> `/auth/role`
- Passenger -> passenger shell
- Driver + not verified -> `/verification`
- Driver + verified -> driver shell
- Junior -> junior shell

## What The Tests Do

- `route_graph_extractor_test.dart`
  - Walks the real `RouteBase` tree from `createRouter(...)`
  - Asserts no duplicate full paths or route names
  - Asserts canonical route presence
  - Asserts alias routes are redirect-only (no builders)

- `route_connectivity_test.dart`
  - Uses `debugRedirectForTest(...)` to resolve redirect chains
  - Detects redirect loops (bounded hop resolution)
  - Validates key invariants and alias redirects

- `state_matrix_test.dart`
  - Covers combinations of: onboarding/auth/profile completeness/role/verified/premium
  - Asserts final destinations are stable and loop-free

## How To Run

```powershell
flutter test test/routing_debugger/ -r compact
```

