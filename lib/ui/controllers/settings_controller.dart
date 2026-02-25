import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Domain
import '../../domain/entities/settings.dart';

class SettingsController with ChangeNotifier {
  static const String settingsBoxName = 'settings';
  
  late Settings _settings;
  bool isInitialized = false;

  Settings get settings => _settings;

  SettingsController();

  Future<void> initialize() async {
    if (isInitialized) return;
    
    final box = await Hive.openBox<Settings>(settingsBoxName);
    _settings = box.get(0) ?? Settings();

    // Nếu chưa có settings, tạo mặc định
    if (!_settings.isInBox) {
      await box.put(0, _settings);
    }
    
    isInitialized = true;
    notifyListeners();
  }

  // Chỉ cần hàm này nếu user muốn đổi đơn vị tiền tệ ngay trong lúc edit (nếu có tính năng đó)
  Future<void> saveSettings() async {
    await _settings.save();
    notifyListeners();
  }
}