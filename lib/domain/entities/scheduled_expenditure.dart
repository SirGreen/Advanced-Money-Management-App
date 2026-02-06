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
    this.reminderDaysBefore,
  });

  @HiveField(13)
  int? reminderDaysBefore;

  int get participantId => id.hashCode;
}
