# RiderOS --- Master Prompt 1 (Foundation & V1)

## Purpose

Build **RiderOS**, a production-grade Flutter motorcycle companion.

### This is NOT

-   Navigation app
-   Google Maps replacement
-   Website
-   SaaS dashboard
-   Analytics platform

Google Maps handles navigation. RiderOS handles ride information.

## Tech

-   Flutter
-   Dart
-   Riverpod
-   GoRouter
-   Hive/Isar
-   Geolocator
-   Sensors Plus
-   Flutter Compass
-   Permission Handler
-   Connectivity Plus

Landscape only.

Preferred resolution: **2340×1080** Preferred aspect ratio: **19.5:9**

Responsive: - 1280×720 - 1600×720 - 1920×1080 - Android Auto - Landscape
tablets

## Design

Treat the UI as an embedded Motorcycle HMI.

References: - BMW Motorrad TFT - Garmin Zumo - Bosch Motorcycle
Cluster - KTM TFT

Avoid: - Websites - Admin dashboards - Colorful cards - Gradients -
Glassmorphism - Decorative animations

Night: - Background #000000 - White typography - Grey secondary text

Day: - White background - Black typography

Colors only for status: - Green = active - Orange = warning - Red =
emergency

## Information Priority

1.  Speed
2.  Trip
3.  Ride Time
4.  Fuel Range
5.  Compass
6.  Altitude
7.  Weather
8.  Clock
9.  Battery

## Folder Structure

``` text
lib/
 app/
 core/
 features/
 models/
 repositories/
 database/
 routing/
```

## Core Modules

### Ride Console

Live: - Speed - Trip - Ride time - Average speed - Max speed - Compass -
Altitude - Fuel range - Weather - Clock

### Ride Session

Start → Record → Summary → Save

### Fuel

Store: - Liters - Price - Odometer

Calculate: - Mileage - Cost/km - Fuel range - Monthly cost

### Android Auto

Companion only.

Display: - Speed - Trip - Ride Time - Fuel - Compass - Emergency

No navigation.

## Performance

60 FPS

Offline first

Minimal rebuilds

Reusable widgets

No hardcoded dimensions.

## Deliverable

Generate a clean, production-ready Flutter application with scalable
architecture and OEM-quality HMI principles.
