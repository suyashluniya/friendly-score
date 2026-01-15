<div align="center">

# Friendly Score

Professional equestrian timing application for show jumping and mounted sports events. Real-time timing system with Bluetooth connectivity to ESP32 hardware, comprehensive race management, and performance analytics.

**Version 2.0.7**

</div>

---

## ✨ Features

### Core Functionality
- **PIN-Protected Access** – Secure login with customizable 4-digit PIN and master reset
- **Event Location Management** – Configure and save event venues with location details
- **Dual Sport Modes** – Show Jumping and Mounted Sports timing
- **Real-Time Bluetooth Timing** – Connect to ESP32 hardware for precise race timing
- **Race Management** – Active race monitoring with countdown, pause/resume, and results
- **Comprehensive Reporting** – Race history, analytics, and performance reports

### Hardware Integration
- Bluetooth connectivity to ESP32 timing devices
- Binary protocol for command transmission
- Real-time race data streaming
- Automatic device discovery and pairing

### User Experience
- Material 3 design with modern UI
- Animated transitions and haptic feedback
- PDF report generation with rider photos
- Persistent data storage for race history
- Settings screen with PIN management

### Security
- PIN-based authentication with persistent storage
- Secure master reset functionality
- Production-ready logging system
- Configurable debug modes

---

## 🔧 Hardware Requirements

- **ESP32 Bluetooth Device** – Custom timing hardware for race events
- Configured with timing sensors and race detection
- Communicates via binary protocol (see `lib/utils/command_protocol.dart`)

---

## 📁 Project Structure

```
lib/
  main.dart                        # App entry, theme & routes
  screens/
    pin_login_screen.dart          # Secure PIN authentication
    event_location_screen.dart     # Event venue configuration
    mode_selection_screen.dart     # Sport mode selection hub
    jumping_screen.dart            # Show jumping mode options
    mountain_sport_screen.dart     # Mounted sports timing
    bluetooth_ready_screen.dart    # Bluetooth device connection
    active_race_screen.dart        # Live race monitoring
    race_results_screen.dart       # Race completion & results
    reporting_screen.dart          # Historical race data
    settings_screen.dart           # App configuration & PIN management
    change_pin_screen.dart         # PIN modification flow
    forgot_pin_screen.dart         # Master reset functionality
  services/
    bluetooth_service.dart         # ESP32 Bluetooth communication
    location_service.dart          # Event location persistence
    mode_service.dart              # Sport mode state management
    unified_race_data_service.dart # Race data storage & retrieval
    pin_service.dart               # PIN authentication service
  utils/
    command_protocol.dart          # Binary protocol definitions
    logger.dart                    # Production logging utility
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Android Studio / Xcode for mobile development
- ESP32 timing hardware (for full functionality)

Check Flutter installation:
```sh
flutter --version
flutter doctor
```

### Installation

1. **Clone the repository**
```sh
git clone <repository-url>
cd friendly-score
```

2. **Install dependencies**
```sh
flutter pub get
```

3. **Configure assets**
- Place app icon: `assets/icons/app_icon.png` (1024x1024px)
- Place splash image: `assets/images/splash_horse.png`

4. **Generate icons and splash screens**
```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

5. **Run the application**
```sh
flutter run -d <device>
```

---

## 🔐 Default Credentials

**Default PIN:** `0000`  
**Master Reset Phrase:** `masterreset` (case-insensitive)

Users should change the default PIN immediately via Settings → Change PIN.

---

## 📱 Platform Support

- ✅ **Android** – Fully supported (MinSDK 24, Android 7.0+)
- ✅ **iOS** – Fully supported (iOS 12.0+)
- ⚠️ **Web/Desktop** – Limited (Bluetooth not supported)

---

## 🧪 Testing

Run all tests:
```sh
flutter test
```

Run specific test:
```sh
flutter test test/mode_selection_test.dart
```

---

## 📦 Production Builds

### Android
```sh
# APK (for distribution)
flutter build apk --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS
```sh
# Requires macOS with Xcode
flutter build ios --release

# Build IPA
flutter build ipa --release
```

### Version Management
Version is defined in `pubspec.yaml`:
```yaml
version: 2.0.7+7  # format: major.minor.patch+buildNumber
```

---

## 🛠 Development

### Code Quality
```sh
# Run static analysis
flutter analyze

# Format code
dart format .
```

### Logging
The app uses a centralized Logger utility (`lib/utils/logger.dart`):
- Automatically disabled in release builds
- Supports debug, info, warning, and error levels
- Integrated with Flutter DevTools

### Linting Rules
Production-ready linting enabled in `analysis_options.yaml`:
- `avoid_print: true` – Enforces Logger usage
- `prefer_single_quotes: true`
- `prefer_const_constructors: true`

---

## 🏗 Architecture

- **State Management** – StatefulWidgets with `setState` for screen-level state
- **Data Persistence** – SharedPreferences for lightweight storage
- **Hardware Communication** – Custom Bluetooth service with binary protocol
- **Navigation** – Named routes in MaterialApp
- **Theming** – Material 3 with custom color scheme

---

## 📖 Documentation

- **User Guide:** See `USER_GUIDE.md` for detailed usage instructions
- **Protocol Spec:** See `lib/utils/command_protocol.dart` for hardware communication
- **Timing System:** See `Timing System.pdf` for hardware specifications

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/feature-name`)
3. Commit changes (`git commit -m 'Add feature'`)
4. Run tests and analyzer (`flutter test && flutter analyze`)
5. Push to branch (`git push origin feat/feature-name`)
6. Open a Pull Request

---

## 📄 License

Proprietary - All rights reserved. Not for public distribution without authorization.

---

## 🏆 Credits

**Made with love by Rysing Hope ❤️**

---

## 📬 Support

For questions, issues, or feature requests, please open an issue in the repository.

---

**Current Version:** 2.0.7  
**Last Updated:** January 15, 2026
