import '../entities/expenditure.dart';
import '../entities/tag.dart';
import '../entities/export_config.dart';

abstract class ExportRepository {
  Future<String> exportTransactions(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap, {
    String currencyCode = 'VND',
    String? languageCode,
  });

  List<Expenditure> filterTransactions(
    List<Expenditure> expenditures,
    ExportConfig config,
  );

  Map<String, dynamic> getExportSummary(List<Expenditure> expenditures);

  Future<String> getExportDirectoryPath();
}
