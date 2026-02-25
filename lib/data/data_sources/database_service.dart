import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

// Import Domain Entities
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';

class DatabaseService {
  // Chỉ giữ lại các Box cần thiết cho luồng thêm chi tiêu từ hóa đơn
  static const String expenditureBoxName = 'expenditures';
  static const String tagBoxName = 'tags';

  // --- 1. KHỞI TẠO ---
  Future<void> openBoxes() async {
    // Chỉ mở box Expenditure và Tag
    if (!Hive.isBoxOpen(expenditureBoxName)) {
      await Hive.openBox<Expenditure>(expenditureBoxName);
    }
    if (!Hive.isBoxOpen(tagBoxName)) {
      await Hive.openBox<Tag>(tagBoxName);
    }
  }

  // --- 2. QUẢN LÝ EXPENDITURES (Chi tiêu) ---
  
  // Lưu chi tiêu mới (Được gọi từ ExpenditureController.addExpenditure)
  Future<void> saveExpenditure(Expenditure exp) async {
    final box = Hive.box<Expenditure>(expenditureBoxName);
    await box.put(exp.id, exp);
  }

  // --- 3. QUẢN LÝ TAGS (Danh mục) ---
  
  // Lấy tất cả tags để hiển thị và map với kết quả OCR
  List<Tag> getAllTags() {
    if (Hive.isBoxOpen(tagBoxName)) {
       return Hive.box<Tag>(tagBoxName).values.toList();
    }
    return [];
  }

  // Lưu tag mới (Nếu người dùng hoặc AI tạo tag mới)
  Future<void> saveTag(Tag tag) async {
    final box = Hive.box<Tag>(tagBoxName);
    await box.put(tag.id, tag);
  }
}