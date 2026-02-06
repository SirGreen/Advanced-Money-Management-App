import 'package:hive/hive.dart';

part 'investment.g.dart';

@HiveType(typeId: 10)
class Investment extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String symbol;
  @HiveField(2)
  String name;
  @HiveField(3)
  double quantity;
  @HiveField(4)
  double averageBuyPrice;
  @HiveField(5)
  double? currentPrice;
  @HiveField(6)
  double? dayChange;

  Investment({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averageBuyPrice,
    this.currentPrice,
    this.dayChange,
  });

  double get totalValue => (currentPrice ?? averageBuyPrice) * quantity;
  double get totalCost => averageBuyPrice * quantity;
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent =>
      (gainLoss / totalCost).isNaN ? 0.0 : (gainLoss / totalCost) * 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'quantity': quantity,
    'averageBuyPrice': averageBuyPrice,
    'currentPrice': currentPrice,
    'dayChange': dayChange,
  };

  factory Investment.fromJson(Map<String, dynamic> json) => Investment(
    id: json['id'],
    symbol: json['symbol'],
    name: json['name'],
    quantity: json['quantity'],
    averageBuyPrice: json['averageBuyPrice'],
    currentPrice: json['currentPrice'],
    dayChange: json['dayChange'],
  );
}
