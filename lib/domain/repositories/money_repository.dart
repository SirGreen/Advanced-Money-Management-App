import '../entities/money_entity.dart';

// các get/set đơn giản thôi, cái này là interface nên ko đụng tới
// hive/data source. chỉ ghi các method get/set, r implement lại sau trong
// 1 class dưới folder "data/repositories"
abstract class MoneyRepository {
  Future<MoneyEntity> getMoneySpent();
  Future<void> saveMoneySpent(int amount);
}
