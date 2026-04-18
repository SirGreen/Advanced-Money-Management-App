import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/cached_rate.dart';

class CurrencyApiService {
  static const String _apiKey = String.fromEnvironment('EXCHANGE_API_KEY');

  Future<CachedRate?> fetchLatestRates() async {
    if (_apiKey.isEmpty) {
      debugPrint("ERROR: EXCHANGE_API_KEY is not set. Please run the app with --dart-define.");
      return null;
    }

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/$_apiKey/latest/USD');
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
