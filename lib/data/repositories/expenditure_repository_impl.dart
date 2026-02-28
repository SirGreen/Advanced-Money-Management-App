import '../../domain/repositories/expenditure_repository.dart';
import '../../domain/entities/expenditure.dart';
import '../data_sources/expenditure_service.dart';

class ExpenditureRepositoryImpl implements ExpenditureRepository {
  final ExpenditureService _service;

  ExpenditureRepositoryImpl(this._service);

  @override
  Future<List<Expenditure>> getExpenditures() => _service.getAll();

  @override
  Future<void> addExpenditure(Expenditure expenditure) =>
      _service.add(expenditure);

  @override
  Future<void> updateExpenditure(Expenditure expenditure) =>
      _service.update(expenditure);

  @override
  Future<void> deleteExpenditure(String id) => _service.delete(id);
}
