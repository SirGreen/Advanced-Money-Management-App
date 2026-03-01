import 'package:hive/hive.dart';
import '../../domain/entities/settings.dart';

class SettingsService {
  static const String settingsBoxName = 'settings';

  Future<Settings> getSettings() async {
    final box = await Hive.openBox<Settings>(settingsBoxName);
    Settings? settings = box.get(0);

    if (settings == null || !settings.isInBox) {
      settings = Settings();
      await box.put(0, settings);
    }

    return settings;
  }

  Future<void> saveSettings(Settings settings) async {
    final box = await Hive.openBox<Settings>(settingsBoxName);
    await box.put(0, settings);
  }
}
