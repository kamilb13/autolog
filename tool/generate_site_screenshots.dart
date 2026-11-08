// Run from the repository root: flutter test tool/generate_site_screenshots.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:autolog/core/theme/app_theme.dart';
import 'package:autolog/data/repositories/expense_repository.dart';
import 'package:autolog/data/repositories/reminder_repository.dart';
import 'package:autolog/data/repositories/vehicle_repository.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/service_reminder.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:autolog/l10n/app_localizations.dart';
import 'package:autolog/presentation/providers/app_providers.dart';
import 'package:autolog/presentation/screens/add_expense_screen.dart';
import 'package:autolog/presentation/screens/main_navigation_screen.dart';
import 'package:autolog/presentation/screens/vehicle_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers/fake_repositories.dart';

const _vehicles = [
  Vehicle(
    id: 'demo-volvo',
    brand: 'Volvo',
    model: 'V60',
    year: 2020,
    licensePlate: 'WA 12345',
    mileageKm: 128450,
    fuelType: 'Diesel',
    generationOrTrim: 'D4',
  ),
  Vehicle(
    id: 'demo-toyota',
    brand: 'Toyota',
    model: 'Yaris',
    year: 2022,
    licensePlate: 'KR 24680',
    mileageKm: 38200,
    fuelType: 'Hybryda',
  ),
];
const _expenses = [
  Expense(
    id: 'demo-1',
    vehicleId: 'demo-volvo',
    category: ExpenseCategory.fuel,
    title: 'Tankowanie',
    amountPln: 312.50,
    date: '2026-11-07',
    mileageKm: 128450,
  ),
  Expense(
    id: 'demo-2',
    vehicleId: 'demo-volvo',
    category: ExpenseCategory.service,
    title: 'Wymiana oleju i filtrów',
    amountPln: 640,
    date: '2026-11-03',
    mileageKm: 128100,
  ),
  Expense(
    id: 'demo-3',
    vehicleId: 'demo-volvo',
    category: ExpenseCategory.parts,
    title: 'Wycieraczki przednie',
    amountPln: 129,
    date: '2026-10-24',
    mileageKm: 127850,
  ),
];

class _Vehicles extends VehicleRepository {
  @override
  Future<List<Vehicle>> getAllVehicles() async => _vehicles;
}

class _Expenses extends ExpenseRepository {
  @override
  Future<List<Expense>> getExpenses({
    String? vehicleId,
    ExpenseCategory? category,
    String? searchQuery,
  }) async => _expenses
      .where(
        (e) =>
            (vehicleId == null || e.vehicleId == vehicleId) &&
            (category == null || e.category == category) &&
            (searchQuery == null || e.title.contains(searchQuery)),
      )
      .toList();
}

class _Reminders extends ReminderRepository {
  @override
  Future<List<ServiceReminder>> getReminders({
    String? vehicleId,
    AlertSeverity? severityFilter,
    String? searchQuery,
  }) async => const [
    ServiceReminder(
      id: 'demo-reminder',
      vehicleId: 'demo-volvo',
      title: 'Przegląd techniczny',
      description: '',
      dueDate: '2026-12-01',
      daysRemaining: 23,
      severity: AlertSeverity.info,
    ),
  ];
}

class _ScreenshotBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  _ScreenshotBinding();
  setUpAll(() async {
    final config = jsonDecode(
      File('.dart_tool/package_config.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;
    final flutter = packages.cast<Map<String, dynamic>>().firstWhere(
      (p) => p['name'] == 'flutter',
    );
    final fonts = Uri.parse("${flutter['rootUri']}/")
        .resolve('../../bin/cache/artifacts/material_fonts/');
    // Replace the test runner's block font, including platform font aliases.
    for (final family in ['Roboto', 'sans-serif', 'monospace']) {
      final text = FontLoader(family);
      for (final font in [
        'Roboto-Regular.ttf',
        'Roboto-Medium.ttf',
        'Roboto-Bold.ttf',
      ]) {
        text.addFont(
          File.fromUri(fonts.resolve(font))
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await text.load();
    }
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File.fromUri(fonts.resolve('MaterialIcons-Regular.otf'))
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)),
      );
    await icons.load();
  });
  testWidgets('capture actual app screens with isolated demo data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final entry in <String, Widget>{
      'garage': const MainNavigationScreen(),
      'dashboard': const VehicleDashboardScreen(vehicleId: 'demo-volvo'),
      'expense': const AddExpenseScreen(initialVehicleId: 'demo-volvo'),
    }.entries) {
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            ...testRepositoryOverrides,
            vehicleRepositoryProvider.overrideWith((ref) => _Vehicles()),
            expenseRepositoryProvider.overrideWith((ref) => _Expenses()),
            reminderRepositoryProvider.overrideWith((ref) => _Reminders()),
          ],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('pl'),
              home: entry.value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (entry.key == 'expense') {
        await tester.enterText(find.byType(TextFormField).at(0), '312,50');
        await tester.enterText(find.byType(TextFormField).at(1), 'Tankowanie');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }
      // Restore Android's default font where the test engine uses block glyphs.
      for (final paragraph in tester.renderObjectList<RenderParagraph>(
        find.byType(RichText),
      )) {
        final text = paragraph.text as TextSpan;
        if (text.style?.fontFamily == null) {
          paragraph.text = TextSpan(
            text: text.text,
            children: text.children,
            style: (text.style ?? const TextStyle()).copyWith(
              fontFamily: 'Roboto',
            ),
          );
        }
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File('site/assets/${entry.key}.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
