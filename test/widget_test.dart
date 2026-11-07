import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'helpers/fake_repositories.dart';

import 'package:autolog/main.dart';
import 'package:autolog/presentation/screens/main_navigation_screen.dart';

void main() {
  testWidgets('AutoLogApp smoke test and navigation test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testRepositoryOverrides,
        child: const AutoLogApp(),
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
