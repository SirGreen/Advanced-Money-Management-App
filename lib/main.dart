import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'domain/entities/expenditure.dart';
import 'domain/entities/tag.dart';
import 'domain/entities/settings.dart';
import 'domain/entities/scheduled_expenditure.dart';

import 'data/data_sources/llm_service.dart';
import 'data/data_sources/tag_local_data_source.dart';
import 'data/data_sources/expenditure_service.dart';
import 'data/data_sources/scheduled_expenditure_service.dart';
import 'data/data_sources/settings_service.dart';
import 'data/services/notification_service.dart';

import 'data/repositories/receipt_repository_impl.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'data/repositories/expenditure_repository_impl.dart';
import 'data/repositories/scheduled_expenditure_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';

import 'domain/usecases/scan_receipt_usecase.dart';
import 'domain/usecases/add_tag.dart';
import 'domain/usecases/get_all_tags.dart';
import 'domain/usecases/update_tag.dart';
import 'domain/services/recurring_transaction_service.dart';

import 'ui/tags/tag_view_model.dart';
import 'ui/transaction/expenditure_view_model.dart';
import 'ui/transaction/scheduled_expenditure_view_model.dart';
import 'ui/settings/settings_view_model.dart';

import 'l10n/app_localizations.dart';
import 'ui/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeDateFormatting('vi_VN', null);

  Hive.registerAdapter(ExpenditureAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(ScheduledExpenditureAdapter());
  Hive.registerAdapter(ScheduleTypeAdapter());
  Hive.registerAdapter(DividerTypeAdapter());
  Hive.registerAdapter(SettingsAdapter());

  final notificationService = NotificationService();
  await notificationService.init();

  final settingsRepository = SettingsRepositoryImpl(SettingsService());
  final tagRepository = TagRepositoryImpl(TagLocalDataSource());
  final expenditureRepository = ExpenditureRepositoryImpl(ExpenditureService());
  final scheduledRepository = ScheduledExpenditureRepositoryImpl(
    ScheduledExpenditureService(),
  );
  final receiptRepository = ReceiptRepositoryImpl(LLMService());

  final scanReceiptUseCase = ScanReceiptUseCase(receiptRepository);

  final settingsViewModel = SettingsViewModel(repository: settingsRepository);
  await settingsViewModel.initialize();

  final recurringService = RecurringTransactionService(
    scheduledRepository,
    expenditureRepository,
    notificationService,
  );

  final count = await recurringService.checkAndCreateTransactions();
  if (count > 0) debugPrint("Auto-created $count recurring transactions.");

  runApp(
    MyApp(
      settingsViewModel: settingsViewModel,
      tagRepository: tagRepository,
      expenditureRepository: expenditureRepository,
      scheduledRepository: scheduledRepository,
      scanReceiptUseCase: scanReceiptUseCase,
      recurringService: recurringService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsViewModel settingsViewModel;
  final TagRepositoryImpl tagRepository;
  final ExpenditureRepositoryImpl expenditureRepository;
  final ScheduledExpenditureRepositoryImpl scheduledRepository;
  final ScanReceiptUseCase scanReceiptUseCase;
  final RecurringTransactionService recurringService;

  const MyApp({
    super.key,
    required this.settingsViewModel,
    required this.tagRepository,
    required this.expenditureRepository,
    required this.scheduledRepository,
    required this.scanReceiptUseCase,
    required this.recurringService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsViewModel),

        Provider<RecurringTransactionService>.value(value: recurringService),

        ChangeNotifierProvider(
          create: (_) => TagViewModel(
            getAllTags: GetAllTags(tagRepository),
            addTag: AddTag(tagRepository),
            updateTag: UpdateTag(tagRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenditureViewModel(
            repository: expenditureRepository,
            tagRepository: tagRepository,
            scanReceiptUseCase: scanReceiptUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduledExpenditureViewModel(scheduledRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          final settingsViewModel = context.watch<SettingsViewModel>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Finance App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainView(),
          );
        },
      ),
    );
  }
}
