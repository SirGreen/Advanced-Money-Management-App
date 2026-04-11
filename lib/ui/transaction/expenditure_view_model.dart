import 'dart:io';

import 'package:adv_money_mana/domain/repositories/settings_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../domain/entities/expenditure.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/entities/settings.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';

class ExpenditureViewModel extends ChangeNotifier {
  final ExpenditureRepository _repository;
  final TagRepository _tagRepository;
  final SettingsRepository _settingsRepository;

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
    required SettingsRepository settingsRepository,
    required ScanReceiptUseCase scanReceiptUseCase,
  }) : _repository = repository,
       _tagRepository = tagRepository,
       _settingsRepository = settingsRepository,
       _scanReceiptUseCase = scanReceiptUseCase {
    loadExpenditures();
  }

  // will be used by ChangeNotifierProxyProvider<TagViewModel, ExpenditureViewModel> in main.dart
  // i'd rather use Streams provided by reactive Repositories but whatever...
  void updateTags(List<Tag> newTags) {
    tags = newTags;
    notifyListeners();
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

  Tag? getTagById(String id) {
    return tags.firstWhereOrNull((tag) => tag.id == id);
  }

  double getAllTimeMoneyLeft() {
    double total = 0;
    for (var exp in _normalExpenditures) {
      total += (exp.isIncome ? 1 : -1) * (exp.amount ?? 0);
    }
    for (var exp in _recurringInstances) {
      total += (exp.isIncome ? 1 : -1) * (exp.amount ?? 0);
    }
    return total;
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
    List<String> subTagIds = const [],
    DateTime? date,
    String? notes,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final settings = await _settingsRepository.getSettings();
      final newExpenditure = Expenditure(
        id: const Uuid().v4(),
        articleName: isIncome ? 'Income' : 'Expense',
        amount: amount,
        date: date ?? DateTime.now(),
        mainTagId: mainTagId,
        subTagIds: subTagIds,
        isIncome: isIncome,
        currencyCode: settings.primaryCurrencyCode,
        notes: notes,
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
    final settings = await _settingsRepository.getSettings();
    if (settings.geminiApiKey == null) {
      debugPrint("Cannot analyze budget: Missing LLM API key.");
      return null;
    }

    try {
      final tagNames = tags.map((t) => t.name).toList();
      return await _scanReceiptUseCase.call(settings, imageFile, tagNames);
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
          .where(
            (e) =>
                selectedTagIds.contains(e.mainTagId) ||
                e.subTagIds.any((subId) => selectedTagIds.contains(subId)),
          )
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

  double getSpentAmountForTagBudget(Tag tag) {
    if (tag.budgetAmount == null ||
        tag.budgetAmount! <= 0 ||
        tag.budgetInterval == 'None') {
      return 0.0;
    }
    try {
      final budgetPeriod = _getCurrentBudgetPeriod(tag.budgetInterval);
      final searchFilter = SearchFilter(
        tags: [tag],
        startDate: budgetPeriod.start,
        endDate: budgetPeriod.end,
        transactionType: TransactionTypeFilter.expense,
      );
      final transactionsForPeriod = getFilteredExpenditures(searchFilter);
      return transactionsForPeriod.fold(
        0.0,
        (sum, exp) => sum + (exp.amount ?? 0),
      );
    } catch (_) {
      return 0.0;
    }
  }

  // Utils for LLM-related things

  DateTimeRange _getCurrentBudgetPeriod(String interval) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (interval) {
      case 'Weekly':
        int daysToSubtract = now.weekday - 1; // Assumes Monday is 1
        startDate = DateTime(now.year, now.month, now.day - daysToSubtract);
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        endDate = (now.month < 12)
            ? DateTime(now.year, now.month + 1, 0)
            : DateTime(now.year + 1, 1, 0);
        break;
      case 'Yearly':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      default:
        throw ArgumentError(
          "Budget analysis requires a 'Weekly', 'Monthly', or 'Yearly' interval.",
        );
    }

    startDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      0,
      0,
      0,
    );
    endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return DateTimeRange(start: startDate, end: endDate);
  }

  // LLM-related functionality

  Future<List<Object>> recommendTags(String articleName) async {
    final settings = await _settingsRepository.getSettings();
    if (articleName.isEmpty ||
        articleName.length < 3 ||
        settings.geminiApiKey == null) {
      return [];
    }
    final existingTagNames = tags.map((t) => t.name).toList();
    final recommendationJson = await _tagRepository.recommendTags(
      settings,
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

  Future<Map<String, dynamic>?> analyzeBudgetForTag(Tag tag) async {
    final settings = await _settingsRepository.getSettings();
    if (settings.geminiApiKey == null) {
      debugPrint("Cannot analyze budget: Missing LLM API key.");
      return null;
    }

    if (tag.budgetAmount == null ||
        tag.budgetAmount! <= 0 ||
        tag.budgetInterval == 'None') {
      debugPrint(
        "Cannot analyze budget: No amount or interval set for tag '${tag.name}'.",
      );
      return null;
    }

    try {
      final budgetPeriod = _getCurrentBudgetPeriod(tag.budgetInterval);
      final searchFilter = SearchFilter(
        tags: [tag],
        startDate: budgetPeriod.start,
        endDate: budgetPeriod.end,
      );
      final transactionsForPeriod = getFilteredExpenditures(searchFilter);

      final serializedTransactions = transactionsForPeriod
          .map(
            (exp) => {
              'name': exp.articleName,
              'amount': exp.amount,
              'date': exp.date.toIso8601String().split('T').first,
              'is_income': exp.isIncome,
            },
          )
          .toList();

      final budgetDetails = {
        'category_name': tag.name,
        'amount': tag.budgetAmount,
        'interval': tag.budgetInterval,
        'start_date': budgetPeriod.start.toIso8601String().split('T').first,
      };

      final analysis = await _repository.analyzeBudget(
        settings: settings,
        transactions: serializedTransactions,
        budgetDetails: budgetDetails,
        currentDate: DateTime.now().toIso8601String().split('T').first,
        budgetEndDate: budgetPeriod.end.toIso8601String().split('T').first,
        userContext: settings.userContext,
      );

      return analysis;
    } catch (e) {
      debugPrint("Error during budget analysis for tag '${tag.name}': $e");
      return null;
    }
  }

  Future<ReportData> getReportData(DateTimeRange dateRange) async {
    // Filter expenditures in date range
    final transactionsInPeriod = _normalExpenditures
        .where((exp) {
          final expDate = exp.date;
          return expDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              expDate.isBefore(dateRange.end.add(const Duration(days: 1)));
        })
        .toList();

    // Add recurring instances too
    transactionsInPeriod.addAll(
      _recurringInstances.where((exp) {
        final expDate = exp.date;
        return expDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            expDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }),
    );

    // Group by tag for income and expenses
    final Map<Tag, TagReportData> incomeByTag = {};
    final Map<Tag, TagReportData> expenseByTag = {};

    double totalIncome = 0;
    double totalExpense = 0;

    for (final exp in transactionsInPeriod) {
      final tag = getTagById(exp.mainTagId);
      if (tag == null) continue;

      final amount = exp.amount ?? 0;

      if (exp.isIncome) {
        totalIncome += amount;
        if (incomeByTag.containsKey(tag)) {
          incomeByTag[tag]!.totalAmount += amount;
          incomeByTag[tag]!.transactionCount += 1;
        } else {
          incomeByTag[tag] = TagReportData(
            totalAmount: amount,
            transactionCount: 1,
          );
        }
      } else {
        totalExpense += amount;
        if (expenseByTag.containsKey(tag)) {
          expenseByTag[tag]!.totalAmount += amount;
          expenseByTag[tag]!.transactionCount += 1;
        } else {
          expenseByTag[tag] = TagReportData(
            totalAmount: amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Calculate line chart data
    final LineChartReportData? lineChartData = _computeLineChartData(
      transactionsInPeriod,
      dateRange,
    );

    return ReportData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeByTag: incomeByTag,
      expenseByTag: expenseByTag,
      lineChartData: lineChartData,
    );
  }

  LineChartReportData? _computeLineChartData(
    List<Expenditure> transactions,
    DateTimeRange dateRange,
  ) {
    if (transactions.isEmpty) return null;

    final Map<DateTime, double> incomeByDay = {};
    final Map<DateTime, double> expenseByDay = {};

    // Initialize all days in range
    DateTime current = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
    final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
    while (current.isBefore(end.add(const Duration(days: 1)))) {
      incomeByDay[current] = 0;
      expenseByDay[current] = 0;
      current = current.add(const Duration(days: 1));
    }

    // Aggregate by day
    for (final exp in transactions) {
      final dayKey = DateTime(exp.date.year, exp.date.month, exp.date.day);
      if (exp.isIncome) {
        incomeByDay[dayKey] = (incomeByDay[dayKey] ?? 0) + (exp.amount ?? 0);
      } else {
        expenseByDay[dayKey] = (expenseByDay[dayKey] ?? 0) + (exp.amount ?? 0);
      }
    }

    // Convert to sorted lists
    final sortedDays = incomeByDay.keys.toList()..sort();
    if (sortedDays.isEmpty) return null;

    // Create FlSpots
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      incomeSpots.add(FlSpot(i.toDouble(), incomeByDay[day] ?? 0));
      expenseSpots.add(FlSpot(i.toDouble(), expenseByDay[day] ?? 0));
    }

    double maxY = 0;
    for (final spot in [...incomeSpots, ...expenseSpots]) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY * 1.1; // Add 10% padding

    return LineChartReportData(
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      minX: 0,
      maxX: (sortedDays.length - 1).toDouble(),
      maxY: maxY,
    );
  }

  Future<Map<String, dynamic>?> analyzeFullReport(
    ReportData reportData,
    DateTimeRange dateRange,
    Settings settings,
  ) async {
    List<Map<String, dynamic>> createBreakdownList(
      Map<Tag, TagReportData> sections,
    ) {
      return sections.entries.map((entry) {
        final Tag tag = entry.key;
        final TagReportData tagData = entry.value;
        return {'category': tag.name, 'amount': tagData.totalAmount};
      }).toList();
    }

    final incomeBreakdown = createBreakdownList(reportData.incomeByTag);
    final expenseBreakdown = createBreakdownList(reportData.expenseByTag);

    final SearchFilter filter = SearchFilter(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
    final List<Expenditure> transactionsInPeriod = getFilteredExpenditures(
      filter,
    );

    final serializedTransactions = transactionsInPeriod.map((exp) {
      final tagName = getTagById(exp.mainTagId)?.name ?? 'Uncategorized';
      return {
        'name': exp.articleName,
        'amount': exp.amount,
        'date': exp.date.toIso8601String().split('T').first,
        'is_income': exp.isIncome,
        'category': tagName,
      };
    }).toList();
    return await _repository.analyzeFinancialReport(
      settings: settings,
      dateRangeStart: dateRange.start.toIso8601String().split('T').first,
      dateRangeEnd: dateRange.end.toIso8601String().split('T').first,
      userContext: settings.userContext,
      totalIncome: reportData.totalIncome,
      totalExpenses: reportData.totalExpense,
      incomeBreakdown: incomeBreakdown,
      expenseBreakdown: expenseBreakdown,
      transactionList: serializedTransactions,
    );
  }
}
