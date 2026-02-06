import '../entities/scheduled_expenditure.dart';

abstract class ScheduledExpenditureRepository {
  Future<List<ScheduledExpenditure>> getAll();
  Future<void> add(ScheduledExpenditure item);
  Future<void> update(ScheduledExpenditure item);
  Future<void> delete(String id);
}
