import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/export_config.dart';

class ExportService {
  // Generate CSV content from expenditures
  String generateCSV(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap, {
    String currencyCode = 'VND',
    String? languageCode,
  }) {
    final List<List<String>> rows = [];

    final currencyFormat = NumberFormat.simpleCurrency(
      name: currencyCode,
      locale: languageCode,
    );
    final currencySymbol = currencyFormat.currencySymbol;
    final amountFormat = NumberFormat.decimalPattern(languageCode);

    // Header
    final headers = config.selectedFields.map((field) {
      switch (field) {
        case 'date':
          return 'Date';
        case 'amount':
          return 'Amount ($currencyCode)';
        case 'category':
          return 'Category';
        case 'notes':
          return 'Notes';
        case 'type':
          return 'Type';
        case 'currency':
          return 'Currency';
        case 'article':
          return 'Description';
        default:
          return field;
      }
    }).toList();
    rows.add(headers);

    // Data rows
    for (final expenditure in expenditures) {
      final row = <String>[];

      for (final field in config.selectedFields) {
        switch (field) {
          case 'date':
            row.add(DateFormat('dd/MM/yyyy').format(expenditure.date));
          case 'amount':
            // Use decimal pattern for data cells to avoid currency symbol corruption
            // The currency symbol is already in the header to identify the unit
            row.add(amountFormat.format(expenditure.amount ?? 0));
          case 'category':
            final category = _getCategoryName(expenditure, tagMap);
            row.add(category);
          case 'notes':
            row.add(expenditure.notes ?? '');
          case 'type':
            row.add(expenditure.isIncome ? 'Income' : 'Expense');
          case 'currency':
            row.add(expenditure.currencyCode);
          case 'article':
            row.add(expenditure.articleName);
          default:
            row.add('');
        }
      }
      rows.add(row);
    }

    return _rowsToCsv(rows);
  }

  String _rowsToCsv(List<List<String>> rows) {
    return '${rows.map((row) {
      return row.map((field) {
        // Replace non-breaking spaces (\u00A0 and \u202F) which often confuse mobile CSV parsers
        final cleaned = field.replaceAll('\u00A0', ' ').replaceAll('\u202F', ' ');
        // Escape quotes by doubling them and wrapping the field in quotes
        final escaped = cleaned.replaceAll('"', '""');
        return '"$escaped"';
      }).join(',');
    }).join('\r\n')}\r\n';
  }

  // Generate real Excel content
  List<int>? generateExcel(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap, {
    String currencyCode = 'VND',
    String? languageCode,
  }) {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    final currencyFormat = NumberFormat.simpleCurrency(
      name: currencyCode,
      locale: languageCode,
    );
    final currencySymbol = currencyFormat.currencySymbol;

    // Header
    final headers = config.selectedFields.map((field) {
      switch (field) {
        case 'date':
          return 'Date';
        case 'amount':
          return 'Amount ($currencyCode)';
        case 'category':
          return 'Category';
        case 'notes':
          return 'Notes';
        case 'type':
          return 'Type';
        case 'currency':
          return 'Currency';
        case 'article':
          return 'Description';
        default:
          return field;
      }
    }).toList();

    sheet.appendRow(headers.map((h) => excel_pkg.TextCellValue(h)).toList());

    // Data rows
    for (final expenditure in expenditures) {
      final row = <excel_pkg.CellValue>[];

      for (final field in config.selectedFields) {
        switch (field) {
          case 'date':
            row.add(excel_pkg.TextCellValue(DateFormat('dd/MM/yyyy').format(expenditure.date)));
          case 'amount':
            row.add(excel_pkg.TextCellValue(currencyFormat.format(expenditure.amount ?? 0)));
          case 'category':
            final category = _getCategoryName(expenditure, tagMap);
            row.add(excel_pkg.TextCellValue(category));
          case 'notes':
            row.add(excel_pkg.TextCellValue(expenditure.notes ?? ''));
          case 'type':
            row.add(excel_pkg.TextCellValue(expenditure.isIncome ? 'Income' : 'Expense'));
          case 'currency':
            row.add(excel_pkg.TextCellValue(expenditure.currencyCode));
          case 'article':
            row.add(excel_pkg.TextCellValue(expenditure.articleName));
          default:
            row.add(excel_pkg.TextCellValue(''));
        }
      }

      sheet.appendRow(row);
    }

    return excel.encode();
  }

  // Filter expenditures based on config
  List<Expenditure> filterExpenditures(
    List<Expenditure> allExpenditures,
    ExportConfig config,
  ) {
    return allExpenditures.where((exp) {
      // Date range filter
      if (config.startDate != null && exp.date.isBefore(config.startDate!)) {
        return false;
      }
      if (config.endDate != null) {
        final endOfDay = DateTime(
          config.endDate!.year,
          config.endDate!.month,
          config.endDate!.day,
          23, 59, 59,
        );
        if (exp.date.isAfter(endOfDay)) {
          return false;
        }
      }

      // Income/Expense filter
      if (exp.isIncome && !config.includeIncome) return false;
      if (!exp.isIncome && !config.includeExpense) return false;

      // Category filter
      if (config.selectedCategoryIds != null &&
          !config.selectedCategoryIds!.contains(exp.mainTagId)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<String> exportToFile(
    String content,
    String filename,
    String format,
  ) async {
    try {
      final List<int> encodedContent = utf8.encode(content);
      final bytes = Uint8List.fromList(encodedContent);
      return await exportToFileBytes(bytes, filename, format);
    } catch (e) {
      throw Exception('Error exporting file: $e');
    }
  }

  // Save binary content to file using FilePicker
  Future<String> exportToFileBytes(
    List<int> bytes,
    String filename,
    String format,
  ) async {
    try {
      final extension = format.toLowerCase();
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Exported File',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: Uint8List.fromList(bytes),
      );

      if (result == null) {
        throw Exception('Export cancelled by user');
      }

      return result;
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        throw Exception('Export cancelled by user');
      }
      throw Exception('Error exporting file: $e');
    }
  }

  // Get export directory path for display
  Future<String> getExportDirectoryPath() async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        return 'System Downloads';
      }
      return directory.path;
    } catch (e) {
      return 'System Downloads';
    }
  }

  String _getCategoryName(Expenditure expenditure, Map<String, Tag> tagMap) {
    final tag = tagMap[expenditure.mainTagId];
    if (tag != null) {
      return tag.name;
    }
    return expenditure.mainTagId;
  }

  // Get summary statistics
  Map<String, dynamic> getSummary(List<Expenditure> expenditures) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final exp in expenditures) {
      if (exp.isIncome) {
        totalIncome += exp.amount ?? 0;
      } else {
        totalExpense += exp.amount ?? 0;
      }
    }

    return {
      'totalTransactions': expenditures.length,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'net': totalIncome - totalExpense,
    };
  }
}
