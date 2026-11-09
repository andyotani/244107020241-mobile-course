
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Campus Notification widget test',
      (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Campus Notification'),
          ),
        ),
      ),
    );

    expect(
      find.text('Campus Notification'),
      findsOneWidget,
    );
  });
}
