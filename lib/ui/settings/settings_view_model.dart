import 'package:flutter/material.dart';

import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  Settings? _settings;
  bool isInitialized = false;
  bool _isAppLockEnabled = false;

  Settings get settings => _settings ?? Settings();
  bool get isAppLockEnabled => _isAppLockEnabled;

  SettingsViewModel({required SettingsRepository repository})
    : _repository = repository;

  Future<void> initialize() async {
    if (isInitialized) return;

    _settings = await _repository.getSettings();
    _isAppLockEnabled = await _repository.getAppLockEnabled();

    isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshAppLockState() async {
    _isAppLockEnabled = await _repository.getAppLockEnabled();
    notifyListeners();
  }

  Future<void> toggleAppLock(bool value) async {
    await _repository.setAppLockEnabled(value);
    _isAppLockEnabled = value;
    notifyListeners();
  }

  Future<void> saveSettings(Settings updatedSettings) async {
    await _repository.saveSettings(updatedSettings);

    _settings = updatedSettings;
    notifyListeners();
  }

  Future<void> togglePrivacyMode(bool enabled) async {
    if (_settings == null) return;

    _settings!.privacyModeEnabled = enabled;
    await saveSettings(_settings!);
  }

  Future<void> updateGeminiApiKey(String? key) async {
    if (_settings == null) return;

    _settings!.geminiApiKey = key;
    await saveSettings(_settings!);
  }
}
