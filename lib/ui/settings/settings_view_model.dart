import 'package:flutter/material.dart';

import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/usecases/convert_all_data_usecase.dart';
import '../../domain/entities/custom_exchange_rate.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final CurrencyRepository _currencyRepository;
  final ConvertAllDataUseCase _convertAllDataUseCase;

  Settings? _settings;
  bool isInitialized = false;
  bool _isAppLockEnabled = false;
  List<CustomExchangeRate> _customRates = [];

  Settings get settings => _settings ?? Settings();
  bool get isAppLockEnabled => _isAppLockEnabled;
  List<CustomExchangeRate> get customRates => _customRates;

  SettingsViewModel({
    required SettingsRepository repository,
    required CurrencyRepository currencyRepository,
    required ConvertAllDataUseCase convertAllDataUseCase,
  }) : _repository = repository,
       _currencyRepository = currencyRepository,
       _convertAllDataUseCase = convertAllDataUseCase;

  Future<void> initialize() async {
    if (isInitialized) return;

    _settings = await _repository.getSettings();
    _isAppLockEnabled = await _repository.getAppLockEnabled();
    _customRates = await _currencyRepository.getAllCustomRates();

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

  // Currency-related methods

  Future<double?> getExchangeRate(String from, String to) async {
    return await _currencyRepository.getExchangeRate(from, to);
  }

  Future<void> addOrUpdateCustomRate(String from, String to, double rate) async {
    final customRate = CustomExchangeRate(
      conversionPair: "${from}_$to",
      rate: rate,
    );
    await _currencyRepository.saveCustomRate(customRate);
    _customRates = await _currencyRepository.getAllCustomRates();
    notifyListeners();
  }

  Future<void> deleteCustomRate(String conversionPair) async {
    await _currencyRepository.deleteCustomRate(conversionPair);
    _customRates = await _currencyRepository.getAllCustomRates();
    notifyListeners();
  }

  Future<void> convertAllData(double rate, String newCurrencyCode) async {
    await _convertAllDataUseCase.execute(rate, newCurrencyCode);
    await updatePrimaryCurrency(newCurrencyCode);
  }
}
