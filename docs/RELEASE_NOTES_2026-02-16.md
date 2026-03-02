# Khawi Release Notes — 2026-02-16

## Summary
This release consolidates product-flow improvements in trips/live-trip/rating, Supabase security and analytics hardening, and repository quality governance (CI + markdown QA + contributor process).

## Included Commits
- `7f38469d` — feat: finalize trip/rating improvements, Supabase hardening, and markdown QA governance
- `932d893a` — chore: rename staging helper functions to approved PowerShell verbs
- `3c68554b` — chore: suppress stale PSUseApprovedVerbs diagnostics in staging script

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
- Added a runbook for remaining console-only actions: `docs/supabase_remaining_console_actions.md`.

## Documentation & CI Governance
- Added markdown quality gate script: `scripts/markdown_qa.ps1`.
- Added markdown QA workflow: `.github/workflows/markdown-qa.yml`.
- Hardened main CI workflow permissions/concurrency/timeout in `.github/workflows/main.yml`.
- Added contributor process and branch protection docs:
  - `docs/contributor_workflow.md`
  - `docs/branch_protection_setup.md`
- Added PR template and PR drafting support docs:
  - `.github/PULL_REQUEST_TEMPLATE.md`
  - `docs/PR_DRAFTS.md`
  - `docs/PR_SPLIT_FILESETS.md`
- Added split-staging helper script: `scripts/stage_split_prs.ps1`.

## Verification Snapshot
- `flutter analyze` → clean (no issues)
- `flutter test` → 196 passed, 0 failed
- `scripts/markdown_qa.ps1` →
  - `DUPLICATE_HEADINGS=0`
  - `HEADING_LEVEL_SKIPS=0`
  - `TODO_LIKE_HITS=0`

## Post-Release Action (Manual)
Apply GitHub branch protection on `main` per `docs/branch_protection_setup.md` and require checks:
- `build`
- `markdown-qa`

## Rollback Guidance
- App/docs/CI changes: revert commit(s) if needed.
- DB changes: revert with targeted follow-up migration rather than destructive rollback in production environments.
