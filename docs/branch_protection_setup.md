# Branch Protection Setup (GitHub)

Use this guide to enforce quality gates before merging into `main`.

## Required Status Checks

Configure branch protection to require these checks:

- `build` (from `Khawi CI` workflow)
- `markdown-qa` (from `Markdown QA` workflow)

## Recommended Protection Rules

For branch `main`, enable:

- Require a pull request before merging
- Require approvals (at least 1)
- Dismiss stale pull request approvals when new commits are pushed
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Do not allow force pushes
- Do not allow deletions

## Setup Steps

1. Open repository settings on GitHub.
2. Navigate to `Settings` → `Branches`.
3. Under branch protection rules, add or edit rule for `main`.
4. Enable required options listed above.
5. In required status checks, select:
   - `build`
   - `markdown-qa`
6. Save changes.

## Verification

After setup:

1. Open a test pull request.
2. Confirm both checks appear and must pass:
   - `Khawi CI / build`
   - `Markdown QA / markdown-qa`
3. Confirm merge button is blocked until required checks pass.

## Related Documentation

- `docs/contributor_workflow.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
