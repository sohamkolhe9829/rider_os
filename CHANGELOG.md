# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0+1] - 2026-07-25

### Added
- Complete initial architecture and feature set for RiderOS.
- Ride console telemetry (GPS, altitude, compass, speed).
- Fuel management and tracking features.
- Maintenance logs and service tracking.
- Local storage implementation using Hive.
- Enterprise-grade CI/CD pipelines via GitHub Actions.
- Premium open-source documentation suite.

### Changed
- Refactored project structure to feature-first architecture.

### Fixed
- Fixed delay in initial GPS and altitude readings via fast-start location service.
- Fixed missing compassServiceProvider import in settings screen.
- Resolved various UI overflow and alignment issues in the Ride Console.

### Improved
- CI/CD workflow optimized for Flutter 3.44.0 and Java 21.
- Semantic Versioning enforcement added to release pipelines.
