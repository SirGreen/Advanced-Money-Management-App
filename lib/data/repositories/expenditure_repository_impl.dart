import 'package:adv_money_mana/data/data_sources/llm_service.dart';

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

  
}
