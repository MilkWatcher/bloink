import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dilf_flutter/main.dart';

void main() {
  testWidgets('Holding all bubbles completes alarm (normal mode)', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AlarmScreen(goals: ['A','B','C'], randomizeOrder: false, escalationMode: false, requireMorningPrompt: false)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AlarmScreen));

    // hold each bubble in order by invoking startHold on state
    (state as dynamic).startHold(0);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[0], isTrue);

    (state as dynamic).startHold(1);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[1], isTrue);

    (state as dynamic).startHold(2);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[2], isTrue);

    expect(((state as dynamic).completed as List).every((e) => e == true), isTrue);
  });

  testWidgets('Escalation mode blocks out-of-order holds', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AlarmScreen(goals: ['A','B','C'], randomizeOrder: false, escalationMode: true, requireMorningPrompt: false)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AlarmScreen));

    // Attempt out-of-order: try to hold index 1 first
    (state as dynamic).startHold(1);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[1], isFalse);

    // Now hold index 0, should succeed
    (state as dynamic).startHold(0);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[0], isTrue);

    // Now index 1 should succeed
    (state as dynamic).startHold(1);
    await tester.pump(Duration(milliseconds: 3100));
    expect((state as dynamic).completed[1], isTrue);
  });
}
