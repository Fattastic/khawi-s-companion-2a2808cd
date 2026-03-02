# PR Split Filesets (Mechanical Staging)

Use this file to stage exact files for each PR without manually sorting changes.

## PR1 — Docs/CI/Governance

Stage these files:

- `.github/workflows/main.yml`
- `.github/workflows/markdown-qa.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.vscode/tasks.json`
- `scripts/markdown_qa.ps1`
- `README.md`
- `ENV_SETUP.md`
- `PERFORMANCE_ANALYSIS.md`
- `docs/KHAWI_REFINEMENT_BATCHES.md`
- `docs/feature_inventory.md`
- `docs/branch_protection_setup.md`
- `docs/contributor_workflow.md`
- `docs/PR_DRAFTS.md`
- `docs/PR_SPLIT_FILESETS.md`

## PR2 — App + Supabase

Everything else that remains modified/new after PR1 staging belongs to PR2.

Core additions include (non-exhaustive):

- `lib/features/live_trip/**`
- `lib/features/driver/**`
- `lib/features/ride_history/**`
- `lib/features/support/presentation/widgets/trip_issue_sheet.dart`
- `lib/features/trips/**`
- `lib/services/event_log_service.dart`
- `lib/services/favorite_drivers_service.dart`
- `lib/state/providers.dart`
- `supabase/migrations/*.sql`
- `docs/supabase_remaining_console_actions.md`

## One-command helper

Use the script:

- `scripts/stage_split_prs.ps1 -Part docs-ci`
- `scripts/stage_split_prs.ps1 -Part app-backend`

## Suggested flow

1. Run `git status --short`
2. Run `powershell -ExecutionPolicy Bypass -File .\scripts\stage_split_prs.ps1 -Part docs-ci`
3. Open PR1
4. Run `powershell -ExecutionPolicy Bypass -File .\scripts\stage_split_prs.ps1 -Part app-backend`
5. Open PR2
