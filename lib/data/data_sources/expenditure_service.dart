import 'package:hive/hive.dart';
import '../../domain/entities/expenditure.dart';

class ExpenditureService {
  Future<Box<Expenditure>> getBox() async {
    if (!Hive.isBoxOpen('expenditures')) {
      await Hive.openBox<Expenditure>('expenditures');
    }
    return Hive.box<Expenditure>('expenditures');
  }

  Future<List<Expenditure>> getAll() async {
    final box = await getBox();
    return box.values.toList();
  }

  Future<void> add(Expenditure item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> update(Expenditure item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    final box = await getBox();
    await box.delete(id);
  }
}
