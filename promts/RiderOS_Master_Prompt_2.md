# RiderOS --- Master Prompt 2 (V2, V3 & Engineering)

## Purpose

Continue building RiderOS using the existing architecture and design
system. Do **not** redesign V1 modules. Extend them.

------------------------------------------------------------------------

# Existing Modules (Do Not Rebuild)

-   Ride Console
-   Ride Recording
-   Fuel Manager
-   Android Auto Companion
-   Theme System
-   Responsive Engine

Reuse all existing components.

------------------------------------------------------------------------

# Module 1 --- Safety Console

Build a dedicated safety module.

Features:

-   Crash Detection
-   Emergency SOS
-   Medical Card
-   Live Location Sharing
-   Emergency Contacts

Crash flow:

Detect impact →

30 second countdown →

Cancel or continue →

Send live location →

Call emergency contact →

Save ride automatically.

------------------------------------------------------------------------

# Module 2 --- Ride Archive

Store every ride locally.

Each ride includes:

-   Date
-   Distance
-   Duration
-   Average Speed
-   Maximum Speed
-   Start Time
-   End Time
-   Notes
-   Photos (placeholder)
-   Export

Filtering:

-   Today
-   Week
-   Month
-   Year
-   All

------------------------------------------------------------------------

# Module 3 --- Ride Report

Display:

-   Distance
-   Ride Time
-   Average Speed
-   Top Speed
-   Moving Time
-   Stopped Time
-   Elevation
-   Fuel Estimate
-   Weather Snapshot

Support export:

-   PDF
-   GPX
-   CSV
-   JSON

------------------------------------------------------------------------

# Module 4 --- Ride Statistics

Calculate automatically:

-   Lifetime Distance
-   Lifetime Ride Hours
-   Ride Count
-   Longest Ride
-   Fastest Ride
-   Average Ride
-   Monthly Distance
-   Monthly Fuel Cost
-   Total Fuel Cost

Use minimal monochrome charts.

------------------------------------------------------------------------

# Module 5 --- Maintenance

Track:

-   Engine Oil
-   Chain Clean
-   Chain Lube
-   Brake Pads
-   Coolant
-   Air Filter
-   Spark Plug
-   Battery
-   Insurance
-   PUC

Each item stores:

-   Last Service
-   Next Due
-   Remaining KM
-   Remaining Days
-   Notes

------------------------------------------------------------------------

# Module 6 --- Garage

Store bike information:

-   Manufacturer
-   Model
-   Year
-   Registration
-   VIN
-   Engine
-   Accessories
-   Tyres
-   Battery

------------------------------------------------------------------------

# Module 7 --- Settings

General

-   Theme
-   Units
-   Language
-   Time Format

Ride

-   GPS Interval
-   Recording Interval
-   Auto Start
-   Auto Pause

Safety

-   Emergency Contacts
-   Countdown Delay

Data

-   Export
-   Import
-   Backup Placeholder
-   Reset

------------------------------------------------------------------------

# Module 8 --- Android Auto Improvements

Keep interface minimal.

Display only:

-   Speed
-   Trip
-   Ride Time
-   Fuel Range
-   Compass
-   SOS

Never add navigation.

Optimize for split screen with Google Maps.

------------------------------------------------------------------------

# Performance

Target:

-   60 FPS
-   Offline First
-   Battery Efficient
-   Minimal Rebuilds
-   Responsive
-   Clean Architecture

------------------------------------------------------------------------

# Flutter Rules

Use:

-   Feature-first architecture
-   Riverpod
-   Reusable widgets
-   Immutable models
-   Repository pattern
-   Service layer
-   Responsive layouts

Avoid:

-   Hardcoded dimensions
-   Duplicated widgets
-   Business logic in UI

------------------------------------------------------------------------

# Future Reserved Modules

Reserve architecture only for:

-   OBD-II
-   TPMS
-   DJI Action Camera
-   GoPro
-   Smartwatch
-   Cloud Sync
-   Apple CarPlay
-   Group Rides

Do not implement these yet.

------------------------------------------------------------------------

# Final Requirement

Generate production-ready Flutter code.

Keep the application feeling like embedded OEM motorcycle software.

Every new screen must follow the existing design system, remain
landscape-only, and be optimized for 2340×1080 (19.5:9) while scaling
cleanly to Android Auto and other supported landscape displays.
