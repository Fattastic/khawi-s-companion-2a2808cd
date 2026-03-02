# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent via the Task
tool.

**Purpose:** Verify the implementation is well-built — clean, tested,
maintainable, and follows conventions. Run this **only after** spec compliance
is ✅.

---

```
Task tool (general-purpose):
  description: "Review code quality for Task N"
  prompt: |
    You are reviewing the code quality of a completed implementation.

    ## What Was Implemented

    [From implementer's report + spec compliance confirmation]

    ## Commits to Review

    Base SHA: [BASE_SHA - commit before task started]
    Head SHA: [HEAD_SHA - latest commit]

    ## CRITICAL: Spec Is Already Approved

    A separate spec compliance reviewer has confirmed the implementation matches
    requirements. Do NOT re-litigate whether the right things were built.
    Focus exclusively on HOW they were built.

    ## Your Job

    Review the code diff and evaluate:

    **Tests:**
    - Do tests verify real behavior (not just mock calls)?
    - Is coverage meaningful?
    - Are edge cases tested?
    - If TDD was required, was it followed?

    **Code quality:**
    - Are names clear and accurate?
    - Is complexity appropriate (no unnecessary abstraction)?
    - Are there obvious bugs or logic errors?
    - Is error handling correct and complete?

    **Conventions:**
    - Does the code follow existing patterns in the codebase?
    - Are there style or formatting inconsistencies?
    - Is it consistent with adjacent code?

    **Maintainability:**
    - Would a teammate understand this in 6 months?
    - Is there unnecessary duplication?
    - Are there magic numbers or unclear constants?

    **What NOT to flag:**
    - Features that are missing from spec (that's spec reviewer's job)
    - Features that are "extra" (also spec reviewer's job)
    - Personal style preferences without technical justification

    ## Report Format

    ### Strengths
    [What was done well]

    ### Issues
    - **Critical:** [Breaks correctness, security, data integrity]
    - **Important:** [Should fix before proceeding]
    - **Minor:** [Nice to have, low priority]

    ### Assessment
    - ✅ Approved — ready to proceed
    - ❌ Fix required — [which severity level must be addressed]
```
