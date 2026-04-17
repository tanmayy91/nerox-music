# Distribution Guide

This document explains how to complete the submission of Nerox Music to each distribution channel.

---

## ✅ GitHub Releases (Live)

Already automated. Every push to a `v*` tag triggers `build_release.yml` which:
- Builds the signed APK
- Creates a GitHub Release with the APK attached

**Action needed**: Push a version tag:
```bash
git tag v4.0.0
git push origin v4.0.0
```

---

## ✅ Obtainium (Live)

Already working. Users tap:
```
obtainium://add/https://github.com/tanmayy91/nerox-music
```
or add the GitHub URL manually in Obtainium.

---

## ✅ Self-Hosted F-Droid Repository (Live after setup)

The `fdroid-repo.yml` workflow auto-generates and deploys the F-Droid repository index to:

```
https://tanmayy91.github.io/nerox-music/fdroid/repo
```

### One-Time Setup

1. **Generate the keystore** — run the `Build F-Droid Repository` workflow manually once (without the secret set). It will print the base64-encoded keystore in the logs.

2. **Save secrets** — go to **GitHub → Settings → Secrets → Actions** and add:
   - `FDROID_KEYSTORE_B64` — the base64 string from step 1
   - `FDROID_KEYSTORE_PASS` — the password (default `neroxfdr0id`)

3. **Re-run the workflow** — now it will use the stored keystore (consistent fingerprint).

4. **Tell users** to add in F-Droid:
   - Open F-Droid → Settings → Repositories → **+**
   - Paste: `https://tanmayy91.github.io/nerox-music/fdroid/repo`

---

## 🔄 IzzyOnDroid (Pending submission)

IzzyOnDroid is an F-Droid-compatible repository that lists open-source Android apps.
The app's fastlane metadata is already in `fastlane/metadata/android/`.

### How to submit

1. Go to **https://github.com/IzzyOnDroid/repo/issues**
2. Click **New Issue** → choose **App submission**
3. Fill in:
   - **App name**: Nerox Music
   - **Package name**: `com.nrxstudios.neroxmusic`
   - **GitHub URL**: `https://github.com/tanmayy91/nerox-music`
   - **License**: GPL-3.0-only
   - **Category**: Multimedia
4. Submit the issue.

IzzyOnDroid reads the fastlane metadata directly from the repo after approval.

---

## 🔄 Official F-Droid (Pending submission)

Official F-Droid requires a pull request to the [fdroiddata](https://gitlab.com/fdroid/fdroiddata) repository.
The metadata file is ready at `docs/fdroid-metadata.yml`.

### How to submit

1. **Fork** `https://gitlab.com/fdroid/fdroiddata`
2. Copy `docs/fdroid-metadata.yml` into `metadata/com.nrxstudios.neroxmusic.yml` in your fork
3. Open a **Merge Request** with:
   - Title: `New app: Nerox Music (com.nrxstudios.neroxmusic)`
   - Description: brief description of the app
4. The F-Droid team will review and build the app on their build server.

> **Note**: F-Droid builds apps from source — they will clone this repo and run `flutter build apk`. Make sure the build succeeds cleanly.

---

## Package Information

| Field | Value |
|-------|-------|
| **Package ID** | `com.nrxstudios.neroxmusic` |
| **License** | GPL-3.0-only |
| **Source** | https://github.com/tanmayy91/nerox-music |
| **Category** | Multimedia |
| **Min SDK** | 21 (Android 5.0) |
| **Version** | 4.0.0 (code 30) |
