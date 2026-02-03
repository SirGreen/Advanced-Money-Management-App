import '../../domain/repositories/money_repository.dart';
import '../../domain/entities/money_entity.dart';
import '../data_sources/hive_service.dart';

// repository nó sẽ xài service ở lớp dưới để đơn giản hóa việc
// nhập xuất

// nên tạo abstract class (tức interface trong folder "domain/repositories")
// trước r implement nó ở đây dựa trên service

// các method dưới đây y chang cái MoneyRepository.
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
