import '../../domain/entities/cached_rate.dart';
import '../../domain/entities/custom_exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../data_sources/currency_api_service.dart';
import '../data_sources/currency_local_service.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApiService _apiService;
  final CurrencyLocalService _localService;

  CurrencyRepositoryImpl(this._apiService, this._localService);

  @override
  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    // 1. Check custom rates
    final customRates = await _localService.getAllCustomRates();
    final pair = "${from}_$to";
    try {
      final customRate = customRates.firstWhere((r) => r.conversionPair == pair);
      return customRate.rate;
    } catch (_) {
      // Not found in custom rates
    }

    // 2. Check cached rates
    CachedRate? cached = await _localService.getCachedRates();
    if (cached != null) {
      final difference = DateTime.now().difference(cached.lastFetched);
      if (difference.inHours >= 24) {
        // Refresh if older than 24h
        final newRates = await _apiService.fetchLatestRates();
        if (newRates != null) {
          await _localService.saveCachedRates(newRates);
          cached = newRates;
        }
      }
    } else {
      // No cache at all
      cached = await _apiService.fetchLatestRates();
      if (cached != null) {
        await _localService.saveCachedRates(cached);
      }
    }

    if (cached == null) return null;

    final rates = cached.conversionRates;
    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      return null;
    }
    final rateFromBase = rates[from]!;
    final rateToBase = rates[to]!;
    return rateToBase / rateFromBase;
  }

  @override
  Future<List<CustomExchangeRate>> getAllCustomRates() async {
    return _localService.getAllCustomRates();
  }

  @override
  Future<void> saveCustomRate(CustomExchangeRate customRate) async {
    await _localService.saveCustomRate(customRate);
  }

  @override
  Future<void> deleteCustomRate(String conversionPair) async {
    await _localService.deleteCustomRate(conversionPair);
  }

  @override
  Future<void> refreshRates() async {
    final newRates = await _apiService.fetchLatestRates();
    if (newRates != null) {
      await _localService.saveCachedRates(newRates);
    }
  }
}
