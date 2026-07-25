import 'package:go_router/go_router.dart';
import 'package:rider_os/app/splash_screen.dart';
import 'package:rider_os/app/setup_screen.dart';
import 'package:rider_os/features/fuel/presentation/screens/fuel_screen.dart';
import 'package:rider_os/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:rider_os/features/ride_console/presentation/screens/ride_console_screen.dart';
import 'package:rider_os/features/settings/presentation/screens/settings_screen.dart';
import 'package:rider_os/features/safety/presentation/screens/safety_screen.dart';

/// RiderOS route paths.
///
/// All route paths are defined here as constants to prevent
/// typos and enable refactoring.
abstract final class RoutePaths {
  static const splash = '/splash';
  static const setup = '/setup';
  static const console = '/';
  static const fuelManager = '/fuel';
  static const rideArchive = '/archive';
  static const rideReport = '/report';
  static const rideStatistics = '/statistics';
  static const safety = '/safety';
  static const maintenance = '/maintenance';
  static const garage = '/garage';
  static const settings = '/settings';
}

/// RiderOS GoRouter configuration.
///
/// Routes are added incrementally as each module is implemented.
/// The initial route is the Ride Console (home screen).
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.setup,
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: RoutePaths.console,
      builder: (context, state) => const RideConsoleScreen(),
    ),
    GoRoute(
      path: RoutePaths.fuelManager,
      builder: (context, state) => const FuelScreen(),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.safety,
      builder: (context, state) => const SafetyScreen(),
    ),
    GoRoute(
      path: RoutePaths.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),
  ],
);
