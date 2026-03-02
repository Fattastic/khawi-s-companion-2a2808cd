---
name: finishing-a-development-branch
description: Guides the completion of development work by verifying tests and presenting structured options for merge, PR, or cleanup. Use when implementation is complete and you need to decide how to integrate the work.
---

# Finishing a Development Branch

## When to use this skill

Guide completion of development work by presenting clear options and handling
the chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to
complete this work."

---

## How to use it

### Step 1: Verify Tests

Run the project's test suite before anything else:

```bash
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**

```
Tests failing (<N> failures). Must fix before completing:
[Show failures]
Cannot proceed with merge/PR until tests pass.
```

Stop. Do not proceed to Step 2.

**If tests pass:** Continue.

---

### Step 2: Determine Base Branch

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from `main` — is that correct?"

---

### Step 3: Present Options

Present **exactly** these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

Don't add explanation — keep options concise.

---

### Step 4: Execute Choice

#### Option 1 — Merge Locally

```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
<test command>          # verify tests on merged result
git branch -d <feature-branch>
```

Then → **Step 5: Cleanup worktree**

#### Option 2 — Push and Create PR

```bash
git push -u origin <feature-branch>
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then → **Step 5: Cleanup worktree**

#### Option 3 — Keep As-Is

Report: "Keeping branch `<name>`. Worktree preserved at `<path>`."

Do **not** cleanup worktree.

#### Option 4 — Discard

**Confirm first:**

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact typed confirmation, then:

```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then → **Step 5: Cleanup worktree**

---

### Step 5: Cleanup Worktree

For **Options 1, 2, 4** only — check if in a worktree:

```bash
git worktree list | grep $(git branch --show-current)
```

If yes:

```bash
git worktree remove <worktree-path>
```

For **Option 3:** Keep the worktree.

---

## Quick Reference

| Option           | Merge | Push | Keep Worktree | Delete Branch |
| ---------------- | ----- | ---- | ------------- | ------------- |
| 1. Merge locally | ✅    | —    | —             | ✅            |
| 2. Create PR     | —     | ✅   | ✅            | —             |
| 3. Keep as-is    | —     | —    | ✅            | —             |
| 4. Discard       | —     | —    | —             | ✅ (force)    |

---

## Common Mistakes

| ❌ Mistake                     | ✅ Fix                                 |
| ------------------------------ | -------------------------------------- |
| Skipping test verification     | Always verify before offering options  |
| Open-ended "what next?"        | Present exactly 4 structured options   |
| Auto-cleanup for Option 2 or 3 | Only cleanup for Options 1 and 4       |
| No confirmation for discard    | Require typed `'discard'` confirmation |

---

## Red Flags

**Never:**

- Proceed with failing tests
- Merge without verifying tests on merged result
- Delete work without explicit confirmation
- Force-push without explicit request

**Always:**

- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

---

## Integration

| Skill                         | Relationship                                 |
| ----------------------------- | -------------------------------------------- |
| `executing-plans`             | Calls this skill after all batches complete  |
| `subagent-driven-development` | Calls this skill after all tasks complete    |
| `using-git-worktrees`         | This skill cleans up the worktree it created |
