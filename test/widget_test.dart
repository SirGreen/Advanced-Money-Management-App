import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:adv_money_mana/main.dart';

import 'package:adv_money_mana/domain/entities/expenditure.dart';
import 'package:adv_money_mana/domain/entities/tag.dart';
import 'package:adv_money_mana/domain/entities/scheduled_expenditure.dart';
import 'package:adv_money_mana/domain/entities/settings.dart';

import 'package:adv_money_mana/data/data_sources/settings_service.dart';
import 'package:adv_money_mana/data/data_sources/tag_local_data_source.dart';
import 'package:adv_money_mana/data/data_sources/expenditure_service.dart';
import 'package:adv_money_mana/data/data_sources/scheduled_expenditure_service.dart';
import 'package:adv_money_mana/data/data_sources/llm_service.dart';
import 'package:adv_money_mana/data/services/notification_service.dart';

import 'package:adv_money_mana/data/repositories/settings_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/tag_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/expenditure_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/scheduled_expenditure_repository_impl.dart';
import 'package:adv_money_mana/data/repositories/receipt_repository_impl.dart';

import 'package:adv_money_mana/domain/usecases/scan_receipt_usecase.dart';
import 'package:adv_money_mana/domain/services/recurring_transaction_service.dart';

import 'package:adv_money_mana/ui/settings/settings_view_model.dart';

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

    await initializeDateFormatting('vi_VN', null);
    final notificationService = NotificationService();
    await notificationService.init();

    final settingsRepository = SettingsRepositoryImpl(SettingsService());
    final tagRepository = TagRepositoryImpl(TagLocalDataSource());
    final expenditureRepository = ExpenditureRepositoryImpl(
      ExpenditureService(),
    );
    final scheduledRepository = ScheduledExpenditureRepositoryImpl(
      ScheduledExpenditureService(),
    );
    final receiptRepository = ReceiptRepositoryImpl(LLMService());

    final scanReceiptUseCase = ScanReceiptUseCase(receiptRepository);

    final recurringService = RecurringTransactionService(
      scheduledRepository,
      expenditureRepository,
      notificationService,
    );

    final settingsViewModel = SettingsViewModel(repository: settingsRepository);
    await settingsViewModel.initialize();

    await tester.pumpWidget(
      MyApp(
        settingsViewModel: settingsViewModel,
        tagRepository: tagRepository,
        expenditureRepository: expenditureRepository,
        scheduledRepository: scheduledRepository,
        scanReceiptUseCase: scanReceiptUseCase,
        recurringService: recurringService,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
