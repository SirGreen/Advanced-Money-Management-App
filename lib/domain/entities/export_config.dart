// Export configuration for transactions
class ExportConfig {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedFields; // e.g., ['date', 'amount', 'category', 'notes']
  final bool includeIncome;
  final bool includeExpense;
  final List<String>? selectedCategoryIds; // null = all categories
  final String exportFormat; // 'csv' or 'excel'

  ExportConfig({
    this.startDate,
    this.endDate,
    this.selectedFields = const ['date', 'amount', 'category', 'notes', 'type'],
    this.includeIncome = true,
    this.includeExpense = true,
    this.selectedCategoryIds,
    this.exportFormat = 'csv',
  });

  factory ExportConfig.fromJson(Map<String, dynamic> json) {
    return ExportConfig(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      selectedFields: List<String>.from(json['selectedFields'] ?? ['date', 'amount', 'category', 'notes', 'type']),
      includeIncome: json['includeIncome'] ?? true,
      includeExpense: json['includeExpense'] ?? true,
      selectedCategoryIds: json['selectedCategoryIds'] != null ? List<String>.from(json['selectedCategoryIds']) : null,
      exportFormat: json['exportFormat'] ?? 'csv',
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'selectedFields': selectedFields,
    'includeIncome': includeIncome,
    'includeExpense': includeExpense,
    'selectedCategoryIds': selectedCategoryIds,
    'exportFormat': exportFormat,
  };

  // Preset configurations
  static ExportConfig allTransactions() => ExportConfig(
    startDate: null,
    endDate: null,
    selectedFields: ['date', 'amount', 'category', 'notes', 'type', 'currency'],
  );

  static ExportConfig thisMonth() {
    final now = DateTime.now();
    return ExportConfig(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      selectedFields: ['date', 'amount', 'category', 'notes', 'type'],
    );
  }

  static ExportConfig thisYear() {
    final now = DateTime.now();
    return ExportConfig(
      startDate: DateTime(now.year, 1, 1),
      endDate: now,
      selectedFields: ['date', 'amount', 'category', 'notes', 'type'],
    );
  }

  static ExportConfig customRange(DateTime start, DateTime end) =>
      ExportConfig(
        startDate: start,
        endDate: end,
        selectedFields: ['date', 'amount', 'category', 'notes', 'type'],
      );

  // Get field label in Vietnamese
  String getFieldLabel(String fieldName) {
    const labels = {
      'date': 'Ngày',
      'amount': 'Số tiền',
      'category': 'Danh mục',
      'notes': 'Ghi chú',
      'type': 'Loại',
      'currency': 'Tiền tệ',
      'article': 'Mô tả',
      'receipt': 'Chứng từ',
    };
    return labels[fieldName] ?? fieldName;
  }
}
