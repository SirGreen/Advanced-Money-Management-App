import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/export_config.dart';
import '../../domain/repositories/export_repository.dart';
import '../services/export_service.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportService _exportService;

  ExportRepositoryImpl(this._exportService);

  @override
  Future<String> exportTransactions(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap,
  ) async {
    // Filter transactions
    final filtered = filterTransactions(expenditures, config);

    // Generate content based on format
    String content;
    if (config.exportFormat == 'excel') {
      content = _exportService.generateExcel(filtered, config, tagMap);
    } else {
      content = _exportService.generateCSV(filtered, config, tagMap);
    }

    // Generate filename
    final dateStr = DateTime.now().toString().split(' ').first;
    final filename = 'transactions_$dateStr.${config.exportFormat}';

    // Save to file
    return await _exportService.exportToFile(
      content,
      filename,
      config.exportFormat,
    );
  }

  @override
  List<Expenditure> filterTransactions(
    List<Expenditure> expenditures,
    ExportConfig config,
  ) {
    return _exportService.filterExpenditures(expenditures, config);
  }

  @override
  Map<String, dynamic> getExportSummary(List<Expenditure> expenditures) {
    return _exportService.getSummary(expenditures);
  }

  @override
  Future<String> getExportDirectoryPath() {
    return _exportService.getExportDirectoryPath();
  }
}
