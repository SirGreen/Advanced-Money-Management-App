import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// --- Imports from Master ---
import 'domain/entities/expenditure.dart'; 
import 'domain/entities/tag.dart';
import 'domain/entities/settings.dart';
import 'ui/controllers/settings_controller.dart';
import 'ui/controllers/expenditure_controller.dart';
import 'data/data_sources/database_service.dart';
import 'data/data_sources/llm_service.dart';
import 'data/repositories/receipt_repository_impl.dart'; 
import 'domain/usecases/scan_receipt_usecase.dart';
import 'l10n/app_localizations.dart';
import 'ui/sections/camera_scanner_page.dart';

// --- Imports from tags-Huy ---
import 'data/data_sources/tag_local_data_source.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'domain/usecases/add_tag.dart';
import 'domain/usecases/get_all_tags.dart';
import 'domain/usecases/update_tag.dart';
import 'ui/tags/manage_tags_page.dart';
import 'ui/tags/tag_view_model.dart';

void main() async {
  // 1. Ensure Flutter Binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Register Hive Adapters (Keep all of them)
  Hive.registerAdapter(ExpenditureAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(SettingsAdapter());

  // 4. Khởi tạo Database Service & Mở các Box cần thiết
  final databaseService = DatabaseService();
  await databaseService.openBoxes();

  // 5. Khởi tạo SettingsController và load dữ liệu ban đầu
  final settingsController = SettingsController();
  await settingsController.initialize();

  // 6. Setup Dependency Injection cho tính năng Scan
  // LLMService -> Repository -> UseCase -> Controller
  final llmService = LLMService();


  final receiptRepository = ReceiptRepositoryImpl(llmService);
  final scanReceiptUseCase = ScanReceiptUseCase(receiptRepository);

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp SettingsController đã được initialize
        ChangeNotifierProvider.value(value: settingsController),

        // Cung cấp ExpenditureController với UseCase được inject vào
        ChangeNotifierProvider(
          create: (_) => ExpenditureController(
            scanReceiptUseCase: scanReceiptUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. INITIALIZE TAG DEPENDENCIES (from tags-Huy)
    // In a larger app, you might move this to a dependency injection container (like GetIt)
    final tagLocalDataSource = TagLocalDataSource();
    final tagRepository = TagRepositoryImpl(tagLocalDataSource);

    final getAllTags = GetAllTags(tagRepository);
    final addTag = AddTag(tagRepository);
    final updateTag = UpdateTag(tagRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TagViewModel(
            getAllTags: getAllTags,
            addTag: addTag,
            updateTag: updateTag,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          // 4. LISTEN TO SETTINGS (from master)
          // This ensures the MaterialApp rebuilds when theme/language changes
          final settings = context.watch<SettingsController>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Finance App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            home: const ManageTagsPage(), 
      ),
      
      // Cấu hình Localization (Đa ngôn ngữ)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Nếu bạn lưu locale trong settings, có thể dùng: 
      // locale: settingsController.settings.locale,

      // Màn hình chính
      // Bạn có thể đổi thành HomePage() hoặc màn hình Dashboard của bạn
      home: const CameraScannerPage(), 
    );
  }
}