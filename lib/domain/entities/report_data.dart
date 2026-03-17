import 'package:fl_chart/fl_chart.dart';

import 'tag.dart';

class TagReportData {
  double totalAmount;
  int transactionCount;
  TagReportData({required this.totalAmount, required this.transactionCount});
}

class LineChartReportData {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final double minX, maxX;
  final double maxY;

  LineChartReportData({
    required this.incomeSpots,
    required this.expenseSpots,
    required this.minX,
    required this.maxX,
    required this.maxY,
  });
}

class ReportData {
  final double totalIncome;
  final double totalExpense;
  final Map<Tag, TagReportData> incomeByTag;
  final Map<Tag, TagReportData> expenseByTag;
  final LineChartReportData? lineChartData;

  ReportData({
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    required this.incomeByTag,
    required this.expenseByTag,
    this.lineChartData,
  });
}
