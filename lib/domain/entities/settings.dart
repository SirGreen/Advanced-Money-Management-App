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
  @HiveField(6)
  String converterFromCurrency;
  @HiveField(7)
  String converterToCurrency;
  @HiveField(8)
  bool remindersEnabled;
  @HiveField(9)
  DateTime? lastBackupDate;
  @HiveField(10)
  String? userContext;

  Settings({
    this.dividerType = DividerType.monthly,
    this.paydayStartDay = 1,
    this.fixedIntervalDays = 7,
    this.languageCode,
    this.paginationLimit = 50,
    this.primaryCurrencyCode = 'JPY',
    this.converterFromCurrency = 'USD',
    this.converterToCurrency = 'JPY',
    this.remindersEnabled = false,
    this.lastBackupDate,
    this.userContext,
  });

  Map<String, dynamic> toJson() => {
    'dividerType': dividerType.index,
    'paydayStartDay': paydayStartDay,
    'fixedIntervalDays': fixedIntervalDays,
    'languageCode': languageCode,
    'paginationLimit': paginationLimit,
    'primaryCurrencyCode': primaryCurrencyCode,
    'converterFromCurrency': converterFromCurrency,
    'converterToCurrency': converterToCurrency,
    'remindersEnabled': remindersEnabled,
    'lastBackupDate': lastBackupDate?.toIso8601String(),
    'userContext': userContext, 
  };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    dividerType: DividerType.values[json['dividerType']],
    paydayStartDay: json['paydayStartDay'],
    fixedIntervalDays: json['fixedIntervalDays'],
    languageCode: json['languageCode'],
    paginationLimit: json['paginationLimit'],
    primaryCurrencyCode: json['primaryCurrencyCode'],
    converterFromCurrency: json['converterFromCurrency'],
    converterToCurrency: json['converterToCurrency'],
    remindersEnabled: json['remindersEnabled'],
    lastBackupDate: json['lastBackupDate'] != null
        ? DateTime.parse(json['lastBackupDate'])
        : null,
    userContext: json['userContext'], 
  );
}
