import 'package:hive/hive.dart';

import 'investment.dart';

part 'portfolio.g.dart';

@HiveType(typeId: 11)
class Portfolio extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HiveList<Investment> investments;

  Portfolio({required this.id, required this.name, required this.investments});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'investments': investments.map((i) => i.toJson()).toList(),
  };

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    final investmentBox = Hive.box<Investment>('investments');
    return Portfolio(
      id: json['id'],
      name: json['name'],
      investments: HiveList(investmentBox),
    );
  }

  double get totalValue {
    return investments.fold(
      0.0,
      (sum, investment) => sum + investment.totalValue,
    );
  }

  double get totalCost {
    return investments.fold(
      0.0,
      (sum, investment) => sum + investment.totalCost,
    );
  }

  double get totalGainLoss => totalValue - totalCost;

  double get totalGainLossPercent {
    final cost = totalCost;
    return cost == 0 ? 0.0 : (totalGainLoss / cost) * 100;
  }
}
