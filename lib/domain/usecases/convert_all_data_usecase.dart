import '../repositories/expenditure_repository.dart';
import '../repositories/scheduled_expenditure_repository.dart';
import '../repositories/tag_repository.dart';

class ConvertAllDataUseCase {
  final ExpenditureRepository expenditureRepository;
  final ScheduledExpenditureRepository scheduledRepository;
  final TagRepository tagRepository;

  ConvertAllDataUseCase({
    required this.expenditureRepository,
    required this.scheduledRepository,
    required this.tagRepository,
  });

  Future<void> execute(double rate, String newCurrencyCode) async {
    // 1. Convert Expenditures
    final expenditures = await expenditureRepository.getExpenditures();
    for (final exp in expenditures) {
      if (exp.amount != null) {
        exp.amount = exp.amount! * rate;
      }
      exp.currencyCode = newCurrencyCode;
      await expenditureRepository.updateExpenditure(exp);
    }

    // 2. Convert Scheduled Expenditures
    final scheduled = await scheduledRepository.getAll();
    for (final rule in scheduled) {
      if (rule.amount != null) {
        rule.amount = rule.amount! * rate;
      }
      rule.currencyCode = newCurrencyCode;
      await scheduledRepository.update(rule);
    }

    // 3. Convert Tag Budgets
    final tags = await tagRepository.getAllTags();
    for (final tag in tags) {
      if (tag.budgetAmount != null) {
        tag.budgetAmount = tag.budgetAmount! * rate;
      }
      await tagRepository.updateTag(tag);
    }
    
    // Note: Saving accounts and goals are not converted here yet 
    // to match the old app's functionality precisely as requested.
  }
}
