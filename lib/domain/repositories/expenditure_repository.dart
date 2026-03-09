import '../entities/expenditure.dart';
import '../entities/settings.dart';

abstract class ExpenditureRepository {
  Future<List<Expenditure>> getExpenditures();
  Future<void> addExpenditure(Expenditure expenditure);
  Future<void> updateExpenditure(Expenditure expenditure);
  Future<void> deleteExpenditure(String id);

  Future<Map<String, dynamic>?> analyzeBudget({
    required Settings settings,
    required List<Map<String, dynamic>> transactions,
    required Map<String, dynamic> budgetDetails,
    required String currentDate,
    required String budgetEndDate,
    required String? userContext,
  });

  Future<Map<String, dynamic>?> analyzeFinancialReport({
    required Settings settings,
    required String dateRangeStart,
    required String dateRangeEnd,
    required String? userContext,
    required double totalIncome,
    required double totalExpenses,
    required List<Map<String, dynamic>> incomeBreakdown,
    required List<Map<String, dynamic>> expenseBreakdown,
    required List<Map<String, dynamic>> transactionList,
  });
}
