---
name: requesting-code-review
description: Dispatches a code-reviewer subagent to catch issues. Use when completing tasks, implementing major features, or before merging to verify work meets requirements.
---

# Requesting Code Review

Dispatch a `code-reviewer` subagent to catch issues before they cascade.

**Core principle:** Review early, review often.

---

## When to Request Review

**Mandatory:**

- After each task in subagent-driven development
- After completing a major feature
- Before merging to `main`

**Optional but valuable:**

- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing a complex bug

---

## How to use it

### 1. Get git SHAs

```bash
BASE_SHA=$(git rev-parse HEAD~1)   # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

### 2. Dispatch code-reviewer subagent

Use the Task tool with the `code-reviewer` template at
`requesting-code-review/code-reviewer.md`.

**Fill in these placeholders:**

| Placeholder              | What to put         |
| ------------------------ | ------------------- |
| `{WHAT_WAS_IMPLEMENTED}` | What you just built |
| `{PLAN_OR_REQUIREMENTS}` | What it should do   |
| `{BASE_SHA}`             | Starting commit     |
| `{HEAD_SHA}`             | Ending commit       |
| `{DESCRIPTION}`          | Brief summary       |

### 3. Act on feedback

| Severity           | Action                   |
| ------------------ | ------------------------ |
| Critical           | Fix immediately          |
| Important          | Fix before proceeding    |
| Minor              | Note for later           |
| Incorrect feedback | Push back with reasoning |

---

## Example

```
[Just completed Task 2: Add verification function]

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

[Fix progress indicators → Continue to Task 3]
```

---

## Integration with Workflows

| Workflow                    | When to review                                          |
| --------------------------- | ------------------------------------------------------- |
| Subagent-driven development | After **each** task — catch issues before they compound |
| Executing plans             | After each batch (3 tasks)                              |
| Ad-hoc development          | Before merge / when stuck                               |

---

## Red Flags

**Never:**

- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues

**If reviewer is wrong:**

- Push back with technical reasoning
- Show code/tests that prove it works
- See `receiving-code-review` skill for guidance

---

See template at: `requesting-code-review/code-reviewer.md`
