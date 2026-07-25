import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_os/features/fuel/domain/fuel_log.dart';

/// Local storage handler for persisting [FuelLog] objects.
class FuelStorage {
  static const String boxName = 'fuel_logs_box';
  static const String statsBoxName = 'fuel_stats_storage_box';

  Box? _box;
  Box? _statsBox;

  /// Initialize the storage box.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(_FuelLogAdapter());
    }
    _box = await Hive.openBox(boxName);
    _statsBox = await Hive.openBox(statsBoxName);
  }

  /// Save a new fuel log.
  Future<void> saveLog(FuelLog log) async {
    if (_box == null) await init();
    await _box!.put(log.id, log);
  }

  /// Delete a fuel log.
  Future<void> deleteLog(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  /// Retrieve all saved fuel logs.
  Future<List<FuelLog>> getAllLogs() async {
    if (_box == null) await init();
    final logs = _box!.values.cast<FuelLog>().toList();
    logs.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return logs;
  }

  // ── Statistics Storage ────────────────────────────

  Future<double> getUnloggedGpsDistance() async {
    if (_statsBox == null) await init();
    return _statsBox!.get('unloggedGpsDistance', defaultValue: 0.0) as double;
  }

  Future<void> setUnloggedGpsDistance(double distance) async {
    if (_statsBox == null) await init();
    await _statsBox!.put('unloggedGpsDistance', distance);
  }

  Future<void> addUnloggedGpsDistance(double distance) async {
    final current = await getUnloggedGpsDistance();
    await setUnloggedGpsDistance(current + distance);
  }

  Future<double> getAverageMileage() async {
    if (_statsBox == null) await init();
    return _statsBox!.get('averageMileage', defaultValue: 0.0) as double;
  }

  Future<void> setAverageMileage(double mileage) async {
    if (_statsBox == null) await init();
    await _statsBox!.put('averageMileage', mileage);
  }

  Future<double> getDistanceSinceFullTank() async {
    if (_statsBox == null) await init();
    return _statsBox!.get('distanceSinceFullTank', defaultValue: 0.0) as double;
  }

  Future<void> setDistanceSinceFullTank(double distance) async {
    if (_statsBox == null) await init();
    await _statsBox!.put('distanceSinceFullTank', distance);
  }

  Future<void> addDistanceSinceFullTank(double distance) async {
    final current = await getDistanceSinceFullTank();
    await setDistanceSinceFullTank(current + distance);
  }

  Future<double> getFuelSinceFullTank() async {
    if (_statsBox == null) await init();
    return _statsBox!.get('fuelSinceFullTank', defaultValue: 0.0) as double;
  }

  Future<void> setFuelSinceFullTank(double volume) async {
    if (_statsBox == null) await init();
    await _statsBox!.put('fuelSinceFullTank', volume);
  }

  Future<void> addFuelSinceFullTank(double volume) async {
    final current = await getFuelSinceFullTank();
    await setFuelSinceFullTank(current + volume);
  }

  Future<double> getCurrentFuelLiters() async {
    if (_statsBox == null) await init();
    return _statsBox!.get('currentFuelLiters', defaultValue: 0.0) as double;
  }

  Future<void> setCurrentFuelLiters(double volume) async {
    if (_statsBox == null) await init();
    await _statsBox!.put('currentFuelLiters', volume);
  }
}

/// Manual Hive TypeAdapter for [FuelLog]. Type ID 1.
class _FuelLogAdapter extends TypeAdapter<FuelLog> {
  @override
  final int typeId = 1;

  @override
  FuelLog read(BinaryReader reader) {
    final id = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final volumeAddedLiters = reader.readDouble();
    final pricePerLiter = reader.readDouble();
    final totalCost = reader.readDouble();
    final distanceRiddenKm = reader.readDouble();
    final isFullTank = reader.readBool();

    // Default values for fields missing in legacy records
    bool isBaseline = false;
    double? computedMileageKmpl;

    if (reader.availableBytes > 0) {
      isBaseline = reader.readBool();
    }

    if (reader.availableBytes > 0) {
      final hasComputedMileage = reader.readBool();
      if (hasComputedMileage && reader.availableBytes > 0) {
        computedMileageKmpl = reader.readDouble();
      }
    }

    return FuelLog(
      id: id,
      date: date,
      volumeAddedLiters: volumeAddedLiters,
      pricePerLiter: pricePerLiter,
      totalCost: totalCost,
      distanceRiddenKm: distanceRiddenKm,
      isFullTank: isFullTank,
      isBaseline: isBaseline,
      computedMileageKmpl: computedMileageKmpl,
    );
  }

  @override
  void write(BinaryWriter writer, FuelLog obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeDouble(obj.volumeAddedLiters);
    writer.writeDouble(obj.pricePerLiter);
    writer.writeDouble(obj.totalCost);
    writer.writeDouble(obj.distanceRiddenKm);
    writer.writeBool(obj.isFullTank);
    writer.writeBool(obj.isBaseline);
    writer.writeBool(obj.computedMileageKmpl != null);
    if (obj.computedMileageKmpl != null) {
      writer.writeDouble(obj.computedMileageKmpl!);
    }
  }
}
