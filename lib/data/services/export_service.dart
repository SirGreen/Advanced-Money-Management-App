import 'dart:typed_data';
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
    Map<String, Tag> tagMap,
  ) {
    final buffer = StringBuffer();

    // Header
    final headers = config.selectedFields.map((field) {
      switch (field) {
        case 'date':
          return 'Date';
        case 'amount':
          return 'Amount (₫)';
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

    buffer.writeln('"${headers.join('","')}"');

    // Data rows
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    for (final expenditure in expenditures) {
      final row = <String>[];

      for (final field in config.selectedFields) {
        switch (field) {
          case 'date':
            row.add(DateFormat('dd/MM/yyyy').format(expenditure.date));
          case 'amount':
            row.add(currencyFormat.format(expenditure.amount ?? 0));
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

      // Escape quotes and escape fields with commas
      final escapedRow = row.map((field) {
        final escaped = field.replaceAll('"', '""');
        return '"$escaped"';
      }).toList();

      buffer.writeln(escapedRow.join(','));
    }

    return buffer.toString();
  }

  // Generate real Excel content
  List<int>? generateExcel(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap,
  ) {
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    // Header
    final headers = config.selectedFields.map((field) {
      switch (field) {
        case 'date':
          return 'Date';
        case 'amount':
          return 'Amount (₫)';
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
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

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
      if (config.endDate != null && exp.date.isAfter(config.endDate!)) {
        return false;
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

  // Save string content to file using FilePicker
  Future<String> exportToFile(
    String content,
    String filename,
    String format,
  ) async {
    try {
      final bytes = Uint8List.fromList(content.codeUnits);
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
