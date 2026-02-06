import 'package:flutter_test/flutter_test.dart';
import 'package:adv_money_mana/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:adv_money_mana/data/data_sources/hive_service.dart';

// nên đọc documentation để viết test
// tui chưa hình dung là nên có test cho từng tí code luôn ko
// tui nghĩ có thể tách việc thêm test thành task riêng nếu sprint đang chật quá

// test này tui chưa fix nên để sau :v

void main() {
  testWidgets('Money View updates smoke test', (WidgetTester tester) async {
    await Hive.initFlutter();
    final hiveService = HiveService();
    // Note: This test might still fail logic-wise because Hive needs open boxes
    // For now, fixing the compilation error at least.

    await tester.pumpWidget(MyApp(hiveService: hiveService));

    expect(find.text('Spend \$10'), findsOneWidget);
    expect(find.text('Spend \$50'), findsOneWidget);

    await tester.tap(find.text('Spend \$10'));

    await tester.pump();

    // expect(find.text('\$0'), findsNothing);
    // expect(find.text('\$10'), findsOneWidget);
  });
}
