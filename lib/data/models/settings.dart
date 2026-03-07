import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
enum DividerType {
  @HiveField(0)
  monthly,
  @HiveField(1)
  paydayCycle,
  @HiveField(2)
  fixedInterval,
}

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  DividerType dividerType;
  @HiveField(1)
  int paydayStartDay;
  @HiveField(2)
  int fixedIntervalDays;
  @HiveField(3)
  String? languageCode;
  @HiveField(4)
  int paginationLimit;
  @HiveField(5)
  String primaryCurrencyCode;

  Settings({
    this.dividerType = DividerType.monthly,
    this.paydayStartDay = 1,
    this.fixedIntervalDays = 7,
    this.languageCode,
    this.paginationLimit = 50,
    this.primaryCurrencyCode = 'JPY',
  });

  Map<String, dynamic> toJson() => {
        'dividerType': dividerType.index,
        'paydayStartDay': paydayStartDay,
        'fixedIntervalDays': fixedIntervalDays,
        'languageCode': languageCode,
        'paginationLimit': paginationLimit,
        'primaryCurrencyCode': primaryCurrencyCode,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        dividerType: DividerType.values[json['dividerType'] as int],
        paydayStartDay: json['paydayStartDay'] as int,
        fixedIntervalDays: json['fixedIntervalDays'] as int,
        languageCode: json['languageCode'] as String?,
        paginationLimit: json['paginationLimit'] as int,
        primaryCurrencyCode: json['primaryCurrencyCode'] as String,
      );
}