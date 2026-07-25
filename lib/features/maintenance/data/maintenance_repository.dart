import 'package:rider_os/features/maintenance/data/maintenance_storage.dart';
import 'package:rider_os/features/maintenance/domain/maintenance_item.dart';
import 'package:rider_os/features/ride_session/data/ride_storage.dart';

class MaintenanceRepository {
  MaintenanceRepository(this._storage, this._rideStorage);

  final MaintenanceStorage _storage;
  final RideStorage _rideStorage;

  Future<List<MaintenanceItem>> getItems() async {
    final items = await _storage.getAllItems();
    if (items.isEmpty) {
      return _initializeDefaultItems();
    }
    return items;
  }

  Future<void> saveItem(MaintenanceItem item) async {
    await _storage.saveItem(item);
  }

  Future<void> recordService(String id, String notes) async {
    final items = await _storage.getAllItems();
    final item = items.firstWhere((i) => i.id == id);

    final currentDistance = await _rideStorage.getLifetimeGpsDistance();
    final now = DateTime.now();

    final updatedItem = item.copyWith(
      lastServiceDate: now,
      lastServiceDistance: currentDistance,
      nextDueDate: item.type.defaultIntervalDays != null
          ? now.add(Duration(days: item.type.defaultIntervalDays!))
          : null,
      nextDueDistance: item.type.defaultIntervalKm != null
          ? currentDistance + item.type.defaultIntervalKm!
          : null,
      notes: notes,
    );

    await _storage.saveItem(updatedItem);
  }

  Future<List<MaintenanceItem>> _initializeDefaultItems() async {
    final defaultItems = MaintenanceType.values.map((type) {
      return MaintenanceItem(id: type.name, type: type);
    }).toList();

    for (final item in defaultItems) {
      await _storage.saveItem(item);
    }

    return defaultItems;
  }
}
