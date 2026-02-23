import 'dart:io';
import '../repositories/receipt_repository.dart';

class ScanReceiptUseCase {
  final ReceiptRepository repository;

  ScanReceiptUseCase(this.repository);

  Future<Map<String, dynamic>?> call(File image, List<String> existingTagNames) async {
    return await repository.scanReceipt(image, existingTagNames);
  }
}