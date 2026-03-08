import '../../domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<Settings> getSettings();
  Future<void> saveSettings(Settings settings);
  Future<bool> getAppLockEnabled();
  Future<void> setAppLockEnabled(bool enabled);
}
