import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_os/features/ride_session/domain/ride_session.dart';

/// Local storage handler for persisting [RideSession] objects using Hive.
class RideStorage {
  static const String boxName = 'ride_sessions_box';

  Box? _box;

  /// Initialize the storage box. Must be called before use.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(_RideSessionAdapter());
    }
    _box = await Hive.openBox(boxName);
  }

  /// Save a completed ride session to disk.
  Future<void> saveRide(RideSession session) async {
    if (_box == null) await init();
    await _box!.put(session.id, session);
  }

  /// Retrieve all saved ride sessions.
  Future<List<RideSession>> getAllRides() async {
    if (_box == null) await init();
    // Filter out the metadata keys
    final rides = _box!.values.whereType<RideSession>().toList();
    // Sort by start time descending (newest first).
    rides.sort((a, b) => b.startTime.compareTo(a.startTime));
    return rides;
  }

  /// Get lifetime GPS distance (invisible odometer).
  Future<double> getLifetimeGpsDistance() async {
    if (_box == null) await init();
    return _box!.get('lifetimeGpsDistance', defaultValue: 0.0) as double;
  }

  /// Set lifetime GPS distance.
  Future<void> setLifetimeGpsDistance(double distance) async {
    if (_box == null) await init();
    await _box!.put('lifetimeGpsDistance', distance);
  }
}

/// Manual Hive TypeAdapter for [RideSession].
/// Using a manual adapter avoids build_runner dependencies and conflicts.
class _RideSessionAdapter extends TypeAdapter<RideSession> {
  @override
  final int typeId = 0;

  @override
  RideSession read(BinaryReader reader) {
    final id = reader.readString();
    final startTime = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final endTime = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final distanceKm = reader.readDouble();
    final durationSeconds = reader.readInt();
    final avgSpeedKmh = reader.readDouble();
    final maxSpeedKmh = reader.readDouble();

    // Altitude fields were added later. Provide defaults if they don't exist.
    double startAltitude = 0.0;
    double endAltitude = 0.0;
    double highestAltitude = 0.0;
    double lowestAltitude = 0.0;
    double elevationGain = 0.0;
    double elevationLoss = 0.0;

    if (reader.availableBytes > 0) {
      startAltitude = reader.readDouble();
      endAltitude = reader.readDouble();
      highestAltitude = reader.readDouble();
      lowestAltitude = reader.readDouble();
      elevationGain = reader.readDouble();
      elevationLoss = reader.readDouble();
    }

    return RideSession(
      id: id,
      startTime: startTime,
      endTime: endTime,
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      avgSpeedKmh: avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      startAltitude: startAltitude,
      endAltitude: endAltitude,
      highestAltitude: highestAltitude,
      lowestAltitude: lowestAltitude,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
    );
  }

  @override
  void write(BinaryWriter writer, RideSession obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeInt(obj.endTime.millisecondsSinceEpoch);
    writer.writeDouble(obj.distanceKm);
    writer.writeInt(obj.durationSeconds);
    writer.writeDouble(obj.avgSpeedKmh);
    writer.writeDouble(obj.maxSpeedKmh);
    writer.writeDouble(obj.startAltitude);
    writer.writeDouble(obj.endAltitude);
    writer.writeDouble(obj.highestAltitude);
    writer.writeDouble(obj.lowestAltitude);
    writer.writeDouble(obj.elevationGain);
    writer.writeDouble(obj.elevationLoss);
  }
}
