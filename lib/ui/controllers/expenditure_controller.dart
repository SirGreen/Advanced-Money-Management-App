import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:money_mana_app/data/model/expenditure.dart';
import 'package:money_mana_app/data/model/report_data.dart';
import 'package:money_mana_app/data/model/settings.dart';
import 'package:money_mana_app/data/model/tag.dart';
import 'package:money_mana_app/app/services/currency_api_service.dart';
import 'package:money_mana_app/app/services/currency_service.dart';
import 'package:money_mana_app/app/services/database_service.dart';
import 'package:money_mana_app/app/services/expenditure_service.dart';
import 'package:money_mana_app/app/services/reporting_service.dart';
import 'package:money_mana_app/app/services/tag_service.dart';
import 'package:money_mana_app/l10n/app_localizations.dart';

class ExpenditureController with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  late final ExpenditureService _expenditureService;
  late final TagService _tagService;
  late final ReportingService _reportingService;
  late final CurrencyService _currencyService;

  List<Expenditure> _expenditures = [];
  List<Tag> _tags = [];
  AppLocalizations? _l10n;
  bool _isLoading = false;
  bool _hasMoreExpenditures = true;

  List<Expenditure> get expenditures => _expenditures;
  List<Tag> get tags => _tags;


  bool get isLoading => _isLoading;
  bool get hasMoreExpenditures => _hasMoreExpenditures;
  static String get defaultTagId => TagService.defaultTagId;

  ExpenditureController() {
    _expenditureService = ExpenditureService(_dbService);
    _tagService = TagService(_dbService);
    _reportingService = ReportingService(_dbService);
    final apiService = CurrencyAPIService();
    _currencyService = CurrencyService(_dbService, apiService);
  }

  Future<void> initialize(AppLocalizations l10n, Settings settings) async {
    _l10n = l10n;
    await _loadAllNonExpenditureData();
    await loadInitialExpenditures(settings);
  }

  Future<void> _loadAllNonExpenditureData() async {
    _tags = _tagService.getAllTags();
    if (_tags.isEmpty && _l10n != null) {
      await _tagService.createDefaultTags(_l10n!);
      _tags = _tagService.getAllTags();
    }
  }

  Future<void> loadInitialExpenditures(Settings settings) async {
    if (_isLoading) return;
    _setLoading(true);
    _expenditures = [];
    final result = await _expenditureService.getExpendituresWithPagination(
      settings: settings,
      currentCount: 0,
    );
    _expenditures = result.expenditures;
    _hasMoreExpenditures = result.hasMore;
    _setLoading(false);
  }

  Future<void> loadMoreExpenditures(Settings settings) async {
    if (_isLoading || !_hasMoreExpenditures) return;
    _setLoading(true);
    final result = await _expenditureService.getExpendituresWithPagination(
      settings: settings,
      currentCount: _expenditures.length,
      lastLoadedExpenditure: _expenditures.last,
    );
    if (result.expenditures.isNotEmpty) {
      _expenditures.addAll(result.expenditures);
    }
    _hasMoreExpenditures = result.hasMore;
    _setLoading(false);
  }

  List<Expenditure> getTransactionsForTagInRange(
    Tag tag,
    DateTimeRange range,
  ) {
    return _expenditureService.getTransactionsForTagInRange(tag, range);
  }

  double getAllTimeMoneyLeft() {
    return _reportingService.getAllTimeMoneyLeft();
  }

  Future<void> addExpenditure(
    Settings settings, {
    required String articleName,
    double? amount,
    required DateTime date,
    required String mainTagId,
    required bool isIncome,
    String? notes,
  }) async {
    await _expenditureService.addExpenditure(
      settings: settings,
      articleName: articleName,
      amount: amount,
      date: date,
      mainTagId: mainTagId,
      isIncome: isIncome,
      notes: notes,
    );
    await loadInitialExpenditures(settings);
  }

  Future<void> updateExpenditure(
    Settings settings,
    Expenditure expenditure,
  ) async {
    await _expenditureService.updateExpenditure(expenditure);
    await loadInitialExpenditures(settings);
  }

  Future<void> deleteExpenditure(Settings settings, String id) async {
    await _expenditureService.deleteExpenditure(id);
    await loadInitialExpenditures(settings);
  }

  Tag? getTagById(String id) {
    return _tags.firstWhereOrNull((tag) => tag.id == id);
  }
  Future<ReportData> getReportData(DateTimeRange dateRange) async {
    return _reportingService.getReportData(dateRange, getTagById);
  }

  List<Object> getGroupedExpenditures(
    Settings settings, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<Expenditure> listToGroup = _expenditures;
    if (startDate != null) {
      listToGroup = listToGroup
          .where((exp) => !exp.date.isBefore(startDate))
          .toList();
    }
    if (endDate != null) {
      final inclusiveEndDate = endDate.add(const Duration(days: 1));
      listToGroup = listToGroup
          .where((exp) => exp.date.isBefore(inclusiveEndDate))
          .toList();
    }
    return _reportingService.getGroupedExpenditures(
      listToGroup,
      settings,
      _l10n,
    );
  }

  Future<void> convertAllExpenditures(
    double rate,
    String newCurrencyCode,
    Settings settings,
  ) async {
    await _currencyService.convertAllData(rate, newCurrencyCode);
    await initialize(_l10n!, settings);
  }

  Future<double?> getBestExchangeRate(String from, String to) async {
    return _currencyService.getBestExchangeRate(from, to);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}