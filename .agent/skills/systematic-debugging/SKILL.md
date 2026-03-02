---
name: systematic-debugging
description: Enforces a systematic debugging process to find root causes before attempting fixes. Use when encountering any bug, test failure, or unexpected behavior.
---

# Systematic Debugging

## When to use this skill

Random fixes waste time and create new bugs. Quick patches mask underlying
issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom
fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

---

## When to use this skill

Use for **any** technical issue: test failures, bugs, unexpected behavior,
performance problems, build failures, integration issues.

**Use this ESPECIALLY when:**

- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- A previous fix didn't work
- You don't fully understand the issue

---

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**Before attempting ANY fix:**

1. **Read error messages carefully** — don't skip past errors or warnings. Read
   stack traces completely. Note line numbers, file paths, error codes.

2. **Reproduce consistently** — can you trigger it reliably? What are the exact
   steps? If not reproducible → gather more data, don't guess.

3. **Check recent changes** — git diff, recent commits, new dependencies,
   config/env changes.

4. **Gather evidence in multi-component systems**

   When system has multiple components (CI → build → signing, API → service →
   DB), add diagnostic instrumentation **before** proposing fixes:

   ```bash
   # Layer 1: Workflow
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing
   security list-keychains
   security find-identity -v
   ```

   Run once to gather evidence showing WHERE it breaks, then investigate that
   layer.

5. **Trace data flow** — see `root-cause-tracing.md` for the full backward
   tracing technique. Quick version: where does the bad value originate? What
   called this with the bad value? Trace up until you find the source. Fix at
   source, not symptom.

### Phase 2: Pattern Analysis

1. Find working examples of similar code in the codebase
2. Read reference implementations **completely** — don't skim
3. List every difference between working and broken, however small
4. Understand dependencies, config, environment assumptions

### Phase 3: Hypothesis and Testing

1. Form **one** hypothesis: _"I think X is the root cause because Y"_
2. Make the **smallest** possible change to test it — one variable at a time
3. Verify — did it work? Yes → Phase 4. No → form a **new** hypothesis. Don't
   stack fixes.
4. If you don't know → say so. Don't pretend. Ask or research.

### Phase 4: Implementation

1. **Create failing test case** — simplest possible reproduction. Use
   `test-driven-development` skill.
2. **Implement single fix** — address root cause only. No "while I'm here"
   improvements.
3. **Verify fix** — test passes? No other tests broken?
4. **If fix doesn't work:**
   - Count how many fixes you've tried
   - < 3: Return to Phase 1 with new information
   - **≥ 3: Stop and question the architecture (see below)**

### When 3+ Fixes Fail: Question Architecture

Pattern indicating an architectural problem:

- Each fix reveals new shared state/coupling in a different place
- Fixes require massive refactoring
- Each fix creates new symptoms elsewhere

**Stop and ask:** Is this pattern fundamentally sound? Are we stuck through
sheer inertia? Should we refactor vs. continue fixing symptoms?

**Discuss with your human partner before attempting more fixes.**

---

## Red Flags — Stop and Follow Process

If you catch yourself thinking any of these, **return to Phase 1:**

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Here are the main problems: [lists fixes without investigation]"
- "One more fix attempt" _(when already tried 2+)_
- Each fix reveals a new problem in a different place

---

## Common Rationalizations

| Excuse                                   | Reality                                                          |
| ---------------------------------------- | ---------------------------------------------------------------- |
| Issue is simple, don't need process      | Simple issues have root causes. Process is fast for simple bugs. |
| Emergency, no time                       | Systematic is FASTER than guess-and-check thrashing.             |
| Just try this first                      | First fix sets the pattern. Do it right from the start.          |
| Multiple fixes at once saves time        | Can't isolate what worked. Causes new bugs.                      |
| Reference too long, I'll adapt           | Partial understanding guarantees bugs. Read completely.          |
| One more fix attempt (after 2+ failures) | 3+ failures = architectural problem. Question pattern.           |

---

## Supporting Files

| File                         | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| `root-cause-tracing.md`      | Trace bugs backward through call stack                     |
| `defense-in-depth.md`        | Add validation at multiple layers after finding root cause |
| `condition-based-waiting.md` | Replace arbitrary timeouts with condition polling          |

**Related skills:** `test-driven-development`, `verification-before-completion`
