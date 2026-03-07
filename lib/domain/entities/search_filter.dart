import 'tag.dart';

enum TransactionTypeFilter { all, income, expense }

enum SortOption { dateDesc, dateAsc, amountDesc, amountAsc, nameAsc, nameDesc }

class SearchFilter {
  String? keyword;
  DateTime? startDate;
  DateTime? endDate;
  List<Tag>? tags;
  double? minAmount;
  double? maxAmount;
  TransactionTypeFilter transactionType;
  SortOption sortOption;

  SearchFilter({
    this.keyword,
    this.startDate,
    this.endDate,
    this.tags,
    this.minAmount,
    this.maxAmount,
    this.transactionType = TransactionTypeFilter.all,
    this.sortOption = SortOption.dateDesc,
  });

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'tags': tags?.map((t) => t.id).toList(),
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'transactionType': transactionType.toString(),
    'sortOption': sortOption.toString(),
  };
}
