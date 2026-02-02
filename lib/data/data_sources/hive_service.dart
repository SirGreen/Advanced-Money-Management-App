import 'package:hive/hive.dart';

class HiveService {
  Future<Box> _getBox() async {
    return await Hive.openBox('moneyBox');
  }

  Future<int> read() async {
    final box = await _getBox();
    return box.get('amount', defaultValue: 0);
  }

  Future<void> write(int amount) async {
    final box = await _getBox();
    await box.put('amount', amount);
  }
}
