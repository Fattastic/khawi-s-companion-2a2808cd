# Khawi v2026.02.16

## Summary
This release consolidates product-flow improvements in trips/live-trip/rating, Supabase security and analytics hardening, and repository quality governance (CI + markdown QA + contributor process).

## Included Commits
- `7f38469d` — feat: finalize trip/rating improvements, Supabase hardening, and markdown QA governance
- `932d893a` — chore: rename staging helper functions to approved PowerShell verbs
- `3c68554b` — chore: suppress stale PSUseApprovedVerbs diagnostics in staging script
- `efc8e5e2` — docs: add release notes for 2026-02-16

## Product & App Changes
- Improved live-trip rating flow reliability for driver/passenger with better target resolution and fallback handling.
- Added persistent selected passenger handling and better trip detail surfaces in live-trip UX.
- Expanded post-ride and ride-history flows with receipt and issue-report affordances.
- Enhanced marketplace and booking flows (filters/scheduling/favorites and richer trip details).
- Added/expanded telemetry emission around rating lifecycle events.

## Backend & Data (Supabase)
- Added rating-funnel analytics surfaces and summary functions.
- Applied security hardening migrations (search path normalization, policy tightening, RLS-related fixes where patchable).
- Added missing performance indexes and removed duplicate/redundant index definitions.
- Added a runbook for remaining console-only actions.

## Documentation & CI Governance
- Added markdown quality gate script and workflow.
- Hardened main CI workflow permissions/concurrency/timeout.
- Added contributor process, branch protection, and PR template documentation.
- Added split-staging helper and PR drafting support docs.

## Verification Snapshot
- `flutter analyze` → clean (no issues)
- `flutter test` → 196 passed, 0 failed
- markdown QA →
  - `DUPLICATE_HEADINGS=0`
  - `HEADING_LEVEL_SKIPS=0`
  - `TODO_LIKE_HITS=0`

## Notes
- Branch protection is configured for `main` with required checks:
  - `build`
  - `markdown-qa`
