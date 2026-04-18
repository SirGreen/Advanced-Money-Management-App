import '../entities/custom_exchange_rate.dart';

abstract class CurrencyRepository {
  Future<double?> getExchangeRate(String from, String to);
  Future<List<CustomExchangeRate>> getAllCustomRates();
  Future<void> saveCustomRate(CustomExchangeRate customRate);
  Future<void> deleteCustomRate(String conversionPair);
  Future<void> refreshRates();
}
