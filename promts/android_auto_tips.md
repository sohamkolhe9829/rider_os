RiderOS: Android Auto Implementation & Testing Guide
Because Android Auto enforces strict, native UI templates to prevent driver distraction, a pure Flutter UI cannot be rendered directly on the car's head unit. Therefore, the application requires a hybrid approach: building the car-facing interface natively using the Android Car App Library and using Flutter for the mobile application and business logic.

Part 1: Implementation Guide
Step 1: Android Dependencies
You must add the Android Car App Library dependencies to your native Android module.

Open android/app/build.gradle and add the following to your dependencies:

Gradle
dependencies {
    // For Android Auto specific functionality
    implementation("androidx.car.app:app:1.7.0")
    implementation("androidx.car.app:app-projected:1.7.0")
}
Step 2: Android Manifest Configuration
You need to declare your CarAppService and the application category so the head unit recognizes your app.

Open android/app/src/main/AndroidManifest.xml and add the service declaration inside the <application> tag:

XML
<service 
    android:name=".AutoService" 
    android:exported="true" 
    android:permission="android.permission.BIND_CAR_SERVICE">
    <intent-filter>
        <action android:name="androidx.car.app.CarAppService"/>
    </intent-filter>
    <meta-data 
        android:name="androidx.car.app.category" 
        android:value="poi"/> <!-- Use "poi" (Point of Interest) for fuel/dashboard utility -->
</service>
Step 3: Native Kotlin Implementation  
In your Android src directory, you need to implement three core components for Android Auto.  

1. AutoService.kt - The entry point for Android Auto:  

Kotlin
package com.rideros.app

import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

class AutoService : CarAppService() {
    override fun createHostValidator(): HostValidator {
        return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
    }

    override fun onCreateSession(): Session {
        return AutoSession()
    }
}
2. AutoSession.kt - Manages the lifecycle of the car screen:

Kotlin
package com.rideros.app

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session

class AutoSession : Session() {
    override fun onCreateScreen(intent: Intent): Screen {
        return MainAutoScreen(carContext)
    }
}
3. MainAutoScreen.kt - Renders the UI using Google's templates:  

Kotlin
package com.rideros.app

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*

class MainAutoScreen(carContext: CarContext) : Screen(carContext) {
    override fun onGetTemplate(): Template {
        val row = Row.Builder()
            .setTitle("Speed: 0 km/h")
            .addText("Distance: 0 km")
            .build()

        val pane = Pane.Builder()
            .addRow(row)
            .build()

        return PaneTemplate.Builder(pane)
            .setTitle("RiderOS Dashboard")
            .build()
    }
}
Step 4: The Flutter-to-Native Bridge (MethodChannel)
To send live GPS and speed data from Flutter to the native Android Auto screen, set up a MethodChannel.

In MainActivity.kt:

Kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.rideros.app/auto_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateTelemetry") {
                val speed = call.argument<Double>("speed")
                // Pass this speed to your MainAutoScreen to trigger a UI refresh
                result.success("Updated")
            } else {
                result.notImplemented()
            }
        }
    }
}
Part 2: Testing Guide
You can test this implementation without sitting in your car by using Google's Desktop Head Unit (DHU).

Step 1: Enable Developer Mode on Your Phone
Download and install Android Auto from the Google Play Store on your Android phone.

Open the Android Auto app settings.

Scroll down to the About section and tap Version to expand the version information.

Tap the "Version and permission info" section 10 times.

A prompt will appear asking to "Allow development settings?". Tap OK.

Step 2: Start the Head Unit Server
In the Android Auto settings, tap the three-dot overflow menu in the top-right corner.

Select Start head unit server.

A foreground service will appear in your phone's notification tray indicating that the server is running.

Step 3: Run the Desktop Head Unit (DHU)
Connect your phone to your computer via USB. Make sure the phone screen is unlocked.

Open your computer's terminal/command prompt and forward the socket connection using ADB:

Bash
adb forward tcp:5277 tcp:5277
Note: This allows the DHU to connect to your phone's head unit server over a TCP socket.

Navigate to your Android SDK directory (usually <sdk>/extras/google/auto/).

Launch the emulator:

Windows: desktop-head-unit.exe

macOS/Linux: ./desktop-head-unit

The DHU window will open on your computer, mirroring exactly what your Flutter app's native Kotlin code renders on an actual car dashboard.

Step 4: Testing in a Real Vehicle
To test your app in a real car, Android Auto enforces a strict security restriction: it blocks apps installed via standard USB debugging (adb install) unless you explicitly allow unknown sources.

Go to the Android Auto settings on your phone.

Open the three-dot developer menu and select Developer Settings.

Scroll down and check the box for Unknown sources.

Plug your phone into your motorcycle/car head unit, and RiderOS will appear in the app launcher.
(Note: If the application uses the androidx.car.app library, you may eventually be required to distribute it via the Google Play Internal Test Track for real-vehicle testing without developer settings enabled).