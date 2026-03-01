import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';

class ExpenditureViewModel extends ChangeNotifier {
  final ExpenditureRepository _repository;
  final TagRepository _tagRepository;

  final ScanReceiptUseCase _scanReceiptUseCase;

  List<Expenditure> _normalExpenditures = [];
  List<Expenditure> get expenditures =>
      _normalExpenditures; // For Dashboard (Normal only)

  List<Expenditure> _recurringInstances = [];
  List<Expenditure> get recurringInstances =>
      _recurringInstances; // For Recurring Tab

  List<Tag> tags = [];
  bool isLoading = false;
  String? errorMessage;

  ExpenditureViewModel({
    required ExpenditureRepository repository,
    required TagRepository tagRepository,
    required ScanReceiptUseCase scanReceiptUseCase,
  }) : _repository = repository,
       _tagRepository = tagRepository,
       _scanReceiptUseCase = scanReceiptUseCase {
    _loadTags();
    loadExpenditures();
  }

  Future<void> loadExpenditures() async {
    isLoading = true;
    notifyListeners();
    try {
      final all = await _repository.getExpenditures();

      _normalExpenditures = all
          .where((e) => e.scheduledExpenditureId == null)
          .toList();
      _normalExpenditures.sort((a, b) => b.date.compareTo(a.date));

      _recurringInstances = all
          .where((e) => e.scheduledExpenditureId != null)
          .toList();
      _recurringInstances.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTags() async {
    tags = await _tagRepository.getAllTags();
    if (tags.isEmpty) {
      await _seedDefaultTags();
      tags = await _tagRepository.getAllTags();
    }
    notifyListeners();
  }

  Future<void> _seedDefaultTags() async {
    final defaults = [
      Tag(
        id: 'food',
        name: 'Food',
        colorValue: 0xFFFF5722,
        iconName: 'fastfood',
      ),
      Tag(
        id: 'transport',
        name: 'Transport',
        colorValue: 0xFF2196F3,
        iconName: 'directions_bus',
      ),
      Tag(
        id: 'shopping',
        name: 'Shopping',
        colorValue: 0xFFE91E63,
        iconName: 'shopping_bag',
      ),
      Tag(
        id: 'income',
        name: 'Income',
        colorValue: 0xFF4CAF50,
        iconName: 'attach_money',
      ),
    ];
    for (final tag in defaults) {
      await _tagRepository.addTag(tag);
    }
  }

  Future<void> addExpenditure(Expenditure expenditure) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.addExpenditure(expenditure);
      await loadExpenditures();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuickExpenditure({
    required double amount,
    required bool isIncome,
    required String mainTagId,
    DateTime? date,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final newExpenditure = Expenditure(
        id: const Uuid().v4(),
        articleName: isIncome ? 'Income' : 'Expense',
        amount: amount,
        date: date ?? DateTime.now(),
        mainTagId: mainTagId,
        isIncome: isIncome,
        currencyCode: 'VND', // Default
      );

      await _repository.addExpenditure(newExpenditure);
      await loadExpenditures(); // Refresh list immediately
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpenditure(Expenditure expenditure) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.updateExpenditure(expenditure);
      await loadExpenditures();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpenditure(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteExpenditure(id);
      await loadExpenditures();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> processReceipt(File imageFile) async {
    try {
      final t = await _tagRepository.getAllTags();
      final tagNames = t.map((t) => t.name).toList();
      return await _scanReceiptUseCase.call(imageFile, tagNames);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // TODO: implement this
  Future<List<Object>> recommendTags(String articleName) async {
    return [];
  }
}
