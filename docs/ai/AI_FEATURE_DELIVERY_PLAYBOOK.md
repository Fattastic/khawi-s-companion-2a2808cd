# AI Feature Delivery Playbook

Use this exact workflow for new features and non-trivial modifications.

## Step 1 — Scope and Affected Areas

- Define user-visible behavior in 3-5 bullets.
- List impacted files using `docs/ai/AI_PROJECT_MAP.md`.
- Decide required test layers (unit/widget/routing/golden/backend smoke).

## Step 2 — Implement Minimum Safe Change

- Change only files necessary for requested behavior.
- Keep existing routing and role gate invariants unless explicitly changing them.
- Centralize formatting/domain logic where repeated.

## Step 3 — Add/Update Tests First-Class

- Add focused tests near changed logic.
- For routing edits, include redirect invariants.
- For display logic edits, include localization + placeholder edge cases.

## Step 4 — Validate Locally (Required)

```bash
flutter analyze
flutter test
```

If backend contract touched:

```powershell
$env:KHAWI_INTEGRATION_TEST='1'
flutter test test/backend_smoke_test.dart
```

Optional release gate when required:

```bash
flutter build apk
```

## Step 5 — Update Docs

At minimum:

- Append completed batch to `docs/KHAWI_REFINEMENT_BATCHES.md`
- Update `README.md` if workflows/quality gates changed
- Update feature status docs if scope changed

## Step 6 — Commit Hygiene

- One clear commit per batch with descriptive message.
- Include only relevant files for that batch.
- Push only after all required gates pass.

## Done Criteria

- Behavior implemented and tested
- Analyzer clean
- Full tests passing
- Docs synchronized
