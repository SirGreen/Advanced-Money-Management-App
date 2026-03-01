import 'dart:io';

abstract class ReceiptRepository {
  Future<Map<String, dynamic>?> scanReceipt(
    File image,
    List<String> existingTagNames,
  );
}
