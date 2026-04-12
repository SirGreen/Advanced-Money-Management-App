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

  @HiveField(11)
  bool privacyModeEnabled;

  @HiveField(12)
  String? geminiApiKey;

  Settings({
    this.dividerType = DividerType.monthly,
    this.paydayStartDay = 1,
    this.fixedIntervalDays = 7,
    this.languageCode,
    this.paginationLimit = 50,
    this.primaryCurrencyCode = 'VND',
    this.converterFromCurrency = 'USD',
    this.converterToCurrency = 'VND',
    this.remindersEnabled = false,
    this.lastBackupDate,
    this.userContext,
    this.privacyModeEnabled = false,
    this.geminiApiKey,
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
    'privacyModeEnabled': privacyModeEnabled,
    'geminiApiKey': geminiApiKey,
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
    privacyModeEnabled: json['privacyModeEnabled'] ?? false,
    geminiApiKey: json['geminiApiKey'],
  );

  Settings copyWith({
    DividerType? dividerType,
    int? paydayStartDay,
    int? fixedIntervalDays,
    String? languageCode,
    bool clearLanguageCode = false,
    int? paginationLimit,
    String? primaryCurrencyCode,
    String? converterFromCurrency,
    String? converterToCurrency,
    bool? remindersEnabled,
    DateTime? lastBackupDate,
    bool clearLastBackupDate = false,
    String? userContext,
    bool clearUserContext = false,
    bool? privacyModeEnabled,
    String? geminiApiKey,
    bool clearGeminiApiKey = false,
  }) {
    return Settings(
      dividerType: dividerType ?? this.dividerType,
      paydayStartDay: paydayStartDay ?? this.paydayStartDay,
      fixedIntervalDays: fixedIntervalDays ?? this.fixedIntervalDays,
      languageCode: clearLanguageCode ? null : (languageCode ?? this.languageCode),
      paginationLimit: paginationLimit ?? this.paginationLimit,
      primaryCurrencyCode: primaryCurrencyCode ?? this.primaryCurrencyCode,
      converterFromCurrency: converterFromCurrency ?? this.converterFromCurrency,
      converterToCurrency: converterToCurrency ?? this.converterToCurrency,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      lastBackupDate: clearLastBackupDate ? null : (lastBackupDate ?? this.lastBackupDate),
      userContext: clearUserContext ? null : (userContext ?? this.userContext),
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
      geminiApiKey: clearGeminiApiKey ? null : (geminiApiKey ?? this.geminiApiKey),
    );
  }
}
