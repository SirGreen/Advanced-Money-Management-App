import 'package:flutter/foundation.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/export_config.dart';
import '../../domain/repositories/export_repository.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/settings_repository.dart';

class ExportViewModel extends ChangeNotifier {
  final ExportRepository _exportRepository;
  final ExpenditureRepository _expenditureRepository;
  final TagRepository _tagRepository;
  final SettingsRepository _settingsRepository;

  ExportConfig _config = ExportConfig.allTransactions();
  bool _isExporting = false;
  String? _exportedFilePath;
  String? _error;
  Map<String, dynamic>? _summary;
  List<Expenditure> _filteredTransactions = [];
  String _exportDirectoryPath = 'Đang tải...';

  ExportConfig get config => _config;
  bool get isExporting => _isExporting;
  String? get exportedFilePath => _exportedFilePath;
  String? get error => _error;
  Map<String, dynamic>? get summary => _summary;
  List<Expenditure> get filteredTransactions => _filteredTransactions;
  String get exportDirectoryPath => _exportDirectoryPath;

  ExportViewModel({
    required ExportRepository exportRepository,
    required ExpenditureRepository expenditureRepository,
    required TagRepository tagRepository,
    required SettingsRepository settingsRepository,
  })  : _exportRepository = exportRepository,
        _expenditureRepository = expenditureRepository,
        _tagRepository = tagRepository,
        _settingsRepository = settingsRepository {
    _loadExportDirectoryPath();
  }

  Future<void> _loadExportDirectoryPath() async {
    try {
      _exportDirectoryPath = await _exportRepository.getExportDirectoryPath();
      notifyListeners();
    } catch (e) {
      _exportDirectoryPath = 'Lỗi: $e';
      notifyListeners();
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _config = ExportConfig(
      startDate: start,
      endDate: end,
      selectedFields: _config.selectedFields,
      includeIncome: _config.includeIncome,
      includeExpense: _config.includeExpense,
      selectedCategoryIds: _config.selectedCategoryIds,
      exportFormat: _config.exportFormat,
    );
    _error = null;
    notifyListeners();
    _updatePreview();
  }

  void setFieldSelection(List<String> fields) {
    _config = ExportConfig(
      startDate: _config.startDate,
      endDate: _config.endDate,
      selectedFields: fields,
      includeIncome: _config.includeIncome,
      includeExpense: _config.includeExpense,
      selectedCategoryIds: _config.selectedCategoryIds,
      exportFormat: _config.exportFormat,
    );
    notifyListeners();
  }

  void setIncomeIncluded(bool value) {
    _config = ExportConfig(
      startDate: _config.startDate,
      endDate: _config.endDate,
      selectedFields: _config.selectedFields,
      includeIncome: value,
      includeExpense: _config.includeExpense,
      selectedCategoryIds: _config.selectedCategoryIds,
      exportFormat: _config.exportFormat,
    );
    notifyListeners();
    _updatePreview();
  }

  void setExpenseIncluded(bool value) {
    _config = ExportConfig(
      startDate: _config.startDate,
      endDate: _config.endDate,
      selectedFields: _config.selectedFields,
      includeIncome: _config.includeIncome,
      includeExpense: value,
      selectedCategoryIds: _config.selectedCategoryIds,
      exportFormat: _config.exportFormat,
    );
    notifyListeners();
    _updatePreview();
  }

  void setExportFormat(String format) {
    _config = ExportConfig(
      startDate: _config.startDate,
      endDate: _config.endDate,
      selectedFields: _config.selectedFields,
      includeIncome: _config.includeIncome,
      includeExpense: _config.includeExpense,
      selectedCategoryIds: _config.selectedCategoryIds,
      exportFormat: format,
    );
    notifyListeners();
  }

  void usePresetThisMonth() {
    _config = ExportConfig.thisMonth();
    notifyListeners();
    _updatePreview();
  }

  void usePresetThisYear() {
    _config = ExportConfig.thisYear();
    notifyListeners();
    _updatePreview();
  }

  void usePresetAllTransactions() {
    _config = ExportConfig.allTransactions();
    notifyListeners();
    _updatePreview();
  }

  Future<void> _updatePreview() async {
    try {
      final allExpenditures = await _expenditureRepository.getExpenditures();
      _filteredTransactions = _exportRepository.filterTransactions(
        allExpenditures,
        _config,
      );
      _summary = _exportRepository.getExportSummary(_filteredTransactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> export() async {
    _isExporting = true;
    _error = null;
    _exportedFilePath = null;
    notifyListeners();

    try {
      // Get all data
      final allExpenditures = await _expenditureRepository.getExpenditures();
      final allTags = await _tagRepository.getAllTags();
      final tagMap = {for (var tag in allTags) tag.id: tag};
      final settings = await _settingsRepository.getSettings();

      // Export
      final filePath = await _exportRepository.exportTransactions(
        allExpenditures,
        _config,
        tagMap,
        currencyCode: settings.primaryCurrencyCode,
        languageCode: settings.languageCode,
      );

      _exportedFilePath = filePath;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearExportedFile() {
    _exportedFilePath = null;
    notifyListeners();
  }
}
