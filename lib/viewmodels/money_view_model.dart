import 'package:flutter/material.dart';
import '../models/money_model.dart';

class MoneyViewModel extends ChangeNotifier {
  final MoneyModel _model = MoneyModel(totalSpent: 0);

  int get totalSpent => _model.totalSpent;

  void addExpense(int amount) {
    _model.totalSpent += amount;
    
    notifyListeners(); 
  }

  void resetSpending() {
    _model.totalSpent = 0;
    notifyListeners();
  }
}