import 'package:hive/hive.dart';
import '../../domain/repositories/scheduled_expenditure_repository.dart';
import '../../domain/entities/scheduled_expenditure.dart';

class ScheduledExpenditureRepositoryImpl
    implements ScheduledExpenditureRepository {
  ScheduledExpenditureRepositoryImpl();

  Future<Box<ScheduledExpenditure>> get _box async {
    if (!Hive.isBoxOpen('scheduled_expenditures')) {
      await Hive.openBox<ScheduledExpenditure>('scheduled_expenditures');
    }
    return Hive.box<ScheduledExpenditure>('scheduled_expenditures');
  }

  @override
  Future<List<ScheduledExpenditure>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<void> add(ScheduledExpenditure item) async {
    final box = await _box;
    await box.put(item.id, item);
  }

  @override
  Future<void> update(ScheduledExpenditure item) async {
    final box = await _box;
    await box.put(item.id, item);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
