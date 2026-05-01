import '../../domain/entities/cached_rate.dart';
import '../../domain/entities/custom_exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../data_sources/currency_api_service.dart';
import '../data_sources/currency_local_service.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyApiService _apiService;
  final CurrencyLocalService _localService;
  final SettingsRepository _settingsRepository;

  CurrencyRepositoryImpl(this._apiService, this._localService, this._settingsRepository);

  @override
  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    // 1. Check custom rates
    final customRates = await _localService.getAllCustomRates();
    final pair = "${from}_$to";
    final reciprocalPair = "${to}_$from";

    CustomExchangeRate? direct;
    CustomExchangeRate? reciprocal;

    for (final r in customRates) {
      if (r.conversionPair == pair) {
        direct = r;
      } else if (r.conversionPair == reciprocalPair) {
        reciprocal = r;
      }
    }

    if (direct != null) {
      return direct.rate;
    } else if (reciprocal != null && reciprocal.rate != 0) {
      return 1.0 / reciprocal.rate;
    }

    // 2. Check cached rates
    CachedRate? cached = await _localService.getCachedRates();
    final settings = await _settingsRepository.getSettings();
    final apiKey = settings.exchangeRateApiKey;

    if (cached != null) {
      final difference = DateTime.now().difference(cached.lastFetched);
      if (difference.inHours >= 24) {
        // Refresh if older than 24h
        final newRates = await _apiService.fetchLatestRates(apiKey: apiKey);
        if (newRates != null) {
          await _localService.saveCachedRates(newRates);
          cached = newRates;
        }
      }
    } else {
      // No cache at all
      cached = await _apiService.fetchLatestRates(apiKey: apiKey);
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

    // Ensure reciprocal is updated too to rectify asymmetric ratios
    final parts = customRate.conversionPair.split('_');
    if (parts.length == 2 && customRate.rate != 0) {
      final reciprocalPair = "${parts[1]}_${parts[0]}";
      final reciprocalRate = CustomExchangeRate(
        conversionPair: reciprocalPair,
        rate: 1.0 / customRate.rate,
      );
      await _localService.saveCustomRate(reciprocalRate);
    }
  }

  @override
  Future<void> deleteCustomRate(String conversionPair) async {
    await _localService.deleteCustomRate(conversionPair);

    // Also delete reciprocal
    final parts = conversionPair.split('_');
    if (parts.length == 2) {
      final reciprocalPair = "${parts[1]}_${parts[0]}";
      await _localService.deleteCustomRate(reciprocalPair);
    }
  }

  @override
  Future<void> refreshRates() async {
    final settings = await _settingsRepository.getSettings();
    final newRates = await _apiService.fetchLatestRates(apiKey: settings.exchangeRateApiKey);
    if (newRates != null) {
      await _localService.saveCachedRates(newRates);
    }
  }
}
