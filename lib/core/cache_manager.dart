import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static const String _authBox = 'auth_cache';
  static const String _settingsBox = 'settings_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_authBox);
    await Hive.openBox(_settingsBox);
  }

  static Box get authBox => Hive.box(_authBox);
  static Box get settingsBox => Hive.box(_settingsBox);

  static Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  static dynamic getData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }
}
