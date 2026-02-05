import 'package:hive/hive.dart';

part 'cached_rate.g.dart';

@HiveType(typeId: 8)
class CachedRate extends HiveObject {
  
  @HiveField(0)
  final String baseCode; 

  @HiveField(1)
  Map<String, double> conversionRates;

  @HiveField(2)
  DateTime lastFetched;

  CachedRate({
    required this.baseCode,
    required this.conversionRates,
    required this.lastFetched,
  });

  Map<String, dynamic> toJson() => {
    'baseCode':baseCode,
    'conversionRates':conversionRates,
    'lastFetched':lastFetched.toIso8601String(),
  };

    factory CachedRate.fromJson(Map<String, dynamic> json) {
    final rawRates = json['conversionRates'] as Map<String, dynamic>;
    final convertedRates = Map<String, double>.from(
      rawRates.map((key, value) => MapEntry(key, (value as num).toDouble())),
    );
    return CachedRate(
      baseCode: json['baseCode'],
      conversionRates: convertedRates,
      lastFetched: DateTime.parse(json['lastFetched']),
    );
  }
}