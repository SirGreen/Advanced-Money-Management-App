import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/search_filter.dart';
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

  List<Expenditure> getFilteredExpenditures(SearchFilter filter) {
    var results = List<Expenditure>.from(_normalExpenditures);

    // Apply keywords
    if (filter.keyword != null && filter.keyword!.trim().isNotEmpty) {
      final key = filter.keyword!.trim().toLowerCase();
      results = results.where((e) {
        final nameMatch = e.articleName.toLowerCase().contains(key);
        final notesMatch = e.notes?.toLowerCase().contains(key) ?? false;
        return nameMatch || notesMatch;
      }).toList();
    }

    // Apply date range
    if (filter.startDate != null) {
      results = results.where((e) {
        final d = e.date;
        return d.isAfter(filter.startDate!.subtract(const Duration(days: 1))) &&
            d.isBefore(filter.endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply amount range
    if (filter.minAmount != null) {
      results = results
          .where((e) => (e.amount ?? 0) >= filter.minAmount!)
          .toList();
    }
    if (filter.maxAmount != null) {
      results = results
          .where((e) => (e.amount ?? 0) <= filter.maxAmount!)
          .toList();
    }

    // Apply Tags
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      final selectedTagIds = filter.tags!.map((t) => t.id).toSet();
      results = results
          .where((e) => selectedTagIds.contains(e.mainTagId))
          .toList();
    }

    // Apply Transaction Type
    if (filter.transactionType != TransactionTypeFilter.all) {
      final wantsIncome =
          filter.transactionType == TransactionTypeFilter.income;
      results = results.where((e) => e.isIncome == wantsIncome).toList();
    }

    // Since sorting is handled in the UI in the legacy app, we can just return the filtered list,
    // or apply the default sort here. The legacy UI does its own sorting.
    return results;
  }

  Future<List<Object>> recommendTags(String articleName) async {
    if (articleName.isEmpty || articleName.length < 3) {
      return [];
    }
    final existingTagNames = tags.map((t) => t.name).toList();
    final recommendationJson = await _tagRepository.recommendTags(
      articleName,
      existingTagNames,
    );
    if (recommendationJson == null) {
      return [];
    }
    final List<Object> recommendations = [];
    if (recommendationJson['existing_tags'] is List) {
      final List<String> suggestedNames = List<String>.from(
        recommendationJson['existing_tags'],
      );
      for (var name in suggestedNames) {
        try {
          final tag = tags.firstWhere(
            (t) => t.name.toLowerCase() == name.toLowerCase(),
          );

          if (!recommendations.any(
            (item) => item is Tag && item.id == tag.id,
          )) {
            recommendations.add(tag);
          }
        } catch (e) {
          debugPrint(
            "Could not find recommended existing tag: $name. Error: $e",
          );
        }
      }
    }
    if (recommendationJson['new_tag_suggestion'] is String) {
      final String newTagName = recommendationJson['new_tag_suggestion'];
      if (newTagName.isNotEmpty) {
        final alreadyExists = tags.any(
          (t) => t.name.toLowerCase() == newTagName.toLowerCase(),
        );
        final alreadyRecommended = recommendations.any(
          (item) =>
              item is String && item.toLowerCase() == newTagName.toLowerCase(),
        );
        if (!alreadyExists && !alreadyRecommended) {
          recommendations.add(newTagName);
        }
      }
    }
    return recommendations;
  }
}
