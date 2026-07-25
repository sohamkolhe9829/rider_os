import 'dart:async';

import 'package:rider_os/features/fuel/data/fuel_repository.dart';
import 'package:rider_os/features/fuel/domain/fuel_stats.dart';

/// Service that coordinates live ride metrics with static fuel statistics.
///
/// For example, this service calculates the live Estimated Fuel Range
/// based on the current mileage stats and tank capacity, which can
/// dynamically update if we implement live consumption tracking.
class FuelService {
  FuelService(this._repository);

  final FuelRepository _repository;

  final _statsController = StreamController<FuelStats>.broadcast();

  /// Stream of calculated fuel statistics.
  Stream<FuelStats> get statsStream => _statsController.stream;

  /// Fetch the latest stats and push them to the stream.
  Future<void> refreshStats({
    double tankCapacity = 15.0,
    double expectedMileage = 35.0,
  }) async {
    final stats = await _repository.getStats(
      tankCapacity: tankCapacity,
      expectedMileage: expectedMileage,
    );
    _statsController.add(stats);
  }

  void dispose() {
    _statsController.close();
  }
}
