import '../entities/money_entity.dart';

abstract class MoneyRepository {
  Future<MoneyEntity> getMoneySpent();
  Future<void> saveMoneySpent(int amount);
}
