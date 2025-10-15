// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:tlu_schedule_management/main.dart';
import 'package:tlu_schedule_management/app_state.dart';

void main() {
  testWidgets('App builds and shows overview title', (WidgetTester tester) async {
    // Build the real app wrapped by the provider used in main().
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState.sample(),
        child: const TluApp(),
      ),
    );

    // Let animations settle
    await tester.pumpAndSettle();

    // The overview screen shows the title 'Tổng quan'
    expect(find.text('Tổng quan'), findsOneWidget);
  });
}
