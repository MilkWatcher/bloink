import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dilf_flutter/main.dart';

void main() {
  testWidgets('Onboarding shows and starts to main menu', (WidgetTester tester) async {
    await tester.pumpWidget(DilfApp());
    await tester.pumpAndSettle();

    // Onboarding should be visible
    expect(find.text('Welcome to DILF'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Enter a name and start
    await tester.enterText(find.byType(TextField).first, 'Alex');
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // After onboarding we should see the nightly goals prompt
    expect(find.textContaining('Tonight: set three goals'), findsOneWidget);
  });
}
