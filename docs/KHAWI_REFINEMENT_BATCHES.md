# Khawi Refinement Batches (System Audit)

This document tracks major structural, security, performance, and
accessibility/UX passes applied to the Khawi repository.

## Refinement Pass 1 (March 2026)

### Focus Areas

- Code Quality & linting (Dart analyzer)
- Performance and State Anomaly bugs
- UI Resilience in constraints (List view bounded limits)
- Cross-cutting Accessibility (Tooltips, RTL specific alignments)
- Secure Contracts (Rate-limiting, API payloads mapping validation)

### Implemented Fixes

**1. Authentication Security**

- Removed client-side, in-memory OTP rate limitations inside `auth_repo.dart`.
- Depended on Supabase's native GoTrue client `AuthException` with error code
  `429` for proper rate-limiting exceptions preventing brute force.
- Enforced strict Saudi phone verification standards resolving to standard
  `+966` E.164 structures.

**2. List Rendering Performance & State Integrity**

- Applied specific logical `ValueKey` usage to state-holding custom motion
  widgets within scrolling `ListView.builder`s in `NotificationsScreen` and
  `RequestsCenterScreen` to stop state tearing and disjointed UI refreshes.

**3. RLS Exclusivity Policies Check**

- Migrated standard message scraping error handlers into robust deterministic
  parsing of HTTP error `42501` to confidently enforce premium privileges in the
  `RewardsRepo`.

**4. UI Resilience**

- Introduced internal bounding limits manually across Custom `AppCard` items
  natively enabling usage within unconstrained `Axis.horizontal` rows.

**5. UI Accessibility**

- Patched all unlabelled `IconButton` action items across Driver and Passenger
  interfaces and screens ensuring accurate string tools in context of
  bidirectional (RTL) semantics (Arabic & English).

**6. Automated Tests Strengthened**

- Introduced targeted unit testing rules mapping edge cases corresponding
  directly with the Auth Rate bounds logic explicitly resolving
  `RateLimitException`.
- Configured component widget-level evaluations specifically covering stateless
  vs internal states swapping index-mutability for list validations.

---

_Generated during system refactor sweep_
