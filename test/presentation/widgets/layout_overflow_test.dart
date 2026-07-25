import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_os/core/theme/rider_os_theme.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/metric_box.dart';
import 'package:rider_os/features/ride_console/presentation/widgets/console_widgets.dart';

void main() {
  Widget buildTestableWidget(
    Widget child,
    Size size, {
    double textScaleFactor = 1.0,
  }) {
    return MaterialApp(
      theme: RiderOsTheme.day,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('Layout Overflow Tests', () {
    final testSizes = [
      const Size(2340, 1080), // Reference width
      const Size(1600, 720), // Realme Narzo 20A (landscape)
      const Size(800, 480), // Extreme small
    ];

    for (final size in testSizes) {
      testWidgets('MetricBox does not overflow on ${size.width}x${size.height}', (
        tester,
      ) async {
        // We set physical size to be the same as logical size for simplicity
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          buildTestableWidget(
            SizedBox(
              width:
                  300, // Constrained width simulating a column in the console
              child: const MetricBox(
                label: 'VERY LONG LABEL THAT MIGHT OVERFLOW',
                value: '9999.9',
                unit: 'km/h',
                icon: Icons.speed,
              ),
            ),
            size,
            textScaleFactor: 1.3, // 130% text scale
          ),
        );

        // Allow layout to run
        await tester.pumpAndSettle();

        // If there is an overflow, Flutter will throw an exception during layout or painting
        final exceptions = tester.takeException();
        expect(exceptions, isNull, reason: 'Layout overflow detected');
      });

      testWidgets(
        'SpeedDisplay does not overflow on ${size.width}x${size.height} at 199',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildTestableWidget(
              SizedBox(
                width: size.width * 0.4, // Simulate taking up 40% of the screen
                height: size.height * 0.8,
                child: const SpeedDisplay(speed: 199),
              ),
              size,
              textScaleFactor: 1.3, // 130% text scale
            ),
          );

          await tester.pumpAndSettle();

          final exceptions = tester.takeException();
          expect(exceptions, isNull, reason: 'Layout overflow detected');
        },
      );
    }
  });
}
