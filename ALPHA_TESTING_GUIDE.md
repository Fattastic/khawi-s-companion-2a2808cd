# Khawi Alpha Testing Guide

**Version:** 0.1.0 (Alpha)  
**Date:** February 17, 2026  
**Build:** `artifacts/khawi-0.1.0-alpha.apk`

---

## Quick Start — Android

### For Testers

1. **Download** the APK file: `khawi-0.1.0-alpha.apk` (≈76 MB)
2. On your Android phone, go to **Settings → Security → Install Unknown Apps** and allow your browser or file manager
3. Open the APK and tap **Install**
4. Launch **Khawi** and sign in with Google

> **Minimum:** Android 7.0 (API 24) or later

### For the Developer (You)

Build a fresh APK any time:

```powershell
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://oxcustajfzeqibnkjthp.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_jjF9aK40I9cWynRsw2vKeQ_3dtvVsaz `
  --dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=129754711874-3mjqg3b9jdqff9f65mensv7u0maila8e.apps.googleusercontent.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Sharing the APK

| Method | How |
|--------|-----|
| **Direct share** | Send APK via WhatsApp, Telegram, Google Drive, or email |
| **GitHub Release** | Create a release on GitHub and attach the APK file |
| **QR code** | Upload to Google Drive → generate share link → convert to QR |

---

## iOS Setup (Pending Apple Developer Account)

### Prerequisites

1. **Apple Developer Program** membership ($99/year) — [developer.apple.com](https://developer.apple.com/programs/)
2. **Xcode** installed on a Mac
3. Your **Team ID** (10-char string from Membership Details page)

### Setup Steps

Once you have your Apple Developer Team ID:

#### 1. Set the Development Team

Open `ios/Runner.xcodeproj/project.pbxproj` and add your Team ID to all build configurations:

```
DEVELOPMENT_TEAM = YOUR_TEAM_ID;
```

Or open the project in Xcode → Runner target → Signing & Capabilities → select your team.

#### 2. Build for iOS

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://oxcustajfzeqibnkjthp.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_jjF9aK40I9cWynRsw2vKeQ_3dtvVsaz \
  --dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=129754711874-3mjqg3b9jdqff9f65mensv7u0maila8e.apps.googleusercontent.com
```

#### 3. Distribute via TestFlight

1. Open `ios/Runner.xcworkspace` in Xcode
2. Product → Archive
3. Distribute App → App Store Connect (TestFlight)
4. In [App Store Connect](https://appstoreconnect.apple.com), add tester emails under TestFlight → Internal Testing

### iOS Configuration Summary

| Setting | Value |
|---------|-------|
| Bundle ID | `com.khawi.app.khawiApp` |
| Display Name | Khawi App |
| Deep link scheme | `io.supabase.khawi` |
| Min iOS version | Default Flutter (iOS 12+) |

---

## What to Test (Alpha Checklist)

### Critical Flows

- [ ] **Sign up / Sign in** via Google OAuth
- [ ] **Profile creation** — fill name, select role (passenger/driver)
- [ ] **Passenger flow** — search for rides, view trip details
- [ ] **Driver flow** — create a trip, view queue
- [ ] **Navigation** — all tabs work, back button behavior
- [ ] **Deep links** — `io.supabase.khawi://login-callback` (auth redirect)

### Feature Areas

- [ ] Trip search & matching
- [ ] Ride requests (send/accept/decline)
- [ ] Real-time location updates
- [ ] In-trip messaging
- [ ] Ride rating after trip
- [ ] Community features (create/join groups)
- [ ] Events listing
- [ ] Leaderboard / XP display
- [ ] Rewards catalog
- [ ] Fare estimation
- [ ] Junior rides (kid transport)
- [ ] Smart commute suggestions
- [ ] Notifications
- [ ] Profile editing & verification
- [ ] Carbon footprint tracking
- [ ] Promo codes

### Edge Cases

- [ ] No internet connection → proper error messages
- [ ] App backgrounded during trip → location updates resume
- [ ] Permission denied (location, camera) → graceful handling
- [ ] Back navigation from every screen
- [ ] RTL text rendering (Arabic names/content)

### Bug Reporting

When reporting issues, include:
1. **Device** (model + Android/iOS version)
2. **Steps to reproduce** (numbered)
3. **Expected vs actual behavior**
4. **Screenshot or screen recording**

Send reports to: _[add your preferred channel: GitHub Issues, WhatsApp group, email]_

---

## Build Information

| Property | Value |
|----------|-------|
| App ID (Android) | `com.khawi.app.khawi_app` |
| Bundle ID (iOS) | `com.khawi.app.khawiApp` |
| Version | 0.1.0+1 |
| Flutter | 3.27.3 |
| Min Android SDK | 24 (Android 7.0) |
| Backend | Supabase (cloud) |
| Signing | Release-signed APK |
| R8/ProGuard | Enabled (minified + shrunk) |
| Unit tests | 518 passing |
| Analysis | 0 issues |

---

## Next Steps After Alpha

1. **Collect feedback** from testers (2-4 weeks)
2. **Fix critical bugs** found during testing
3. **Set up Apple Developer Account** for iOS TestFlight
4. **Google Play Console** — create app listing for internal testing track
5. **Version bump** to `0.2.0` for beta with fixes applied
6. **Firebase Crashlytics** — add crash reporting for production monitoring
