<div align="center">

# RiderOS

**Production-Grade Motorcycle Ride Companion**

![Flutter Version](https://img.shields.io/badge/Flutter-3.44.0-02569B?logo=flutter)
![Dart SDK](https://img.shields.io/badge/Dart-3.12.0-0175C2?logo=dart)
![Android](https://img.shields.io/badge/Platform-Android%2021%2B-3DDC84?logo=android)
![Android Auto](https://img.shields.io/badge/Android_Auto-Supported-3DDC84?logo=android)
![CI Status](https://github.com/sohamkolhe9829/rider_os/actions/workflows/flutter_ci.yml/badge.svg)
![Latest Release](https://img.shields.io/github/v/release/sohamkolhe9829/rider_os)
![Downloads](https://img.shields.io/github/downloads/sohamkolhe9829/rider_os/total)
![Open Issues](https://img.shields.io/github/issues/sohamkolhe9829/rider_os)
![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

[Project Description](#-project-description) • [Features](#-feature-showcase) • [Installation](#-installation) • [Build Instructions](#-build-instructions) • [Android Auto](#-android-auto-support) • [Contributing](#-contributing)

</div>

---

## 🌟 Project Description

**RiderOS** is a premium, enterprise-quality open-source motorcycle dashboard and ride companion built with Flutter. Designed for extreme stability and a breathtaking UI, it tracks your rides, manages fuel consumption, handles maintenance logs, and projects directly onto your motorcycle's native display via **Android Auto**.

## 🚀 Feature Showcase

- **Ride Tracking & Telemetry**: Real-time GPS, speed, altitude, and compass direction.
- **Fuel Management**: Log fill-ups, track fuel efficiency, and monitor tank capacity.
- **Maintenance Garage**: Keep track of engine oil, brake pads, chain lube, and service logs.
- **Offline First**: Fully functional without cellular coverage via local Hive storage.
- **Crash Detection & SOS**: Automated safety alerts based on telemetry anomalies.

## 📸 Screenshots

*(Screenshots coming soon)*

## 📐 Architecture Diagram

RiderOS follows a strict Feature-First architecture driven by Riverpod.

See the full [Architecture Documentation](docs/architecture.md) for deeper insights.

## 📂 Folder Structure

```text
rider_os/
├── android/          # Android native code (including Auto support)
├── ios/              # iOS native code
├── lib/
│   ├── core/         # Shared utilities, services, theme, and constants
│   ├── features/     # Feature modules (Fuel, Maintenance, Ride Console, Settings)
│   └── main.dart     # Entry point
├── docs/             # Technical documentation
├── .github/          # CI/CD and repository configurations
└── .ai/              # Local AI Memory System
```

## 🛠 Technology Stack

- **Framework**: [Flutter 3.44.0](https://flutter.dev/)
- **Language**: [Dart 3.12.0](https://dart.dev/)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Local Storage**: Hive (`hive`, `hive_flutter`)
- **Routing**: GoRouter (`go_router`)
- **Location & Sensors**: `geolocator`, `sensors_plus`, `flutter_compass`

## 💻 Installation

To run this project locally, ensure you have the correct SDK versions installed.

### Prerequisites

- **Flutter SDK**: `3.44.0`
- **Java**: Temurin JDK 21
- **Android Studio** (or VS Code)

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sohamkolhe9829/rider_os.git
   cd rider_os
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code (Hive Adapters)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🏗 Build Instructions

To build a release APK or App Bundle:

**APK**:
```bash
flutter build apk --release
```

**App Bundle (AAB)**:
```bash
flutter build appbundle --release
```

## 🚗 Android Auto Support

RiderOS natively supports Android Auto. When connected to a compatible motorcycle dashboard, RiderOS projects a specialized, distraction-free UI.
See the [Android Auto Guide](docs/android_auto.md) for testing and development details.

## 🗺 Roadmap

- [ ] Complete Android Auto integration testing
- [ ] iOS CarPlay support investigation
- [ ] Cloud Sync / User Accounts
- [ ] Google Play Store Alpha Release
- [ ] Community Themes

## 🤝 Contributing

We welcome contributions! RiderOS follows a strict `main` and `dev` branch strategy.
Please see our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) before submitting Pull Requests.

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## ❓ FAQ

**Q: Does it work offline?**
A: Yes! All rides are stored locally via Hive and do not require an active internet connection.

**Q: Can I use it on a car?**
A: While designed for motorcycles, the core telemetry works perfectly fine in any vehicle.

## 🎧 Support

If you encounter issues, please open an issue using our [GitHub Templates](.github/ISSUE_TEMPLATE/). For security vulnerabilities, please refer to [SECURITY.md](SECURITY.md).

## 👨‍💻 Developer Information

Developed and maintained by the RiderOS Community.
Primary Contact: [@sohamkolhe9829](https://github.com/sohamkolhe9829)
