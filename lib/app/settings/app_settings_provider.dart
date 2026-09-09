import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const boxName = 'app_settings';
  static const darkModeKey = 'dark_mode';
  static const compactMapKey = 'compact_map_controls';

  final Box<dynamic> box;

  AppSettingsProvider(this.box);

  bool get isDarkMode => box.get(darkModeKey, defaultValue: false) as bool;
  bool get compactMapControls => box.get(compactMapKey, defaultValue: false) as bool;

  Future<void> setDarkMode(bool value) async {
    await box.put(darkModeKey, value);
    notifyListeners();
  }

  Future<void> setCompactMapControls(bool value) async {
    await box.put(compactMapKey, value);
    notifyListeners();
  }

  Future<void> reset() async {
    await box.clear();
    notifyListeners();
  }
}
