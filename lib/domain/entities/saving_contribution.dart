import 'package:hive/hive.dart';

part 'saving_contribution.g.dart';

@HiveType(typeId: 10)
class SavingContribution extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String savingGoalId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime createdAt;

  SavingContribution({
    required this.id,
    required this.savingGoalId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'savingGoalId': savingGoalId,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavingContribution.fromJson(Map<String, dynamic> json) => SavingContribution(
    id: json['id'],
    savingGoalId: json['savingGoalId'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    note: json['note'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
