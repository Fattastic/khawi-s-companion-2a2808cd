# Batch 12 — Trust & Safety Execution Plan

Date: 2026-02-16
Owner: Copilot implementation pass
Target Window: Weeks 5–8 (execution kickoff)
Status: Completed (2026-02-16)

## Objective
Execute Phase 2 Trust & Safety with a strict, testable scope focused on:

1. Trip sharing with emergency contacts
2. ETA display and driver arrival reliability

## Scope (In)
- Passenger live-trip emergency sharing UX hardening
- ETA and arrival/wait-timer behavior consistency in live-trip screens
- Telemetry coverage for safety-share and arrival/rating touchpoints
- Regression coverage for critical trust & safety flows

## Scope (Out)
- Payments, monetization, and pricing changes
- Community/growth initiatives
- New design system primitives

## Workstreams

### WS1 — Emergency Contact Trip Sharing
- Validate and stabilize emergency contacts persistence + toggles
- Ensure one-tap share and auto-share behavior are deterministic
- Standardize user feedback/snackbars for success/failure
- Confirm event logging is emitted for share attempts/outcomes

### WS2 — ETA + Driver Arrival Reliability
- Normalize ETA states (`pending`, `minutes > 0`, `arrived`)
- Ensure arrival detection sets and uses a stable timestamp source
- Keep wait-timer countdown behavior consistent and localized
- Ensure details sheet reflects route/ETA context reliably

### WS3 — Verification & Guardrails
- Add/adjust tests around:
  - live-trip ETA transitions
  - emergency share trigger behavior
  - rating target resolution fallbacks
- Re-run static analysis, full tests, and markdown QA gate

## Deliverables
- Updated live-trip trust/safety UX behavior (passenger + driver)
- Updated telemetry event reliability for trust/safety funnels
- Green validation snapshot for analyze/tests/markdown QA
- Documentation updates in refinement batches and feature inventory

## Acceptance Checklist (Batch 12)
- [ ] Emergency contacts share flow behaves deterministically
- [ ] Auto-share behavior is explicit and validated
- [ ] ETA state transitions are stable and user-readable
- [ ] Arrival wait-timer is consistent and localized
- [ ] Telemetry events are emitted for key trust/safety actions
- [ ] Regression tests for trust/safety critical paths pass
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] `scripts/markdown_qa.ps1` reports zero violations

## Execution Order
1. Lock behavior contract for emergency sharing and ETA transitions
2. Implement/adjust app logic and telemetry
3. Add/adjust tests for critical transitions
4. Run verification gates
5. Update docs + release handoff

## Risks & Mitigations
- Risk: flaky state transitions in live streams
  - Mitigation: explicit state mapping and deterministic fallbacks
- Risk: partial UX parity between RTL/LTR
  - Mitigation: validate all trust/safety labels in both directions
- Risk: telemetry gaps
  - Mitigation: add explicit logging at action boundaries

## Exit Criteria
Batch 12 is complete when all acceptance checklist items are checked and validation snapshot is attached to refinement docs.

## Outcome
Execution completed with deterministic emergency-contacts handling, stabilized ETA/arrival state transitions, focused trust/safety regression tests, and green validation gates.
