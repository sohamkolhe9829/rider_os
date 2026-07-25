import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rider_os/features/maintenance/data/maintenance_repository.dart';
import 'package:rider_os/features/maintenance/data/maintenance_storage.dart';
import 'package:rider_os/features/maintenance/domain/maintenance_item.dart';
import 'package:rider_os/features/ride_session/presentation/providers/session_providers.dart';

final maintenanceStorageProvider = Provider<MaintenanceStorage>((ref) {
  return MaintenanceStorage();
});

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final storage = ref.watch(maintenanceStorageProvider);
  final rideStorage = ref.watch(rideStorageProvider);
  return MaintenanceRepository(storage, rideStorage);
});

final maintenanceItemsProvider = FutureProvider<List<MaintenanceItem>>((
  ref,
) async {
  final repo = ref.watch(maintenanceRepositoryProvider);
  return await repo.getItems();
});

final lifetimeDistanceProvider = FutureProvider<double>((ref) async {
  final rideStorage = ref.watch(rideStorageProvider);
  return await rideStorage.getLifetimeGpsDistance();
});
