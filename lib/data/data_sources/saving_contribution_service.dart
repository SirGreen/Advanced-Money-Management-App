import 'package:hive/hive.dart';
import '../../domain/entities/saving_contribution.dart';

class SavingContributionService {
  Future<Box<SavingContribution>> getBox() async {
    if (!Hive.isBoxOpen('saving_contributions')) {
      await Hive.openBox<SavingContribution>('saving_contributions');
    }
    return Hive.box<SavingContribution>('saving_contributions');
  }

  Future<List<SavingContribution>> getAll() async {
    final box = await getBox();
    return box.values.toList();
  }

  Future<List<SavingContribution>> getByGoalId(String goalId) async {
    final box = await getBox();
    return box.values
        .where((contribution) => contribution.savingGoalId == goalId)
        .toList();
  }

  Future<void> add(SavingContribution item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> update(SavingContribution item) async {
    final box = await getBox();
    await box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    final box = await getBox();
    await box.delete(id);
  }
}
