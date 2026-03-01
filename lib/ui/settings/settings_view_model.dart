import 'package:flutter/material.dart';

import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  Settings? _settings;
  bool isInitialized = false;

  Settings get settings => _settings ?? Settings();

  SettingsViewModel({required SettingsRepository repository})
    : _repository = repository;

  Future<void> initialize() async {
    if (isInitialized) return;

    _settings = await _repository.getSettings();

    isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSettings(Settings updatedSettings) async {
    await _repository.saveSettings(updatedSettings);

    _settings = updatedSettings;
    notifyListeners();
  }
}
