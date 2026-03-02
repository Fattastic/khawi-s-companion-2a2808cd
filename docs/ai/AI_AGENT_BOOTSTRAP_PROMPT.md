# AI Agent Bootstrap Prompt (Reusable)

Copy/paste this into a new AI coding session for fastest onboarding:

---

You are working on Khawi (Flutter + Riverpod + GoRouter + Supabase).

Read these first in order:
1. `docs/ai/AI_CONTEXT_INDEX.md`
2. `docs/ai/AI_PROJECT_MAP.md`
3. `docs/ai/AI_FEATURE_DELIVERY_PLAYBOOK.md`
4. `README.md`
5. `docs/KHAWI_REFINEMENT_BATCHES.md`

Non-negotiable rules:
- Preserve router role gates and redirect invariants unless request explicitly changes them.
- Keep backend naming in sync with `lib/core/backend/backend_contract.dart` and `test/backend_smoke_test.dart`.
- Add focused tests for any non-trivial logic changes.
- Run and pass:
  - `flutter analyze`
  - `flutter test`
- Update docs batch log for completed work.

Output format for each task:
1) short plan,
2) implemented files,
3) tests added/updated,
4) gate results,
5) commit summary.

---
