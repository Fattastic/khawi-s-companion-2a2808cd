---
name: brainstorming
description: Explores user intent, requirements, and design before implementation. Use when starting any creative work, creating features, building components, adding functionality, or modifying behavior.
---

# Brainstorming Ideas Into Designs

## When to use this skill

Help turn ideas into fully formed designs and specs through natural
collaborative dialogue.

Start by understanding the current project context, then ask questions one at a
time to refine the idea. Once you understand what you're building, present the
design and get user approval.

> **Do NOT** invoke any implementation skill, write any code, scaffold any
> project, or take any implementation action until you have presented a design
> and the user has approved it. This applies to **every** project regardless of
> perceived simplicity.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility,
a config change — all of them. "Simple" projects are where unexamined
assumptions cause the most wasted work. The design can be short (a few sentences
for truly simple projects), but you **MUST** present it and get approval.

## How to use it

You MUST create a task for each of these items and complete them in order:

- [ ] **Explore project context** — check files, docs, recent commits
- [ ] **Ask clarifying questions** — one at a time, understand
      purpose/constraints/success criteria
- [ ] **Propose 2-3 approaches** — with trade-offs and your recommendation
- [ ] **Present design** — in sections scaled to their complexity, get user
      approval after each section
- [ ] **Write design doc** — save to `docs/plans/YYYY-MM-DD-<topic>-design.md`
      and commit
- [ ] **Transition to implementation** — invoke `writing-plans` skill to create
      implementation plan

## Process Flow

```mermaid
graph TD
    A[Explore project context] --> B[Ask clarifying questions]
    B --> C[Propose 2-3 approaches]
    C --> D[Present design sections]
    D --> E{User approves design?}
    E -->|no, revise| D
    E -->|yes| F[Write design doc]
    F --> G([Invoke writing-plans skill])
```

> The terminal state is invoking `writing-plans`. Do **NOT** invoke
> `frontend-design`, `mcp-builder`, or any other implementation skill. The
> **ONLY** skill you invoke after brainstorming is `writing-plans`.

---

## How to use it

### 1. Understanding the Idea

- Check out the current project state first (files, docs, recent commits)
- Ask questions **one at a time** to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only **one question per message** — if a topic needs more exploration, break
  it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

### 2. Exploring Approaches

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

### 3. Presenting the Design

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up
  to 200-300 words if nuanced
- **Ask after each section** whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

---

## After the Design

### Documentation

- Write the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Use `elements-of-style:writing-clearly-and-concisely` skill if available
- Commit the design document to git

### Implementation

- Invoke the `writing-plans` skill to create a detailed implementation plan
- Do **NOT** invoke any other skill. `writing-plans` is the next step.

---

## Key Principles

| Principle                 | Description                                           |
| ------------------------- | ----------------------------------------------------- |
| One question at a time    | Don't overwhelm with multiple questions               |
| Multiple choice preferred | Easier to answer than open-ended when possible        |
| YAGNI ruthlessly          | Remove unnecessary features from all designs          |
| Explore alternatives      | Always propose 2-3 approaches before settling         |
| Incremental validation    | Present design, get approval before moving on         |
| Be flexible               | Go back and clarify when something doesn't make sense |
