import '../../domain/repositories/money_repository.dart';
import '../../domain/entities/money_entity.dart';
import '../data_sources/hive_service.dart';

class MoneyRepositoryImpl implements MoneyRepository {
  final HiveService _src;

  MoneyRepositoryImpl(this._src);

  @override
  Future<MoneyEntity> getMoneySpent() async {
    final rawAmount = await _src.read();
    return MoneyEntity(totalSpent: rawAmount);
  }

  @override
  Future<void> saveMoneySpent(int amount) async {
    await _src.write(amount);
  }
}
