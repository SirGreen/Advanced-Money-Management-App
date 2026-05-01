import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'domain/entities/expenditure.dart';
import 'domain/entities/tag.dart';
import 'domain/entities/settings.dart';
import 'domain/entities/scheduled_expenditure.dart';
import 'domain/entities/saving_goal.dart';
import 'domain/entities/saving_contribution.dart';
import 'domain/entities/saving_account.dart';
import 'domain/entities/cached_rate.dart';
import 'domain/entities/custom_exchange_rate.dart';

import 'data/data_sources/llm_service.dart';
import 'data/data_sources/expenditure_service.dart';
import 'data/data_sources/scheduled_expenditure_service.dart';
import 'data/data_sources/settings_service.dart';
import 'data/data_sources/tag_service.dart';
import 'data/data_sources/saving_goal_service.dart';
import 'data/data_sources/saving_contribution_service.dart';
import 'data/data_sources/currency_api_service.dart';
import 'data/data_sources/currency_local_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/export_service.dart';

import 'data/repositories/receipt_repository_impl.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'data/repositories/expenditure_repository_impl.dart';
import 'data/repositories/scheduled_expenditure_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/repositories/saving_goal_repository_impl.dart';
import 'data/repositories/export_repository_impl.dart';
import 'data/repositories/currency_repository_impl.dart';

import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/currency_repository.dart';
import 'domain/usecases/scan_receipt_usecase.dart';
import 'domain/usecases/convert_all_data_usecase.dart';
import 'domain/services/recurring_transaction_service.dart';

import 'ui/tags/tag_view_model.dart';
import 'ui/transaction/expenditure_view_model.dart';
import 'ui/transaction/scheduled_expenditure_view_model.dart';
import 'ui/settings/settings_view_model.dart';
import 'ui/savings/saving_goal_view_model.dart';
import 'ui/savings/saving_account_view_model.dart';
import 'ui/export/export_view_model.dart';
import 'data/data_sources/secure_storage_service.dart';
import 'ui/auth/lock_screen_page.dart';

import 'l10n/app_localizations.dart';
import 'ui/main_view.dart';
import 'package:quick_actions/quick_actions.dart';
import 'ui/transaction/add_transaction_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('ja', null),
    initializeDateFormatting('vi', null),
  ]);

  Hive.registerAdapter(ExpenditureAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(ScheduledExpenditureAdapter());
  Hive.registerAdapter(ScheduleTypeAdapter());
  Hive.registerAdapter(DividerTypeAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(SavingGoalAdapter());
  Hive.registerAdapter(SavingContributionAdapter());
  Hive.registerAdapter(SavingAccountAdapter());
  Hive.registerAdapter(CachedRateAdapter());
  Hive.registerAdapter(CustomExchangeRateAdapter());

  final notificationService = NotificationService();
  await notificationService.init();

  final llmService = LLMService();
  final secureStorageService = SecureStorageService();
  final settingsRepository = SettingsRepositoryImpl(
    SettingsService(),
    secureStorageService,
  );
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

  final currencyApiService = CurrencyApiService();
  final currencyLocalService = CurrencyLocalService();
  final currencyRepository = CurrencyRepositoryImpl(
    currencyApiService,
    currencyLocalService,
    settingsRepository,
  );
  final convertAllDataUseCase = ConvertAllDataUseCase(
    expenditureRepository: expenditureRepository,
    scheduledRepository: scheduledRepository,
    tagRepository: tagRepository,
  );

  final scanReceiptUseCase = ScanReceiptUseCase(receiptRepository);

  final settingsViewModel = SettingsViewModel(
    repository: settingsRepository,
    currencyRepository: currencyRepository,
    convertAllDataUseCase: convertAllDataUseCase,
  );
  await settingsViewModel.initialize();

  final recurringService = RecurringTransactionService(
    scheduledRepository,
    expenditureRepository,
    notificationService,
  );

  final count = await recurringService.checkAndCreateTransactions();
  if (count > 0) debugPrint("Auto-created $count recurring transactions.");

  // Ensure reminders are scheduled for all active rules
  await recurringService.rescheduleAllReminders();

  runApp(
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
      notificationService: notificationService,
    ),
  );
}

// This widget is the root of your application.
class MyApp extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final SettingsViewModel settingsViewModel;
  final TagRepositoryImpl tagRepository;
  final ExpenditureRepositoryImpl expenditureRepository;
  final ScheduledExpenditureRepositoryImpl scheduledRepository;
  final SavingGoalRepositoryImpl savingGoalRepository;
  final ExportRepositoryImpl exportRepository;
  final CurrencyRepository currencyRepository;
  final ScanReceiptUseCase scanReceiptUseCase;
  final RecurringTransactionService recurringService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.settingsRepository,
    required this.settingsViewModel,
    required this.tagRepository,
    required this.expenditureRepository,
    required this.scheduledRepository,
    required this.savingGoalRepository,
    required this.exportRepository,
    required this.currencyRepository,
    required this.scanReceiptUseCase,
    required this.recurringService,
    required this.notificationService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _pinIsSet = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pinIsSet = widget.settingsViewModel.isAppLockEnabled;
    _isLocked = _pinIsSet;
    _setupQuickActions();
  }

  void _setupQuickActions() {
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_add_transaction') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AddTransactionView()),
        );
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_add_transaction',
        localizedTitle: 'Ghi nhanh giao dịch',
        // icon: 'ic_add_shortcut', // Bỏ icon đi để tránh crash trên Android/iOS nếu chưa setup ảnh native
      ),
    ]);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final isEnabled = widget.settingsViewModel.isAppLockEnabled;
      if (isEnabled && !_isLocked) {
        setState(() {
          _pinIsSet = isEnabled;
          _isLocked = true;
        });
      }
    }
  }

  void _onUnlock() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.settingsViewModel),

        Provider<RecurringTransactionService>.value(
          value: widget.recurringService,
        ),

        Provider<NotificationService>.value(
          value: widget.notificationService,
        ),

        ChangeNotifierProvider(
          create: (_) => TagViewModel(widget.tagRepository)..load(),
        ),
        ChangeNotifierProxyProvider<TagViewModel, ExpenditureViewModel>(
          create: (_) => ExpenditureViewModel(
            repository: widget.expenditureRepository,
            tagRepository: widget.tagRepository,
            settingsRepository: widget.settingsRepository,
            currencyRepository: widget.currencyRepository,
            scanReceiptUseCase: widget.scanReceiptUseCase,
          ),
          update: (_, tagViewModel, expenditureViewModel) {
            return expenditureViewModel!..updateTags(tagViewModel.tags);
          },
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ScheduledExpenditureViewModel(widget.scheduledRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SavingGoalViewModel(repository: widget.savingGoalRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SavingAccountViewModel()..loadSavingAccounts(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExportViewModel(
            exportRepository: widget.exportRepository,
            expenditureRepository: widget.expenditureRepository,
            tagRepository: widget.tagRepository,
            settingsRepository: widget.settingsRepository,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final settingsViewModel = context.watch<SettingsViewModel>();
          final locale = settingsViewModel.settings.languageCode == null
              ? null
              : Locale(settingsViewModel.settings.languageCode!);

          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Finance App',
            locale: locale,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainView(),
            builder: (context, child) {
              return Stack(
                children: [
                  child ?? const SizedBox(),
                  if (_isLocked && _pinIsSet)
                    Positioned.fill(
                      child: MaterialApp(
                        debugShowCheckedModeBanner: false,
                        locale: locale,
                        theme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Colors.teal,
                          ),
                          useMaterial3: true,
                        ),
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,
                        supportedLocales: AppLocalizations.supportedLocales,
                        home: LockScreenPage(onUnlock: _onUnlock),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
