import 'package:hive/hive.dart';

part 'expenditure.g.dart';

@HiveType(typeId: 0)
class Expenditure extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String articleName;

  @HiveField(2)
  double? amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String mainTagId;

  @HiveField(5)
  List<String> subTagIds;

  @HiveField(6)
  String? receiptImagePath;

  @HiveField(7)
  String? scheduledExpenditureId;

  @HiveField(8)
  bool isIncome;

  @HiveField(9)
  String currencyCode;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  Expenditure({
    required this.id,
    required this.articleName,
    this.amount,
    required this.date,
    required this.mainTagId,
    this.isIncome = false,
    this.subTagIds = const [],
    this.receiptImagePath,
    this.scheduledExpenditureId,
    required this.currencyCode,
    this.notes,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  Expenditure._({
    required this.id,
    required this.articleName,
    this.amount,
    required this.date,
    required this.mainTagId,
    this.isIncome = false,
    this.subTagIds = const [],
    this.receiptImagePath,
    this.scheduledExpenditureId,
    required this.currencyCode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'articleName': articleName,
    'amount': amount,
    'date': date.toIso8601String(),
    'mainTagId': mainTagId,
    'isIncome': isIncome,
    'subTagIds': subTagIds,
    'receiptImagePath': receiptImagePath,
    'scheduledExpenditureId': scheduledExpenditureId,
    'currencyCode': currencyCode,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Expenditure.fromJson(Map<String, dynamic> json) => Expenditure._(
    id: json['id'],
    articleName: json['articleName'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    mainTagId: json['mainTagId'],
    isIncome: json['isIncome'],
    subTagIds: List<String>.from(json['subTagIds']),
    receiptImagePath: json['receiptImagePath'],
    scheduledExpenditureId: json['scheduledExpenditureId'],
    currencyCode: json['currencyCode'],
    notes: json['notes'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.parse(json['date']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
  );
}
