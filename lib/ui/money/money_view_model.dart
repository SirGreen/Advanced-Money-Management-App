import 'package:flutter/material.dart';
import '../../domain/entities/money_entity.dart';
import '../../domain/repositories/money_repository.dart';

class MoneyViewModel extends ChangeNotifier {
  final MoneyRepository _repository;

  MoneyEntity _data = const MoneyEntity(totalSpent: 0);
  bool isLoading = false;

  MoneyViewModel({required MoneyRepository repository})
    : _repository = repository;

  int get totalSpent => _data.totalSpent;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    _data = await _repository.getMoneySpent();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(int amount) async {
    final newTotal = _data.totalSpent + amount;

    _data = MoneyEntity(totalSpent: newTotal);
    notifyListeners();

    await _repository.saveMoneySpent(newTotal);
  }
}
