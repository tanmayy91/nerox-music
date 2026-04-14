# Contributing to Nerox Music

Thank you for your interest in contributing to Nerox Music! This guide will help you get started.

---

## Code of Conduct

Be respectful and constructive. We welcome contributors of all experience levels.

---

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/tanmayy91/Harmony-Music/issues) first
2. Use a clear, descriptive title
3. Include steps to reproduce the issue
4. Specify your device, OS version, and app version
5. Attach screenshots or logs if possible

### Suggesting Features

Open an issue with the **Feature Request** label. Describe:
- What problem does this solve?
- How should it work?
- Any design ideas or references?

### Submitting Code

1. **Fork** the repository
2. **Create a branch** from `main`: `git checkout -b feature/your-feature`
3. **Make your changes** following the coding guidelines below
4. **Test** your changes on at least one platform
5. **Commit** with clear messages: `git commit -m "feat: add sleep timer improvements"`
6. **Push** and open a **Pull Request**

---

## Development Setup

### Prerequisites
- Flutter SDK 3.24.2+
- Dart SDK >= 3.1.5
- Android Studio or VS Code with Flutter extensions
- JDK 17 (for Android builds)

### Getting Started

```bash
# Clone the repository
git clone https://github.com/tanmayy91/Harmony-Music.git
cd Harmony-Music

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Run linter
flutter analyze

# Build APK
flutter build apk --release
```

---

## Coding Guidelines

### Dart/Flutter Style
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` rules (pre-configured in `analysis_options.yaml`)
- Run `flutter analyze` before submitting PRs

### State Management
- Use **GetX** controllers for all state management
- Initialize controllers with `Get.lazyPut()` in `main.dart`
- Access controllers with `Get.find<ControllerType>()`
- Use `Obx()` widgets for reactive UI updates

### File Organization
- Keep screen + controller files together in screen folders
- Place reusable widgets in `lib/ui/widgets/`
- Business logic goes in `lib/services/`
- Data models in `lib/models/`

### Platform Considerations
- Test on Android, Windows, and Linux when possible
- Use `GetPlatform.isAndroid`, `GetPlatform.isDesktop` for platform checks
- Android uses `just_audio`, Desktop uses `media_kit`

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `camelCase`

---

## Translation

Nerox Music supports 40+ languages via Weblate.

To contribute translations:
1. Visit the [Weblate project](https://hosted.weblate.org/projects/harmony-music/project-translations/)
2. Select your language
3. Translate missing strings

Translation keys are defined in `lib/utils/get_localization.dart` and individual `localization/*.json` files.

---

## License

By contributing, you agree that your contributions will be licensed under the [GPL v3.0](../LICENSE).

---

## Credits

Nerox Music is created by **tanmay** ([@tanmaaahy](https://instagram.com/tanmaaahy)).
