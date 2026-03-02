# Khawi

[![Khawi CI](https://github.com/Fattastic/Khawi/actions/workflows/main.yml/badge.svg)](https://github.com/Fattastic/Khawi/actions/workflows/main.yml)
[![Markdown QA](https://github.com/Fattastic/Khawi/actions/workflows/markdown-qa.yml/badge.svg)](https://github.com/Fattastic/Khawi/actions/workflows/markdown-qa.yml)

**Khawi** (خاوي) is a comprehensive Saudi carpooling platform built with
Flutter, designed to make ride-sharing accessible, safe, and rewarding for
passengers, drivers, and families.

## Quality Gates

- [Khawi CI](https://github.com/Fattastic/Khawi/actions/workflows/main.yml)
- [Markdown QA](https://github.com/Fattastic/Khawi/actions/workflows/markdown-qa.yml)
- [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md)

## AI Development Kit

For faster future feature work with AI agents, start here:

- [docs/ai/AI_CONTEXT_INDEX.md](docs/ai/AI_CONTEXT_INDEX.md)
- [docs/ai/AI_PROJECT_MAP.md](docs/ai/AI_PROJECT_MAP.md)
- [docs/ai/AI_FEATURE_DELIVERY_PLAYBOOK.md](docs/ai/AI_FEATURE_DELIVERY_PLAYBOOK.md)
- [docs/ai/AI_CHANGE_REQUEST_TEMPLATE.md](docs/ai/AI_CHANGE_REQUEST_TEMPLATE.md)
- [docs/ai/AI_AGENT_BOOTSTRAP_PROMPT.md](docs/ai/AI_AGENT_BOOTSTRAP_PROMPT.md)

## PR Checklist

- [ ] Khawi CI is passing for the branch/PR
- [ ] Markdown QA is passing for docs/script/workflow changes
- [ ] New or changed behavior is covered by tests where applicable
- [ ] Relevant documentation has been updated

## Overview

Khawi supports three distinct user roles with specialized features for each:

| Role          | Description            | Key Features                                                   |
| ------------- | ---------------------- | -------------------------------------------------------------- |
| **Passenger** | Find and book rides    | Search rides, instant QR booking, XP rewards, trip tracking    |
| **Driver**    | Offer and manage rides | Offer rides, AI route planning, regular routes, request queue  |
| **Junior**    | Family safety mode     | Parent/guardian controls, trusted drivers, live child tracking |

## Recent Delivery Status

- Current refinement progress: **62 completed batches** (see
  [docs/KHAWI_REFINEMENT_BATCHES.md](docs/KHAWI_REFINEMENT_BATCHES.md))
- Latest completed batches:
  - **Batch 61**: Decouple test harness from routerProvider (KhawiApp removal)
  - **Batch 62**: System Audit Pass: Accessibility, Security Rate Limiting,
    Resilient Sub-Views, and State Keys
- Latest full validation snapshot:
  - `flutter analyze`: no issues
  - `flutter test`: **279 passed, 0 failed**

---

## Core Features

### Ride Matching & Booking

- **Smart Match Algorithm**: AI-powered matching based on route proximity,
  schedule compatibility, and user preferences
- **Women-Only Rides**: Privacy filter for female passengers and drivers
- **Neighborhood Filtering**: Privacy-aware matching within designated
  neighborhoods
- **Instant Rides**: QR code-based quick booking for immediate trips
- **Regular Routes**: Recurring trip scheduling for daily commutes

### Gamification & Rewards

- **XP System**: Earn experience points from rides with role-based multipliers
  - Passenger base: 1.0x (1.25x-1.35x for car owners carpooling)
  - Driver base: 1.5x (up to 1.8x during peak hours)
  - Streak bonuses and weather multipliers
- **Reward Catalog**: Redeem XP for rewards (premium users)
- **Badges & Achievements**: Unlock badges based on activity milestones
- **Challenges**: Periodic goals with bonus XP rewards
- **Referral Program**: Earn rewards for inviting new users

### Trust & Safety

- **Trust Scores**: Computed from ratings, ride history, and behavior signals
- **Trust Tiers**: Bronze, Silver, Gold, Platinum based on trust score
  thresholds
- **Fraud Detection**: Automated detection of collusion and suspicious patterns
- **Driver Verification**: Nafath (national ID) verification for drivers
- **Trip Safety Checks**: Real-time safety monitoring during active trips
- **Message Moderation**: AI-powered chat moderation for trip communications

### Khawi Junior (Family Mode)

- **Parent/Guardian Dashboard**: Manage children's rides from a central hub
- **Trusted Drivers**: Whitelist approved drivers for children's trips
- **Live Tracking**: Real-time location tracking during children's rides
- **Appointed Drivers**: Designate family members as regular drivers
- **Safety Alerts**: Notifications for trip events and deviations

### Premium Subscription (Khawi+)

- **Priority Matching**: Higher visibility in search results
- **Exclusive Rewards**: Access to premium-only rewards catalog
- **Ad-Free Experience**: No promotional interruptions
- **Stripe Integration**: Secure payment processing

---

## Technical Architecture

### Tech Stack

| Layer                | Technology                                   |
| -------------------- | -------------------------------------------- |
| **Frontend**         | Flutter + Dart                               |
| **State Management** | Riverpod                                     |
| **Navigation**       | GoRouter with role-based guards              |
| **Backend**          | Supabase (Auth, Database, Realtime, Storage) |
| **Edge Functions**   | Deno (TypeScript)                            |
| **Payments**         | Stripe                                       |
| **Maps**             | Google Maps Platform                         |
| **Localization**     | ARB (Arabic & English)                       |

### Supabase Edge Functions

All edge functions are located in `supabase/functions/`:

| Function                  | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `smart_match`             | AI-powered ride matching algorithm               |
| `score_matches`           | Compute compatibility scores for ride candidates |
| `xp_calculate`            | Calculate XP rewards with multipliers            |
| `classify_xp_bucket`      | Categorize XP events by type                     |
| `compute_trust_scores`    | Calculate user trust scores                      |
| `compute_trust_tier`      | Determine trust tier from score                  |
| `evaluate_badges`         | Check and award user badges                      |
| `detect_fraud`            | Detect collusion and suspicious patterns         |
| `check_trip_safety`       | Real-time trip safety monitoring                 |
| `moderate_message`        | AI-powered chat moderation                       |
| `predict_acceptance`      | Predict driver acceptance likelihood             |
| `predict_demand`          | Demand forecasting for areas                     |
| `compute_incentives`      | Calculate driver incentives                      |
| `compute_area_incentives` | Area-based incentive computation                 |
| `driver_behavior_scoring` | Analyze driver behavior patterns                 |
| `eta_estimation`          | Estimated time of arrival calculation            |
| `bundle_stops`            | Optimize multi-stop routes                       |
| `redeem_reward`           | Process reward redemptions                       |
| `create_checkout_session` | Stripe checkout session creation                 |
| `stripe_webhook`          | Handle Stripe payment events                     |
| `support_copilot`         | AI support assistant                             |

### Database Schema

Key tables with Row Level Security (RLS):

- `profiles` - User profiles with role, XP, premium status
- `trips` - Carpool trip offers with privacy filters
- `trip_requests` - Passenger booking requests
- `trip_messages` - In-trip chat messages
- `trip_locations` - Real-time location tracking
- `kids` - Children profiles for Junior mode
- `trusted_drivers` - Parent-approved drivers
- `xp_events` - XP transaction ledger
- `rewards` - Available reward catalog
- `redemptions` - Reward redemption history
- `fraud_flags` - Detected fraud indicators

---

## Application Routes

### Entry Flow (Router-Enforced)

```
/splash → /onboarding → /auth/login → /auth/enrichment → /auth/role → [role home]
```

### Role Shells

| Role      | Base Path  | Home Screen        |
| --------- | ---------- | ------------------ |
| Passenger | `/app/p/*` | `/app/p/home`      |
| Driver    | `/app/d/*` | `/app/d/dashboard` |
| Junior    | `/app/j/*` | `/app/j/hub`       |

### Routing Gates (Redirect Order)

1. Splash loading
2. Onboarding gate
3. Auth gate
4. Base profile gate (enrichment)
5. Role hydration and selection
6. Role guards
7. Driver verification gate
8. Premium gate
9. Shared/legacy redirects

Reference: [docs/app_navigation_chart.md](docs/app_navigation_chart.md)

---

## Project Structure

```
lib/
├── app/              # App entry points, routing, route constants
├── core/             # Theme, localization, shared widgets, backend contracts
│   ├── backend/      # API clients and contracts
│   ├── localization/ # ARB files and l10n config
│   ├── theme/        # App theming
│   └── widgets/      # Shared UI components
├── features/         # Feature-first modules (30 directories)
│   ├── auth/         # Authentication flows
│   ├── carbon/       # Carbon footprint tracker
│   ├── challenges/   # Gamification challenges
│   ├── chat/         # In-trip messaging
│   ├── community/    # Communities & groups
│   ├── devtools/     # Dev diagnostics screens
│   ├── driver/       # Driver-specific screens
│   ├── error/        # Error & not-authorized screens
│   ├── events/       # Community events
│   ├── fare_estimate/ # Fare estimation
│   ├── junior/       # Junior/family mode
│   ├── leaderboard/  # XP leaderboard
│   ├── live_trip/    # Active trip tracking
│   ├── matching/     # Ride matching logic
│   ├── notifications/# Push notifications
│   ├── passenger/    # Passenger-specific screens
│   ├── payments/     # Payment processing
│   ├── profile/      # User profile management
│   ├── promo_codes/  # Promotional codes
│   ├── rating/       # Ride ratings
│   ├── realtime/     # Realtime subscriptions
│   ├── referral/     # Referral program
│   ├── requests/     # Trip request management
│   ├── rewards/      # Rewards catalog and redemption
│   ├── ride_history/ # Ride history
│   ├── smart_commute/# Smart commute suggestions
│   ├── subscription/ # Khawi+ premium
│   ├── support/      # Help and support
│   ├── trips/        # Trip offers & marketplace
│   └── xp_ledger/    # XP history and display
├── dev/              # QA nav overlay & debug tools
├── testing/          # Test overrides & mocks
├── services/         # Business logic services
├── providers/        # Riverpod providers
├── models/           # Data models
└── utils/            # Utility functions

supabase/
├── functions/        # Deno edge functions
├── migrations/       # Database migrations
├── seeds/            # Test data seeds
└── config.toml       # Supabase local config

test/
├── unit/             # Unit tests
├── widget/           # Widget tests
├── goldens/          # Golden snapshot tests (10% tolerance)
├── features/         # Feature-specific tests
├── routing_debugger/ # Route debugging tools
└── nav/              # Navigation tests & test harness
```

---

## Development Setup

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Supabase CLI
- Node.js (for tooling)

### Environment Variables

Required dart-defines:

```bash
--dart-define=SUPABASE_URL=<your-supabase-url>
--dart-define=SUPABASE_ANON_KEY=<your-anon-key>
--dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=<google-client-id>
```

See [ENV_SETUP.md](ENV_SETUP.md) for detailed setup instructions.

### Running the App

**VS Code (Recommended):** Use the "Khawi (Debug)" configuration in Run and
Debug (F5).

**Command Line:**

```powershell
.\run_app.ps1
```

### Localization

ARB files:

- `lib/core/localization/arb/app_en.arb`
- `lib/core/localization/arb/app_ar.arb`

Generate localizations:

```bash
flutter gen-l10n
```

---

## Testing

### Run All Tests

```bash
flutter test
```

### Backend Contract Smoke Tests

Run backend contract validation (EdgeFn / DbTable / DbRpc constants + DTO
serialization checks):

```powershell
$env:KHAWI_INTEGRATION_TEST='1'
flutter test test/backend_smoke_test.dart
```

Notes:

- This smoke suite validates contract naming consistency and integration guards.
- `lib/core/backend/backend_contract.dart` is the source of truth for backend
  identifiers.
- Supabase function folder names in `supabase/functions/` must stay aligned with
  `EdgeFn` constants.

### Release Verification Gate

Before merging release-critical changes, run:

```powershell
flutter analyze
flutter test
$env:KHAWI_INTEGRATION_TEST='1'; flutter test test/backend_smoke_test.dart
flutter build apk
```

### Golden Tests

Located in `test/goldens/` with 10% tolerance for cross-platform font rendering.

### Markdown QA

Run markdown structural checks (duplicate headings, heading level skips,
TODO-like markers outside code fences):

```bash
powershell -ExecutionPolicy Bypass -File .\scripts\markdown_qa.ps1 -RootPath .
```

VS Code task:

- `Run Task` → `Markdown QA`

### QA Console (Debug Only)

Enable diagnostics with dart-defines:

```bash
--dart-define=ENABLE_QA_CONSOLE=true
--dart-define=QA_NAV_OVERLAY=true
```

Access via shake gesture or 5-tap on version number in Settings.

See [docs/feature_inventory.md](docs/feature_inventory.md) for full QA console
documentation.

---

## Building

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

---

## Documentation

| Document                                                                     | Description                                            |
| ---------------------------------------------------------------------------- | ------------------------------------------------------ |
| [ENV_SETUP.md](ENV_SETUP.md)                                                 | Environment configuration guide                        |
| [docs/app_navigation_chart.md](docs/app_navigation_chart.md)                 | Full navigation architecture                           |
| [docs/feature_inventory.md](docs/feature_inventory.md)                       | QA console and feature documentation                   |
| [docs/navigation_qa_checklist.md](docs/navigation_qa_checklist.md)           | Navigation testing checklist                           |
| [docs/contributor_workflow.md](docs/contributor_workflow.md)                 | End-to-end contributor flow and local/CI quality gates |
| [docs/branch_protection_setup.md](docs/branch_protection_setup.md)           | Branch protection and required status checks setup     |
| [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)         | Standard PR checklist and validation template          |
| [PERFORMANCE_ANALYSIS.md](PERFORMANCE_ANALYSIS.md)                           | Performance optimization analysis                      |
| [OPTIMIZATION_IMPLEMENTATION_GUIDE.md](OPTIMIZATION_IMPLEMENTATION_GUIDE.md) | Implementation guide for optimizations                 |

---

## License

Proprietary - All Rights Reserved
