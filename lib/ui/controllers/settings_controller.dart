import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:money_mana_app/ui/controller/expenditure_controller.dart';
import 'package:money_mana_app/data/model/settings.dart';
import 'package:money_mana_app/app/services/database_service.dart';


class SettingsController with ChangeNotifier {
  static const String settingsBoxName = 'settings';
  final DatabaseService _dbService = DatabaseService();
  late Settings _settings;
  bool isInitialized = false;

  Settings get settings => _settings;
  DateTimeRange? reportDateRange;

  void updateReportDateRange(DateTimeRange newRange) {
    reportDateRange = newRange;
    notifyListeners();
  }

  SettingsController();

  Future<void> initialize() async {
    if (isInitialized) return;
    await _loadSettings();
    isInitialized = true;
  }

  Future<void> _loadSettings() async {
    final box = Hive.box<Settings>(settingsBoxName);
    _settings = box.get(0) ?? Settings();
    if (!_settings.isInBox) {
      await box.put(0, _settings);
    }
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await Hive.box<Settings>(settingsBoxName).put(0, _settings);
    notifyListeners();
  }

  void updateDividerType(DividerType type) {
    _settings.dividerType = type;
    saveSettings();
  }

  void updatePaydayStartDay(int day) {
    _settings.paydayStartDay = day;
    saveSettings();
  }

  void updateFixedIntervalDays(int days) {
    _settings.fixedIntervalDays = days;
    saveSettings();
  }

  void updateLanguage(String? code) {
    _settings.languageCode = code;
    saveSettings();
  }

  void updatePaginationLimit(int limit) {
    _settings.paginationLimit = limit;
    saveSettings();
  }
  Future<void> updatePrimaryCurrency(
    ExpenditureController expenditureController,
    String newCode,
    Future<double?> Function(String, String) getRateCallback,
  ) async {
    final oldCode = _settings.primaryCurrencyCode;
    if (oldCode == newCode) return;
    final rate = await getRateCallback(oldCode, newCode);
    if (rate == null) {
      throw Exception('Failed to get exchange rate for $oldCode to $newCode');
    }
    await expenditureController.convertAllExpenditures(rate, newCode, settings);
    _settings.primaryCurrencyCode = newCode;
    await saveSettings();
  }
}