# Android Auto Integration

RiderOS natively supports Android Auto, projecting the motorcycle dashboard experience directly onto the vehicle's infotainment screen.

## Setup & Architecture
The Android Auto integration is built using native Android code located in the `android/` directory and communicates with the Flutter engine via MethodChannels.

### Key Components
- **CarAppService**: The entry point for the Android Auto lifecycle.
- **ScreenManager**: Handles navigation between Auto screens (Dashboard, Navigation, Media).
- **TelemetryReceiver**: A background service that receives GPS and sensor data from Flutter (or directly from native APIs) to project onto the Auto screen.

## Development & Testing

### Desktop Head Unit (DHU)
To test Android Auto without a real vehicle or head unit, use the Android Auto Desktop Head Unit (DHU) provided by Google.

1. Install Android Auto on your physical test device (or use the built-in emulator integration).
2. Enable Developer Settings in the Android Auto app on your phone.
3. Start the Head Unit Server from the developer menu.
4. Forward the ADB port:
   ```bash
   adb forward tcp:5277 tcp:5277
   ```
5. Launch the DHU from your Android SDK `/extras/google/auto` directory.

### UI Guidelines for Auto
When modifying Android Auto interfaces in the native codebase, adhere to Google's strict driver distraction guidelines:
- Large touch targets.
- Minimal text.
- High contrast.
- Voice-first interactions where possible.
