import '../../domain/repositories/scheduled_expenditure_repository.dart';
import '../../domain/entities/scheduled_expenditure.dart';
import '../data_sources/scheduled_expenditure_service.dart';

class ScheduledExpenditureRepositoryImpl
    implements ScheduledExpenditureRepository {
  final ScheduledExpenditureService _service;

  ScheduledExpenditureRepositoryImpl(this._service);

  @override
  Future<List<ScheduledExpenditure>> getAll() => _service.getAll();

  @override
  Future<void> add(ScheduledExpenditure item) => _service.add(item);

  @override
  Future<void> update(ScheduledExpenditure item) => _service.update(item);

  @override
  Future<void> delete(String id) => _service.delete(id);
}
