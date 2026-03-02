# PR Drafts (Ready to Paste)

Date: 2026-02-16

This file provides copy-paste PR content for two submission strategies:

1. **Single PR** (all changes together)
2. **Split PRs** (recommended for cleaner review)

---

## Option A — Single PR

### Title
`chore: harden CI/markdown QA and complete trip/rating UX + telemetry refinements`

### Summary
This PR finalizes a comprehensive quality and product refinement pass across docs/CI, trip flows, live-trip rating reliability, and telemetry. It introduces automated markdown quality gates, improves contributor governance documentation, hardens GitHub workflows, and ships live-trip/rating flow fixes with better target resolution and analytics surfaces.

### Scope
- [x] Feature
- [x] Bug fix
- [x] Refactor
- [x] Documentation
- [x] CI/CD

### Validation
- `flutter analyze` → no issues
- `flutter test` → 196 passed, 0 failed
- `powershell -ExecutionPolicy Bypass -File .\scripts\markdown_qa.ps1 -RootPath .`
  - `MD_FILES=19`
  - `DUPLICATE_HEADINGS=0`
  - `HEADING_LEVEL_SKIPS=0`
  - `TODO_LIKE_HITS=0`

### What Changed
- Added markdown structural QA automation and CI enforcement:
  - `scripts/markdown_qa.ps1`
  - `.github/workflows/markdown-qa.yml`
  - `.vscode/tasks.json` (`Markdown QA` task)
- Hardened CI workflow defaults:
  - `.github/workflows/main.yml` (permissions/concurrency/timeout)
- Added governance docs and PR standards:
  - `.github/PULL_REQUEST_TEMPLATE.md`
  - `docs/branch_protection_setup.md`
  - `docs/contributor_workflow.md`
  - README quality-gates/checklist updates
- Fixed markdown quality issues in docs (duplicate headings and links)
- Completed live-trip rating target reliability and telemetry instrumentation
- Expanded trip/rating UX across driver/passenger screens and ride history/post-ride surfaces
- Added/updated Supabase migrations for rating analytics/security/index hardening

### Quality Gates
- [x] Khawi CI is passing for this PR
- [x] Markdown QA is passing for docs/script/workflow changes
- [x] New or changed behavior is covered by tests where applicable
- [x] Relevant documentation has been updated

### Risk & Rollback
- **Risk:** Medium (large cross-cutting PR touching app + docs + CI + migrations)
- **Rollback plan:** Revert this PR as one unit if needed; no irreversible runtime migration behavior beyond additive/index/security hardening already validated.

---

## Option B — Split PRs (Recommended)

### PR 1 (Docs/CI only)

#### Title (PR1)
`chore: add markdown QA gate and contributor governance docs`

#### Summary (PR1)
Adds markdown quality automation (local + CI), hardens workflow defaults, and introduces contributor governance docs/templates to enforce consistent quality standards.

#### Scope (PR1)
- [ ] Feature
- [ ] Bug fix
- [x] Refactor
- [x] Documentation
- [x] CI/CD

#### Suggested Included Files (PR1)
- `.github/workflows/main.yml`
- `.github/workflows/markdown-qa.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.vscode/tasks.json`
- `scripts/markdown_qa.ps1`
- `README.md`
- `docs/feature_inventory.md`
- `docs/branch_protection_setup.md`
- `docs/contributor_workflow.md`
- `ENV_SETUP.md`
- `docs/KHAWI_REFINEMENT_BATCHES.md`
- `PERFORMANCE_ANALYSIS.md`

#### Validation (PR1)
- `powershell -ExecutionPolicy Bypass -File .\scripts\markdown_qa.ps1 -RootPath .` → all 0 violations
- Optional sanity: `flutter analyze`, `flutter test`

#### Risk & Rollback (PR1)
- **Risk:** Low
- **Rollback:** Revert workflow/doc/script updates only

---

### PR 2 (App product + telemetry + migrations)

#### Title (PR2)
`feat: improve live-trip rating reliability, trip UX, and rating analytics telemetry`

#### Summary (PR2)
Improves live-trip and rating reliability with selected target persistence/fallback logic, enhanced trip detail/receipt/reporting UX, favorite-driver support, and rating telemetry analytics (including Supabase hardening migrations).

#### Scope (PR2)
- [x] Feature
- [x] Bug fix
- [x] Refactor
- [ ] Documentation
- [ ] CI/CD

#### Suggested Included Files (PR2)
- `lib/features/live_trip/presentation/live_trip_driver_screen.dart`
- `lib/features/live_trip/presentation/live_trip_passenger_screen.dart`
- `lib/features/live_trip/data/live_trip_counterpart_resolver.dart`
- `lib/features/live_trip/data/selected_rating_passenger_store.dart`
- `lib/features/trips/presentation/widgets/rating_dialog.dart`
- `lib/services/event_log_service.dart`
- `lib/features/ride_history/data/ride_history_repo.dart`
- `lib/features/ride_history/domain/ride_history_entry.dart`
- `lib/features/ride_history/presentation/ride_history_screen.dart`
- `lib/features/ride_history/presentation/widgets/trip_receipt_sheet.dart`
- `lib/features/support/presentation/widgets/trip_issue_sheet.dart`
- `lib/services/favorite_drivers_service.dart`
- `lib/state/providers.dart`
- `lib/features/trips/presentation/ride_marketplace_screen.dart`
- `lib/features/trips/presentation/controllers/ride_marketplace_controller.dart`
- `lib/features/trips/presentation/controllers/offer_ride_controller.dart`
- `lib/features/trips/presentation/offer_ride/offer_ride_wizard.dart`
- `lib/features/trips/domain/trip.dart`
- `lib/features/trips/data/trips_repo.dart`
- `lib/features/trips/presentation/booking_confirmation_screen.dart`
- `lib/features/trips/presentation/post_ride_screen.dart`
- `lib/features/trips/presentation/my_trips_screen.dart`
- `lib/features/trips/presentation/explore_map_screen.dart`
- `lib/features/driver/presentation/dashboard/driver_dashboard_screen.dart`
- `lib/features/driver/presentation/widgets/vehicle_details_card.dart`
- `supabase/migrations/20260216000000_rating_funnel_analytics_views.sql`
- `supabase/migrations/20260216000001_rating_funnel_security_hardening.sql`
- `supabase/migrations/20260216000002_security_and_ratings_index_hardening.sql`
- `supabase/migrations/20260216000003_normalize_owned_public_function_search_path.sql`
- `supabase/migrations/20260216000004_rls_policy_hardening_patchable_items.sql`
- `supabase/migrations/20260216000005_edge_rate_limits_rls_policies.sql`
- `supabase/migrations/20260216000006_add_remaining_missing_fk_indexes.sql`
- `supabase/migrations/20260216000007_rewrite_rls_auth_calls_to_initplan.sql`
- `supabase/migrations/20260216000008_drop_redundant_duplicate_indexes.sql`
- `docs/supabase_remaining_console_actions.md`

#### Validation (PR2)
- `flutter analyze` → no issues
- `flutter test` → 196 passed, 0 failed
- Rating telemetry views/functions validated after migration application

#### Risk & Rollback (PR2)
- **Risk:** Medium
- **Rollback:** Revert app-side changes and migrations in one PR; maintain docs/CI PR independently.

---

## Manual Final Step (GitHub UI)

Apply branch protection on `main` per `docs/branch_protection_setup.md` and require checks:
- `build`
- `markdown-qa`
