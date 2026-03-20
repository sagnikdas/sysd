# Google SSO Setup Plan — SysDesign Flash

## Current State

The Dart/Flutter code for Google Sign-In is **already fully written**. Nothing in the app logic needs to change. What is missing is all the external configuration: Google Cloud Console credentials, platform-native files, and the Supabase OAuth provider setup.

| Layer | Status |
|---|---|
| `google_sign_in: ^7.2.0` in pubspec | ✅ Already added |
| `AuthService.signInWithGoogle()` | ✅ Already written |
| `AuthController` + UI button | ✅ Already wired |
| Supabase `signInWithIdToken` call | ✅ Already written |
| Google Cloud Console project | ❌ Needs setup |
| OAuth 2.0 credentials (iOS + Android) | ❌ Needs setup |
| iOS `Info.plist` URL scheme | ❌ Needs adding |
| Android SHA-1 registered | ❌ Needs registering |
| Supabase Google provider enabled | ❌ Needs enabling |
| `--dart-define` env vars at build time | ❌ Needs configuring |

---

## App identifiers (for reference throughout this guide)

- **Android package name:** `com.sagnikdas.sysd.app.sysdesign_flash`
- **iOS bundle ID:** check Xcode → Runner target → Bundle Identifier (typically `com.sagnikdas.sysd.sysdesignflash` or similar — verify in Xcode before starting)

---

## Step 1 — Google Cloud Console: Create a Project

1. Go to [https://console.cloud.google.com](https://console.cloud.google.com)
2. Click the project dropdown at the top → **New Project**
3. Name it `SysDesign Flash` → **Create**
4. Make sure this new project is selected for all remaining steps in this guide

---

## Step 2 — Enable the Google Sign-In API

1. In the Cloud Console, go to **APIs & Services → Library**
2. Search for **"Google Identity"** or **"Google Sign-In"** → Select **Google Identity Toolkit API** (also called Identity Platform)
3. Click **Enable**

---

## Step 3 — Configure the OAuth Consent Screen

This is what users see when the Google login sheet appears.

1. Go to **APIs & Services → OAuth consent screen**
2. Select **External** → **Create**
3. Fill in:
   - **App name:** `SysDesign Flash`
   - **User support email:** `sagnikd91@gmail.com`
   - **Developer contact email:** `sagnikd91@gmail.com`
4. Click **Save and Continue**
5. On the **Scopes** page → click **Save and Continue** (no extra scopes needed — email and profile are included by default)
6. On the **Test users** page → add `sagnikd91@gmail.com` so you can test before publishing
7. Click **Save and Continue** → **Back to Dashboard**
8. When ready for production, click **Publish App** to make it available to all users (not just test users)

---

## Step 4 — Create OAuth 2.0 Credentials for iOS

1. Go to **APIs & Services → Credentials → Create Credentials → OAuth client ID**
2. Application type: **iOS**
3. **Bundle ID:** enter your iOS bundle ID exactly (verify in Xcode first)
4. Click **Create**
5. Copy these two values — you'll need them shortly:
   - **Client ID** — looks like `123456789-abc...apps.googleusercontent.com`
   - **Reversed client ID** — the same string reversed, e.g. `com.googleusercontent.apps.123456789-abc...`

---

## Step 5 — Create OAuth 2.0 Credentials for Android

1. Go to **APIs & Services → Credentials → Create Credentials → OAuth client ID**
2. Application type: **Android**
3. **Package name:** `com.sagnikdas.sysd.app.sysdesign_flash`
4. **SHA-1 certificate fingerprint** — get this by running:

   **Debug SHA-1** (for development):
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Look for the `debug` variant's `SHA1` line. Alternatively:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey \
     -storepass android -keypass android
   ```

   **Release SHA-1** (for production — from your upload/signing keystore):
   ```bash
   keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
   ```
   > You need to register **both** debug and release SHA-1s. Create two separate Android OAuth client IDs (one per SHA-1), or add multiple fingerprints if the console allows it.

5. Paste the SHA-1 → **Create**
6. Copy the **Client ID** for Android (you'll need it for Supabase)

> **Note:** Android does not use a client secret or need the credential file in the project — the SHA-1 fingerprint IS the verification mechanism. `google-services.json` is only required for Firebase; this project does not use Firebase so you do NOT need it.

---

## Step 6 — Configure iOS: Update Info.plist

Open `ios/Runner/Info.plist` and add the following inside the top-level `<dict>`:

```xml
<!-- Google Sign-In: client ID -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID</string>   <!-- from Step 4, e.g. 123456789-abc....apps.googleusercontent.com -->

<!-- Google Sign-In: OAuth redirect URL scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>  <!-- from Step 4, e.g. com.googleusercontent.apps.123456789-abc... -->
        </array>
    </dict>
</array>
```

Replace `YOUR_IOS_CLIENT_ID` and `YOUR_REVERSED_CLIENT_ID` with the actual values from Step 4.

> **Why the URL scheme?** After Google authenticates the user in Safari/ASWebAuthenticationSession, it redirects back to the app using this custom URL scheme. Without it, the app will hang waiting for the callback and never receive the token.

---

## Step 7 — Update AuthService to pass the iOS Client ID

The current `AuthService.signInWithGoogle()` calls `GoogleSignIn.instance.initialize()` with no arguments. On iOS, `google_sign_in` v7 reads `GIDClientID` from `Info.plist` automatically, so no code change is strictly needed if Step 6 is done correctly.

However, if you want to pass it explicitly (more robust), update `auth_service.dart`:

```dart
await googleSignIn.initialize(
  clientId: 'YOUR_IOS_CLIENT_ID',          // iOS only; ignored on Android
  serverClientId: 'YOUR_WEB_CLIENT_ID',    // needed for Supabase token verification (see Step 9)
);
```

The `serverClientId` (Web client ID from Step 9) ensures the idToken Supabase receives is audience-verified correctly.

---

## Step 8 — Configure Supabase: Enable Google as OAuth Provider

1. Go to your Supabase project dashboard → **Authentication → Providers**
2. Find **Google** → toggle it **Enabled**
3. Fill in:
   - **Client ID (for iOS):** the iOS OAuth Client ID from Step 4
   - **Client ID (for Android):** the Android OAuth Client ID from Step 5
   - **Client Secret:** leave blank — not needed for mobile `signInWithIdToken` flow
4. Under **Redirect URL** — copy the URL Supabase shows (looks like `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`)
   - You do NOT need to add this to `Info.plist`; it's only used for web OAuth flows
5. Click **Save**

---

## Step 9 — Create a Web OAuth Client ID (Required for Token Verification)

Supabase verifies the Google idToken server-side. To do this it needs a Web client ID registered with the same Google project.

1. Go to **APIs & Services → Credentials → Create Credentials → OAuth client ID**
2. Application type: **Web application**
3. Name it `SysDesign Flash Web (Supabase)`
4. Under **Authorized redirect URIs**, add the Supabase callback URL from Step 8:
   `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
5. Click **Create**
6. Copy the **Web Client ID** and **Web Client Secret**
7. Go back to Supabase → **Authentication → Providers → Google**:
   - Set **Client ID** to the **Web Client ID**
   - Set **Client Secret** to the **Web Client Secret**
8. Save

> **Why a Web client?** Google idTokens issued to mobile apps have the mobile client ID as the `aud` (audience) claim. Supabase verifies them using the Web client ID. Providing `serverClientId` (= the Web Client ID) in `initialize()` causes Google to issue a token with the Web client ID as audience instead, which Supabase can verify. This is the standard mobile → Supabase pattern.

Update `auth_service.dart` to pass `serverClientId`:

```dart
await googleSignIn.initialize(
  serverClientId: 'YOUR_WEB_CLIENT_ID',   // Web OAuth Client ID from this step
);
```

---

## Step 10 — Configure Supabase Credentials in the App

Supabase URL and anon key are passed at build time via `--dart-define`. These are already read in `lib/core/config/supabase_config.dart`.

**For local development**, create a `.env.local` file (gitignored) or pass directly:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

**For VS Code**, add to `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "SysDesign Flash (dev)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY"
      ]
    }
  ]
}
```

**For CI/CD or release builds**, pass as environment secrets in your pipeline.

Find your Supabase URL and anon key at: **Supabase Dashboard → Project Settings → API**.

---

## Step 11 — Supabase Database: Ensure RLS Policies Are Set

The sync writes to `user_profiles` and `user_progress` tables. Each table must have Row Level Security enabled so users can only read/write their own rows.

In the Supabase SQL editor, run:

```sql
-- user_profiles RLS
alter table user_profiles enable row level security;

create policy "Users can read own profile"
  on user_profiles for select
  using (auth.uid() = user_id);

create policy "Users can upsert own profile"
  on user_profiles for insert
  with check (auth.uid() = user_id);

create policy "Users can update own profile"
  on user_profiles for update
  using (auth.uid() = user_id);

-- user_progress RLS
alter table user_progress enable row level security;

create policy "Users can read own progress"
  on user_progress for select
  using (auth.uid() = user_id);

create policy "Users can upsert own progress"
  on user_progress for insert
  with check (auth.uid() = user_id);

create policy "Users can update own progress"
  on user_progress for update
  using (auth.uid() = user_id);
```

> If these tables don't exist yet, they need to be created first. Run the schema creation SQL before the RLS policies.

---

## Step 12 — Test the Flow

### iOS Simulator
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
1. Open Settings → tap "Account & Cloud Sync"
2. Tap "Continue with Google"
3. Google login sheet should appear (Safari/ASWebAuthenticationSession)
4. Sign in with `sagnikd91@gmail.com` (added as test user in Step 3)
5. Should return to app, signed in

### Android Emulator / Device
Same flow, but Google uses the native account picker (no browser).

### Common errors and fixes

| Error | Cause | Fix |
|---|---|---|
| `PlatformException(sign_in_failed)` on iOS | Missing URL scheme in Info.plist | Re-check Step 6 |
| `idToken is null` | Wrong client ID or `serverClientId` not set | Re-check Steps 7 & 9 |
| `invalid_grant` from Supabase | Web Client ID not set as `serverClientId` | Re-check Step 9 |
| `AuthApiException: provider not enabled` | Google not enabled in Supabase | Re-check Step 8 |
| `DEVELOPER_ERROR` on Android | SHA-1 not registered | Re-check Step 5 |
| Sign-in sheet never returns | Missing reversed client ID URL scheme on iOS | Re-check Step 6 |

---

## Step 13 — Release Checklist

Before submitting to App Store / Play Store:

- [ ] Publish OAuth consent screen (Step 3 — remove test user restriction)
- [ ] Add release keystore SHA-1 to Android OAuth credential (Step 5)
- [ ] Add production build's iOS client ID to Supabase if using a separate prod project
- [ ] Confirm `SUPABASE_URL` and `SUPABASE_ANON_KEY` are injected in the release build pipeline
- [ ] Verify Supabase RLS policies are active (Step 11)
- [ ] Test with a non-test Google account end-to-end on a real device

---

## Summary of Values to Collect

| Value | Where to get it | Where it goes |
|---|---|---|
| iOS OAuth Client ID | GCP Console → Credentials → iOS credential | `Info.plist GIDClientID` + Supabase Google provider |
| Reversed iOS Client ID | Reverse the iOS Client ID string | `Info.plist CFBundleURLSchemes` |
| Android OAuth Client ID | GCP Console → Credentials → Android credential | Supabase Google provider |
| Web OAuth Client ID | GCP Console → Credentials → Web credential | `AuthService serverClientId` + Supabase Client ID field |
| Web OAuth Client Secret | GCP Console → Credentials → Web credential | Supabase Client Secret field |
| Supabase Project URL | Supabase → Project Settings → API | `--dart-define=SUPABASE_URL` |
| Supabase Anon Key | Supabase → Project Settings → API | `--dart-define=SUPABASE_ANON_KEY` |
| Debug SHA-1 | `./gradlew signingReport` | GCP Android credential |
| Release SHA-1 | `keytool` on your release keystore | GCP Android credential |
