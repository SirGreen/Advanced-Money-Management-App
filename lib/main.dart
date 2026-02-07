import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// 1. Import Entities & Adapters
// LƯU Ý: Bạn cần import các file .g.dart hoặc file chứa Adapter được sinh ra
import 'domain/entities/expenditure.dart'; 
import 'domain/entities/tag.dart';
import 'domain/entities/settings.dart';

// 2. Import Controllers
import '../ui/controllers/settings_controller.dart';
import '../ui/controllers/expenditure_controller.dart';

// 3. Import Services & Data Sources
import 'data/data_sources/database_service.dart';
import 'data/data_sources/llm_service.dart';

// 4. Import Repositories & UseCases
// Giả định bạn đã có file implementation của ReceiptRepository
import 'data/repositories/receipt_repository_impl.dart'; 
import 'domain/usecases/scan_receipt_usecase.dart';

// 5. Import Localization
import 'l10n/app_localizations.dart';

// 6. Import Screens
import 'ui/sections/camera_scanner_page.dart';
// import 'presentation/pages/home_page.dart'; // Trang chủ của bạn

void main() async {
  // 1. Đảm bảo Flutter Binding được khởi tạo trước khi gọi native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Hive
  await Hive.initFlutter();

  // 3. Đăng ký Hive Adapters
  // LƯU Ý: Các class Adapter này (ExpenditureAdapter, TagAdapter, SettingsAdapter) 
  // được sinh ra khi bạn chạy `flutter pub run build_runner build`.
  // Hãy đảm bảo bạn đã generate code và import đúng.
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
    // Lắng nghe SettingsController để cập nhật Theme hoặc Language nếu có
    final _ = context.watch<SettingsController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App', // Tên App của bạn
      
      // Cấu hình Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
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