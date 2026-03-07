import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../ui/controller/expenditure_controller.dart';
import ../../ui/controller/settings_controller.dart';
import ../../data/models/cached_rate.dart';
import ../../app/models/custom_exchange_rate.dart';
import ../../data/model/expenditure.dart';
import ../../data/model/settings.dart';
import ../../data/model/tag.dart';
import ../services/database_service.dart';
import ../../ui/sections/main_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import ../../l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('vi', null);

  await Hive.initFlutter();

  Hive.registerAdapter(ExpenditureAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(DividerTypeAdapter());
  Hive.registerAdapter(CustomExchangeRateAdapter()); // used internally by CurrencyService
  Hive.registerAdapter(CachedRateAdapter());         // used internally by CurrencyService


  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsController()),
        ChangeNotifierProvider(create: (context) => ExpenditureController()),
      ],
      child: const AppLifecycleManager(),
    );
  }
}

class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({super.key});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> {
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await DatabaseService().openAllBoxes();

    if (!mounted) return;

    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    await settingsController.initialize();

    if (!mounted) return;


    final expenditureController =
        Provider.of<ExpenditureController>(context, listen: false);
    final locale = settingsController.settings.languageCode != null
        ? Locale(settingsController.settings.languageCode!)
        : WidgetsBinding.instance.platformDispatcher.locale;

    final l10n = await AppLocalizations.delegate.load(locale);
    await expenditureController.initialize(l10n, settingsController.settings);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Consumer<SettingsController>(
      builder: (context, settingsController, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appName ?? 'Kakeibo',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal, width: 2.0),
              ),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: settingsController.settings.languageCode != null
              ? Locale(settingsController.settings.languageCode!)
              : null,
          home: const MainPage(),
        );
      },
    );
  }
}
