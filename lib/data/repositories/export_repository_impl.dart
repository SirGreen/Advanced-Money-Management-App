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
    Map<String, Tag> tagMap, {
    String currencyCode = 'VND',
    String? languageCode,
  }) async {
    // Filter transactions
    final filtered = filterTransactions(expenditures, config);

    // Generate filename
    final dateStr = DateTime.now().toString().split(' ').first;
    final extension = config.exportFormat == 'excel' ? 'xlsx' : 'csv';
    final filename = 'transactions_$dateStr.$extension';

    // Generate content and save based on format
    if (config.exportFormat == 'excel') {
      final bytes = _exportService.generateExcel(
        filtered,
        config,
        tagMap,
        currencyCode: currencyCode,
        languageCode: languageCode,
      );
      if (bytes == null) {
        throw Exception('Failed to generate Excel content');
      }
      return await _exportService.exportToFileBytes(
        bytes,
        filename,
        extension,
      );
    } else {
      final content = _exportService.generateCSV(
        filtered,
        config,
        tagMap,
        currencyCode: currencyCode,
        languageCode: languageCode,
      );
      return await _exportService.exportToFile(
        content,
        filename,
        extension,
      );
    }
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
