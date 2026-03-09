import 'package:adv_money_mana/data/data_sources/llm_service.dart';

import '../../domain/entities/settings.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/entities/expenditure.dart';
import '../data_sources/expenditure_service.dart';

class ExpenditureRepositoryImpl implements ExpenditureRepository {
  final ExpenditureService _expenditures;
  final LLMService _llm;

  ExpenditureRepositoryImpl(this._expenditures, this._llm);

  @override
  Future<List<Expenditure>> getExpenditures() => _expenditures.getAll();

  @override
  Future<void> addExpenditure(Expenditure expenditure) =>
      _expenditures.add(expenditure);

  @override
  Future<void> updateExpenditure(Expenditure expenditure) =>
      _expenditures.update(expenditure);

  @override
  Future<void> deleteExpenditure(String id) => _expenditures.delete(id);

  @override
  Future<Map<String, dynamic>?> analyzeBudget({
    required Settings settings,
    required List<Map<String, dynamic>> transactions,
    required Map<String, dynamic> budgetDetails,
    required String currentDate,
    required String budgetEndDate,
    required String? userContext,
  }) async {
    return await _llm.analyzeBudget(
      settings: settings,
      transactions: transactions,
      budgetDetails: budgetDetails,
      currentDate: currentDate,
      budgetEndDate: budgetEndDate,
      userContext: userContext,
    );
  }

  @override
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
  }) async {
    return await _llm.analyzeFinancialReport(
      settings: settings,
      dateRangeStart: dateRangeStart,
      dateRangeEnd: dateRangeEnd,
      userContext: userContext,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      incomeBreakdown: incomeBreakdown,
      expenseBreakdown: expenseBreakdown,
      transactionList: transactionList,
    );
  }
}
