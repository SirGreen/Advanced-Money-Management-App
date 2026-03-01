import 'dart:io';
import '../../domain/repositories/receipt_repository.dart';
import '../data_sources/llm_service.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final LLMService _llmService;

  ReceiptRepositoryImpl(this._llmService);

  @override
  Future<Map<String, dynamic>?> scanReceipt(
    File image,
    List<String> existingTagNames,
  ) async {
    // Gọi trực tiếp service cũ của bạn
    return await _llmService.processReceiptImage(image, existingTagNames);
  }
}
