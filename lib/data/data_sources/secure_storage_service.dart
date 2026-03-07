import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _appLockKey = 'is_app_lock_enabled';

  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(key: _appLockKey, value: enabled.toString());
  }

  Future<bool> isAppLockEnabled() async {
    final value = await _storage.read(key: _appLockKey);
    return value == 'true';
  }
}
