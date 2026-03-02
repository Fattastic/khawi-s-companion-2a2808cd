---
name: writing-skills
description: Applies test-driven development principles to write and execute behavioral tests. Use when creating new skills, editing existing skills, or verifying skills work before deployment.
---

# Writing Skills

## When to use this skill

**Writing skills IS Test-Driven Development applied to process documentation.**

Write test cases (pressure scenarios), watch them fail (baseline behavior),
write the skill, watch tests pass (agents comply), refactor (close loopholes).

**Core principle:** If you didn't watch an agent fail without the skill, you
don't know if the skill teaches the right thing.

**REQUIRED BACKGROUND:** Understand `test-driven-development` before using this
skill. Same principles — adapted to documentation.

---

## TDD Mapping

| TDD                 | Skill Creation                               |
| ------------------- | -------------------------------------------- |
| Test case           | Pressure scenario with subagent              |
| Production code     | `SKILL.md`                                   |
| RED — test fails    | Agent violates rule without skill (baseline) |
| GREEN — test passes | Agent complies with skill present            |
| Refactor            | Close loopholes while maintaining compliance |

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to new skills AND edits. Write skill before testing? Delete it.
Start over.

---

## When to Create a Skill

**Create when:**

- Technique wasn't intuitively obvious to you
- You'd reference it again across projects
- Pattern applies broadly (not project-specific)

**Don't create for:**

- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions → put in `CLAUDE.md`
- Mechanical constraints → automate; save docs for judgment calls

---

## Directory Structure

```
Skills/
  skill-name/
    SKILL.md           # Required
    supporting-file.*  # Only if needed (heavy reference or reusable tools)
```

---

## SKILL.md Frontmatter Rules

```yaml
---
name: skill-name-with-hyphens      # Letters, numbers, hyphens only
description: Use when [specific triggering conditions and symptoms]
---
```

- Max **1024 characters** total in frontmatter
- `description` — written in third-person, starts with "Use when..."
- **NEVER summarize the skill's workflow in the description**

### Why "no workflow summary" in description matters

Testing revealed: when a description summarizes the skill's workflow, Claude
follows the description _instead of reading the full skill_. A description
saying "code review between tasks" caused Claude to do ONE review, but the skill
body shows TWO (spec compliance then quality).

```yaml
# ❌ BAD - summarizes workflow
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ✅ GOOD - triggering conditions only
description: Use when executing implementation plans with independent tasks in the current session
```

---

## SKILL.md Structure

```markdown
## When to use this skill

Core principle in 1-2 sentences.

## When to use this skill

Bullets with SYMPTOMS and use cases. Small flowchart only if decision
non-obvious.

## How to use it

Before/after comparison or steps.

## Quick Reference

Table or bullets for scanning.

## Common Mistakes

What goes wrong + fixes.
```

---

## Flowcharts

Use **only** for non-obvious decisions or process loops. Never for reference
material, linear instructions, or labels without semantic meaning. Prefer
Mermaid over dot/graphviz for portability.

---

## Bulletproofing Against Rationalization

For discipline-enforcing skills (TDD, verification, debugging):

1. **Close loopholes explicitly** — state the rule + forbid specific workarounds
2. **Add "spirit vs letter" statement** early: _"Violating the letter is
   violating the spirit."_
3. **Build rationalization table** from baseline testing — every excuse an agent
   uses goes in the table
4. **Create red flags list** — make it easy for agents to self-check

---

## RED-GREEN-REFACTOR for Skills

**RED:** Run pressure scenario WITHOUT skill. Document exact behavior and
rationalizations verbatim.

**GREEN:** Write minimal skill addressing those specific failures. Run same
scenarios WITH skill — agent complies.

**REFACTOR:** Agent finds new rationalization → add explicit counter → re-test
until bulletproof.

---

## Skill Creation Checklist

**RED Phase:**

- [ ] Create pressure scenarios (3+ combined pressures for discipline skills)
- [ ] Run WITHOUT skill — document baseline behavior verbatim

**GREEN Phase:**

- [ ] Name uses only letters, numbers, hyphens
- [ ] Frontmatter ≤ 1024 chars, description starts with "Use when..."
- [ ] Description is triggering conditions only (no workflow summary)
- [ ] Addresses specific failures found in RED
- [ ] One excellent code example (not multi-language)
- [ ] Run WITH skill — verify compliance

**REFACTOR Phase:**

- [ ] Identify new rationalizations → add counters
- [ ] Build rationalization table
- [ ] Create red flags list
- [ ] Re-test until bulletproof

**Quality:**

- [ ] Quick reference table
- [ ] Common mistakes section
- [ ] No narrative storytelling
- [ ] Supporting files only for heavy reference or reusable tools

---

## Common Mistakes

| Mistake                                       | Fix                                      |
| --------------------------------------------- | ---------------------------------------- |
| Writing skill before baseline test            | Run baseline first — it's the RED phase  |
| Workflow summary in description               | Triggering conditions only               |
| Multi-language examples                       | One excellent example                    |
| Narrative ("In session X we found...")        | Reusable patterns instead                |
| Deploying without testing                     | Test every skill before deploying        |
| Batching multiple skills without testing each | Complete checklist per skill before next |

---

## The Bottom Line

Creating skills IS TDD. Same Iron Law. Same cycle. Same benefits.

Follow TDD for code → follow it for skills. It's the same discipline applied to
documentation.
