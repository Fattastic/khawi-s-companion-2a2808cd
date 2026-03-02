# Gamification GitHub Issues Bundle

Use this file to create a full issue set for the gamification program defined in [docs/gamification_delivery_plan.md](docs/gamification_delivery_plan.md).

## Milestones (Create First)
- `Gamification Sprint 1`
- `Gamification Sprint 2`
- `Gamification Sprint 3`
- `Gamification Sprint 4`

## Label Set (Suggested)
- Type: `type:feature`, `type:infra`, `type:analytics`, `type:qa`
- Area: `area:frontend`, `area:backend`, `area:data`, `area:qa`, `area:product`
- Priority: `priority:p0`, `priority:p1`, `priority:p2`
- Program: `program:gamification`
- Sprint: `sprint:1`, `sprint:2`, `sprint:3`, `sprint:4`

---

## Issue 1 — GAMI-101 Define gamification event taxonomy v1
**Title:** GAMI-101 Define gamification event taxonomy v1

**Labels:** `program:gamification`, `type:analytics`, `area:data`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Define the canonical event schema for Tier-1 gamification mechanics and existing ride lifecycle integration.

**Scope**
- Finalize event names and required properties.
- Define shared context fields (`user_role`, `market`, `cohort_id`, `experiment_id`, `app_version`).
- Add privacy constraints (no PII).

**Acceptance Criteria**
- Event schema document approved by FE/BE/DA.
- All Tier-1 flows mapped to explicit events.
- Data dictionary published in docs.

---

## Issue 2 — GAMI-102 Add Riverpod gamification domain scaffold
**Title:** GAMI-102 Add Riverpod gamification domain scaffold

**Labels:** `program:gamification`, `type:infra`, `area:frontend`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Create the Flutter gamification domain scaffolding with no behavior changes.

**Scope**
- Add `state`, `providers`, and `orchestrator` structure.
- Ensure compile-safe integration.
- Keep feature-flagged/no-op behavior.

**Acceptance Criteria**
- Scaffold compiles and tests pass.
- No runtime behavior change in production paths.

---

## Issue 3 — GAMI-103 Build passive progress snapshot API contract
**Title:** GAMI-103 Build passive progress snapshot API contract

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Expose a unified read-only progress snapshot API for role-specific surfaces.

**Scope**
- Define response model (XP summary, streak summary, mission summary placeholders, wallet summary placeholders).
- Implement endpoint/function contract.

**Acceptance Criteria**
- FE can fetch role-aware progress snapshot.
- Contract documented and versioned.

---

## Issue 4 — GAMI-104 Add post-trip passive progress card
**Title:** GAMI-104 Add post-trip passive progress card (read-only)

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `priority:p1`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Render read-only progress feedback in post-trip summary.

**Scope**
- Add UI module using snapshot API.
- Show progress deltas and next milestone teaser.

**Acceptance Criteria**
- Card renders after trip completion.
- No measurable booking/post-trip latency regression.

---

## Issue 5 — GAMI-105 Wire analytics events for ride lifecycle
**Title:** GAMI-105 Wire analytics events for existing ride lifecycle

**Labels:** `program:gamification`, `type:analytics`, `area:frontend`, `area:data`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Instrument ride lifecycle with standardized event taxonomy.

**Scope**
- Add telemetry in key lifecycle points.
- Include required context fields and cohort metadata.

**Acceptance Criteria**
- >=95% expected event coverage in QA logs.
- Schema validation passes for emitted events.

---

## Issue 6 — GAMI-106 Build experiment cohort assignment service
**Title:** GAMI-106 Build experiment cohort assignment service (server-side)

**Labels:** `program:gamification`, `type:infra`, `area:backend`, `area:data`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Create stable user cohort assignment for controlled rollouts and experiments.

**Scope**
- Deterministic assignment by user ID.
- Cohort retrieval endpoint/function.
- Audit logging for assignment decisions.

**Acceptance Criteria**
- Same user gets stable cohort across sessions.
- Assignment is idempotent and auditable.

---

## Issue 7 — GAMI-107 QA non-regression matrix for rides+routing
**Title:** GAMI-107 QA baseline non-regression matrix for rides and routing

**Labels:** `program:gamification`, `type:qa`, `area:qa`, `priority:p0`, `sprint:1`

**Milestone:** `Gamification Sprint 1`

**Body:**
**Summary**
Establish baseline test matrix before enabling Tier-1 gamification mechanics.

**Scope**
- Validate critical ride flows, routing guards, and post-trip surfaces.
- Capture baseline metrics and known risks.

**Acceptance Criteria**
- Regression suite passes with no new critical failures.
- Baseline report published.

---

## Issue 8 — GAMI-201 Implement streak model + grace/recovery rules
**Title:** GAMI-201 Implement streak state model and grace/recovery rules

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p0`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Implement deterministic streak logic aligned to ride outcomes and fairness constraints.

**Acceptance Criteria**
- All streak transitions covered by automated tests.
- Recovery/grace logic is idempotent and replay-safe.

---

## Issue 9 — GAMI-202 Mission schema + weekly scheduler
**Title:** GAMI-202 Implement mission definition schema and weekly scheduler

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p0`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Create mission definitions and weekly mission scheduling by role/cohort.

**Acceptance Criteria**
- Scheduler generates missions per policy.
- Supports role-based and cohort-based variants.

---

## Issue 10 — GAMI-203 Mission progress evaluator
**Title:** GAMI-203 Implement mission progress evaluator on ride completion

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p0`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Update mission progress when qualifying ride events are processed.

**Acceptance Criteria**
- Evaluator handles duplicate/replayed events correctly.
- Mission progress updates are consistent and auditable.

---

## Issue 11 — GAMI-204 Mission UI card for role home
**Title:** GAMI-204 Add mission UI card to role home

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `priority:p1`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Display active missions with progress and completion states in role home.

**Acceptance Criteria**
- AR/EN localized strings complete.
- Mission progress updates reactively without full-screen rebuilds.

---

## Issue 12 — GAMI-205 Streak UI module + recovery affordance
**Title:** GAMI-205 Add streak UI module and recovery affordance

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `priority:p1`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Expose streak state with clear recovery flow and transparent rules.

**Acceptance Criteria**
- Users can see current streak, grace state, and recovery eligibility.
- UI copy clearly explains outcomes and limits.

---

## Issue 13 — GAMI-206 Mission/Streak notification hooks
**Title:** GAMI-206 Add notification hooks for mission and streak milestones

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `area:backend`, `priority:p1`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Send milestone notifications with anti-spam and idempotency constraints.

**Acceptance Criteria**
- Each milestone notification is emitted once.
- Notification cadence respects user preferences/throttles.

---

## Issue 14 — GAMI-207 QA automation for streak/mission edge cases
**Title:** GAMI-207 QA automation for mission and streak edge cases

**Labels:** `program:gamification`, `type:qa`, `area:qa`, `priority:p0`, `sprint:2`

**Milestone:** `Gamification Sprint 2`

**Body:**
**Summary**
Automate edge-case validation for streak breaks/recovery and mission completion logic.

**Acceptance Criteria**
- Automated scenarios cover duplicated events, late events, cancellation paths, and role variance.
- No critical regressions introduced.

---

## Issue 15 — GAMI-301 Value Wallet calculation engine
**Title:** GAMI-301 Implement Value Wallet calculation engine

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `area:data`, `priority:p0`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Compute `earned`, `unlocked`, and `pending` wallet values with configurable reward economics.

**Acceptance Criteria**
- Deterministic calculations with test coverage.
- Configurable policy inputs via server config/feature flags.

---

## Issue 16 — GAMI-302 Wallet API + history
**Title:** GAMI-302 Build wallet summary and history APIs

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p1`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Expose wallet summary and recent value transitions for app rendering.

**Acceptance Criteria**
- Summary and paginated history endpoints available.
- API contract documented.

---

## Issue 17 — GAMI-303 Value Wallet UI module
**Title:** GAMI-303 Add Value Wallet UI to home and profile/rewards

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `priority:p1`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Show wallet values in contextual app surfaces.

**Acceptance Criteria**
- Values are consistent across placements.
- Accessibility labels and localization complete.

---

## Issue 18 — GAMI-304 Next Best Action recommendation service
**Title:** GAMI-304 Implement Next Best Action recommendation service v1

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `area:data`, `priority:p1`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Return a single ranked action recommendation to increase progress with minimal user friction.

**Acceptance Criteria**
- Exactly one primary recommendation returned per user context.
- Recommendation includes explainability metadata.

---

## Issue 19 — GAMI-305 Next Best Action UI + tracking
**Title:** GAMI-305 Add Next Best Action card and click tracking

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `area:data`, `priority:p1`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Render recommendation card and instrument CTA interactions.

**Acceptance Criteria**
- Card appears in designated surface with clear CTA.
- Click/open/outcome events are emitted with cohort metadata.

---

## Issue 20 — GAMI-306 Anti-fraud hardening for gamified events
**Title:** GAMI-306 Extend anti-fraud rules for gamified events

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `priority:p0`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Add abuse protections against synthetic progress and reward farming.

**Acceptance Criteria**
- New fraud rules deployed and validated in staging.
- Monitoring added for false-positive/false-negative tracking.

---

## Issue 21 — GAMI-307 QA perf validation on reward path
**Title:** GAMI-307 QA performance validation for post-trip reward processing path

**Labels:** `program:gamification`, `type:qa`, `area:qa`, `priority:p0`, `sprint:3`

**Milestone:** `Gamification Sprint 3`

**Body:**
**Summary**
Validate latency impact of reward processing under load.

**Acceptance Criteria**
- P95 reward processing within agreed SLO.
- No measurable degradation to booking/ride completion flows.

---

## Issue 22 - GAMI-401 Neighborhood/campus team challenges
**Title:** GAMI-401 Build neighborhood/campus team challenges (social belonging)

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `area:backend`, `priority:p0`, `sprint:4`

**Milestone:** `Gamification Sprint 4`

**Body:**
**Summary**
Launch social team challenges so users can join their neighborhood/campus cohort and progress together.

**Scope**
- Team challenge model (team_id, challenge goal, window, reward).
- Join/leave and progress APIs with anti-abuse checks.
- Team progress UI module in role-home surfaces.

**Acceptance Criteria**
- Users can join a team challenge and see team progress.
- Challenge completion is deterministic and idempotent.
- Team challenge events are emitted for analytics.

---

## Issue 23 - GAMI-402 Trust + Safety mastery tracks
**Title:** GAMI-402 Implement Trust + Safety mastery tracks

**Labels:** `program:gamification`, `type:feature`, `area:frontend`, `area:backend`, `priority:p0`, `sprint:4`

**Milestone:** `Gamification Sprint 4`

**Body:**
**Summary**
Create mastery-track progression tied to safe and reliable rider/driver behavior.

**Scope**
- Mastery track schema (levels, thresholds, rewards, role variants).
- Progress evaluator on trust/safety signals.
- UI to display level, next milestone, and unlocked status.

**Acceptance Criteria**
- Mastery progression updates correctly from qualifying actions.
- Level unlocks are replay-safe and auditable.
- AR/EN messaging clearly explains progression rules.

---

## Issue 24 - GAMI-403 Smart bonus windows
**Title:** GAMI-403 Implement smart bonus windows for off-peak and underserved routes

**Labels:** `program:gamification`, `type:feature`, `area:backend`, `area:data`, `area:frontend`, `priority:p0`, `sprint:4`

**Milestone:** `Gamification Sprint 4`

**Body:**
**Summary**
Introduce dynamic bonus windows that reward desired demand-shaping behaviors.

**Scope**
- Eligibility rules by route/time/role and fairness guardrails.
- Bonus window exposure + claim handling.
- UI presentation of active windows and expected value.

**Acceptance Criteria**
- Eligible users see active windows with transparent conditions.
- Bonus claims are idempotent and policy-constrained.
- Exposure/claim outcomes are logged for optimization.

---

## Issue 25 - GAMI-404 Cohort integration + measurement wiring
**Title:** GAMI-404 Integrate A/B cohorts and measurement wiring across Tier-2 mechanics

**Labels:** `program:gamification`, `type:infra`, `area:backend`, `area:data`, `area:frontend`, `priority:p0`, `sprint:4`

**Milestone:** `Gamification Sprint 4`

**Body:**
**Summary**
Wire experiment cohort assignment and analytics context across team challenges, mastery tracks, and bonus windows.

**Scope**
- Cohort/variant propagation into Tier-2 APIs and UI surfaces.
- Event payload enrichment (`cohort_id`, `experiment_id`, `variant`, `feature_flag`).
- Metric views for conversion and guardrail analysis by cohort.

**Acceptance Criteria**
- Tier-2 events include experiment metadata end-to-end.
- At least 3 experiment slices are analyzable without manual joins.
- Guardrail metrics are available for fast rollback decisions.

---

## Issue 26 - GAMI-405 Full-stack QA and performance validation
**Title:** GAMI-405 QA/performance validation for the full gamification stack

**Labels:** `program:gamification`, `type:qa`, `area:qa`, `area:frontend`, `area:backend`, `priority:p0`, `sprint:4`

**Milestone:** `Gamification Sprint 4`

**Body:**
**Summary**
Validate reliability, accessibility, and runtime performance for Tier-1 + Tier-2 gamification together.

**Scope**
- End-to-end scenarios across streaks, missions, wallet, NBA, team challenges, mastery, and bonus windows.
- AR/EN, accessibility, and reduced-motion checks.
- Load/perf validation for trip completion and reward computation paths.

**Acceptance Criteria**
- No critical functional regressions in core ride flows.
- P95 reward/gamification processing remains within agreed SLO.
- QA report includes findings, risks, and rollout recommendation.

---

## Bulk-Creation Shortcut (Optional)
If you prefer, create issues first with only title + labels + milestone, then paste the full body from this document.

Recommended order:
1. Create all Sprint 1 issues.
2. Create Sprint 2–4 issues in backlog state.
3. Assign owners after capacity planning.

