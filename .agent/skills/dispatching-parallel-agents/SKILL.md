---
name: dispatching-parallel-agents
description: Dispatches parallel agents to simultaneously solve problems. Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies.
---

# Dispatching Parallel Agents

## When to use this skill

When you have multiple unrelated failures (different test files, different
subsystems, different bugs), investigating them sequentially wastes time. Each
investigation is independent and can happen in parallel.

**Core principle:** Dispatch one agent per independent problem domain. Let them
work concurrently.

## When to use this skill

```mermaid
graph TD
    A{Multiple failures?} -->|yes| B{Are they independent?}
    B -->|no - related| C[Single agent investigates all]
    B -->|yes| D{Can they work in parallel?}
    D -->|yes| E[Parallel dispatch]
    D -->|no - shared state| F[Sequential agents]
```

**Use when:**

- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Each problem can be understood without context from others
- No shared state between investigations

**Don't use when:**

- Failures are related (fix one might fix others)
- Need to understand full system state
- Agents would interfere with each other

---

## How to use it

### 1. Identify Independent Domains

Group failures by what's broken:

- File A tests: Tool approval flow
- File B tests: Batch completion behavior
- File C tests: Abort functionality

Each domain is independent — fixing tool approval doesn't affect abort tests.

### 2. Create Focused Agent Tasks

Each agent gets:

- **Specific scope:** One test file or subsystem
- **Clear goal:** Make these tests pass
- **Constraints:** Don't change other code
- **Expected output:** Summary of what you found and fixed

### 3. Dispatch in Parallel

```
Task("Fix agent-tool-abort.test.ts failures")
Task("Fix batch-completion-behavior.test.ts failures")
Task("Fix tool-approval-race-conditions.test.ts failures")
// All three run concurrently
```

### 4. Review and Integrate

When agents return:

- Read each summary
- Verify fixes don't conflict
- Run full test suite
- Integrate all changes

---

## Agent Prompt Structure

Good agent prompts are:

1. **Focused** — One clear problem domain
2. **Self-contained** — All context needed to understand the problem
3. **Specific about output** — What should the agent return?

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in
   message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead
   of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:

1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by:
   - Replacing arbitrary timeouts with event-based waiting
   - Fixing bugs in abort implementation if found
   - Adjusting test expectations if testing changed behavior

Do NOT just increase timeouts - find the real issue.

Return: Summary of what you found and what you fixed.
```

---

## Common Mistakes

| ❌ Anti-pattern                                 | ✅ Better                                  |
| ----------------------------------------------- | ------------------------------------------ |
| Too broad: "Fix all the tests"                  | Specific: "Fix agent-tool-abort.test.ts"   |
| No context: "Fix the race condition"            | Paste the error messages and test names    |
| No constraints: agent might refactor everything | "Do NOT change production code"            |
| Vague output: "Fix it"                          | "Return summary of root cause and changes" |

---

## When NOT to Use

- **Related failures:** Fixing one might fix others — investigate together first
- **Need full context:** Understanding requires seeing entire system
- **Exploratory debugging:** You don't know what's broken yet
- **Shared state:** Agents would interfere (editing same files, using same
  resources)

---

## Real Example

**Scenario:** 6 test failures across 3 files after major refactoring

| File                                    | Failures | Root Cause          |
| --------------------------------------- | -------- | ------------------- |
| `agent-tool-abort.test.ts`              | 3        | Timing issues       |
| `batch-completion-behavior.test.ts`     | 2        | Tools not executing |
| `tool-approval-race-conditions.test.ts` | 1        | Execution count = 0 |

**Decision:** Independent domains → dispatch 3 agents in parallel.

**Results:**

- Agent 1: Replaced timeouts with event-based waiting
- Agent 2: Fixed event structure bug (`threadId` in wrong place)
- Agent 3: Added wait for async tool execution to complete

**Outcome:** Zero conflicts, full suite green, 3× faster than sequential.

---

## Verification

After agents return:

1. **Review each summary** — understand what changed
2. **Check for conflicts** — did agents edit the same code?
3. **Run full suite** — verify all fixes work together
4. **Spot check** — agents can make systematic errors

## Key Benefits

| Benefit         | Description                                        |
| --------------- | -------------------------------------------------- |
| Parallelization | Multiple investigations happen simultaneously      |
| Focus           | Each agent has narrow scope, less context to track |
| Independence    | Agents don't interfere with each other             |
| Speed           | N problems solved in time of 1                     |
