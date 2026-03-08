import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/settings.dart';
import '../data_sources/settings_service.dart';
import '../data_sources/secure_storage_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsService _service;
  final SecureStorageService _secureStorage;

  SettingsRepositoryImpl(this._service, this._secureStorage);

  @override
  Future<Settings> getSettings() => _service.getSettings();

  @override
  Future<void> saveSettings(Settings settings) =>
      _service.saveSettings(settings);

  @override
  Future<bool> getAppLockEnabled() => _secureStorage.isAppLockEnabled();

  @override
  Future<void> setAppLockEnabled(bool enabled) =>
      _secureStorage.setAppLockEnabled(enabled);
}
