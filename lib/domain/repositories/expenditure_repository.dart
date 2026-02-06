import '../entities/expenditure.dart';

abstract class ExpenditureRepository {
  Future<List<Expenditure>> getExpenditures();
  Future<void> addExpenditure(Expenditure expenditure);
  Future<void> updateExpenditure(Expenditure expenditure);
  Future<void> deleteExpenditure(String id);
}
