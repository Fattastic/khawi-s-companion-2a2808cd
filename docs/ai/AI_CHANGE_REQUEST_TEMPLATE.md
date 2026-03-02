# AI Change Request Template

Use this template when asking an AI agent to implement a feature or modification.

## 1) Goal

- What should the user be able to do after this change?

## 2) Scope

- In scope:
- Out of scope:

## 3) UX / Product Requirements

- Required states:
- Empty/error states:
- Localization expectations (EN/AR):

## 4) Technical Constraints

- Files/components that must be reused:
- Files/components that must not be changed:
- Backend contract constraints:

## 5) Testing Requirements

- Required tests to add/update:
- Existing tests that must remain green:

## 6) Validation Gates (required before push)

```bash
flutter analyze
flutter test
```

If backend contract/schema touched:

```powershell
$env:KHAWI_INTEGRATION_TEST='1'
flutter test test/backend_smoke_test.dart
```

## 7) Documentation Updates

- `docs/KHAWI_REFINEMENT_BATCHES.md`
- (Optional based on change) README / feature inventory / competitive analysis

## 8) Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
