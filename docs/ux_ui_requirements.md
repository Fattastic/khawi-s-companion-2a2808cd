# UX/UI & Feature Requirements Document

> **Application Type:** Saudi-focused carpooling & community ride-sharing super-app  
> **User Roles:** Passenger, Driver, Junior (Kids)  
> **Revenue Model:** Free rides; monetized via premium subscription & XP-based gifting  
> **Primary Market:** Saudi Arabia (Arabic-first, bilingual, RTL-native)  
> **Last Updated:** February 18, 2026  
> **Research Base:** Internal competitive analysis + web research (NNGroup, Smashing Magazine, Apple HIG, MIT Touch Lab)

---

## 1. UX/UI Best Practices

### 1.1 General Principles

The following principles are grounded in Jakob Nielsen's 10 Usability Heuristics (NNGroup), Smashing Magazine's comprehensive mobile design guide, and Apple's Human Interface Guidelines — applied specifically to Khawi's carpooling context.

- **Clarity over decoration:** Every screen must have one unmistakable primary action. Decorative elements must never compete with functional controls. *(Heuristic H8: Aesthetic and minimalist design — "no irrelevant information")*
- **Immediate feedback:** All user-triggered actions (booking, canceling, rating, toggling) must provide visual or haptic feedback within 100ms — spinners, shimmer skeletons, or micro-animations. *(H1: Visibility of system status — "always keep users informed through appropriate, timely feedback")*
- **Progressive disclosure:** Surface only what the user needs at each step. Advanced options (ride preferences, comfort tags, promo codes) should be collapsible or accessible via secondary affordances. Reduces cognitive load on small screens.
- **Consistent visual language:** Color, typography, spacing, iconography, and elevation must follow a single design-token system across all roles (Passenger, Driver, Junior) while allowing role-specific accent colors. *(H4: Consistency and standards — users apply Jakob's Law: they expect patterns they know from other apps)*
- **Error prevention over error correction:** Use smart defaults, inline validation, and confirmation dialogs for destructive actions. Prevent invalid states rather than explaining them after the fact. *(H5: Error prevention over error correction)*
- **Meaningful error messages:** When errors do occur, state (1) what went wrong, (2) why, and (3) the concrete next step. Never show generic "An error occurred" messages. *(H9: Help users recover from errors)*
- **User control and freedom:** Every flow must have an easy, clearly labelled "exit" — cancel ride request, undo confirmation, go back without data loss. *(H3: User control and freedom)*
- **Delightful micro-interactions:** XP gains, badge unlocks, trust-tier promotions, and streak completions should use celebratory animations (confetti, glow, pulse) that reinforce positive behavior without blocking flow.
- **Offline resilience:** When connectivity is degraded, cached data (last known trip status, ride history, profile) must remain visible with a clear "offline" indicator. Destructive actions should queue and sync when reconnected. *(Especially critical for Saudi emerging-market users on variable connectivity)*
- **Design for interruption:** Mobile users are on the go — average session is ~72 seconds (NNGroup). The app must save state automatically so users can resume mid-task after any interruption (phone call, lock screen, notification). Show the gist of crucial information before details.
- **Minimize user input:** Typing on mobile is error-prone. Autofill addresses via GPS, use smart defaults for time/date, and prefill fields from user history. Ask only for what is absolutely necessary at each step. *(NNGroup + Smashing Magazine: "use location awareness to reduce manual entry")*
- **Recognition over recall:** Keep critical options visible rather than hidden behind hamburger menus or gesture-only flows. Users should not need to remember previous steps. *(H6: Recognition rather than recall)*
- **Gestures as supplement, never replacement:** Hidden gesture shortcuts (swipe to cancel, swipe to rate) may be offered as shortcuts for power users, but every gesture must have an equivalent visible control. Gestures have the highest learning curve of any interaction pattern because they are invisible by default. *(Smashing Magazine: "every time a visible control is replaced with a gesture, the app's learning curve goes up")*
- **Keyboard type matching:** Every form field must display the appropriate keyboard for its input type — numeric keyboard for phone/OTP fields, email keyboard for email entry, standard keyboard for names and addresses. *(Smashing Magazine: "customize the keyboard for the type of query")*
- **Back button contract:** Tapping back in a multi-step flow (booking wizard, onboarding, profile setup) must never eject the user all the way to the home screen — it must return to the prior step with data intact. Confirm before discarding unsaved progress. *(Smashing Magazine: "an improperly created back button can cause a lot of problems — prevent situations where back takes users to the home screen")*

### 1.2 Navigation & Information Architecture

The NNGroup research on mobile navigation patterns directly validates Khawi's design decisions:

- **Role-based home screens as navigation hubs:** Each role (Passenger, Driver, Junior) lands on a contextually optimized home screen with its top 3 actions immediately accessible — no shared generic dashboard. This is the "navigation hub" pattern best suited to task-oriented apps where users perform one primary task per session (e.g., booking a ride). *(NNGroup: hub-and-spoke pattern is optimal for task-focused apps)*
- **Bottom tab bar (not hamburger menu):** Maximum 4–5 tabs. The active tab must be visually distinct (filled icon + label). The center tab may be a floating primary action (e.g., "Offer Ride" for drivers, "Find Ride" for passengers). Hamburger menus are explicitly avoided — they are the least discoverable navigation pattern and reduce engagement with secondary features. *(NNGroup: "out of sight = out of mind"; Smashing Magazine: "prioritize navigation based on user tasks")*
- **Do not mix navigation patterns:** Once a bottom tab bar is established, it must remain consistent throughout the entire app. No section may switch to a side drawer or different top-level navigation pattern. *(Smashing Magazine: "don't mix navigation patterns")*
- **Depth ≤ 3 taps:** Any critical task (find ride, offer ride, view active trip, check XP) must be reachable within 3 taps from the home screen.
- **Communicate current location:** Every screen must unambiguously answer "Where am I?" via the screen title and highlighted tab. Failing to indicate current location is one of the most common mobile navigation errors. *(Smashing Magazine + NNGroup: current location is a fundamental navigation requirement)*
- **Persistent trip bar:** During an active trip, a collapsible floating bar must remain visible on all screens showing real-time status (ETA, driver name, live map thumbnail) with a tap-to-expand action. This follows H1 (Visibility of system status) — users should always know the status of their active trip.
- **Global search:** A unified search bar (accessible from home) should search across rides, communities, drivers, events, and promo codes — returning categorized results.
- **Settings hierarchy:** Settings must be grouped into logical sections (Account, Ride Preferences, Notifications, Privacy, Accessibility, Subscription) with no more than 7 items visible per group.
- **Standard navigation components:** Use iOS tab bars and Android bottom navigation components natively — users are already familiar with platform conventions and expect them. *(Apple HIG; Smashing Magazine: "use standard navigation components")*
- **Breadcrumb-free navigation:** Use contextual back arrows and labeled app bars instead of breadcrumbs. The current screen title + highlighted tab together fully answer "where am I?" without a breadcrumb trail.

### 1.3 Visual Design Standards

- **Typography:** Use a font stack that supports both Arabic and Latin scripts natively. Arabic text must use a typeface optimized for screen readability (e.g., Noto Sans Arabic or equivalent). **Minimum body text size: 16sp** (Smashing Magazine: "anything smaller than 16 pixels is challenging to read"); Headings: 20–28sp. Limit line length to 30–40 characters per line on mobile.
- **Color system:** Primary brand palette + semantic colors (success/green, warning/amber, error/red, info/blue). Each role should have a subtle accent variant (e.g., Passenger = teal, Driver = indigo, Junior = orange) while sharing the same brand identity. **Never use color as the only indicator** of state — always pair with an icon or label (critical for the 4.5% color-blind population). *(Smashing Magazine + W3C WCAG)*
- **Dark mode parity:** Every screen, component, and illustration must function correctly in both light and dark themes. Use semantic color tokens (not hardcoded hex) so theme switching is automatic.
- **Iconography:** Outlined icons for inactive states, filled icons for active states. Custom icons for Saudi-specific features (women-only, prayer time, Nafath verification). All icons must include semantic labels for accessibility.
- **Spacing & grid:** 8px base grid. Cards should use 16px internal padding, 12px gap between cards. **Touch targets minimum 48×48dp** (validated by MIT Touch Lab research: average fingertip width 8–10mm; 10×10mm minimum = ~38dp; Android/iOS guidelines recommend 48dp).
- **Thumb-zone design:** Place primary CTAs ("Find a Ride", "Offer a Ride", "Request") in the **natural thumb zone** (middle-to-bottom of the screen). Destructive actions (cancel, delete) should be placed in harder-to-reach zones (top of screen or require deliberate stretch) to prevent accidental triggers. *(Smashing Magazine: green zone = easy reach = primary actions; red zone = hard reach = dangerous actions)*
- **Elevation & shadows:** Use a 3-level elevation system (flat, raised, floating). Bottomsheet and modal overlays should dim the background at 40% opacity.
- **Illustrations & empty states:** Every empty state (no rides found, no trip history, empty chat) should include a contextual illustration + a clear call-to-action, not just text. Empty states are also onboarding opportunities. *(Smashing Magazine: "empty states can teach people how to use an app")*
- **Visual weight hierarchy:** The most important element on each screen must have the greatest visual weight (size, color, contrast). The primary CTA ("Request Ride", "Confirm Booking") must visually dominate the screen. *(Smashing Magazine: "large items catch the eye and appear more important — like Lyft's Request button")*
- **Avoid jargon:** Use everyday language the target users understand. "XP", "Trust Tier", and "Comfort Score" must have in-context tooltips on first use. *(H2: Match between system and real world; Smashing Magazine: "unknown terms increase cognitive load")*

### 1.4 Motion & Animation

- **Page transitions:** Shared-element transitions for ride cards (marketplace → detail). Slide-in for push navigation, fade for tab switches.
- **Functional animation only:** Animation must clarify navigational transitions or state changes — not decorate. Ask: "Will this animation be annoying on the 100th use?" If yes, remove it. *(Smashing Magazine: "Functional animation is the best tool to describe state transitions")*
- **Loading states:** **Skeleton screens** (shimmer placeholders matching the layout of incoming content) are preferred over generic spinners. A skeleton screen makes the app feel faster and focuses on progress, not just waiting. *(Smashing Magazine: "skeleton screens focus on actual progress, not just that loading is happening")*. Never show a blank screen or generic spinner on primary screens.
- **Respect reduce-motion setting:** Users with motion sensitivity may have "Reduce Motion" enabled in OS settings. All non-essential animations must be disabled when this setting is active. *(Smashing Magazine + Apple HIG)*
- **Map animations:** Smooth camera fly-to when focusing on a route, marker bounce on arrival, polyline draw animation for active trips.
- **Gamification moments:** XP counter should animate (counting up), badge unlocks should use a reveal animation, and leaderboard rank changes should slide into position. Keep these optional/skippable for users who opt out of animations.

### 1.5 Content & Copy

- **Bilingual parity:** Every string must exist in Arabic (primary) and English. Arabic copy should use Saudi colloquial tone (not formal MSA) for conversational UI (chat, notifications, celebrations).
- **Actionable microcopy:** Button labels must be verbs ("ابحث عن رحلة" / "Find a Ride"), not nouns. Error messages must state what happened + what to do next.
- **Localized formatting:** Dates in Hijri + Gregorian, currency in SAR, phone numbers in +966 format, distances in km.
- **Short, scannable content:** Mobile users scan rather than read. Lead with the most important information. Use bullet points, cards, and bold text to create hierarchy. Limit paragraphs to 2–3 lines max in the UI.

### 1.6 First-Time & Onboarding Experience

*(Validated by Smashing Magazine + NNGroup research on first-time experience)*

- **Avoid a sign-in wall:** Users must be able to see the value proposition (onboarding screens or a browsable ride preview) before being forced to register. 25% of users abandon apps after a single use if the first experience is frustrating. *(Localytics research via Smashing Magazine)*
- **Value-first onboarding:** Show the core value (free rides, trusted community, XP rewards) in 3–5 swipeable screens before any signup. Screens must be skippable.
- **Contextual onboarding:** Teach features at the moment they are relevant — not in a pre-use tutorial dump. Show a tooltip for "XP" when the user first earns it, not on the onboarding screen. *(Smashing Magazine: "Contextual onboarding means instructions are provided only when the user needs them")*
- **Avoid permissions walls:** Never ask for location, notification, or camera permissions at app launch. Request them contextually — location when the user first taps "Find a Ride", notifications when they first book a ride. Users grant permissions far more readily when they understand why at that moment. *(Apple design guidelines + Smashing Magazine)*
- **Use empty states for onboarding:** First-time empty screens (no ride history, no communities joined) should guide users on what to do next — not just say "Nothing here yet." *(Smashing Magazine: "empty states teach users how to use the app")*
- **Minimal setup required at start:** The app should work with just phone verification + role selection. Prompt for photo, vehicle info, and national ID after the user has experienced core value.

### 1.7 Push Notifications Best Practices

*(Annoying notifications are the #1 reason people uninstall apps — 71% of respondents, per Appiterate survey)*

- **Every notification must have clear value:** Ride accepted, driver arriving, trip complete, streak at risk. Never send notifications just because you can.
- **Personalize notification content:** Notifications should reference the user's specific context (driver's name, destination, XP amount earned) — not be generic.
- **Avoid notification floods:** Combine related events into a single notification where possible. Do not send multiple notifications in rapid succession for a single trip event.
- **Respect quiet hours:** Default quiet hours from 11 PM to 6 AM. Users can customize this range. Peak notification window is 6 PM–10 PM for ride-related updates.
- **Use correct notification channels:** Ride-critical updates (driver arriving, SOS) = push notification. General updates (weekly leaderboard, new badge) = in-app feed or email. *(Smashing Magazine: "select the proper notification type based on urgency and content type")*
- **Deep linking:** All notifications must deep-link directly to the relevant screen (active trip map, XP dashboard, challenge detail) — never land on the home screen generically.

---

## 2. Core Features & Functionalities

### 2.1 Onboarding & Registration

- **Value-first splash:** 3–5 onboarding screens explaining the core value proposition, tailored by detected locale (Arabic default for Saudi SIMs). Screens must be swipeable and skippable.
- **Phone-based authentication:** OTP via SMS as the primary auth method (Saudi norm). Social login (Google, Apple) as secondary.
- **National identity verification:** Integration with national identity platform for trust. Verified badge shown on profile and ride cards. This request must come after first-value delivery — not at initial signup.
- **Role selection:** Users must choose a role (Passenger, Driver, Junior) after authentication. Role can be switched later from settings. Each role unlocks a tailored home screen and feature set. **Role is never auto-restored on cold start** — fresh role selection ensures intentional context switching.
- **Profile completion funnel:** Guided profile setup with a progress indicator (photo, name, phone, vehicle info for drivers, parent link for juniors). Incomplete profiles should show persistent (but non-blocking) prompts until finished. Show a percentage completion indicator to motivate users to fill it.
- **Permission requests:** Location, notifications, and contacts permissions requested contextually (when the user first needs them), not in a permissions wall at signup. Explain the benefit at point of request: "We need your location to find rides near you." *(Apple HIG + Smashing Magazine: permissions in context see far higher acceptance rates)*
- **Biometric login:** Support Face ID / fingerprint for returning users. Reduces login friction to a single tap. *(Apple HIG + Smashing Magazine: "minimize the number of steps required to log in using biometric features")*

### 2.2 Ride Discovery & Booking

**Design goal: A passenger must be able to find, review, and request a ride in under 2 minutes** — respecting the ~72-second average mobile session length (NNGroup). Every extra step or friction point risks abandonment.

- **Map-centric search:** Full-screen map with pin-drop for origin and destination. **GPS auto-detect for current location** — never ask users to type their address manually when location is available. Autocomplete address search powered by mapping service with Saudi address coverage. *(NNGroup: "GPS/camera features are the greatest mobile UX opportunity — use them to reduce manual input")*
- **Chunk the booking flow:** Break the booking steps across logical screens (1: Where? 2: When? 3: Confirm). Each screen has one question to answer. Never combine multiple complex decisions on a single screen. *(Smashing Magazine: "break tasks into bite-sized chunks")*
- **Ride marketplace:** Card-based list of available rides matching the search, sorted by AI match score. Each card shows: driver photo, name, rating, trust badge, vehicle info, departure time, pickup proximity, comfort score, seat availability.
- **Smart filters:** Filter by departure time range, women-only, kids-friendly, comfort preferences (chattiness, smoking, AC), community membership, and Khawi+ priority rides.
- **Ride detail screen:** Expanded view with route map, driver profile, vehicle details, comfort tags, reviews summary, and a prominent "Request" button. The "Request" button must be in the thumb zone (bottom half of screen).
- **Instant match (QR):** Scan/show QR code for in-person instant ride matching (events, campuses, workplaces).
- **Advance scheduling:** Book rides up to 30 days ahead. Calendar integration for reminder notifications.
- **Recurring rides:** Set a repeating schedule (e.g., Sun–Thu 7:30 AM) for daily commute carpooling with auto-match.
- **Flexibility for experts:** Power users can set ride preferences once and have them remembered for future searches. *(H7: Flexibility and efficiency of use — shortcuts for experienced users)*

### 2.3 Ride Offering (Driver)

**Design goal: A driver must be able to publish a ride offer in under 60 seconds.** The wizard must follow the chunked-steps principle — one decision per screen — and remember prior inputs to eliminate repetitive data entry for recurring commuters.

- **Offer ride wizard:** Step-by-step flow: origin → destination → date/time → available seats → preferences → confirm. Maximum three screens. Each step shows a progress indicator (Step 1 of 3). *(Smashing Magazine: "break tasks into bite-sized chunks")*
- **Smart route suggestions:** AI-recommended routes based on historical demand patterns and the driver's commute history. Reduces manual entry to a single confirmation tap for regular commuters.
- **Pre-filled defaults:** Date/time defaults to the driver's next most-common departure slot. Seat count defaults to the last-used value. Preferences (women-only, AC, music) default to saved profile — driver only changes what's different.
- **Multi-stop support:** Add up to 3 intermediate waypoints when creating a ride, with route optimization.
- **Recurring ride creation:** Set once, active every week. Edit or pause at any time. Pause/resume must be a single tap — not a delete-and-recreate flow.
- **Demand heat map:** Overlay on the driver's map showing high-demand areas with XP bonus zones. Shown on the driver home screen as an ambient awareness layer, not a forced screen.
- **Request management:** Incoming ride requests arrive as card-based notifications with the passenger's trust badge, rating, and pickup proximity visible before accept/decline. One-tap accept with a 10-second undo window. *(H3: User control and freedom)*
- **Passenger capacity guidance:** Show a real-time vehicle capacity diagram (front seat + back row) so drivers can visualize how their accepted passengers fill the car before confirming additional requests.

### 2.4 Active Trip Experience

**Design goal: The active trip screen is a safety-critical, high-anxiety UI.** It must prioritize real-time status above all else and reduce cognitive load to the minimum. Apply H1 (visibility of system status) relentlessly throughout.

- **Real-time map tracking:** Live GPS positions of driver and passenger on a shared map view. Smooth marker interpolation (no jumps).
- **ETA countdown:** Prominent countdown timer showing estimated arrival at pickup point and at destination. Updates dynamically with traffic data. **This is the single most anxious moment for both riders and drivers — make the ETA the single most visible element on the screen.**
- **Driver arrival notification:** Push notification + in-app alert when driver is 2 minutes away and when arrived.
- **In-trip chat:** Real-time messaging with AI-moderated content filtering. Quick-reply templates ("On my way", "I'm here", "Running 5 min late"). Voice message support. Quick replies dramatically reduce the need to type while in a vehicle.
- **Trip sharing:** One-tap share of live trip link (via WhatsApp, SMS) with emergency contacts. Recipients see real-time map without needing the app.
- **SOS / panic button:** Persistent, quickly accessible emergency button during active trips. Must be **visible and reachable with one thumb, always on-screen** — never more than one tap away. Triggers: alert to emergency contacts, GPS coordinates to authorities, optional audio recording. *(Apple HIG: support interactions that accommodate the way people hold their device)*
- **In-app navigation:** "Navigate" button that deep-links to preferred maps app (Google Maps, Apple Maps, Waze) with route pre-filled. Basic routing overlay for at-a-glance direction.
- **Speed & safety alerts:** Real-time alerts if the vehicle exceeds speed thresholds or deviates significantly from the planned route.
- **Minimal interruption during active trip:** Suppress all non-trip notifications (XP updates, social, marketing) during the active trip phase. The user's entire attention should be available for safety. *(NNGroup: design for the user's primary task)*

### 2.5 Post-Trip & Feedback

**Design goal: The post-trip screen is a high-engagement moment** — users have just shared a journey and their sentiment is fresh. Capture feedback immediately, surface earned rewards, and create a shareable positive moment that drives social word-of-mouth.

- **Mandatory rating:** Bidirectional 5-star rating (both rider and driver rate each other). Completion-gated: must rate before next ride. Rating screen appears automatically on trip completion — never buried in the menu.
- **Comfort tags:** Quick-select tag chips ("Clean car", "Smooth driving", "On time", "Good AC", "Friendly") aggregated into a comfort score. Tag chips require zero typing — one tap to select. *(Smashing Magazine: "minimize user input")*
- **Written reviews:** Optional free-text review displayed on the user's public profile. AI-moderated for toxicity. Character limit: 280 — encourages concise, useful feedback.
- **Trip summary screen:** Route map replay, distance, duration, CO₂ saved, XP earned, and a "Share trip" option with a branded card image. XP earned should animate counting up — a small celebration. *(Delightful micro-interaction principle)*
- **Ride receipt:** Downloadable/emailable trip receipt with all trip details (even for free rides — useful for corporate users and tax purposes).
- **In-app store rating prompt:** After the user's 5th completed trip — or after a trip they rated 5 stars — surface a native app store rating prompt. This is the optimal moment: the user is satisfied, engaged, and has experienced real value. Never prompt before 3 trips. *(Best-practice timing: post-value-delivery, not on first launch)*
- **Report & dispute:** In-context issue reporting with category picker (safety concern, route issue, driver behavior, lost item). Auto-creates support ticket.
- **Lost & found:** Structured flow to report and recover items left in vehicles. In-app messaging with the matched driver.

### 2.6 Account & Personalization

- **Profile management:** Editable name, photo, bio, preferred neighborhoods, language, ride preferences. Public vs. private profile view toggle.
- **Ride preferences:** Chattiness, music, smoking, AC, luggage — stored in profile and used for matching. These preferences must transfer to every future ride automatically. *(H7: personalization and efficiency for returning users)*
- **Notification preferences:** Per-category toggles (Trips, Social, Rewards, System). Quiet hours setting. Granular control is key — users who cannot control notifications will simply disable all of them.
- **Subscription management:** Khawi+ subscribe/cancel/upgrade flow with benefit comparison. In-app purchase integration.
- **Theme & display:** System default / Light / Dark mode toggle. Font size adjustment for accessibility.
- **Language toggle:** Arabic ↔ English switch without app restart. RTL layout auto-adapts.
- **Personalized recommendations:** Surface context-aware ride suggestions ("You usually ride at 7:30 AM on Sundays"). Starbucks-model personalization: use past behavior to create tailored offers. *(Smashing Magazine: "personalization is one of the most critical aspects of mobile apps today")*

### 2.7 Gamification & Rewards

**Design goal: Gamification must feel earned, not exploitative.** Every XP gain and badge must be tied to a real positive behavior (riding, driving, helping the community, safety). The system must be transparent — users always know exactly how much XP each action earns before committing to it.

- **XP system:** Earn XP for every ride (taken or offered), ratings given, streaks maintained, challenges completed, referrals converted. XP counter visible on home screen with a progress bar to the next level. The per-action XP table must be viewable in-app so users can make informed decisions. *(H10: Help and documentation; H2: Match real world — users need to understand the value of their actions)*
- **Levels & badges:** Progressive levels with unlockable badges. Milestone badges (first ride, 100 rides, 1 ton CO₂ saved). Special event badges (Ramadan Challenge, National Day). Badge descriptions must explain exactly how to earn them — no mystery requirements.
- **Streaks:** Daily/weekly ride streaks with multiplier bonuses. Streak-at-risk notification (sent 2 hours before midnight when a day's streak is at risk, not at midnight after it's already broken). *(NNGroup: timely, relevant notifications)*
- **Challenges:** Time-limited goals ("Complete 5 rides this week", "Carpool to 3 events this month") with XP rewards. Progress bars visible on challenge cards so users always know how close they are. *(H1: Visibility of system status)*
- **Leaderboard:** Weekly top riders and drivers — global, neighborhood, and friend scopes. Top 3 earn bonus XP multipliers. Leaderboard resets every Sunday so new users always have a chance to rank — not dominated by day-one users forever.
- **Rewards marketplace:** Redeem XP for partner coupons (coffee, fuel, dining), Khawi+ credits, exclusive badges. Show XP cost upfront on each reward card — no reveal after clicking. *(H5: Error prevention)*
- **XP gifting:** Send XP to another user as a thank-you gesture after a ride. Gifting leaderboard for most generous users. Gifting has a daily cap to prevent abuse.

### 2.8 Trust & Safety System

**Design goal: Trust must be visible at every decision point.** A user should never need to leave the app to assess whether a driver or passenger is safe to ride with. Every trust signal must be surfaced inline — on the ride card, on the profile, and during the active trip — never buried in a separate "safety" section.

- **Trust tier system:** Bronze → Silver → Gold → Platinum progression based on verification, ratings, ride count, and community engagement. Tier badge is the first visual element on every ride card and profile avatar — not an afterthought. Tap on the tier badge to see a breakdown of what criteria were met. *(H10: Help and documentation — users must understand what "Gold" means)*
- **Trust tier progression UI:** A dedicated "My Trust Profile" screen shows the user's current tier, the exact criteria met and unmet for the next tier, and estimated XP/rides needed to advance. Progress bars for each criterion. *(H1: Visibility of system status)*
- **Identity verification:** National ID (Nafath) verification badge — displayed prominently and distinctly from the trust tier badge. Drivers additionally verified with license, vehicle registration, and background check. Verification status shown on all driver-facing cards.
- **Junior-trusted flag:** Special shield badge for drivers verified and approved for kids' rides. Requires additional vetting beyond Platinum tier. Shown only when the passenger or parent is browsing in Junior mode.
- **Women-only rides:** Matching filter ensuring women passengers are matched only with women drivers. When a female passenger enables this filter, only female-verified driver profiles are returned — the filter is enforced at the data layer, not just clientside. Culturally critical for the Saudi market.
- **Community trust boost:** Rides within the same community (neighborhood, university, workplace) receive elevated trust signals with a visible "Community Verified" badge on the ride card — helping users distinguish vetted neighbors from strangers.
- **Pre-trip safety card:** Before the trip begins, both passenger and driver see a summary card: each other's trust tier, rating, photo, and an in-app emergency number. Reinforces safety awareness at the moment it matters.
- **Automated safety checks:** AI-powered trip monitoring for route deviations, speed anomalies, and unexpected stops. Proactive check-in prompts ("Are you okay?") to both parties if an anomaly is detected.
- **Fraud detection:** ML-based detection of fake accounts, suspicious booking patterns, and rating manipulation. Account flags result in a temporary review state, not an immediate ban — preserving user rights while protecting the community.

### 2.9 Communication & Social

**Design goal: Communication must enable coordination without creating a distraction or safety risk.** All messaging during an active trip must be achievable with one hand and minimal attention — quick replies and voice messages take priority over free-text entry while the vehicle is moving.

- **In-app messaging:** Per-ride chat threads with text, voice messages, and photo (location pin) sharing. AI-moderated for safety. Chat is scoped to the trip — it is not a persistent DM channel. After trip completion, the thread is readable but locked for new messages after 24 hours.
- **Quick-reply templates:** Pre-populated messages for common coordination ("Which entrance?", "I'm wearing a red jacket", "2 minutes away", "At the main gate"). Users can customize up to 5 personal templates. *(H7: Flexibility and efficiency — shortcuts for returning users)*
- **Contactless pickup coordination:** Dedicated "I'm here" / "On my way" status chips that both parties see on their live map screens — eliminating the need to type while driving or walking.
- **Push notifications:** Rich notifications with inline action buttons (Accept, Decline, View Trip). All ride push notifications must deep-link directly to the relevant context — never to the home screen. *(Section 1.7 notification principles apply in full)*
- **Community ride boards:** Post ride offers/requests to neighborhood or campus communities. Community members see these before the general marketplace.
- **In-app referral sharing:** One-tap referral via WhatsApp / SMS deep-link with branded referral card image and personalized promo code. Referral link auto-expires after 30 days to prevent stale attribution.

---

## 3. Advanced / Differentiating Features

### 3.1 Junior / Kids Safety Mode

**Design rationale:** No direct competitor in the Saudi market offers a parent-supervised, trust-gated children's ride mode. Uber Family Profiles exist but do not have a whitelist or live-tracking depth. This feature directly addresses the segment of Saudi parents who manage school commutes. It must be designed to reduce parental anxiety — every interaction should signal safety and control. *(Internal competitive analysis: Uber, Careem, Jeeny — none offer comparable Junior depth)*

- **Dedicated junior role:** Separate app experience for children, linked to a parent account. Simplified UI with age-appropriate design — larger text, bright colors, no complex data screens.
- **Trusted driver whitelist:** Parents curate a list of approved drivers. Only whitelisted drivers can match with junior rides. The whitelist management UI must be simple enough for non-tech-savvy parents.
- **Parent live tracking:** Real-time trip tracking on the parent's device with push notifications for departure, waypoint arrival, and trip completion. The parent-facing tracking card must be the most prominent UI element during a junior's active trip.
- **School carpool coordination:** Dedicated flow for recurring school commutes with trusted neighborhood drivers. Group coordination for multiple kids on the same route.
- **Junior rewards:** Age-appropriate XP and badge system encouraging safe behavior (seatbelt confirmation, punctuality). Rewards visible to parents — shared celebration of good behavior.

### 3.2 AI-Powered Intelligence

**Design rationale:** AI intelligence must be invisible when it's working and transparent when the user needs to understand a decision. "Why did I get matched with this driver?" and "Why didn't I see any rides?" must always have an accessible explanation. AI that is opaque erodes trust. *(H10: Help and documentation — users must be able to understand system decisions; H1: Visibility of system status)*

- **13-function ML engine:** Match scoring, route bundling, dynamic incentives, trust scoring, message moderation, acceptance prediction, demand forecasting, fraud detection, ETA estimation, driver behavior scoring, badge evaluation, XP classification, and support copilot.
- **Smart commute auto-match:** ML-detected commute patterns automatically suggest daily carpool partners. "3 people are going your way tomorrow morning" notification. The suggestion must show the user *why* — "Based on your past 8 Tuesday rides".
- **Demand-responsive XP zones:** Dynamic XP multipliers in high-demand areas/times to incentivize driver supply where it's needed. Zone bonuses are indicated on the driver's heat map *before* the driver commits to a route, so drivers can make an informed decision. *(H5: Error prevention — no surprises after commitment)*
- **Churn prediction:** Identify users at risk of leaving and trigger retention campaigns (personalized push, promo codes, XP bonuses). Retention messages must feel helpful, not manipulative — they must reference real value the user has received. *(NNGroup: relevant, personalized notifications)*
- **Context-aware recommendations:** "You usually ride at 7:30 AM on Sundays — here are 3 drivers going your way." Recommendations include a one-tap dismiss and a "Don't suggest" option — users can opt out of pattern-based nudges.

### 3.3 Community-First Social Layer

**Design rationale:** Trust is easier to establish within known social groups. BlaBlaCar's research found that rides within social circles have 4× higher acceptance rates. The community layer must reduce the "stranger anxiety" that is the primary barrier to carpooling adoption in Saudi Arabia. Community membership must be earned through real ties, not self-declaration. *(Internal competitive analysis: BlaBlaCar community model; NNGroup: reduce cognitive friction by surfacing familiar context)*

- **Neighborhood communities (حارة خاوي):** Auto-joined communities based on user's neighborhood with local ride boards, community stats, and CO₂ impact dashboards. Auto-join is based on the user's verified home address — not self-reported.
- **University campus carpools:** Verified student groups (.edu.sa email) with campus-specific ride boards and exam-period surge coordination. Email verification gated — no anonymous community members.
- **Event rides:** Pre-built ride boards for major events (Riyadh Season, concerts, football matches) with venue-specific pickup zones and return-ride coordination. Event boards are surfaced contextually based on the user's neighborhood and past event attendance.
- **Corporate ride groups:** Employer-tagged ride boards for workplace commutes with optional corporate billing integration. Employer verification via corporate email domain.

### 3.4 Saudi Market-Specific Intelligence

**Design rationale:** A product that understands local culture without being asked builds significantly deeper trust than a generic global product with localization bolted on. These features must never feel like translations — they must feel native. *(H2: Match between system and real world — cultural metaphors, not just language translation)*

- **Prayer time awareness:** Ride scheduling accounts for Salah times — no ride suggestions during prayer windows, post-prayer surge optimization. Prayer window calculations use user-location-aware Salah times (Umm Al-Qura schedule), not a fixed global offset.
- **Ramadan mode:** Adjusted timing around Iftar/Suhoor, Ramadan-specific challenges, charity ride options. Ramadan UI uses a warm color palette and crescent motif — a seasonal design system layer, not a permanent change.
- **Hajj/Umrah programs:** Verified religious tourism rides with multilingual matching (Arabic, Urdu, Malay, Turkish). Multilingual matching must work at the ride-card level — a passenger sees the driver's language badges before requesting.
- **Saudi cultural calendar:** National Day challenges, school calendar integration, entertainment season ride boards. Calendar-reactive badges are pre-announced 1 week before activation so users can plan toward them.
- **Vision 2030 alignment:** Carbon savings dashboard aligned with Saudi Green Initiative metrics. Women-driver recruitment visibility. Green Impact statistics are shareable to social media as a branded card image.

### 3.5 Sustainability & Impact

**Design rationale:** Environmental impact must be made concrete and personal — not an abstract stat buried in a settings screen. "You personally prevented 32 kg of CO₂ this month" is more motivating than "Our platform saved 15,000 kg." Individual attribution drives repeated behavior. *(Behavioral science: goal gradient effect — progress toward a personal milestone is more motivating than aggregate community progress)*

- **Carbon footprint tracker:** Per-ride and cumulative CO₂ savings vs. solo driving. Monthly "Green Impact" report. CO₂ savings are shown at the trip summary screen (Section 2.5) immediately after every ride — not only in a monthly report.
- **Green badges:** Milestone badges at 100 kg, 500 kg, and 1 ton CO₂ saved. A badge approaching 80% completion shows a progress bar nudge on the home screen dashboard.
- **Community impact dashboard:** Neighborhood-level stats ("Al Rabwah saved 500 kg CO₂ this month"). Rankings between communities create healthy competition and social visibility. *(Section 3.3 community layer integration)*
- **EV preference:** Filter for electric or hybrid vehicles in ride search. EV drivers receive a green badge modifier on their profile to signal eco-conscious status.

### 3.6 Premium Membership (Khawi+)

**Design rationale:** Subscription value must be immediately perceptible on every ride — not a one-time paywall experience. Members must see concrete evidence of their premium status in each session; otherwise churn risk is high after the first billing cycle. *(Subscription UX principle: deliver visible, recurring value; not just unlock-once features)*

- **Priority matching:** Khawi+ members appear higher in match results and get first access to limited-seat rides. The priority boost must be quantifiable and shown to the subscriber: "Your Khawi+ priority resulted in a match 2 minutes faster today."
- **Exclusive badges:** Premium-only badge designs and profile frames. A subtle Khawi+ crown modifier is visible on the user's avatar throughout the app — a persistent identity signal, not just a settings badge.
- **Ad-free experience:** No promotional banners or interstitials. Non-Khawi+ users see max 1 tasteful promotional card per session — never during an active trip or safety-critical flow. *(H8: Aesthetic and minimalist design)*
- **Enhanced analytics:** Detailed ride statistics, monthly reports, earnings summaries (drivers). Reports are exportable as PDF for corporate users and driver tax purposes.
- **Trip insurance inclusion:** Micro-insurance coverage bundled with subscription. Insurance details are presented in plain language — not legal text — with a single-page summary accessible from the active-trip screen.

---

## 4. User Flows & Interaction Patterns

### 4.1 Onboarding Flow

```
App Launch → Language Selection (Arabic/English)
  → Splash Screens (3–5, swipeable, skippable)
  → Phone Authentication (OTP)
  → National ID Verification (optional, prompted)
  → Role Selection (Passenger / Driver / Junior)
  → Profile Setup (name, photo, vehicle for Driver, parent link for Junior)
  → Notification Permission (contextual)
  → Location Permission (contextual, when first searching)
  → Home Screen (role-specific)
```

**Key principles:**
- Returning users skip the splash/language/registration steps and land on role selection — role selection is shown on every cold start by design (see FT-11 and the `ActiveRoleNotifier` implementation contract)
- Allow users to reach the home screen with a minimal profile; prompt completion later via contextual nudge cards, not blocking modals
- Each role triggers role-specific setup steps (driver: vehicle info; junior: parent link)

### 4.2 Passenger – Find a Ride Flow

```
Home Screen → "Find a Ride" (primary CTA)
  → Map / Address Input (origin + destination)
  → Ride Marketplace (filtered, sorted by AI match)
  → Ride Detail (driver profile, route, preferences, comfort score)
  → "Request Ride" → Confirmation (date, time, pickup point)
  → Waiting for Acceptance (real-time status)
  → Accepted → Active Trip (ETA, chat, live map, share, SOS)
  → Arrival → Trip Summary (rating, tags, review, receipt, XP earned)
```

### 4.3 Driver – Offer a Ride Flow

```
Home Screen → "Offer a Ride" (FAB or primary CTA)
  → Route Input (origin → destination, optional waypoints)
  → Schedule (date, time, recurring option)
  → Preferences (seats, women-only, comfort tags)
  → Review & Publish
  → Ride Listed in Marketplace
  → Incoming Requests (accept/decline with rider profile preview)
  → Active Trip (navigation, passenger pickup, ETA, chat)
  → Trip Complete → Summary (ratings received, XP earned, comfort score update)
```

### 4.4 Junior – Ride Flow (Parent-Supervised)

```
Parent Account → Junior Profile Setup (name, photo, school)
  → Trusted Driver Whitelist (add/remove drivers)
  → Request Ride (school carpool or ad-hoc)
  → Parent Approval Gate (push notification to parent for confirmation)
  → Matched with Whitelisted Driver
  → Parent Live Tracking (real-time map, notifications)
  → Junior In-Trip (simplified UI, SOS, no chat with strangers)
  → Arrival → Parent Notification
  → Junior XP Reward (seatbelt badge, punctuality streak)
```

### 4.5 Recurring Commute Flow

```
Settings → "My Commute" → Set Home Address + Work Address
  → Define Schedule (days + departure time)
  → AI Auto-Match → "3 drivers go your way"
  → Accept Match → Recurring Booking (weekly, auto-renewing)
  → Daily Reminder Notification (15 min before)
  → Active Trip → Normal Trip Flow
  → Pause / Edit / Cancel Commute anytime
```

### 4.6 Community & Event Flow

```
Home → Communities Tab
  → My Neighborhood / My University / My Workplace
  → Community Ride Board (offers + requests)
  → Post a Ride Request to Community
  → Browse Event Rides (Riyadh Season, concerts)
  → Book Event Ride (pickup zone + return-ride option)
  → Community Stats (CO₂ saved, rides completed, top contributors)
```

### 4.7 Gamification & Rewards Flow

```
Home → XP Badge (tap to expand)
  → XP Dashboard (current XP, level, next milestone, active streak)
  → Active Challenges (cards with progress bars)
  → Leaderboard (weekly, neighborhood, friends)
  → Rewards Store (browse, filter, redeem with XP)
  → Gift XP (select user, enter amount, send)
  → Badge Collection (earned, locked, progress toward each)
```

### 4.8 Emergency / Safety Flow

```
Active Trip → SOS Button (always visible, long-press to activate)
  → Confirmation ("Are you sure?")
  → Triggered:
      - Emergency contacts notified with live location link
      - GPS coordinates logged
      - Optional: audio recording begins
      - Support ticket auto-created
  → Post-incident: Support follow-up, incident report review
```

### 4.9 Settings Flow

```
Home → Profile Tab → Settings (gear icon)
  → Account (name, photo, phone, national ID, linked accounts)
  → Ride Preferences (chattiness, music, smoking, AC, luggage)
  → Notifications (per-category toggles, quiet hours)
  → Privacy (location sharing, profile visibility, data download)
  → Accessibility (font size, high contrast, reduce motion, senior mode)
  → Subscription (Khawi+ status, benefits, manage/cancel)
  → Language (Arabic / English toggle)
  → Help & Support → (see 4.10)
  → About (version, licenses, terms, privacy policy)
  → Sign Out / Delete Account (destructive, requires confirmation)
```

**Key principles:**
- Settings entries must be grouped, not dumped in one flat list. Max 7 items per group.
- Destructive actions (Sign Out, Delete Account) must use red-tinted text and require a separate confirmation step — they must never sit adjacent to safe actions without visual separation.
- Language change takes effect immediately without app restart.

### 4.10 Help & Support Flow

```
Settings → Help & Support
  → Search bar (semantic search across help articles)
  → Suggested topics ("How do ratings work?", "Cancel a ride", "SOS guidance")
  → Browse categories (Trips, Account, Safety, Payments, Khawi+, Junior)
  → Article view (concise steps with screenshots; link to related articles)
  → Not resolved? → Live Chat / Support Ticket
  → Support ticket: attach screenshot, select category, describe issue → Submit
  → Ticket status tracker (open / in review / resolved)
```

**Key principles:**
- Help content must be searchable and in-context — the most relevant article should surface when a user navigates from an error screen. *(H10: Help and documentation — in-context, concrete steps)*
- Live chat is the escalation path, not the entry point. Self-service articles must resolve ≥ 70% of common queries.

### 4.11 Subscription / Khawi+ Flow

```
Settings → Subscription  OR  Profile → "Go Premium" badge
  → Khawi+ Benefits screen (side-by-side Free vs. Premium comparison)
  → Select plan (monthly / annual with savings callout)
  → Payment (in-app purchase via App Store / Google Play)
  → Confirmation + immediate benefit activation
  → Premium home: priority match badge visible, ad-free confirmed
  → Manage: upgrade, downgrade, cancel (with retention offer)
  → Cancellation: takes effect at end of billing period; no immediate loss of access
```

**Key principles:**
- The benefit comparison table must show concrete, quantified advantages — not vague descriptions ("priority matching" → "Up to 3× more ride options").
- Cancellation must be fully completable inside the app — not redirected to a web page or email. *(H3: User control and freedom)*

### 4.12 Trust Tier Progression Flow

```
Profile → Trust Badge (tap)
  → My Trust Profile screen
      - Current tier (Bronze / Silver / Gold / Platinum) with badge illustration
      - Criteria met: ✓ National ID verified, ✓ 50+ rides, ✓ Rating ≥ 4.8
      - Criteria needed for next tier: progress bars for each
  → "How tiers work" explainer (linked article)
  → "Improve your trust" suggestions (e.g., "Add vehicle registration")
```

**Key principles:**
- The tier criteria must be fully transparent — no hidden scoring. *(H2: Match real world — users must understand how the system works)*
- The path to the next tier must include actionable steps the user can take today, not passive waiting.

---

## 5. Accessibility & Usability Considerations

### 5.1 Visual Accessibility

- All text must meet WCAG 2.1 AA contrast ratios (4.5:1 for body text, 3:1 for large text) in both light and dark themes.
- Support dynamic type / font scaling up to 200% without layout breakage.
- Never rely on color alone to convey information. Use icons, labels, or patterns alongside color indicators.
- Provide a high-contrast mode option for users with low vision.
- All images and illustrations must include descriptive alt-text.

### 5.2 Motor Accessibility

- All interactive elements must have a minimum touch target of 48×48dp with adequate spacing (8dp minimum between targets).
- Swipe gestures must have tap-based alternatives (e.g., swipe-to-delete must also offer a delete button via long-press menu).
- Forms must support sequential focus navigation (tab order) on external keyboards.
- Avoid time-limited interactions; where unavoidable, provide an option to extend the time limit.

### 5.3 Cognitive Accessibility

- Use clear, simple language. Avoid jargon. Provide tooltips for unfamiliar terms (e.g., "XP", "Trust Tier", "Comfort Score").
- Multi-step flows must show a progress indicator (step X of Y) and allow backward navigation without data loss.
- Confirmations must be explicit for irreversible actions (cancel ride, delete account). Use distinct button styles for destructive vs. safe actions.
- Error messages must state: (1) what went wrong, (2) why, and (3) what the user can do to fix it.

### 5.4 Screen Reader & Assistive Technology

- All interactive elements must have meaningful semantic labels (not "Button 1", but "Request this ride with Ahmed").
- Screen reader focus order must follow visual layout (top-to-bottom, start-to-end per reading direction).
- Map interactions must have non-visual alternatives (address search, list view of nearby rides).
- Live trip status updates must be announced to screen readers via accessibility live regions.

### 5.5 Localization & Cultural Sensitivity

- Full RTL layout support for Arabic. Mirror all directional icons, navigation flows, and animations for RTL.
- Date pickers must support Hijri calendar alongside Gregorian.
- Prayer time overlays must be sensitive to the user's geographic location (sunrise/sunset calculation for local Salah times).
- Women-only UX flows must be designed with cultural dignity — no patronizing iconography or messaging.
- Content must avoid culturally insensitive imagery (alcohol, gambling references, inappropriate dress depictions).

### 5.6 Device & Network Resilience

- Support screen sizes from 5" phones to 12.9" tablets with responsive layouts.
- Orientation: portrait-primary, landscape-supported for tablets.
- **Low-end device support:** The Saudi market's primary device tier is mid-range Android (Samsung A-series, Galaxy M-series) with 3–4 GB RAM and 64 GB storage. The app must:
  - Run without lag on devices with Snapdragon 680 / equivalent CPU
  - Keep installed APK size ≤ 50 MB (defer maps tiles and media assets via CDN)
  - Avoid memory-intensive operations on the UI thread
  - Use vector assets and compressed image formats (WebP) to minimize storage footprint
  *(Smashing Magazine: "make sure your product works with older, low-end devices — smartphones in emerging markets cost below $100")*
- **Variable connectivity design:** The app must function usefully across Wi-Fi, 4G, 3G, and intermittent 2G. On slow connections:
  - Load visible content first; lazy-load content below the fold
  - Use HTTP caching headers aggressively for static data (driver profiles, community metadata)
  - Show a dismissible "Slow connection" banner rather than timing out silently
  - Ride search and booking must succeed on networks up to 5-second latency
- Graceful degradation on offline state: cached ride history, profile data, and last-known trip status remain accessible. Clearly marked with "Last updated X minutes ago".
- All critical interactions (ride request, SOS, rating) must work on networks with up to 5-second latency without timing out or losing user input.

### 5.7 Senior-Friendly Mode

- Optional large-text mode with simplified navigation (fewer tabs, larger buttons, higher contrast).
- Voice-guided interaction support for core flows (find ride, call driver).
- Reduced cognitive load: fewer choices per screen, clearer labeling, no gamification clutter (badges/XP hidden if opted out).

---

## 6. Acceptance Criteria

### 6.1 UX/UI Acceptance Criteria

| ID | Criterion | Testable Condition |
|----|-----------|-------------------|
| UX-01 | Visual consistency across all screens | All screens pass a visual regression audit against the design-token system (colors, typography, spacing, elevation). No hardcoded values outside the token set. |
| UX-02 | Primary task completable without guidance | A first-time user completes the "Find a Ride" flow (onboarding → search → request → confirmation) without external help in ≤ 5 minutes during usability testing. |
| UX-03 | Navigation indicates current location | Every screen displays a title and/or highlighted tab that unambiguously identifies the user's position in the app hierarchy. |
| UX-04 | Feedback for every user action | Every tap on an interactive element produces visible feedback (ripple, state change, loading indicator, or confirmation) within 100ms. |
| UX-05 | Dark mode parity | Every screen renders correctly in both light and dark themes with no illegible text, missing icons, or broken layouts — verified by visual regression tests in both modes. |
| UX-06 | RTL layout correctness | All screens render correctly in Arabic (RTL) with mirrored navigation, icons, and animations. No LTR-only layout artifacts remain. |
| UX-07 | Empty state handling | Every list, feed, or data screen displays a contextual empty-state illustration with a clear call-to-action when no data is available. |
| UX-08 | Error state clarity | Every error shown to the user contains: (1) a human-readable description, (2) why it happened, and (3) an actionable next step or retry button. |
| UX-09 | 3-tap reachability | The 6 most-used actions (find ride, offer ride, active trip, XP dashboard, chat, settings) are reachable from the home screen within ≤ 3 taps. |
| UX-10 | Loading state quality | No screen ever shows a blank white/black page during data loading. Shimmer placeholders or skeleton layouts are used for all primary content areas. |
| UX-11 | No sign-in wall | A new user can view the app's value proposition (onboarding screens) before being required to register. The app does not force immediate account creation on first launch. |
| UX-12 | Contextual permissions | Location, notification, and camera permissions are requested only when directly triggered by a user action (e.g., tapping "Find a Ride") — never on app launch or during onboarding screens. |
| UX-13 | Keyboard type correctness | Phone number fields display a numeric keypad; email fields display an email keyboard; free-text fields display a standard keyboard. Verified across iOS and Android. |
| UX-14 | Back button safety | Tapping back mid-flow (booking wizard, profile setup, report form) returns to the prior step with all entered data intact. Back never ejects to the home screen from within a multi-step flow. |
| UX-15 | Gesture alternatives | Every swipe gesture in the app (swipe to dismiss, swipe to accept) has a visible tap-based equivalent. Gesture-only actions with no visible alternative are not permitted. |
| UX-16 | Notification relevance | 100% of sent notifications include the user's specific context (trip details, driver name, XP amount). Generic "Check out the app!" class notifications are not sent. Verified via notification log audit. |

### 6.2 Feature Acceptance Criteria

| ID | Criterion | Testable Condition |
|----|-----------|-------------------|
| FT-01 | Ride search returns relevant results | Searching with a valid origin and destination returns ≥ 1 ride (or a meaningful "no rides" state with a "post request" CTA) within 3 seconds. |
| FT-02 | Ride booking end-to-end | A passenger can search, select, request, and receive a booking confirmation (or driver acceptance) with real-time status updates at each step. |
| FT-03 | Driver ride offering | A driver can create and publish a ride (origin, destination, time, seats) in ≤ 60 seconds. The ride appears in the marketplace immediately. |
| FT-04 | Real-time tracking accuracy | During an active trip, the driver's position updates on the passenger's map at ≤ 5-second intervals with GPS accuracy ≤ 50 meters in urban areas. |
| FT-05 | Bidirectional rating | Both rider and driver are prompted to rate (1–5 stars + optional tags) after trip completion. Ratings are reflected on profiles within 10 seconds. |
| FT-06 | Chat delivery | Messages sent during an active trip are delivered and displayed to the recipient within 2 seconds under normal network conditions. |
| FT-07 | Push notification delivery | Ride-related notifications (request received, ride accepted, driver arriving, trip complete) are delivered within 10 seconds of the triggering event. |
| FT-08 | XP system correctness | XP is awarded correctly for all defined actions (ride completion, rating, streak, challenge, referral). The XP counter on the home screen updates in real time. |
| FT-09 | Junior ride safety gate | A junior-role ride request requires parent approval before proceeding. Only whitelisted drivers appear in junior matching results. |
| FT-10 | Emergency SOS flow | Activating SOS during a trip sends the user's live GPS link to all configured emergency contacts within 15 seconds and persists an incident record. |
| FT-11 | Role selection on every launch | Every cold start of the app routes the user to role selection regardless of previously selected role. The last role is not auto-restored. |
| FT-12 | Subscription management | A user can subscribe to, view benefits of, and cancel the premium membership entirely within the app. Subscription status takes effect within 30 seconds. |
| FT-13 | Referral tracking | A referred user's registration is attributed to the referrer. XP is awarded to the referrer when the referred user completes their first ride. |
| FT-14 | Community ride board | Rides posted to a community board are visible only to verified community members within 5 seconds of posting. |
| FT-15 | Advance scheduling | A ride created with a future date/time generates a reminder notification at the configured intervals (1 hour and 15 minutes before departure). |
| FT-16 | Biometric login | A returning user can authenticate using Face ID or fingerprint on a supported device within 1 tap after the OS biometric prompt. Falls back to OTP if biometric fails. |
| FT-17 | GPS auto-detect | When a user grants location permission and taps "Find a Ride", their current location is auto-populated as the origin without any manual address entry. Accuracy within 100 meters. |
| FT-18 | Trust tier display | Every ride card, profile screen, and active trip screen displays the relevant user's trust tier badge. The badge is correct and up-to-date within 60 seconds of a tier change. |
| FT-19 | Women-only filter enforcement | When a female passenger enables the women-only filter, only female-verified driver profiles are returned in search results. Male driver profiles are suppressed at the API layer — not just UI. |
| FT-20 | In-app store rating prompt | The native app store rating dialog is shown after the user completes their 5th trip, or after any trip they rate 5 stars. It is never shown before 3 completed trips or more than once per 60 days. |
| FT-21 | Settings completeness | All settings listed in Section 4.9 (Account, Ride Preferences, Notifications, Privacy, Accessibility, Subscription, Language, Help, About, Sign Out) are accessible and functional within the Settings screen. |
| FT-22 | Help search | A user can search for a help topic and receive ≥ 1 relevant article within 2 seconds. Help content must be available offline for the 10 most-accessed articles. |

### 6.3 Performance & Quality Acceptance Criteria

| ID | Criterion | Testable Condition |
|----|-----------|-------------------|
| PQ-01 | Cold start time | App launches to the first interactive screen in ≤ 3 seconds on a mid-range device (e.g., Samsung A-series) under normal network conditions. APK installed size does not require > 50 MB of storage to launch (additional assets loaded on demand). |
| PQ-01a | Page load time | All primary content screens (ride marketplace, profile, XP dashboard) display meaningful content within 2 seconds of navigation. 47% of users abandon if a page takes longer than 2 seconds to load. *(Smashing Magazine: mobile page load expectations)* |
| PQ-02 | Frame rate during maps | Map scrolling and trip tracking maintain ≥ 55 fps on target devices. No visible jank during marker updates or camera animations. |
| PQ-03 | API response latency | 95th-percentile response time for core APIs (search rides, submit rating, fetch profile) is ≤ 1 second. |
| PQ-04 | Offline data access | Ride history, profile data, and last-known trip status remain accessible without network connectivity, displayed with a visible "offline" indicator. |
| PQ-05 | Battery efficiency | Active trip tracking (GPS + network) consumes ≤ 5% battery per hour on a device with a 4,000 mAh battery. |
| PQ-06 | Memory consumption | App memory usage does not exceed 250 MB during active trip tracking with map rendering. No memory leaks detected across a 30-minute active session. |
| PQ-07 | Crash rate | Production crash-free rate is ≥ 99.5% across all supported devices and OS versions. |
| PQ-08 | Data integrity | No user data (rides, ratings, XP, profiles) is lost during normal app operations, including backgrounding, force-quit, and OS-initiated termination. |
| PQ-09 | Concurrent user handling | The backend supports ≥ 10,000 concurrent active trips without degradation in match response time or tracking update frequency. |
| PQ-10 | Accessibility compliance | The app passes automated accessibility audits (Semantics tree validation) with zero critical violations. Manual screen reader testing confirms all core flows are navigable. |

### 6.4 Security & Privacy Acceptance Criteria

| ID | Criterion | Testable Condition |
|----|-----------|-------------------|
| SP-01 | Authentication security | All API calls require a valid, unexpired authentication token. Expired tokens trigger automatic refresh or re-authentication — never silent failure. |
| SP-02 | Data encryption | All data in transit uses TLS 1.2+. Sensitive data at rest (tokens, personal info) is stored in platform-secure storage (Keychain / EncryptedSharedPreferences). |
| SP-03 | PII protection | Personal information (phone number, national ID, home address) is never exposed in logs, analytics events, or error reports. |
| SP-04 | Location privacy | User location data is transmitted only during active trips and ride searches. Location sharing stops immediately when a trip ends or is cancelled. |
| SP-05 | Content moderation | AI chat moderation flags and blocks messages containing harassment, personal information sharing requests, or inappropriate content within 1 second of sending. |
| SP-06 | Junior account isolation | Junior accounts cannot access adult-facing features. Communication with non-whitelisted adults is blocked at the data layer. |

---

## 7. Design Heuristic Mapping — Khawi Features to Nielsen's 10 Heuristics

This table maps each of Jakob Nielsen's 10 Usability Heuristics to concrete Khawi features, providing an audit checklist for designers and QA reviewers.

| # | Heuristic | Khawi Implementation |
|---|-----------|---------------------|
| H1 | **Visibility of system status** | Persistent trip bar on all screens during active trip; skeleton loaders on all data screens; real-time ETA countdown; XP counter updates in real time |
| H2 | **Match between system & real world** | Saudi Arabic colloquial tone (not MSA); Hijri calendar dates; map as the primary metaphor for ride navigation; familiar card/list patterns |
| H3 | **User control and freedom** | Cancel ride request before acceptance; undo last action in chat; back navigation without data loss on all multi-step flows; clear exit on every modal |
| H4 | **Consistency and standards** | Single design-token system across all roles; native platform components (iOS tab bar, Android bottom nav); consistent icon grammar (filled = active, outlined = inactive) |
| H5 | **Error prevention** | Inline address validation; confirmation dialog before canceling an accepted ride; smart defaults for time/date; duplicate booking detection |
| H6 | **Recognition over recall** | Bottom tab bar always visible (no hamburger hiding); quick-reply templates in chat; ride preferences pre-filled from last booking; saved addresses |
| H7 | **Flexibility and efficiency** | QR instant match for power users; recurring commute auto-match; saved ride preferences; Khawi+ priority placement for frequent users |
| H8 | **Aesthetic & minimalist design** | Role-specific home screens show only top 3 actions; no feature dumping on the home screen; driver dashboard decluttered during active trip |
| H9 | **Error recovery** | Meaningful error messages with cause + fix; retry buttons on all network failures; trip dispute flow with clear categories; lost & found structured flow |
| H10 | **Help & documentation** | Contextual tooltips for "XP", "Trust Tier", "Comfort Score"; in-app FAQ accessible from Settings; onboarding empty states that teach by example |

---

## 8. Research Sources

This document incorporates findings from the following authoritative external sources, validated against the Khawi competitive analysis and feature inventory:

| Source | Key Findings Used |
|--------|------------------|
| **Nielsen Norman Group — Mobile UX** (nngroup.com/articles/mobile-ux/) | 72-second average mobile session → book-a-ride in < 2 min target; design for interruption/state saving; GPS over manual address entry |
| **Nielsen Norman Group — 10 Usability Heuristics** (nngroup.com/articles/ten-usability-heuristics/) | Full heuristic mapping in Section 7; applied to all UX principles in Section 1 |
| **Nielsen Norman Group — Mobile Navigation Patterns** (nngroup.com/articles/mobile-navigation-patterns/) | Tab bar validation; hamburger menu avoidance justification; navigation hub rationale for task-oriented apps |
| **Smashing Magazine — Comprehensive Guide to Mobile App Design** (smashingmagazine.com/2018/02/comprehensive-guide-to-mobile-app-design/) | Cognitive load reduction; thumb zone design; skeleton screens; contextual permissions; onboarding patterns; notification strategy; 25% one-use abandonment statistic |
| **Apple Human Interface Guidelines — Designing for iOS** (developer.apple.com/design/human-interface-guidelines/designing-for-ios) | Controls in middle/bottom display for thumb reach; biometric auth integration; system feature integration (location, shortcuts) |
| **MIT Touch Lab** (touchlab.mit.edu) | Minimum touch target size: 10×10mm (≈38dp) → Khawi uses 48dp for safety margin |
| **Internal: docs/COMPETITIVE_ANALYSIS.md** | Uber, Careem, Lyft, BlaBlaCar, InDrive, Jeeny feature comparison; Saudi-market gap analysis; trust and safety benchmarks |
| **Internal: docs/feature_inventory.md** | Full feature inventory and role-based capability mapping for Khawi v1 |

---

*This document is a living reference for product design, development planning, and QA validation. Update acceptance criteria as features evolve.*
