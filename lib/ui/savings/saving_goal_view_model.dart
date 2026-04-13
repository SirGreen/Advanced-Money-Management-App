import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/entities/saving_contribution.dart';
import '../../domain/repositories/saving_goal_repository.dart';

class SavingGoalViewModel extends ChangeNotifier {
  final SavingGoalRepository _repository;

  List<SavingGoal> _savingGoals = [];
  final Map<String, List<SavingContribution>> _contributionsByGoal = {};
  bool _isLoading = false;
  String? _error;

  SavingGoalViewModel({required SavingGoalRepository repository})
      : _repository = repository;

  List<SavingGoal> get savingGoals => _savingGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSavingGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savingGoals = await _repository.getAllSavingGoals();

      // Load contributions for each goal
      _contributionsByGoal.clear();
      for (final goal in _savingGoals) {
        final contributions = await _repository.getContributionsByGoalId(goal.id);
        _contributionsByGoal[goal.id] = contributions;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSavingGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? endDate,
    String? notes,
  }) async {
    try {
      const uuid = Uuid();
      final goal = SavingGoal(
        id: uuid.v4(),
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        startDate: DateTime.now(),
        endDate: endDate,
        notes: notes,
      );
      await _repository.addSavingGoal(goal);
      _savingGoals.add(goal);
      _contributionsByGoal[goal.id] = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSavingGoal(SavingGoal goal) async {
    try {
      await _repository.updateSavingGoal(goal);
      final index = _savingGoals.indexWhere((g) => g.id == goal.id);
      if (index >= 0) {
        _savingGoals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSavingGoal(String goalId) async {
    try {
      await _repository.deleteSavingGoal(goalId);
      _savingGoals.removeWhere((g) => g.id == goalId);
      _contributionsByGoal.remove(goalId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addContribution({
    required String goalId,
    required double amount,
    DateTime? date,
    String? note,
  }) async {
    try {
      const uuid = Uuid();
      final contribution = SavingContribution(
        id: uuid.v4(),
        savingGoalId: goalId,
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
        createdAt: DateTime.now(),
      );
      await _repository.addContribution(contribution);

      // Update local list
      if (!_contributionsByGoal.containsKey(goalId)) {
        _contributionsByGoal[goalId] = [];
      }
      _contributionsByGoal[goalId]?.add(contribution);

      // Reload goal from repository to get updated currentAmount
      final updatedGoal = await _repository.getSavingGoalById(goalId);
      final goalIndex = _savingGoals.indexWhere((g) => g.id == goalId);
      if (goalIndex >= 0 && updatedGoal != null) {
        _savingGoals[goalIndex] = updatedGoal;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateContribution(SavingContribution contribution) async {
    try {
      await _repository.updateContribution(contribution);
      final list = _contributionsByGoal[contribution.savingGoalId];
      if (list != null) {
        final index = list.indexWhere((c) => c.id == contribution.id);
        if (index >= 0) {
          list[index] = contribution;
        }
      }

      // Reload goal from repository to get updated currentAmount
      final updatedGoal = await _repository.getSavingGoalById(contribution.savingGoalId);
      final goalIndex = _savingGoals.indexWhere((g) => g.id == contribution.savingGoalId);
      if (goalIndex >= 0 && updatedGoal != null) {
        _savingGoals[goalIndex] = updatedGoal;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteContribution(String contributionId, String goalId) async {
    try {
      await _repository.deleteContribution(contributionId);
      final list = _contributionsByGoal[goalId];
      if (list != null) {
        list.removeWhere((c) => c.id == contributionId);
      }

      // Reload goal from repository to get updated currentAmount
      final updatedGoal = await _repository.getSavingGoalById(goalId);
      final goalIndex = _savingGoals.indexWhere((g) => g.id == goalId);
      if (goalIndex >= 0 && updatedGoal != null) {
        _savingGoals[goalIndex] = updatedGoal;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<SavingContribution> getContributionsForGoal(String goalId) {
    return _contributionsByGoal[goalId] ?? [];
  }

  SavingGoal? getGoalById(String goalId) {
    try {
      return _savingGoals.firstWhere((g) => g.id == goalId);
    } catch (e) {
      return null;
    }
  }
}
