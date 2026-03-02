# Khawi Gamification Delivery Plan

This plan operationalizes [Gamification Analysis for Khawi](docs/gamification_analysis_for_khawi.md) into execution-ready work for Product, Flutter, Backend, Data, and QA.

## 1) Scope & Delivery Objectives
- Ship Tier-1 mechanics first: `Commute Streak 2.0`, `Behavior-linked Weekly Missions`, `Value Wallet`, `Next Best Action`.
- Protect core ride performance and trust/safety KPIs while increasing retention and repeat shared rides.
- Enable controlled rollout through cohort experiments and guardrails.

## 2) Delivery Model
- Sprint length: 2 weeks.
- Initial horizon: 4 sprints (8 weeks).
- Estimation scale: Story Points (SP) + complexity notes.
- Ownership labels:
  - `FE` Flutter app
  - `BE` Supabase + Edge Functions
  - `DA` Analytics/Data
  - `QA` QA automation + release validation
  - `PD` Product/Design

## 3) Sprint Plan (High Level)

| Sprint | Theme | Primary Outcomes |
|---|---|---|
| Sprint 1 | Foundation & Instrumentation | Event taxonomy live, gamification domain scaffolded, passive progress surfaces |
| Sprint 2 | Core Mechanics A | Streak engine + weekly missions (pilot cohort) |
| Sprint 3 | Core Mechanics B | Value Wallet + Next Best Action + anti-fraud hardening |
| Sprint 4 | Tier-2 Mechanics & Validation | Team challenges, mastery tracks, smart bonus windows, cohort wiring, full-stack QA/perf validation |

## 4) Execution Backlog (Ticket-Level)

### Sprint 1 — Foundation & Instrumentation

| ID | Title | Owner | Est. | Dependencies | Acceptance Criteria |
|---|---|---:|---:|---|---|
| GAMI-101 | Define gamification event taxonomy v1 | DA, PD | 3 SP | none | Canonical event schema approved and documented; all Tier-1 flows mapped to events |
| GAMI-102 | Add Riverpod gamification domain scaffold (`state`, `providers`, `orchestrator`) | FE | 5 SP | none | Compile-safe scaffold merged; no behavior change yet |
| GAMI-103 | Build passive progress snapshot API contract | BE, FE | 5 SP | GAMI-101 | App can fetch a unified progress snapshot for user role without writes |
| GAMI-104 | Add post-trip passive progress card (read-only) | FE | 3 SP | GAMI-102, GAMI-103 | Post-trip screen renders progress snapshot with zero added booking latency |
| GAMI-105 | Wire analytics events for existing ride lifecycle | FE, DA | 5 SP | GAMI-101 | Event coverage for key ride lifecycle actions >= 95% in QA logs |
| GAMI-106 | Build experiment cohort assignment service (server-side) | BE, DA | 5 SP | GAMI-101 | Stable cohort assignment by user ID; idempotent and auditable |
| GAMI-107 | QA baseline: non-regression matrix for rides + routing | QA | 3 SP | none | Regression suite passes with no added failures in ride core flows |

### Sprint 2 — Core Mechanics A (Streak + Missions)

| ID | Title | Owner | Est. | Dependencies | Acceptance Criteria |
|---|---|---:|---:|---|---|
| GAMI-201 | Implement streak state model and grace/recovery rules | BE | 8 SP | GAMI-103, GAMI-106 | Deterministic streak transitions for all ride outcomes with tests |
| GAMI-202 | Mission definition schema + scheduler (weekly) | BE | 8 SP | GAMI-106 | Weekly mission generation supports role-based and cohort-based variants |
| GAMI-203 | Mission progress evaluator on ride completion | BE | 8 SP | GAMI-202 | Mission progress updates are idempotent and replay-safe |
| GAMI-204 | Mission UI card for role home | FE | 5 SP | GAMI-202 | Role home shows current missions + progress + completion states |
| GAMI-205 | Streak UI module + recovery affordance | FE | 5 SP | GAMI-201 | Users can see streak status and recovery availability clearly |
| GAMI-206 | Notification hooks for mission/streak milestones | FE, BE | 5 SP | GAMI-201, GAMI-203 | Milestone notifications trigger only once per qualifying milestone |
| GAMI-207 | QA scenario automation for mission/streak edge-cases | QA | 5 SP | GAMI-201..206 | Automated tests cover streak breaks, recoveries, mission completion edge paths |

### Sprint 3 — Core Mechanics B (Value Wallet + Next Best Action)

| ID | Title | Owner | Est. | Dependencies | Acceptance Criteria |
|---|---|---:|---:|---|---|
| GAMI-301 | Value Wallet calculation engine (earned/unlocked/pending) | BE, DA | 8 SP | GAMI-203 | Wallet calculations deterministic; configurable via remote config |
| GAMI-302 | Wallet API + history endpoints | BE | 5 SP | GAMI-301 | API supports summary + recent transitions with pagination |
| GAMI-303 | Value Wallet UI module (home + profile/rewards) | FE | 5 SP | GAMI-302 | Wallet rendered in two placements with consistent values |
| GAMI-304 | Next Best Action recommendation service v1 | BE, DA | 8 SP | GAMI-203, GAMI-301 | Recommendation returns one ranked, explainable action per user |
| GAMI-305 | Next Best Action UI card + click tracking | FE, DA | 5 SP | GAMI-304 | Single CTA card displayed and tracked with cohort metadata |
| GAMI-306 | Anti-fraud rule updates for gamified events | BE | 8 SP | GAMI-301 | New abuse patterns detected; false-positive rate monitored |
| GAMI-307 | QA load/perf validation on post-trip reward path | QA | 3 SP | GAMI-301..306 | P95 reward processing remains within agreed SLO and does not degrade ride flow |

### Sprint 4 - Tier-2 Mechanics and Validation

| ID | Title | Owner | Est. | Dependencies | Acceptance Criteria |
|---|---|---:|---:|---|---|
| GAMI-401 | Neighborhood/campus team challenges (social belonging) | FE, BE | 8 SP | GAMI-203, GAMI-204 | Users can join a team challenge, track team progress, and receive completion rewards with anti-abuse safeguards |
| GAMI-402 | Trust + Safety mastery tracks | FE, BE | 8 SP | GAMI-203, GAMI-205 | Mastery tracks progress from trust/safety actions, unlock levels deterministically, and render clearly in AR/EN |
| GAMI-403 | Smart bonus windows (off-peak/underserved routes) | BE, DA, FE | 8 SP | GAMI-301, GAMI-304 | Eligible users see bonus windows with transparent rules; bonus claims are idempotent and route/time constrained |
| GAMI-404 | A/B experiment cohort integration + measurement wiring | BE, DA, FE | 5 SP | GAMI-106, GAMI-401, GAMI-402, GAMI-403 | All Tier-2 surfaces emit cohort/variant metadata and support experiment slicing with guardrail metrics |
| GAMI-405 | QA/performance validation for full gamification stack | QA, FE, BE | 5 SP | GAMI-401..404 | End-to-end regression, accessibility, and load/perf checks pass with no core ride-flow degradation |

## 5) Engineering Integration Points

### Flutter (FE)
- Add gamification domain modules under `lib/features/gamification/`:
  - `data/` (DTO + repository adapters)
  - `domain/` (models + policies)
  - `presentation/` (cards/widgets)
- Hook display modules into existing screens only:
  - post-trip summary
  - role home header/content region
  - profile/rewards summary tiles

### Supabase / Edge (BE)
- Extend current edge processing around XP/rewards/trust rails:
  - streak computation
  - mission scheduler + evaluator
  - value wallet computation
  - next-action recommendation
  - team challenge lifecycle (join/progress/complete)
  - trust/safety mastery progression
  - smart bonus window eligibility + claim processing
- Ensure idempotent processing and replay-safe logic on trip completion events.

### Analytics (DA)
- Standard event context fields on every event:
  - `user_role`, `market`, `cohort_id`, `experiment_id`, `app_version`.
- Build experiment-ready metric views for:
  - retention
  - repeat commute frequency
  - redemption conversion
  - reward cost vs incremental activity
  - team challenge participation/completion
  - mastery level progression by role
  - bonus-window exposure/claim conversion

## 6) Non-Functional Requirements (Must-Have)
- No degradation to booking/request flow latency.
- No increase in cancellation rate due to gamification UI friction.
- No PII in gamification analytics payloads.
- AR/EN localization for all user-facing gamification strings.
- Accessibility compliance (screen reader labels, target sizes, reduced-motion respect).

## 7) Guardrails & Rollback Criteria
- **Immediate rollback triggers**:
  - booking conversion drop > agreed threshold,
  - elevated fraud flags beyond expected band,
  - significant support ticket spike linked to reward confusion.
- **Soft-stop triggers**:
  - mission completion too low/high (poor calibration),
  - reward unit economics exceed pilot budget envelope.

## 8) Definition of Done (Program Level)
Program considered complete for Tier-1 when all are true:
1. Tier-1 mechanics live behind feature flags with stable telemetry.
2. Pilot cohort shows positive movement in repeat shared rides and retention.
3. Reward economics stay inside predefined ROI boundary.
4. No critical regressions in trust/safety or core ride UX.
5. Rollout/rollback runbook validated in production-like environment.

## 9) Suggested Work Breakdown by Capacity (Per Sprint)
- FE: 10–15 SP
- BE: 13–18 SP
- DA: 6–10 SP
- QA: 5–8 SP
- PD: 2–4 SP

If one team is constrained, prioritize in this order:
1. event instrumentation + cohorting,
2. streak + missions,
3. value wallet,
4. next best action,
5. advanced experimentation.

## 10) Immediate Next Actions (This Week)
1. Approve ticket list and owners.
2. Lock KPI definitions and guardrail thresholds.
3. Start Sprint 1 with `GAMI-101`, `GAMI-102`, `GAMI-103`, `GAMI-107` in parallel.
4. Schedule pilot market/cohort decision workshop (Product + Data + Ops).

---

### Notes
- This delivery plan intentionally avoids introducing separate gamification-only screens unless data proves necessity.
- Reward economics values (including SAR-equivalent framing) should be finalized only after pilot data and anti-fraud review.

