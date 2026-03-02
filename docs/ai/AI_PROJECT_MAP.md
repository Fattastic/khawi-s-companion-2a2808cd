# AI Project Map

A practical map of where to implement common change types.

## 1) Routing and Entry Flow

- Route constants: `lib/app/routes.dart`
- Router redirects/gates: `lib/app/router.dart`
- Navigation reference: `docs/app_navigation_chart.md`
- Route tests:
  - `test/router_redirect_test.dart`
  - `test/routing_debugger/*`
  - `test/navigation_smoke_test.dart`

## 2) Booking and Trip UX

- Marketplace and booking sheet: `lib/features/trips/presentation/ride_marketplace_screen.dart`
- Booking confirmation: `lib/features/trips/presentation/booking_confirmation_screen.dart`
- Related unit tests:
  - `test/unit/booking_confirmation_vehicle_test.dart`
  - `test/unit/booking_confirmation_eta_test.dart`
  - `test/unit/booking_confirmation_summary_formatters_test.dart`

## 3) Backend Contracts and Data Safety

- Backend registry/constants: `lib/core/backend/backend_contract.dart`
- Requests payload normalization: `lib/features/requests/data/requests_repo.dart`
- Contract smoke tests: `test/backend_smoke_test.dart`
- Supabase schema/migrations:
  - `supabase_schema.sql`
  - `supabase/migrations/*`

## 4) Role-Specific Surfaces

- Passenger: `lib/features/passenger/*`
- Driver: `lib/features/driver/*`
- Junior/family: `lib/features/junior/*`
- Shared features: `lib/features/*` (non-role folders like rewards, notifications, ride_history)

## 5) Localization and Text

- Localizations generated files: `lib/core/localization/*`
- ARB source files:
  - `lib/core/localization/arb/app_en.arb`
  - `lib/core/localization/arb/app_ar.arb`

## 6) Golden and Visual Stability

- Entry flow goldens: `test/goldens/entry_flow_goldens_test.dart`
- Golden helpers: `test/goldens/golden_test_config.dart`
- Test app builder (critical for deterministic routing): `test/nav/test_app_builder.dart`

## 7) Documentation to Keep in Sync

- Batch log: `docs/KHAWI_REFINEMENT_BATCHES.md`
- Feature status: `docs/feature_inventory.md`
- Competitive gap status: `docs/COMPETITIVE_ANALYSIS.md`
- Release flow: `README.md`
