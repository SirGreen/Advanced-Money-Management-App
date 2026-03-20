import 'package:hive/hive.dart';
import '../../domain/entities/saving_goal.dart';

class SavingGoalService {
  Future<Box<SavingGoal>> getBox() async {
    if (!Hive.isBoxOpen('saving_goals')) {
      await Hive.openBox<SavingGoal>('saving_goals');
    }
    return Hive.box<SavingGoal>('saving_goals');
  }

  Future<List<SavingGoal>> getAll() async {
    final box = await getBox();
    return box.values.toList();
  }

  Future<SavingGoal?> getById(String id) async {
    final box = await getBox();
    return box.get(id);
  }

  Future<void> add(SavingGoal item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> update(SavingGoal item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    final box = await getBox();
    await box.delete(id);
  }
}
