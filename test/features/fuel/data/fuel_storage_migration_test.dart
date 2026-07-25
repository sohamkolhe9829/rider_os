import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_os/features/fuel/data/fuel_storage.dart';

void main() {
  group('FuelStorage Hive Migration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_migration_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test(
      'successfully reads legacy FuelLog schema (missing isBaseline and computedMileageKmpl)',
      () async {
        final boxName = 'test_fuel_logs_box';

        // 1. Register fake old adapter
        Hive.registerAdapter(LegacyFuelLogAdapter());
        final rawBox = await Hive.openBox(boxName);

        final legacyLog = LegacyFuelLog(
          id: 'old_log_1',
          date: DateTime(2025, 1, 1).millisecondsSinceEpoch,
          volumeAddedLiters: 10.0,
          pricePerLiter: 1.5,
          totalCost: 15.0,
          distanceRiddenKm: 150.0,
          isFullTank: true,
        );

        await rawBox.put('old_log_1', legacyLog);
        await rawBox.close();

        // 2. Clear registry and use real FuelStorage logic
        Hive.resetAdapters();

        // We manually register the REAL adapter
        // (Normally FuelStorage handles this, but since box names are hardcoded, we just test the adapter)

        // We need to use reflection or just access the real adapter. Wait, `_FuelLogAdapter` is private.
        // But we can just call `FuelStorage().init()` which registers it, then we can read from our box!
        // But FuelStorage().init() opens the hardcoded box.
        // So let's write to the hardcoded box name: 'fuel_logs_box'
        Hive.registerAdapter(LegacyFuelLogAdapter());
        final legacyBox = await Hive.openBox('fuel_logs_box');
        await legacyBox.put('old_log_1', legacyLog);
        await legacyBox.close();
        Hive.resetAdapters();

        // Now use real FuelStorage!
        final storage = FuelStorage();
        await storage.init(); // This registers the new _FuelLogAdapter (id=1)

        final logs = await storage.getAllLogs();

        expect(logs.length, 1);
        final readLog = logs.first;

        expect(readLog.id, 'old_log_1');
        expect(readLog.volumeAddedLiters, 10.0);
        expect(readLog.distanceRiddenKm, 150.0);
        expect(readLog.isFullTank, true);

        // MIGRATED FIELDS
        expect(
          readLog.isBaseline,
          false,
          reason: 'isBaseline should default to false for legacy data',
        );
        expect(
          readLog.computedMileageKmpl,
          isNull,
          reason: 'computedMileageKmpl should default to null for legacy data',
        );
      },
    );
  });
}

class LegacyFuelLog {
  LegacyFuelLog({
    required this.id,
    required this.date,
    required this.volumeAddedLiters,
    required this.pricePerLiter,
    required this.totalCost,
    required this.distanceRiddenKm,
    required this.isFullTank,
  });

  final String id;
  final int date;
  final double volumeAddedLiters;
  final double pricePerLiter;
  final double totalCost;
  final double distanceRiddenKm;
  final bool isFullTank;
}

class LegacyFuelLogAdapter extends TypeAdapter<LegacyFuelLog> {
  @override
  final int typeId = 1; // Must match the real adapter ID

  @override
  LegacyFuelLog read(BinaryReader reader) {
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, LegacyFuelLog obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date);
    writer.writeDouble(obj.volumeAddedLiters);
    writer.writeDouble(obj.pricePerLiter);
    writer.writeDouble(obj.totalCost);
    writer.writeDouble(obj.distanceRiddenKm);
    writer.writeBool(obj.isFullTank);
    // STOPS HERE! Does NOT write isBaseline or computedMileageKmpl.
  }
}
