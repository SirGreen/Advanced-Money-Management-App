import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// này cũng định nghĩa cách app đc init & chạy thôi
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
import 'data/data_sources/secure_storage_service.dart';
import 'ui/auth/lock_screen_page.dart';

import 'l10n/app_localizations.dart';
import 'ui/main_view.dart';

void main() async {
  // nhớ để nguyên dòng này vì hive cần đc init cho flutter trước khi
  // khởi tạo các class có đụng tới hive
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

  final secureStorageService = SecureStorageService();
  final settingsRepository = SettingsRepositoryImpl(
    SettingsService(),
    secureStorageService,
  );
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

// This widget is the root of your application.
class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _pinIsSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPinSet();
  }

  Future<void> _checkPinSet() async {
    final isEnabled = widget.settingsViewModel.isAppLockEnabled;
    setState(() {
      _pinIsSet = isEnabled;
      _isLocked = _pinIsSet;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _checkPinSet().then((_) {
        if (_pinIsSet && !_isLocked) {
          setState(() {
            _isLocked = true;
          });
        }
      });
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

        ChangeNotifierProvider(
          create: (_) => TagViewModel(
            getAllTags: GetAllTags(widget.tagRepository),
            addTag: AddTag(widget.tagRepository),
            updateTag: UpdateTag(widget.tagRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenditureViewModel(
            repository: widget.expenditureRepository,
            tagRepository: widget.tagRepository,
            scanReceiptUseCase: widget.scanReceiptUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ScheduledExpenditureViewModel(widget.scheduledRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
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
            builder: (context, child) {
              return Stack(
                children: [
                  if (child != null) child,
                  if (_isLocked && _pinIsSet)
                    Positioned.fill(
                      child: MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Colors.green,
                          ),
                          useMaterial3: true,
                        ),
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
