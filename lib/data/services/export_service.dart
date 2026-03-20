import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
          return 'Ngày';
        case 'amount':
          return 'Số tiền (₫)';
        case 'category':
          return 'Danh mục';
        case 'notes':
          return 'Ghi chú';
        case 'type':
          return 'Loại';
        case 'currency':
          return 'Tiền tệ';
        case 'article':
          return 'Mô tả';
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
            row.add(expenditure.isIncome ? 'Thu nhập' : 'Chi tiêu');
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

  // Generate Excel-like content (using CSV with proper formatting)
  // Note: For true Excel files, you would use a proper Excel library
  String generateExcel(
    List<Expenditure> expenditures,
    ExportConfig config,
    Map<String, Tag> tagMap,
  ) {
    // For now, we'll use CSV format which can be opened in Excel
    // In production, consider using 'excel' package
    return generateCSV(expenditures, config, tagMap);
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

  // Save to file and return file path
  Future<String> exportToFile(
    String content,
    String filename,
    String format,
  ) async {
    try {
      // Get Downloads directory from device
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Không thể truy cập thư mục Downloads');
      }

      final exportPath = '${directory.path}${Platform.pathSeparator}Transactions_Export';

      // Create directory if not exists
      final exportDir = Directory(exportPath);
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Generate filename with timestamp if not provided
      final finalFilename = filename.isEmpty
          ? 'transactions_${DateTime.now().millisecondsSinceEpoch}.$format'
          : filename;

      final file = File('$exportPath${Platform.pathSeparator}$finalFilename');
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      throw Exception('Lỗi khi xuất tệp: $e');
    }
  }

  // Get export directory path for display
  Future<String> getExportDirectoryPath() async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        return 'Không xác định';
      }
      return '${directory.path}${Platform.pathSeparator}Transactions_Export';
    } catch (e) {
      return 'Lỗi: $e';
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
