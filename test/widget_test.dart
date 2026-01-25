import 'package:flutter_test/flutter_test.dart';
// Replace 'your_app_package' with your actual package name defined in pubspec.yaml
import 'package:adv_money_mana/main.dart'; 

void main() {
  testWidgets('Money View updates smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('\$0'), findsOneWidget);
    expect(find.text('\$10'), findsNothing);

    await tester.tap(find.text('Spend \$10'));

    await tester.pump();

    expect(find.text('\$0'), findsNothing);
    expect(find.text('\$10'), findsOneWidget);
  });
}
