import 'package:hive/hive.dart';

class MoneyService {
  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen('moneyBox')) {
      await Hive.openBox('moneyBox');
    }
    return Hive.box('moneyBox');
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
