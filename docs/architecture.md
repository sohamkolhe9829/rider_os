# Architecture

RiderOS employs a strictly decoupled, **Feature-First Architecture** combined with **Riverpod** for robust state management and Dependency Injection (DI).

## Folder Structure (Feature-First)
Unlike layer-first architectures (which group all UI together, all Data together), we group files by feature to maximize cohesion and scalability.

```
lib/
  core/
    constants/
    services/       # Global services like Location, Compass
    theme/
    widgets/        # Shared global widgets
  features/
    fuel/
      presentation/ # UI, Providers, ViewModels
      domain/       # Entities, abstract repositories
      data/         # API, local storage (Hive), repository impl
    maintenance/
    ride_console/
```

## State Management (Riverpod)
Riverpod is the sole state management solution.
- **Dependency Injection**: Services (like `LocationService`) are injected via Providers. We strictly prohibit the use of singletons (`MyClass._instance`) to ensure mockability during testing.
- **Immutability**: State models must be immutable. We prefer Dart 3 records or freezed for complex states.
- **Scoping**: Providers are kept as narrowly scoped as possible to prevent unnecessary rebuilds.

## Local Storage (Hive)
To support the "Offline First" mandate (motorcycles frequently enter cellular dead-zones), RiderOS relies on Hive.
- All domain entities have corresponding Hive TypeAdapters.
- Adapters are generated locally via `build_runner` and checked into source control to reduce CI build times.

## Hardware Integration
- Native sensors (GPS, Compass) run as background services wrapped in Dart Streams.
- The `RideConsoleRepository` aggressively caches and smooths this data using Exponential Moving Averages (EMA) to prevent UI jitter while riding.
