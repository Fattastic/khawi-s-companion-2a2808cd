---
name: using-git-worktrees
description: Creates isolated git worktrees with smart directory selection and safety verification. Use when starting feature work that needs isolation from current workspace or before executing implementation plans.
---

# Using Git Worktrees

## When to use this skill

Git worktrees create isolated workspaces sharing the same repository, allowing
work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification =
reliable isolation.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an
isolated workspace."

---

## Directory Selection (Priority Order)

### 1. Check Existing Directories

```bash
ls -d .worktrees 2>/dev/null    # Preferred (hidden)
ls -d worktrees 2>/dev/null     # Alternative
```

If both exist → use `.worktrees/`.

### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

If preference specified → use it without asking.

### 3. Ask User

If neither exists and no CLAUDE.md preference:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global)

Which would you prefer?
```

---

## Safety Verification

### Project-Local Directories (`.worktrees/` or `worktrees/`)

**MUST verify directory is ignored before creating worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored** — fix broken things immediately:

1. Add appropriate line to `.gitignore`
2. Commit the change
3. Then proceed

**Why critical:** Prevents accidentally committing worktree contents to the
repository.

### Global Directory (`~/.config/superpowers/worktrees`)

No `.gitignore` verification needed — outside project entirely.

---

## Creation Steps

```bash
# 1. Detect project name
project=$(basename "$(git rev-parse --show-toplevel)")

# 2. Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"

# 3. Run project setup (auto-detect)
[ -f package.json ]      && npm install
[ -f Cargo.toml ]        && cargo build
[ -f requirements.txt ]  && pip install -r requirements.txt
[ -f pyproject.toml ]    && poetry install
[ -f go.mod ]            && go mod download

# 4. Verify clean baseline
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Report failures — ask whether to proceed or investigate.

**If tests pass:** Report ready.

---

## Quick Reference

| Situation              | Action                         |
| ---------------------- | ------------------------------ |
| `.worktrees/` exists   | Use it (verify ignored)        |
| `worktrees/` exists    | Use it (verify ignored)        |
| Both exist             | Use `.worktrees/`              |
| Neither exists         | Check CLAUDE.md → ask user     |
| Directory not ignored  | Add to `.gitignore` + commit   |
| Tests fail at baseline | Report + ask before proceeding |

---

## Common Mistakes

| Mistake                       | Fix                                         |
| ----------------------------- | ------------------------------------------- |
| Skipping ignore verification  | Always use `git check-ignore` first         |
| Assuming directory location   | Follow priority: existing > CLAUDE.md > ask |
| Proceeding with failing tests | Report failures, get explicit permission    |
| Hardcoding setup commands     | Auto-detect from project files              |

---

## Example

```
"I'm using the using-git-worktrees skill to set up an isolated workspace."

[.worktrees/ exists → verified ignored → ]
git worktree add .worktrees/auth -b feature/auth
npm install
npm test → 47 passing

Worktree ready at /Users/ahmed/Khawi/.worktrees/auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

---

## Integration

| Skill                            | Role                                                        |
| -------------------------------- | ----------------------------------------------------------- |
| `brainstorming`                  | REQUIRED once design is approved and implementation follows |
| `subagent-driven-development`    | REQUIRED before executing any tasks                         |
| `executing-plans`                | REQUIRED before executing any tasks                         |
| `finishing-a-development-branch` | Cleans up the worktree this skill created                   |
