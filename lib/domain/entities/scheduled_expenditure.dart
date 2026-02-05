import 'package:hive/hive.dart';

part 'scheduled_expenditure.g.dart';

@HiveType(typeId: 5)
enum ScheduleType {
  @HiveField(0)
  dayOfMonth,
  @HiveField(1)
  endOfMonth, 
  @HiveField(2)
  daysBeforeEndOfMonth,
  @HiveField(3)
  fixedInterval,
}

@HiveType(typeId: 4) 
class ScheduledExpenditure extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  double? amount;
  @HiveField(3)
  String mainTagId;
  @HiveField(4)
  List<String> subTagIds;
  @HiveField(5)
  ScheduleType scheduleType;
  @HiveField(6)
  int scheduleValue;
  @HiveField(7)
  DateTime startDate;
  @HiveField(8)
  DateTime? lastCreatedDate;
  @HiveField(9)
  bool isActive;
  @HiveField(10)
  DateTime? endDate;
  @HiveField(11)
  bool isIncome;
  @HiveField(12)
  String currencyCode;

  ScheduledExpenditure({
    required this.id,
    required this.name,
    required this.amount,
    required this.mainTagId,
    required this.subTagIds,
    required this.scheduleType,
    required this.scheduleValue,
    required this.startDate,
    this.lastCreatedDate,
    this.isActive = true, 
    this.endDate,
    this.isIncome = false,
    required this.currencyCode,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'mainTagId': mainTagId,
    'subTagIds': subTagIds,
    'scheduleType': scheduleType.index,
    'scheduleValue': scheduleValue,
    'startDate': startDate.toIso8601String(),
    'lastCreatedDate': lastCreatedDate?.toIso8601String(),
    'isActive': isActive,
    'endDate': endDate?.toIso8601String(),
    'isIncome': isIncome,
    'currencyCode': currencyCode,
  };

  factory ScheduledExpenditure.fromJson(Map<String, dynamic> json) =>
      ScheduledExpenditure(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        mainTagId: json['mainTagId'],
        subTagIds: List<String>.from(json['subTagIds']),
        scheduleType: ScheduleType.values[json['scheduleType']],
        scheduleValue: json['scheduleValue'],
        startDate: DateTime.parse(json['startDate']),
        lastCreatedDate: json['lastCreatedDate'] != null
            ? DateTime.parse(json['lastCreatedDate'])
            : null,
        isActive: json['isActive'],
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        isIncome: json['isIncome'],
        currencyCode: json['currencyCode'],
      );
}
