import 'package:flutter/material.dart';
import '../../domain/repositories/scheduled_expenditure_repository.dart';
import '../../domain/entities/scheduled_expenditure.dart';

class ScheduledExpenditureViewModel extends ChangeNotifier {
  final ScheduledExpenditureRepository _repository;

  List<ScheduledExpenditure> scheduledExpenditures = [];
  bool isLoading = false;
  String? errorMessage;

  ScheduledExpenditureViewModel(this._repository) {
    loadScheduledExpenditures();
  }

  Future<void> loadScheduledExpenditures() async {
    isLoading = true;
    notifyListeners();
    try {
      scheduledExpenditures = await _repository.getAll();
      debugPrint(
        "ViewModel: Loaded ${scheduledExpenditures.length} items from Hive.",
      );
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("ViewModel: Error loading items: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addScheduledExpenditure(ScheduledExpenditure item) async {
    debugPrint("ViewModel: Adding scheduled item ${item.name}");
    await _repository.add(item);
    debugPrint("ViewModel: Added to repo. Reloading...");
    await loadScheduledExpenditures();
    debugPrint("ViewModel: Reloaded. Count: ${scheduledExpenditures.length}");
  }

  Future<void> updateScheduledExpenditure(ScheduledExpenditure item) async {
    await _repository.update(item);
    await loadScheduledExpenditures();
  }

  Future<void> deleteScheduledExpenditure(String id) async {
    await _repository.delete(id);
    await loadScheduledExpenditures();
  }
}
