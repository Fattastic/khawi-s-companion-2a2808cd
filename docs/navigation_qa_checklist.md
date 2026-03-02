# Khawi Navigation QA Checklist (Refactored)

This checklist tracks the manual verification of the new Navigation Architecture.

## A. Cold Start & Loading Behavior
- [ ] **QA-01:** Cold start always begins at `/splash`.
- [ ] **QA-02:** Stay on `/splash` while `onboardingDone` is loading.
- [ ] **QA-03:** Stay on `/splash` while profile is loading (authed).

## B. Onboarding Gate
- [ ] **QA-04:** Must go to `/onboarding` if onboarding not done.
- [ ] **QA-05:** Cannot skip onboarding by deep link (redirects back).
- [ ] **QA-06:** Cannot access `/app/*` before onboarding.

## C. Auth Gate
- [ ] **QA-07:** After onboarding, unauthenticated users go to `/auth/login`.
- [ ] **QA-08:** Deep link to protected route while logged out bounces to `/auth/login`.

## D. Profile Enrichment / Role Selection Gate
- [ ] **QA-09:** Authed but profile missing (null) → `/auth/enrichment`.
- [ ] **QA-10:** Authed but fullName empty → `/auth/enrichment`.
- [ ] **QA-10b:** Authed, profile complete, but no activeRole → `/auth/role`.
- [ ] **QA-10c:** User on `/auth/enrichment` with complete profile + role → auto-redirected to home.

## E. Default Role Landing
- [ ] **QA-11:** Passenger complete profile lands at `/app/p/home`.
- [ ] **QA-12:** Junior complete profile lands at `/app/j/hub`.
- [ ] **QA-13:** Driver complete profile & verified lands at `/app/d/dashboard`.
- [ ] **QA-14:** Driver complete profile but NOT verified lands at `/verification`.

## F. Role Guards (/app/*)
- [ ] **QA-15:** Passenger cannot access driver routes (`/app/d/*`) → `/not-authorized`.
- [ ] **QA-16:** Driver cannot access passenger routes (`/app/p/*`) → `/not-authorized`.
- [ ] **QA-17:** Junior cannot access passenger/driver routes → `/not-authorized`.

## G. Verification Gate (Driver)
- [ ] **QA-18:** Unverified driver cannot access any `/app/d/*` → redirects to `/verification`.
- [ ] **QA-19:** Verified driver can access `/app/d/*` normally.
- [ ] **QA-20:** If driver becomes verified, router stops forcing `/verification` on next refresh.
- [ ] **QA-20b:** Unverified driver on `/verification` stays (no redirect away).
- [ ] **QA-20c:** NafathVerificationScreen shows identity + vehicle verification cards.
- [ ] **QA-20d:** "Not now" button on verification screen navigates to `/auth/role`.

## H. Premium Gate (Redeem)
- [ ] **QA-21:** Non-premium blocked from `/shared/redeem` (redirects to `/subscription`).
- [ ] **QA-22:** Premium can access `/shared/redeem`.
- [ ] **QA-23:** Legacy redeem paths (e.g., `/rewards/redeem`) redirect to canonical `/shared/redeem`.

## I. Legacy Routes Redirects
- [ ] **QA-24:** `/login` redirects to `/auth/login`.
- [ ] **QA-25:** `/passenger/home` redirects to `/app/p/home`.
- [ ] **QA-26:** `/driver/dashboard` redirects to `/app/d/dashboard` (or `/verification`).
- [ ] **QA-27:** `/junior/hub` redirects to `/app/j/hub`.

## J. ShellRoute Integrity & Tab State
- [ ] **QA-28:** Switching tabs does not reset tab state (e.g., Search state preserved in Home tab).
- [ ] **QA-29:** Deep link to nested route (e.g., `/app/p/home/search`) resolves shell correctly with tab highlighted.

## K. Error Handling
- [ ] **QA-30:** Unknown route goes to `/404`.
- [ ] **QA-31:** Role mismatch correctly renders `/not-authorized`.
- [ ] **QA-32:** No redirect loops under any transition state.
