# AI Context Index

This is the first file an AI coding agent should read before making changes in Khawi.

## Read Order (Fastest Reliable Onboarding)

1. `README.md`
2. `docs/ai/AI_PROJECT_MAP.md`
3. `docs/app_navigation_chart.md`
4. `docs/feature_inventory.md`
5. `docs/KHAWI_REFINEMENT_BATCHES.md`
6. `lib/app/router.dart` + `lib/app/routes.dart`
7. `lib/core/backend/backend_contract.dart`
8. `docs/ai/AI_FEATURE_DELIVERY_PLAYBOOK.md`

## Source of Truth by Concern

- Product scope and implemented features:
  - `docs/feature_inventory.md`
  - `docs/KHAWI_REFINEMENT_BATCHES.md`
- Routing and role gates:
  - `lib/app/router.dart`
  - `lib/app/routes.dart`
  - `docs/app_navigation_chart.md`
- Backend naming/contracts:
  - `lib/core/backend/backend_contract.dart`
  - `test/backend_smoke_test.dart`
- Contribution and CI policy:
  - `docs/contributor_workflow.md`
  - `README.md` (Testing + Release Verification Gate)

## Mandatory Validation Before Push

Run in this order:

```bash
flutter analyze
flutter test
```

When backend contracts are affected:

```powershell
$env:KHAWI_INTEGRATION_TEST='1'
flutter test test/backend_smoke_test.dart
```

## AI Guardrails

- Never bypass router role gates in `lib/app/router.dart` without tests.
- Never rename backend contract identifiers without updating smoke tests.
- Prefer focused unit tests for formatter/domain logic.
- For navigation changes, run routing + golden tests before full suite.
- Update `docs/KHAWI_REFINEMENT_BATCHES.md` for every completed batch.
