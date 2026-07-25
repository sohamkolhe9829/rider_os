import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_os/core/theme/theme_provider.dart';
import 'package:rider_os/features/settings/presentation/providers/settings_providers.dart';

void main() {
  test('ThemeNotifier changes state when themeModeProvider updates', () {
    final container = ProviderContainer(
      overrides: [
        // Initialize to Dark
        themeModeProvider.overrideWith((ref) => 'Dark'),
      ],
    );
    addTearDown(container.dispose);

    // Initial state should be night mode
    expect(container.read(isNightModeProvider), isTrue);

    // Update the underlying setting to Light
    container.read(themeModeProvider.notifier).state = 'Light';

    // The theme provider should reactively become day mode
    expect(container.read(isNightModeProvider), isFalse);

    // Update to System (during testing we can't easily mock time for System, but we can verify it resolves)
    // Just verify it doesn't crash when set to System
    container.read(themeModeProvider.notifier).state = 'System';
    final isNight = container.read(isNightModeProvider);
    expect(isNight, isNotNull);
  });
}
