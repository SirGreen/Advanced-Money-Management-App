import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// Domain
import '../../domain/entities/tag.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';

// Data
import '../../data/data_sources/database_service.dart';

class ExpenditureController with ChangeNotifier {
  final ScanReceiptUseCase _scanReceiptUseCase;
  final DatabaseService _dbService = DatabaseService();

  List<Tag> _tags = [];
  bool _isLoading = false;

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  
  // Tag mặc định dùng khi không scan được tag
  static const String defaultTagId = 'others'; 

  ExpenditureController({
    required ScanReceiptUseCase scanReceiptUseCase,
  }) : _scanReceiptUseCase = scanReceiptUseCase {
    _loadTags(); // Load tags ngay khi khởi tạo để sẵn sàng cho việc Scan
  }

  Future<void> _loadTags() async {
    // Giả lập hoặc gọi DB thực tế để lấy tags
    _tags = _dbService.getAllTags(); 
    notifyListeners();
  }

  // --- LOGIC 1: XỬ LÝ SCAN ẢNH (Phục vụ CameraScannerPage) ---
  Future<Map<String, dynamic>?> processReceipt(File image) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingTagNames = _tags.map((t) => t.name).toList();
      // Gọi UseCase
      final result = await _scanReceiptUseCase.call(image, existingTagNames);
      return result;
    } catch (e) {
      debugPrint("Scan error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- LOGIC 2: LƯU GIAO DỊCH (Phục vụ AddEditExpenditurePage) ---
  Future<void> addExpenditure(
    Settings settings, {
    required String articleName,
    required double? amount,
    required DateTime date,
    required String mainTagId,
    required List<String> subTagIds,
    required bool isIncome,
    String? notes,
    String? receiptImagePath,
  }) async {
    final newExpenditure = Expenditure(
      id: const Uuid().v4(),
      articleName: articleName,
      amount: amount ?? 0,
      date: date,
      mainTagId: mainTagId,
      subTagIds: subTagIds,
      isIncome: isIncome,
      notes: notes ?? '',
      receiptImagePath: receiptImagePath,
      currencyCode: settings.primaryCurrencyCode, // Lấy từ Settings
    );

    await _dbService.saveExpenditure(newExpenditure);
    notifyListeners();
  }

  // --- LOGIC 3: GỢI Ý TAG & TẠO TAG (Phục vụ AddEditExpenditurePage) ---
  Future<List<Object>> recommendTags(String articleName) async {
    // Logic gọi AI hoặc check từ khóa để gợi ý tag (Giữ placeholder)
    return []; 
  }

  Future<void> addTag({required String id, required String name, int? colorValue, String? iconName}) async {
    final newTag = Tag(
      id: id, 
      name: name, 
      colorValue: colorValue ?? 0xFF9E9E9E, 
      iconName: iconName
    );
    await _dbService.saveTag(newTag);
    await _loadTags();
  }
}