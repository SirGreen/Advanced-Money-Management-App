import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/cached_rate.dart';

class CurrencyApiService {
  static const String _defaultApiKey = String.fromEnvironment('EXCHANGE_API_KEY');

  Future<CachedRate?> fetchLatestRates({String? apiKey}) async {
    final effectiveApiKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : _defaultApiKey;

    if (effectiveApiKey.isEmpty) {
      debugPrint("ERROR: Exchange Rate API Key is not set. Please set it in Settings or via --dart-define.");
      return null;
    }

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$effectiveApiKey/latest/USD');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          final rates = Map<String, double>.from(
            data['conversion_rates'].map((k, v) => MapEntry(k, (v as num).toDouble())),
          );
          return CachedRate(
            baseCode: data['base_code'],
            conversionRates: rates,
            lastFetched: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint("Currency API Service Exception: $e");
    }
    return null;
  }
}
