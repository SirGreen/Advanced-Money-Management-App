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

    final updatedSettings = _settings!.copyWith(privacyModeEnabled: enabled);
    await saveSettings(updatedSettings);
    _settings = updatedSettings;
  }

  Future<void> updateGeminiApiKey(String? key) async {
    if (_settings == null) return;

    final trimmedKey = key?.trim();
    final isClear = trimmedKey == null || trimmedKey.isEmpty;
    final updatedSettings = _settings!.copyWith(
      geminiApiKey: isClear ? null : trimmedKey,
      clearGeminiApiKey: isClear,
    );
    await saveSettings(updatedSettings);
    _settings = updatedSettings;
  }

  Future<void> updatePrimaryCurrency(String currencyCode) async {
    if (_settings == null) return;

    final updatedSettings = _settings!.copyWith(primaryCurrencyCode: currencyCode);
    await saveSettings(updatedSettings);
    _settings = updatedSettings;
  }

  Future<void> updateUserContext(String? context) async {
    if (_settings == null) return;

    final trimmedContext = context?.trim();
    final isClear = trimmedContext == null || trimmedContext.isEmpty;
    final updatedSettings = _settings!.copyWith(
      userContext: isClear ? null : trimmedContext,
      clearUserContext: isClear,
    );
    await saveSettings(updatedSettings);
    _settings = updatedSettings;
  }
}
