import '../../domain/repositories/money_repository.dart';
import '../../domain/entities/money_entity.dart';
import '../data_sources/in_memory_service.dart';

class MoneyRepositoryImpl implements MoneyRepository {
  final InMemoryService _localStorage;

  MoneyRepositoryImpl(this._localStorage);

  @override
  Future<MoneyEntity> getMoneySpent() async {
    final rawAmount = await _localStorage.read();
    return MoneyEntity(totalSpent: rawAmount);
  }

  @override
  Future<void> saveMoneySpent(int amount) async {
    await _localStorage.write(amount);
  }
}
