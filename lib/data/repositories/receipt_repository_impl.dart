import 'dart:io';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../data_sources/llm_service.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final LLMService _llmService;

  ReceiptRepositoryImpl(this._llmService);

  @override
  Future<Map<String, dynamic>?> scanReceipt(
    Settings settings,
    File image,
    List<String> existingTagNames,
  ) async {
    return await _llmService.processReceiptImage(
      settings,
      image,
      existingTagNames,
    );
  }
}
