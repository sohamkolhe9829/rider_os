import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final batteryStateProvider = StreamProvider<int>((ref) async* {
  final battery = Battery();
  // Yield initial value
  try {
    yield await battery.batteryLevel;
  } catch (_) {
    yield 85; // Fallback
  }

  // Stream changes
  await for (final _ in battery.onBatteryStateChanged) {
    try {
      yield await battery.batteryLevel;
    } catch (_) {}
  }
});

final clockProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>();

  final formatter = DateFormat('h:mm a');

  // Emit initial value
  controller.add(formatter.format(DateTime.now()));

  // Update every minute (or just every 10 seconds to ensure it stays in sync)
  final timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    controller.add(formatter.format(DateTime.now()));
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
