# QA Console & Feature Inventory

[![Khawi CI](https://github.com/Fattastic/Khawi/actions/workflows/main.yml/badge.svg)](https://github.com/Fattastic/Khawi/actions/workflows/main.yml)
[![Markdown QA](https://github.com/Fattastic/Khawi/actions/workflows/markdown-qa.yml/badge.svg)](https://github.com/Fattastic/Khawi/actions/workflows/markdown-qa.yml)

## Overview
The **QA Console** is a unified debugging platform built into the Khawi application. It provides developers and QA testers with tools to inspect app state, simulate user roles, override feature flags, and run automated scenarios without modifying the codebase.

**Access:**
- **Debug/Profile Mode:** Shake device OR 5-tap on Version number in Settings.
- **Release Mode:** Disabled.

## Features & Panels

### 1. Backend Health Panel
**Objective:** Verify connectivity and latency to backend services.
- **Checks:**
    - Supabase Connectivity (Auth, DB).
    - Edge Function Latency (`xp-calculate`, `verify-identity`).
    - Third-party APIs (Google Maps).
- **Actions:** detailed latency breakdown.

### 2. Feature Flags Panel
**Objective:** Toggle features on/off dynamically.
- **Capabilities:**
    - View all server-side feature flags.
    - **Local Override:** Force enable/disable a flag for the current session.
    - Visualize rollout percentages.

### 3. Persona Panel (Role Simulator)
**Objective:** Test the app as different users without re-login.
- **Simulated Roles:**
    - **Passenger:** Standard vs. Premium.
    - **Driver:** Verified vs. Unverified.
    - **Junior:** Child vs. Parent.
- **Effect:** Overrides the global `myProfileProvider`.

### 4. XP Inspector
**Objective:** Debug the Gamification Engine.
- **View:** Current XP, Level, Rank.
- **Tools:**
    - "Dry Run" XP calculation for a trip.
    - View active multipliers (e.g., "Rainy Day", "Streak").

### 5. Rewards Panel
**Objective:** Inspect the Reviews & Rewards system.
- **View:** Available Rewards Catalog.
- **Tools:**
    - Simulate redemption (check balance check logic).
    - Reset redemption history (mock only).

### 6. Trust & Safety Panel
**Objective:** Verify Trust Score logic.
- **View:** Trust Score, Badge eligibility.
- **Tools:**
    - Inject "Negative Signal" (e.g., Report).
    - Inject "Positive Signal" (e.g., 5-star rating).

### 7. Scenario Runner
**Objective:** Automate complex user flows.
- **Scenarios:**
    - **"Complete Standard Trip"**: Simulates Request -> Match -> Start -> End.
    - **"Junior Trip Flow"**: Simulates Notification -> Parent Approval -> Ride.
    - **"Dispute Charge"**: Simulates Trip completion followed by Help Ticket.

### 8. Logs (State Viewer)
**Objective:** View internal logs and network traces.
- **Content:**
    - Network Requests with `X-Khawi-Trace-Id`.
    - Edge Function logs.
    - Riverpod State changes.

## Structured Logging
All network requests initiated by the QA Console inject a **Trace ID** (`X-Khawi-Trace-Id`) to allow end-to-end tracing in Supabase logs.
- **Format:** `device_id:timestamp:random_suffix`
- **PII Safety:** All sensitive data (phones, emails) is redacted in local logs.

## Testing Data
To populate staging with test data, run the seeds provided in `supabase/seeds/staging_seeds.sql`.
To reset, run `supabase/seeds/staging_reset.sql`.

---

## Planned Features (from Competitive Analysis)

> See [COMPETITIVE_ANALYSIS.md](COMPETITIVE_ANALYSIS.md) for full specifications and implementation roadmap.
> Roadmap status in this file is the execution source of truth and is periodically synced back to `docs/COMPETITIVE_ANALYSIS.md`.

### Phase 1 — Revenue Enablers (Weeks 1-4)
| Feature | Status | Priority |
|---------|--------|----------|
| Fare estimation & cost-share calculator | ✅ Completed (Batch 30 baseline) | 🔴 Critical |
| Ride history & receipts | ✅ Completed (Batch 31 baseline + Batch 45 hardening) | 🔴 Critical |
| 5-star bidirectional rating | ✅ Completed (Batch 32 enhancements) | 🟠 High |
| Vehicle details display in UI | ✅ Completed (Batch 33 enhancements) | 🟡 Medium |
| Dark mode | ✅ Completed (Batch 34 status reconciliation) | 🟡 Medium |

### Phase 2 — Trust & Safety (Weeks 5-8)
| Feature | Status | Priority |
|---------|--------|----------|
| Trip sharing with emergency contacts | ✅ Completed (Batch 12) | 🟠 High |
| ETA display & driver arrival | ✅ Completed (Batch 12) | 🟠 High |
| Ride preferences (chattiness, smoking, AC) | ✅ Completed (Batch 13) | 🟡 Medium |
| Favorite drivers | ✅ Completed | 🟡 Medium |
| Quick reply chat templates + voice messages | ✅ Completed (Batch 13+14) | 🟡 Medium |

### Phase 3 — Growth (Weeks 9-12)
| Feature | Status | Priority |
|---------|--------|----------|
| Ride scheduling (future dates) | ✅ Completed (core flow) | 🟠 High |
| Driver earnings dashboard | ✅ Completed (Batch-aligned UI) | 🟠 High |
| Leaderboard & social competition | ✅ Completed (Batch 16) | 🟡 Medium |
| Promo codes & discount system | ✅ Completed (Batch 17 core) | 🟡 Medium |
| Carbon footprint tracker | ✅ Completed (Batch 18 core) | 🟡 Medium |

### Phase 4 — Monetization (Weeks 13-16)
| Feature | Status | Priority |
|---------|--------|----------|
| Khawi+ benefits expansion (priority matching, badges) | ✅ Completed (Batch 29 baseline) | 🔴 Critical |
| Smart Commute auto-matching | ✅ Completed (Batch 35 status closure) | 🟠 High |
| Price negotiation (Khawi Flex) | ✅ Completed (Batch 36 status closure) | 🟡 Medium |
| Corporate / business rides | ✅ Completed (Batch 37 status closure) | 🟢 Low |

### Phase 5 — Differentiation (Weeks 17-24)
| Feature | Status | Priority |
|---------|--------|----------|
| Khawi Communities (حارة خاوي) | ✅ Completed (Batch 24 activation) | 🟡 Medium |
| Smart Route Suggestion (ML) | ✅ Completed (Batch 23 baseline) | 🟠 High |
| Commute Pattern Detector (ML) | ✅ Completed (Batch 28 baseline) | 🟠 High |
| Arabic NLP Chat Assistant (خاوي مساعد) | ✅ Completed (Batch 25 baseline) | 🟡 Medium |
| University campus carpools | ✅ Completed (Batch 26 baseline) | 🟡 Medium |
| Event/entertainment rides | ✅ Completed (Batch 27 baseline) | 🟡 Medium |

### Residual Backlog — Post Batch 39
| Feature | Status | Priority |
|---------|--------|----------|
| Multi-stop / waypoint support | ✅ Completed (Batch 40 baseline) | 🟠 High |
| In-app navigation for drivers | ✅ Completed (Batch 41 baseline) | 🟠 High |
| Written reviews (beyond tags) | ✅ Completed (Batch 42 baseline) | 🟠 High |
| Trip summary with route map | ✅ Completed (Batch 43 baseline) | 🟡 Medium |
| Accessibility mode (wheelchair/senior/assistive) | ✅ Completed (Batch 44 baseline + Batch 46 vision baseline) | 🟡 Medium |
