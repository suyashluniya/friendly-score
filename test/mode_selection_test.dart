import 'package:demo/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mode selection shows two buttons and navigates', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Jumping'), findsOneWidget);
    expect(find.text('Mountain Sport'), findsOneWidget);

    await tester.tap(find.text('Jumping'));
    await tester.pumpAndSettle();
    expect(find.text('Jumping Mode'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mountain Sport'));
    await tester.pumpAndSettle();
    expect(find.text('Mountain Sport Mode'), findsOneWidget);
  });
}
