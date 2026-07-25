import 'package:rider_os/features/fuel/data/fuel_storage.dart';
import 'package:rider_os/features/ride_session/data/ride_recorder.dart';
import 'package:rider_os/features/ride_session/data/ride_storage.dart';
import 'package:rider_os/features/ride_session/domain/ride_session.dart';

/// Repository that coordinates between the live [RideRecorder]
/// and the persistent [RideStorage].
class RideRepository {
  RideRepository(this._recorder, this._storage, this._fuelStorage);

  final RideRecorder _recorder;
  final RideStorage _storage;
  final FuelStorage _fuelStorage;

  /// Save a completed session.
  Future<void> saveSession(RideSession session) async {
    await _storage.saveRide(session);
  }

  /// Get all historical sessions.
  Future<List<RideSession>> getHistory() async {
    return _storage.getAllRides();
  }

  /// Stops the current recording and saves the resulting session.
  Future<RideSession?> endAndSaveRide() async {
    final session = _recorder.end();
    if (session != null) {
      await saveSession(session);
      // Bug 2: Every completed ride adds ride distance to unloggedGpsDistance.
      await _fuelStorage.addUnloggedGpsDistance(session.distanceKm);
      // Milestone 5: Invisible odometer for maintenance tracking
      final currentLifetime = await _storage.getLifetimeGpsDistance();
      await _storage.setLifetimeGpsDistance(
        currentLifetime + session.distanceKm,
      );
    }
    return session;
  }
}
