import 'package:hive/hive.dart';

part 'saving_goal.g.dart';

@HiveType(typeId: 9)
class SavingGoal extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? notes;
  @HiveField(3)
  double targetAmount;
  @HiveField(4)
  double currentAmount;
  @HiveField(5)
  DateTime startDate;
  @HiveField(6)
  DateTime? endDate;

  SavingGoal({
    required this.id,
    required this.name,
    this.notes,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    this.endDate,
  });

  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'notes': notes,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory SavingGoal.fromJson(Map<String, dynamic> json) => SavingGoal(
    id: json['id'],
    name: json['name'],
    notes: json['notes'],
    targetAmount: json['targetAmount'],
    currentAmount: json['currentAmount'],
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
  );
}
