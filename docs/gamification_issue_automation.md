# Gamification Issue Automation Runbook

This runbook uses:
- Script: [scripts/setup_github_cli.ps1](scripts/setup_github_cli.ps1)
- Script: [scripts/create_gamification_issues.ps1](scripts/create_gamification_issues.ps1)
- Script: [scripts/sync_gamification_issues.ps1](scripts/sync_gamification_issues.ps1)
- Script: [scripts/cleanup_gamification_issues.ps1](scripts/cleanup_gamification_issues.ps1)
- Script: [scripts/run_gamification_issue_ops.ps1](scripts/run_gamification_issue_ops.ps1)
- Seed data: [docs/gamification_issues_seed.json](docs/gamification_issues_seed.json)

## Clear the `gh` blocker first (Windows)
- Check-only:
  - `./scripts/setup_github_cli.ps1`
- Attempt install + checks:
  - `./scripts/setup_github_cli.ps1 -Install`
- If you only want install status (skip auth check):
  - `./scripts/setup_github_cli.ps1 -Install -SkipAuthCheck`
- CI/locked shell mode (no interactive auth attempt):
  - `./scripts/setup_github_cli.ps1 -Install -NonInteractive`
- CI/locked shell with token auth:
  - `$env:GH_TOKEN = '<token>'`
  - `./scripts/setup_github_cli.ps1 -Install -NonInteractive`
- Explicit token parameter (alternative):
  - `./scripts/setup_github_cli.ps1 -Install -NonInteractive -Token '<token>'`

## One-Command Orchestration (Recommended)
Default behavior runs `create + sync` (cleanup is explicit only).

- Preview create+sync:
  - `./scripts/run_gamification_issue_ops.ps1`
- Apply create+sync:
  - `./scripts/run_gamification_issue_ops.ps1 -Apply`
- Run all stages including cleanup:
  - `./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -Apply`
- Run only cleanup:
  - `./scripts/run_gamification_issue_ops.ps1 -RunCleanup`

### Continue past stage failures
Useful when one stage fails but you still want the orchestrator to attempt later stages.

- Preview with continue mode:
  - `./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -ContinueOnStageError`
- Apply with continue mode:
  - `./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -ContinueOnStageError -Apply`

### Reduce repeated preflight output
When running multiple stages, use `-QuietPreflight` to suppress repeated checklist blocks from each stage script.

- Example (compact multi-stage preview):
  - `./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -ContinueOnStageError -QuietPreflight`

### One-time prerequisite check before any stage
Use `-InstallHints` to run a single centralized preflight validation (gh installed/authenticated, repo context, seed file), then exit early if not ready.

- Example:
  - `./scripts/run_gamification_issue_ops.ps1 -InstallHints`
- Example with explicit stage set:
  - `./scripts/run_gamification_issue_ops.ps1 -RunCreate -RunSync -RunCleanup -InstallHints`

## Prerequisites
1. Install GitHub CLI (`gh`): https://cli.github.com/
2. Authenticate:
  - Interactive: `gh auth login`
  - Non-interactive: set `GH_TOKEN` or `GITHUB_TOKEN`
3. Ensure repository access:
   - `gh repo view`

## Safe Preview (No Changes)
From repo root:

`./scripts/create_gamification_issues.ps1`

This runs in `DRY-RUN` by default and prints intended operations.

## Apply Changes (Create Milestones, Labels, Issues)

`./scripts/create_gamification_issues.ps1 -Apply`

## Sync Existing Issues (Title/Body/Labels/Milestone)
Use this after manual edits to the JSON seed when issues already exist in GitHub.
When sprint scope changes in Markdown docs (for example Sprint 4 `GAMI-401..405`),
update `docs/gamification_issues_seed.json` first, then run sync.

- Preview:
  - `./scripts/sync_gamification_issues.ps1`
- Apply updates:
  - `./scripts/sync_gamification_issues.ps1 -Apply`

## Cleanup Stale Issues (Not Present in Seed)
Use this to find (and optionally close) open `GAMI-*` issues that are no longer present in the seed.

- Preview stale issues only:
  - `./scripts/cleanup_gamification_issues.ps1`
- Close stale issues:
  - `./scripts/cleanup_gamification_issues.ps1 -Apply`
- Close with alternate reason:
  - `./scripts/cleanup_gamification_issues.ps1 -Apply -CloseReason completed`

## Target a Specific Repository Explicitly

`./scripts/create_gamification_issues.ps1 -Owner <org-or-user> -Repo <repo> -Apply`

## Partial Operations
- Only milestones + labels:
  - `./scripts/create_gamification_issues.ps1 -SkipIssues -Apply`
- Only issues (assuming labels/milestones already exist):
  - `./scripts/create_gamification_issues.ps1 -SkipMilestones -SkipLabels -Apply`

## Idempotency Behavior
- Milestones: checks if title already exists before creating.
- Labels: created/updated with `--force`.
- Issues: skips if an issue with the same ID prefix (e.g., `GAMI-101`) already exists in title.

## Troubleshooting
- `Required tool not found: gh`
  - Install GitHub CLI and retry.
- `Unable to resolve repository`
  - Pass `-Owner` and `-Repo` explicitly.
- Permission errors
  - Re-run `gh auth login` with repo scope and verify org permissions.
- Missing milestones during sync
  - Run `./scripts/create_gamification_issues.ps1 -SkipIssues -Apply` first.

## Notes
- The creation script now prints a preflight checklist on failure (instead of stopping without guidance).
- Cleanup script only targets open issues with a title prefix like `GAMI-###`.
- Keep `docs/gamification_delivery_plan.md`, `docs/gamification_github_issues_bundle.md`, and `docs/gamification_issues_seed.json` aligned before running automation.
