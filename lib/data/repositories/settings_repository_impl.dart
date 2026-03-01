import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/settings.dart';
import '../data_sources/settings_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsService _service;

  SettingsRepositoryImpl(this._service);

  @override
  Future<Settings> getSettings() => _service.getSettings();

  @override
  Future<void> saveSettings(Settings settings) =>
      _service.saveSettings(settings);
}
