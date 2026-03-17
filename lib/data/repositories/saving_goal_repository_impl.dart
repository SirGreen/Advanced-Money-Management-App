import '../../domain/entities/saving_goal.dart';
import '../../domain/entities/saving_contribution.dart';
import '../../domain/repositories/saving_goal_repository.dart';
import '../data_sources/saving_goal_service.dart';
import '../data_sources/saving_contribution_service.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalService _savingGoalService;
  final SavingContributionService _contributionService;

  SavingGoalRepositoryImpl(this._savingGoalService, this._contributionService);

  @override
  Future<List<SavingGoal>> getAllSavingGoals() async {
    return await _savingGoalService.getAll();
  }

  @override
  Future<SavingGoal?> getSavingGoalById(String id) async {
    return await _savingGoalService.getById(id);
  }

  @override
  Future<void> addSavingGoal(SavingGoal goal) async {
    await _savingGoalService.add(goal);
  }

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {
    await _savingGoalService.update(goal);
  }

  @override
  Future<void> deleteSavingGoal(String id) async {
    await _savingGoalService.delete(id);
    // Also delete all contributions for this goal
    final contributions = await _contributionService.getByGoalId(id);
    for (final contribution in contributions) {
      await _contributionService.delete(contribution.id);
    }
  }

  @override
  Future<List<SavingContribution>> getContributionsByGoalId(String goalId) async {
    return await _contributionService.getByGoalId(goalId);
  }

  @override
  Future<void> addContribution(SavingContribution contribution) async {
    await _contributionService.add(contribution);
    // Update the saving goal's current amount
    final goal = await _savingGoalService.getById(contribution.savingGoalId);
    if (goal != null) {
      goal.currentAmount += contribution.amount;
      await _savingGoalService.update(goal);
    }
  }

  @override
  Future<void> updateContribution(SavingContribution contribution) async {
    final oldContribution = await _contributionService.getBox().then((box) {
      for (var item in box.values) {
        if (item.id == contribution.id) return item;
      }
      return null;
    });

    if (oldContribution != null) {
      final goal = await _savingGoalService.getById(contribution.savingGoalId);
      if (goal != null) {
        // Adjust the goal's current amount based on difference
        goal.currentAmount = goal.currentAmount - oldContribution.amount + contribution.amount;
        await _savingGoalService.update(goal);
      }
    }
    await _contributionService.update(contribution);
  }

  @override
  Future<void> deleteContribution(String id) async {
    final box = await _contributionService.getBox();
    final contribution = box.get(id);
    if (contribution != null) {
      // Update the saving goal's current amount
      final goal = await _savingGoalService.getById(contribution.savingGoalId);
      if (goal != null) {
        goal.currentAmount -= contribution.amount;
        await _savingGoalService.update(goal);
      }
      await _contributionService.delete(id);
    }
  }
}
