import 'package:hive/hive.dart';

part 'custom_exchange_rate.g.dart';

@HiveType(typeId: 7)
class CustomExchangeRate extends HiveObject {
  @HiveField(0)
  final String conversionPair;

  @HiveField(1)
  double rate;

  CustomExchangeRate({required this.conversionPair, required this.rate});

  Map<String, dynamic> toJson() => {
    'conversionPair': conversionPair,
    'rate': rate,
  };

  factory CustomExchangeRate.fromJson(Map<String, dynamic> json) =>
      CustomExchangeRate(
        conversionPair: json['conversionPair'],
        rate: json['rate'],
      );
}
