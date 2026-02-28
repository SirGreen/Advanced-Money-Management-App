import 'package:hive/hive.dart';

part 'saving_account.g.dart';

@HiveType(typeId: 12)
class SavingAccount extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  double balance;
  @HiveField(3)
  String? notes;
  @HiveField(4)
  double? annualInterestRate;
  @HiveField(5)
  DateTime startDate;
  @HiveField(6)
  DateTime? endDate;

  SavingAccount({
    required this.id,
    required this.name,
    this.balance = 0.0,
    this.notes,
    this.annualInterestRate,
    required this.startDate,
    this.endDate,
  });

  double getEstimatedFutureValue(DateTime futureDate) {
    if (annualInterestRate == null ||
        annualInterestRate! <= 0 ||
        futureDate.isBefore(DateTime.now())) {
      return balance;
    }
    final double years = futureDate.difference(DateTime.now()).inDays / 365.25;
    final rateAsDecimal = annualInterestRate! / 100;
    return balance * (1 + rateAsDecimal * years);
  }

  bool isActiveOn(DateTime date) {
    final afterStart = !date.isBefore(startDate);
    final beforeEnd = (endDate == null) || date.isBefore(endDate!);
    return afterStart && beforeEnd;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'balance': balance,
    'notes': notes,
    'annualInterestRate': annualInterestRate,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };

  factory SavingAccount.fromJson(Map<String, dynamic> json) => SavingAccount(
    id: json['id'],
    name: json['name'],
    balance: json['balance'],
    notes: json['notes'],
    annualInterestRate: json['annualInterestRate'],
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
  );
}
