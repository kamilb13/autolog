import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:autolog/main.dart';
import 'package:autolog/presentation/screens/main_navigation_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('AutoLogApp smoke test and navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AutoLogApp(),
      ),
    );

    // Let async providers initialize and settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
