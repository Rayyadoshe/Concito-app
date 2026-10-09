
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eco_tracker/main.dart';

void main() {
  testWidgets('EcoTracker app displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoTrackerApp());

    expect(find.text('EcoTracker'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

