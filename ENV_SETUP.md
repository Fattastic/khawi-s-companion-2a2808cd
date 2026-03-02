# Khawi Environment Setup

This guide covers the complete environment configuration for developing and running the Khawi carpooling application.

---

## Prerequisites

Before setting up the environment, ensure you have:

- **Flutter SDK** 3.x or later
- **Dart SDK** 3.x or later
- **Supabase CLI** (for local development)
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **Node.js** 18+ (for tooling scripts)

---

## Environment Variables

The Khawi app requires the following environment variables passed via `--dart-define`:

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key | Yes |
| `SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID` | Google OAuth client ID | Yes |
| `ENABLE_QA_CONSOLE` | Enable QA debugging console | No (debug only) |
| `QA_NAV_OVERLAY` | Enable navigation overlay | No (debug only) |

---

## Running the App

### Option 1: VS Code Launch (Recommended)

Use the pre-configured **"Khawi (Debug)"** configuration:

1. Open VS Code
2. Press `F5` or go to Run → Start Debugging
3. Select "Khawi (Debug)" from the launch configuration dropdown

The launch configuration is defined in `.vscode/launch.json` with all required environment variables.

### Option 2: PowerShell Script (Windows)

```powershell
.\run_app.ps1
```

This script automatically loads all environment variables and runs the app.

### Option 3: Command Line

For manual execution with all required variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=your-google-client-id
```

### Option 4: With QA Console Enabled

For debugging and testing:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=your-google-client-id \
  --dart-define=ENABLE_QA_CONSOLE=true \
  --dart-define=QA_NAV_OVERLAY=true
```

---

## Local Supabase Development

### Starting Local Supabase

```powershell
# Start Supabase with Google OAuth configured
.\tools\start_local_supabase_with_google.ps1
```

Or manually:

```bash
supabase start
```

### Seeding Test Data

```bash
# Seed local users for testing
node tools/seed_local_users.mjs
```

Or use the SQL seeds:

```bash
# Apply staging seeds
psql -f supabase/seeds/staging_seeds.sql

# Reset staging data
psql -f supabase/seeds/staging_reset.sql
```

### Running Edge Functions Locally

```bash
supabase functions serve
```

---

## Platform-Specific Setup

### Android (OAuth)

1. Ensure Android SDK is installed via Android Studio
2. Configure `android/local.properties`:
   ```properties
   sdk.dir=/path/to/android/sdk
   flutter.sdk=/path/to/flutter
   ```
3. For release builds, configure `android/key.properties` with signing keys

### iOS (OAuth)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing & capabilities with your Apple Developer account
3. Run `pod install` in the `ios/` directory:
   ```bash
   cd ios && pod install
   ```

### Web (OAuth)

```bash
flutter run -d chrome
```

---

## Google OAuth Configuration

### Android

1. Add your SHA-1 key to the Google Cloud Console
2. Download `google-services.json` to `android/app/`

### iOS

1. Configure URL schemes in `ios/Runner/Info.plist`
2. Add your reversed client ID

### Web

1. Add authorized JavaScript origins to Google Cloud Console
2. Add authorized redirect URIs

---

## Troubleshooting

### Common Issues

**"Supabase URL not configured"**
- Ensure `SUPABASE_URL` is passed via `--dart-define`
- Check `.vscode/launch.json` configuration

**Google Sign-In not working**
- Verify Google OAuth client ID is correct
- Check SHA-1 fingerprint is added to Google Cloud Console
- Ensure redirect URIs are configured

**Edge Functions failing**
- Run `supabase functions serve` for local testing
- Check Supabase dashboard logs for deployed functions

**Hot reload not working**
- Ensure you're running in debug mode
- Try `flutter clean && flutter pub get`

---

## Environment Files Reference

| File | Purpose |
|------|---------|
| `.vscode/launch.json` | VS Code debug configurations |
| `android/local.properties` | Android SDK paths |
| `android/key.properties` | Android signing configuration |
| `supabase/config.toml` | Supabase local configuration |
| `run_app.ps1` | Windows run script with env vars |

---

## Support

For setup issues, consult the [Supabase documentation](https://supabase.com/docs) or the [Flutter documentation](https://docs.flutter.dev).
