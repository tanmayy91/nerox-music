# Google Sign-In Setup Guide

This guide walks you through the one-time configuration needed to enable Google Sign-In in Nerox Music on Android.

> **Desktop / Linux / Windows**: Google Sign-In currently targets Android only. The UI card is rendered everywhere, but the actual OAuth flow only works on Android.

---

## Overview

| Step | What you do |
|------|-------------|
| 1 | Create a Firebase project (or use Google Cloud Console) |
| 2 | Register your Android app and add the SHA-1 fingerprint |
| 3 | Enable Google Sign-In as an auth provider |
| 4 | Download `google-services.json` and place it in the project |
| 5 | Verify the Gradle wiring (already done in this repo) |
| 6 | Build and test |

---

## Step 1 — Create a Firebase Project

1. Open [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project**.
3. Give it any name (e.g. `nerox-music`).
4. You can disable Google Analytics for this project if you prefer.
5. Click **Create project** and wait for provisioning.

> **Alternative — Google Cloud Console only**
> If you prefer not to use Firebase, follow the [Google Cloud Console path](#appendix-google-cloud-console-only) at the bottom of this guide.

---

## Step 2 — Add an Android App to the Project

1. In the Firebase project overview, click the **Android** icon ( `</>` ) or **Add app → Android**.
2. Fill in the details:

   | Field | Value |
   |-------|-------|
   | Android package name | `com.anandnet.harmonymusic` |
   | App nickname | Nerox Music *(optional)* |
   | Debug signing certificate SHA-1 | *(see below)* |

3. **Get your debug SHA-1 fingerprint**:

   ```bash
   # On macOS / Linux
   keytool -list -v \
     -keystore ~/.android/debug.keystore \
     -alias androiddebugkey \
     -storepass android \
     -keypass android

   # On Windows (Command Prompt)
   keytool -list -v ^
     -keystore %USERPROFILE%\.android\debug.keystore ^
     -alias androiddebugkey ^
     -storepass android ^
     -keypass android
   ```

   Copy the **SHA1** value and paste it into the Firebase form.

   > For a **release** build you must also register the release key's SHA-1. Generate a release keystore with `keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release` and get its SHA-1 the same way.

4. Click **Register app**.

---

## Step 3 — Enable Google Sign-In

1. In the Firebase Console sidebar go to **Build → Authentication**.
2. Click **Get started** (first time only).
3. Under the **Sign-in method** tab, find **Google** and click it.
4. Toggle the **Enable** switch to on.
5. Choose a **Project support email** (your Google account email is fine).
6. Click **Save**.

---

## Step 4 — Download and Place `google-services.json`

1. Back in **Project settings** (gear icon ⚙ → Project settings → Your apps), click **Download google-services.json**.
2. Place the file here inside your local clone:

   ```
   android/app/google-services.json
   ```

   A template showing the expected structure is provided at `android/app/google-services.json.template`.

3. **Do not commit this file.** It is already listed in `.gitignore`.

   ```
   android/app/google-services.json   ← gitignored ✓
   android/app/google-services.json.template  ← committed as reference ✓
   ```

---

## Step 5 — Gradle Wiring (already done)

The repository already has the Google Services plugin wired in:

**`android/settings.gradle`** — plugin declared:
```groovy
id "com.google.gms.google-services" version "4.4.2" apply false
```

**`android/app/build.gradle`** — plugin applied:
```groovy
id "com.google.gms.google-services"
```

No further Gradle changes are needed.

---

## Step 6 — Build and Test

```bash
# Install dependencies
flutter pub get

# Run on a connected Android device or emulator
flutter run

# Or build a debug APK
flutter build apk --debug
```

On first launch, open **Settings** — you should see the Google Sign-In card at the top. Tap **Sign in** and complete the OAuth flow.

---

## Troubleshooting

### `google-services.json not found` build error

Ensure the file is placed at exactly `android/app/google-services.json` (not inside a subdirectory).

### `ApiException: 10` / `DEVELOPER_ERROR`

This means the SHA-1 fingerprint registered in Firebase does not match the keystore used to sign the APK.

- **Debug builds**: register the debug keystore SHA-1 (see Step 2).
- **Release builds**: register the release keystore SHA-1.
- You can add multiple SHA-1 fingerprints to the same Firebase app.

### `ApiException: 12500` / sign-in dialog appears then immediately fails

Google Play Services may be outdated on the emulator. Use a physical device or update Google Play Services in the emulator.

### Sign-In button shows a loading spinner indefinitely

Check `adb logcat` for `Google Sign-In error` messages. Ensure the device has internet access and the `INTERNET` permission is present in `AndroidManifest.xml` (it is already there).

### Auth works on debug but not release

Add your **release** SHA-1 to the Firebase Console (Project settings → Your apps → Add fingerprint) and re-download `google-services.json`.

---

## Appendix — Google Cloud Console Only

If you prefer not to use Firebase at all, you can create OAuth 2.0 credentials directly in Google Cloud Console:

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project.
3. Go to **APIs & Services → Credentials → Create credentials → OAuth client ID**.
4. Select **Android** as the application type.
5. Enter package name `com.anandnet.harmonymusic` and your SHA-1.
6. Create a second credential of type **Web application** — `google_sign_in` requires this to get a `serverClientId`.
7. Construct `google-services.json` manually using the template at `android/app/google-services.json.template`, filling in the project number, client IDs, and API key from the Cloud Console.
