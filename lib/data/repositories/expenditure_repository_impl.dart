import 'package:hive/hive.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/entities/expenditure.dart';
import '../data_sources/hive_service.dart';

class ExpenditureRepositoryImpl implements ExpenditureRepository {
  ExpenditureRepositoryImpl(HiveService hiveService);

  Future<Box<Expenditure>> get _box async {
    if (!Hive.isBoxOpen('expenditures')) {
      await Hive.openBox<Expenditure>('expenditures');
    }
    return Hive.box<Expenditure>('expenditures');
  }

  @override
  Future<List<Expenditure>> getExpenditures() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> addExpenditure(Expenditure expenditure) async {
    final box = await _box;
    await box.put(expenditure.id, expenditure);
  }

  @override
  Future<void> updateExpenditure(Expenditure expenditure) async {
    final box = await _box;
    await box.put(expenditure.id, expenditure);
  }

  @override
  Future<void> deleteExpenditure(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
