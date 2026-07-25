import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_os/features/maintenance/domain/maintenance_item.dart';

class MaintenanceStorage {
  static const String boxName = 'maintenance_box';

  Box? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(_MaintenanceItemAdapter());
    }
    _box = await Hive.openBox(boxName);
  }

  Future<void> saveItem(MaintenanceItem item) async {
    if (_box == null) await init();
    await _box!.put(item.id, item);
  }

  Future<void> deleteItem(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  Future<List<MaintenanceItem>> getAllItems() async {
    if (_box == null) await init();
    return _box!.values.cast<MaintenanceItem>().toList();
  }
}

class _MaintenanceItemAdapter extends TypeAdapter<MaintenanceItem> {
  @override
  final int typeId = 2;

  @override
  MaintenanceItem read(BinaryReader reader) {
    return MaintenanceItem(
      id: reader.readString(),
      type: MaintenanceType.values[reader.readInt()],
      lastServiceDate: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
      lastServiceDistance: reader.readDouble(),
      nextDueDate: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
      nextDueDistance: reader.readBool() ? reader.readDouble() : null,
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceItem obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.type.index);

    writer.writeBool(obj.lastServiceDate != null);
    if (obj.lastServiceDate != null) {
      writer.writeInt(obj.lastServiceDate!.millisecondsSinceEpoch);
    }

    writer.writeDouble(obj.lastServiceDistance);

    writer.writeBool(obj.nextDueDate != null);
    if (obj.nextDueDate != null) {
      writer.writeInt(obj.nextDueDate!.millisecondsSinceEpoch);
    }

    writer.writeBool(obj.nextDueDistance != null);
    if (obj.nextDueDistance != null) {
      writer.writeDouble(obj.nextDueDistance!);
    }

    writer.writeString(obj.notes);
  }
}
