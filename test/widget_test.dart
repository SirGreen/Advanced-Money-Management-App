import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:adv_money_mana/main.dart';

import 'package:adv_money_mana/domain/entities/expenditure.dart';
import 'package:adv_money_mana/domain/entities/tag.dart';
import 'package:adv_money_mana/domain/entities/scheduled_expenditure.dart';
import 'package:adv_money_mana/domain/entities/settings.dart';
import 'package:adv_money_mana/domain/entities/saving_goal.dart';
import 'package:adv_money_mana/domain/entities/saving_contribution.dart';

import 'package:adv_money_mana/data/data_sources/tag_service.dart';
import 'package:adv_money_mana/data/data_sources/expenditure_service.dart';
import 'package:adv_money_mana/data/data_sources/scheduled_expenditure_service.dart';
import 'package:adv_money_mana/data/data_sources/saving_goal_service.dart';
import 'package:adv_money_mana/data/data_sources/saving_contribution_service.dart';
import 'package:adv_money_mana/data/data_sources/llm_service.dart';
import 'package:adv_money_mana/data/services/notification_service.dart';

import 'package:adv_money_mana/domain/repositories/settings_repository.dart';
import 'package:adv_money_mana/data/repositories/tag_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/expenditure_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/scheduled_expenditure_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/receipt_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/saving_goal_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/export_repository_impl.dart';

import 'package:adv_money_mana/data/services/export_service.dart';

import 'package:adv_money_mana/domain/usecases/scan_receipt_usecase.dart';
import 'package:adv_money_mana/domain/services/recurring_transaction_service.dart';

import 'package:adv_money_mana/ui/settings/settings_view_model.dart';
import 'package:adv_money_mana/domain/repositories/currency_repository.dart';
import 'package:adv_money_mana/domain/usecases/convert_all_data_usecase.dart';
import 'package:adv_money_mana/domain/entities/custom_exchange_rate.dart';

class MockNotificationService extends Mock implements NotificationService {}

class FakeCurrencyRepository implements CurrencyRepository {
  @override
  Future<double?> getExchangeRate(String from, String to) async => 1.0;
  @override
  Future<List<CustomExchangeRate>> getAllCustomRates() async => [];
  @override
  Future<void> saveCustomRate(CustomExchangeRate customRate) async {}
  @override
  Future<void> deleteCustomRate(String conversionPair) async {}
  @override
  Future<void> refreshRates() async {}
}

class FakeConvertAllDataUseCase extends Mock implements ConvertAllDataUseCase {
  @override
  Future<void> execute(double rate, String newCurrencyCode) async {}
}

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> getSettings() async => Settings();

  @override
  Future<void> saveSettings(Settings settings) async {}

  @override
  Future<bool> getAppLockEnabled() async => false;

  @override
  Future<void> setAppLockEnabled(bool enabled) async {}
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App runs', (WidgetTester tester) async {
    Hive.registerAdapter(ExpenditureAdapter());
    Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(ScheduledExpenditureAdapter());
    Hive.registerAdapter(ScheduleTypeAdapter());
    Hive.registerAdapter(DividerTypeAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(SavingGoalAdapter());
    Hive.registerAdapter(SavingContributionAdapter());

    await initializeDateFormatting('vi_VN', null);

    final mockNotificationService = MockNotificationService();
    when(() => mockNotificationService.init()).thenAnswer((_) async {});
    await mockNotificationService.init();

    final llmService = LLMService();

    final settingsRepository = FakeSettingsRepository();
    final tagRepository = TagRepositoryImpl(TagService(), llmService);
    final expenditureRepository = ExpenditureRepositoryImpl(
      ExpenditureService(),
      llmService,
    );
    final scheduledRepository = ScheduledExpenditureRepositoryImpl(
      ScheduledExpenditureService(),
    );
    final savingGoalRepository = SavingGoalRepositoryImpl(
      SavingGoalService(),
      SavingContributionService(),
    );
    final exportRepository = ExportRepositoryImpl(ExportService());
    final receiptRepository = ReceiptRepositoryImpl(llmService);

    final scanReceiptUseCase = ScanReceiptUseCase(receiptRepository);
    final currencyRepository = FakeCurrencyRepository();
    final convertAllDataUseCase = FakeConvertAllDataUseCase();

    final recurringService = RecurringTransactionService(
      scheduledRepository,
      expenditureRepository,
      mockNotificationService,
    );

    final settingsViewModel = SettingsViewModel(
      repository: settingsRepository,
      currencyRepository: currencyRepository,
      convertAllDataUseCase: convertAllDataUseCase,
    );
    await settingsViewModel.initialize();

    await tester.pumpWidget(
      MyApp(
        settingsRepository: settingsRepository,
        settingsViewModel: settingsViewModel,
        tagRepository: tagRepository,
        expenditureRepository: expenditureRepository,
        scheduledRepository: scheduledRepository,
        savingGoalRepository: savingGoalRepository,
        exportRepository: exportRepository,
        currencyRepository: currencyRepository,
        scanReceiptUseCase: scanReceiptUseCase,
        recurringService: recurringService,
        notificationService: mockNotificationService,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
