<div align="center">

# Timing / Mode Selection Demo

Lightweight Flutter application showcasing a polished Mode Selection flow (Jumping + Mounted Sports) with animated cards, nested option screens, themed typography (Google Fonts) and basic widget tests. Serves as a starter / reference for adding additional sport timing modes.

</div>

---

## ✨ Features

Core
- Mode Selection landing screen (animated with `flutter_animate`)
- Two primary modes: Show Jumping & Mounted (Mountain) Sports
- Nested Jumping options: Top Score & Normal modes
- Consistent theming & typography via `GoogleFonts.poppinsTextTheme`

UI / UX
- Material 3 theme configuration (light scheme, custom buttons & cards)
- Hero wrappers on mode cards (ready for future detailed transitions)
- Responsive safe-area layout & accessible large tap targets

Code & Tooling
- Centralized route table in `main.dart`
- Widget test example (mode selection navigation)
- Lints enabled via `flutter_lints`

---

## 📁 Project Structure (Selected)

```
lib/
  main.dart                      # App entry, theme & routes
  screens/
    mode_selection_screen.dart   # Landing mode picker
    jumping_screen.dart          # Secondary menu for jumping options
    top_score_screen.dart        # (Placeholder) Top score jumping mode
    normal_jumping_screen.dart   # (Placeholder) Normal jumping mode
    mountain_sport_screen.dart   # (Placeholder) Mounted sport mode


---

## 🧭 Routes

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | `ModeSelectionScreen` | Choose main sport mode |
| `/jumping` | `JumpingScreen` | Jumping sub-mode menu |
| `/jumping/top` | `TopScoreJumpingScreen` | Placeholder next screen |
| `/jumping/normal` | `NormalJumpingScreen` | Placeholder next screen |
| `/mountain` | `MountainSportScreen` | Placeholder mounted sport mode |

These are registered in `MaterialApp.routes` inside `main.dart`.

---

## 🛠 Dependencies

Runtime:
- `flutter` (Material 3)
- `google_fonts` – custom Poppins font styling
- `flutter_animate` – entrance animations for screen widgets

Dev / Test:
- `flutter_test`
- `flutter_lints`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed (matching Dart SDK constraint `^3.9.2`)
- Device, emulator, or Chrome (for web)

Check versions:
```sh
flutter --version
```

### Install Packages
```sh
flutter pub get
```

### Run (choose one target)
```sh
flutter run                      # Auto pick device
flutter run -d chrome            # Web
flutter run -d windows           # Windows desktop (if enabled)
flutter run -d macos             # macOS (if enabled)
flutter run -d android           # Android emulator / device
```

---

## 🧪 Testing
Run all tests:
```sh
flutter test
```

Focus a single test file:
```sh
flutter test test/mode_selection_test.dart
```

---

## 📦 Building

Common build outputs:
```sh
flutter build apk            # Android (release)
flutter build appbundle      # Android Play Store
flutter build ios            # iOS (requires Xcode setup)
flutter build web            # Web (builds to build/web)
flutter build windows        # Windows desktop
```

Specify versioning (override `pubspec.yaml`):
```sh
flutter build apk --build-name 1.0.1 --build-number 2
```

---

## 🧩 Architecture Notes
Currently the project is intentionally simple:
- Stateless screens with direct `Navigator.pushNamed` routing
- Theming centralized in `MyApp` (could be extracted later)
- Placeholder / future expansion screens kept minimal

Potential next steps:
1. Introduce state management (Provider / Riverpod / BLoC) when dynamic data arrives
2. Add route generation + deep links
3. Replace placeholder screens with real timing / scoring logic
4. Implement animations between Hero-tagged cards & detail screens
5. Add golden tests and screenshot testing for visual regression

---

## 🧹 Code Quality
Static analysis:
```sh
flutter analyze
```
Format code:
```sh
dart format .
```

---

## 🤝 Contributing
1. Fork & branch (`feat/your-feature`)
2. Run tests & analyzer before opening a PR
3. Provide screenshots / screen recordings for UI changes

---

## 📄 License
Currently unspecified. Add a `LICENSE` file if distributing.

---

## 📬 Contact / Notes
Questions or ideas? Open an issue or start a discussion. This README reflects the structure as of the current commit and Flutter SDK constraint `^3.9.2`.

---

Happy building! 🛠
