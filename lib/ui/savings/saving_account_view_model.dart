import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/saving_account.dart';

class SavingAccountViewModel extends ChangeNotifier {
  List<SavingAccount> _savingAccounts = [];
  bool _isLoading = false;
  String? _error;

  List<SavingAccount> get savingAccounts => _savingAccounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Box<SavingAccount>> _getBox() async {
    if (!Hive.isBoxOpen('saving_accounts')) {
      await Hive.openBox<SavingAccount>('saving_accounts');
    }
    return Hive.box<SavingAccount>('saving_accounts');
  }

  Future<void> loadSavingAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final box = await _getBox();
      _savingAccounts = box.values.toList();
      _savingAccounts.sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSavingAccount({
    required String name,
    required double balance,
    String? notes,
    double? annualInterestRate,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      const uuid = Uuid();
      final account = SavingAccount(
        id: uuid.v4(),
        name: name,
        balance: balance,
        notes: notes,
        annualInterestRate: annualInterestRate,
        startDate: startDate ?? DateTime.now(),
        endDate: endDate,
      );

      final box = await _getBox();
      await box.put(account.id, account);
      await loadSavingAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSavingAccount(SavingAccount account) async {
    try {
      final box = await _getBox();
      await box.put(account.id, account);
      await loadSavingAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSavingAccount(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      await loadSavingAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
