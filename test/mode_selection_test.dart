import 'package:friendly_score/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mode selection shows two buttons and navigates', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Show Jumping'), findsOneWidget);
    expect(find.text('Mounted Sports'), findsOneWidget);

    await tester.tap(find.text('Show Jumping'));
    await tester.pumpAndSettle();
    expect(find.text('Jumping Mode'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mounted Sports'));
    await tester.pumpAndSettle();
    expect(find.text('Mounted Sports Mode'), findsOneWidget);
  });
}
