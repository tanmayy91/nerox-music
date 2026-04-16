# Build Instructions

## Nerox Music — Build Guide

---

## Prerequisites

| Tool | Version | Required For |
|------|---------|-------------|
| Flutter SDK | 3.24.2+ | All platforms |
| Dart SDK | >= 3.1.5 | All platforms |
| JDK | 17 | Android |
| Android SDK | Latest | Android |
| Visual Studio 2022 | With C++ workload | Windows |
| GCC/Clang | Latest | Linux |
| GTK 3 | Development headers | Linux |

---

## Setup

### 1. Install Flutter

Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).

### 2. Install Dependencies

```bash
cd nerox-music
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
flutter analyze
```

### 4. Google Sign-In credentials (Android only)

Google Sign-In requires a `google-services.json` file that is **not** committed to the repository (it contains OAuth secrets).

→ Follow the **[Google Sign-In Setup guide](GOOGLE_SIGNIN_SETUP.md)** to create your credentials and place the file at `android/app/google-services.json` before building for Android.

---

## Build for Android

### Debug Build
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

---

## Build for Windows

### Debug Build
```bash
flutter run -d windows
```

### Release Build
```bash
flutter build windows --release
```

Output: `build/windows/x64/runner/Release/`

### Creating Installer

The project includes InnoSetup configuration at `windows/packaging/exe/inno_setup.iss`. Use [InnoSetup](https://jrsoftware.org/isinfo.php) to create a Windows installer.

---

## Build for Linux

### Prerequisites (Ubuntu/Debian)
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libmpv-dev
```

### Debug Build
```bash
flutter run -d linux
```

### Release Build
```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

---

## CI/CD

Nerox Music uses GitHub Actions for automated builds:

| Workflow | File | Trigger |
|----------|------|---------|
| Build & Release APK | `build_release.yml` | Push to main, tags, PRs |
| Code Quality | `code_quality.yml` | PRs |
| Windows Build | `win_exe.yml` | Manual dispatch |
| GitHub Pages | `pages.yml` | Push to main |

### APK Artifacts

Every push to `main` builds a release APK and uploads it as a GitHub Actions artifact named `nerox-music-apk`.

### Creating a Release

1. Tag the commit: `git tag v4.0.0`
2. Push the tag: `git push origin v4.0.0`
3. The workflow automatically creates a GitHub Release with the APK attached.

---

## Troubleshooting

### Common Issues

**Flutter pub get fails:**
Some dependencies use custom Git forks. Ensure you have network access to GitHub.

**Android build fails with `google-services.json not found`:**
Google Sign-In requires a `google-services.json` credential file that is not committed to the repository.
Follow the [Google Sign-In Setup guide](GOOGLE_SIGNIN_SETUP.md) to create one.

**Android build fails with JDK error:**
Ensure JDK 17 is installed and `JAVA_HOME` is set correctly.

**Linux build fails with missing libraries:**
Install the required GTK and MPV development packages listed above.

**Windows build fails:**
Ensure Visual Studio 2022 is installed with the "Desktop development with C++" workload.
