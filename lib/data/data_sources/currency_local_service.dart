import 'package:hive/hive.dart';
import '../../domain/entities/cached_rate.dart';
import '../../domain/entities/custom_exchange_rate.dart';

class CurrencyLocalService {
  static const String cachedRateBoxName = 'cached_rates';
  static const String customRateBoxName = 'custom_rates';
  static const String latestRatesKey = 'latest_rates';

  Future<Box<CachedRate>> _getCachedRateBox() async {
    if (!Hive.isBoxOpen(cachedRateBoxName)) {
      await Hive.openBox<CachedRate>(cachedRateBoxName);
    }
    return Hive.box<CachedRate>(cachedRateBoxName);
  }

  Future<Box<CustomExchangeRate>> _getCustomRateBox() async {
    if (!Hive.isBoxOpen(customRateBoxName)) {
      await Hive.openBox<CustomExchangeRate>(customRateBoxName);
    }
    return Hive.box<CustomExchangeRate>(customRateBoxName);
  }

  Future<CachedRate?> getCachedRates() async {
    final box = await _getCachedRateBox();
    return box.get(latestRatesKey);
  }

  Future<void> saveCachedRates(CachedRate cachedRate) async {
    final box = await _getCachedRateBox();
    await box.put(latestRatesKey, cachedRate);
  }

  Future<List<CustomExchangeRate>> getAllCustomRates() async {
    final box = await _getCustomRateBox();
    return box.values.toList();
  }

  Future<void> saveCustomRate(CustomExchangeRate customRate) async {
    final box = await _getCustomRateBox();
    await box.put(customRate.conversionPair, customRate);
  }

  Future<void> deleteCustomRate(String conversionPair) async {
    final box = await _getCustomRateBox();
    await box.delete(conversionPair);
  }
}
