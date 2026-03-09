import 'dart:io';

import '../entities/settings.dart';

abstract class ReceiptRepository {
  Future<Map<String, dynamic>?> scanReceipt(
    Settings settings,
    File image,
    List<String> existingTagNames,
  );
}
