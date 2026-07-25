import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorage {
  static const String boxName = 'settings_box';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  Future<void> setBool(String key, bool value) async {
    if (_box == null) await init();
    await _box!.put(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    if (_box == null) await init();
    return _box!.get(key, defaultValue: defaultValue) as bool;
  }

  Future<void> setString(String key, String value) async {
    if (_box == null) await init();
    await _box!.put(key, value);
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    if (_box == null) await init();
    return _box!.get(key, defaultValue: defaultValue) as String;
  }

  Future<void> setDouble(String key, double value) async {
    if (_box == null) await init();
    await _box!.put(key, value);
  }

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    if (_box == null) await init();
    return _box!.get(key, defaultValue: defaultValue) as double;
  }
}
