import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_stripe_connect_example/main.dart';

void main() {
  testWidgets('home page asks for a publishable key when none is defined', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Stripe Connect Demo'), findsOneWidget);
    expect(
      find.textContaining('Set STRIPE_PUBLISHABLE_KEY with --dart-define.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });
}
