import '../entities/saving_goal.dart';
import '../entities/saving_contribution.dart';

abstract class SavingGoalRepository {
  Future<List<SavingGoal>> getAllSavingGoals();
  Future<SavingGoal?> getSavingGoalById(String id);
  Future<void> addSavingGoal(SavingGoal goal);
  Future<void> updateSavingGoal(SavingGoal goal);
  Future<void> deleteSavingGoal(String id);
  Future<List<SavingContribution>> getContributionsByGoalId(String goalId);
  Future<void> addContribution(SavingContribution contribution);
  Future<void> updateContribution(SavingContribution contribution);
  Future<void> deleteContribution(String id);
}
