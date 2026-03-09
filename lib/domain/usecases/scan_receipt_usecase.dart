import 'dart:io';

import '../entities/settings.dart';
import '../repositories/receipt_repository.dart';

class ScanReceiptUseCase {
  final ReceiptRepository repository;

  ScanReceiptUseCase(this.repository);

  Future<Map<String, dynamic>?> call(
    Settings settings,
    File image,
    List<String> existingTagNames,
  ) async {
    return await repository.scanReceipt(settings, image, existingTagNames);
  }
}
