# Contributor Workflow

This guide defines the standard contribution flow for this repository.

## 1) Start a Change

1. Create a branch from `main`.
2. Implement changes with focused commits.
3. Update tests and docs when behavior changes.

## 2) Run Local Quality Gates

Run before opening a pull request:

```bash
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File .\scripts\markdown_qa.ps1 -RootPath .
```

## 3) Open a Pull Request

1. Open a PR targeting `main`.
2. Fill out the PR template:
   - `.github/PULL_REQUEST_TEMPLATE.md`
3. Ensure all checklist items are addressed.

## 4) Required CI Checks

The PR must pass:

- `Khawi CI / build`
- `Markdown QA / markdown-qa`

## 5) Merge Requirements

Before merge:

- At least one approval
- Required checks are green
- Branch is up to date with `main`

## 6) Repository Protection

For branch rule configuration, follow:

- `docs/branch_protection_setup.md`

## Quick Links

- `README.md` (project entrypoint)
- `.github/PULL_REQUEST_TEMPLATE.md` (PR checklist)
- `.github/workflows/main.yml` (Khawi CI)
- `.github/workflows/markdown-qa.yml` (Markdown QA)
