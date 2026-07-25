# RiderOS — Master Prompt 1 (Complete Vision & Architecture)

## Vision & Philosophy
Build **RiderOS**, a production-grade Flutter motorcycle companion application built specifically for Android Auto users. 
Philosophy: One ride. One dashboard. Everything calculated. No AI. No unnecessary complexity.

### Strict Anti-Goals (What this is NOT)
- NOT a navigation app (Google Maps handles routing).
- NO AI predictions or recommendations (except explicitly defined calculations).
- NO Google Maps SDK, Mapbox, or route calculation.
- NOT a SaaS dashboard or web app.

## Tech Stack & Architecture
- **Framework:** Flutter (Mobile UI) & Native Kotlin (Android Car App Library bridge).
- **State Management:** Provider.
- **Database:** Hive (Local-first, completely offline).
- **Sensors:** Geolocator, Sensors Plus, Flutter Compass.
- **System:** Permission Handler, Connectivity Plus.
- **Background Execution:** MUST implement a Foreground Service (Native Android or `flutter_background_service`) to ensure GPS and sensor tracking survive when the screen is off or when Google Maps is in the foreground.
- **Architecture Standard:** Strict **Clean Architecture**. The app must be scalable and decoupled into `presentation`, `domain`, and `data` layers.

## Global Theming & UI Principles
**1. Dynamic Time-Based Theme (Globalized)**
The app must automatically switch themes based on the device clock (time of day).
- **Day Mode (e.g., 06:00 to 17:59):** Pure White background, Solid Black typography.
- **Night Mode (e.g., 18:00 to 05:59):** Pure Black background (#000000), Solid White typography, Grey secondary text.
- **Accent Colors (Strictly for status only):** Green = Active/Good, Orange = Warning, Red = Emergency.
- No gradients, no glassmorphism, no decorative animations. Treat the UI as a high-contrast, embedded Motorcycle HMI (Human-Machine Interface).

**2. Display & Responsiveness**
- Landscape only for mobile.
- Preferred resolution: 2340×1080 (19.5:9 aspect ratio).
- Responsive across: 1280×720, 1600×720, 1920×1080, and Landscape tablets.
- Highly reusable widgets with no hardcoded dimensions.

## Folder Structure (Clean Architecture)
```text
lib/
 ├── core/
 │    ├── theme/ (Global time-based B&W theme logic)
 │    ├── constants/
 │    ├── utils/
 │    └── error/
 ├── features/
 │    ├── ride_session/
 │    ├── dashboard/
 │    ├── fuel_manager/
 │    ├── safety/
 │    ├── analytics/
 │    └── auto_bridge/ (MethodChannels for Android Auto)
 └── main.dart


 