---
name: verification-before-completion
description: Requires running verification commands and confirming outputs before making claims. Use when about to claim work is complete, fixed, or passing, before committing or creating PRs.
---

# Verification Before Completion

## When to use this skill

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

---

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it
passes.

---

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY  – What command proves this claim?
2. RUN       – Execute the FULL command (fresh, complete)
3. READ      – Full output, check exit code, count failures
4. VERIFY    – Does output confirm the claim?
              If NO  → State actual status with evidence
              If YES → State claim WITH evidence
5. CLAIM     – Only now make the assertion
```

Skip any step = lying, not verifying.

---

## Common Failures

| Claim                 | Requires                        | Not Sufficient                 |
| --------------------- | ------------------------------- | ------------------------------ |
| Tests pass            | Test command output: 0 failures | Previous run, "should pass"    |
| Linter clean          | Linter output: 0 errors         | Partial check, extrapolation   |
| Build succeeds        | Build command: exit 0           | Linter passing, logs look good |
| Bug fixed             | Test original symptom: passes   | Code changed, assumed fixed    |
| Regression test works | Red-green cycle verified        | Test passes once               |
| Agent completed       | VCS diff shows changes          | Agent reports "success"        |
| Requirements met      | Line-by-line checklist          | Tests passing                  |

---

## Key Patterns

**Tests:**

```
✅ [Run test command] → output shows 34/34 pass → "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**

```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**

```
✅ [Run build] → exit 0 → "Build passes"
❌ "Linter passed" (linter ≠ compiler)
```

**Requirements:**

```
✅ Re-read plan → checklist → verify each item → report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**

```
✅ Agent reports success → check VCS diff → verify changes → report actual state
❌ Trust agent report
```

---

## Red Flags — Stop

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Done!", "Perfect!")
- About to commit/push/PR without verification
- Trusting agent success reports without independent check
- Relying on partial verification
- **ANY wording implying success without having run verification**

---

## Rationalization Prevention

| Excuse                                  | Reality                |
| --------------------------------------- | ---------------------- |
| "Should work now"                       | RUN the verification   |
| "I'm confident"                         | Confidence ≠ evidence  |
| "Just this once"                        | No exceptions          |
| "Linter passed"                         | Linter ≠ compiler      |
| "Agent said success"                    | Verify independently   |
| "Partial check is enough"               | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter     |

---

## When to Apply

**Always before:**

- ANY success or completion claim
- ANY expression of satisfaction
- Committing, PRs, task completion
- Moving to the next task
- Delegating to agents

The rule applies to exact phrases, paraphrases, implications, and ANY
communication suggesting completion or correctness.

---

## The Bottom Line

Run the command. Read the output. **Then** make the claim.

No shortcuts. Non-negotiable.
