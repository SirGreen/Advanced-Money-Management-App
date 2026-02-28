import 'package:hive/hive.dart';
import '../../domain/entities/scheduled_expenditure.dart';

class ScheduledExpenditureService {
  Future<Box<ScheduledExpenditure>> getBox() async {
    if (!Hive.isBoxOpen('scheduled_expenditures')) {
      await Hive.openBox<ScheduledExpenditure>('scheduled_expenditures');
    }
    return Hive.box<ScheduledExpenditure>('scheduled_expenditures');
  }

  Future<List<ScheduledExpenditure>> getAll() async {
    final box = await getBox();
    return box.values.toList();
  }

  Future<void> add(ScheduledExpenditure item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> update(ScheduledExpenditure item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    final box = await getBox();
    await box.delete(id);
  }
}
