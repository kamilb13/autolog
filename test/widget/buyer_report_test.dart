import 'dart:convert';

import 'package:autolog/data/services/pdf_report_service.dart';
import 'package:autolog/domain/models/buyer_report.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:autolog/presentation/widgets/buyer_report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const vehicle = Vehicle(
  id: 'volvo',
  brand: 'Volvo',
  model: 'V60',
  year: 2020,
  licensePlate: 'WA 12345',
  mileageKm: 125000,
  fuelType: 'Diesel',
  vin: 'YV1TEST12345678901',
  purchasePricePln: 85000,
);
const entries = [
  Expense(
    id: 'fuel',
    vehicleId: 'volvo',
    category: ExpenseCategory.fuel,
    title: 'Tankowanie',
    amountPln: 333,
    date: '2026-09-15',
  ),
  Expense(
    id: 'oil',
    vehicleId: 'volvo',
    category: ExpenseCategory.service,
    title: 'Wymiana oleju',
    amountPln: 450,
    date: '2026-09-10',
    mileageKm: 124500,
    workshopOrLocation: 'Serwis Żółć',
    note: 'Olej 0W-20, wymiana filtra.',
  ),
  Expense(
    id: 'parts',
    vehicleId: 'volvo',
    category: ExpenseCategory.parts,
    title: 'Klocki hamulcowe',
    amountPln: 280,
    date: '01.08.2026',
  ),
];

BuyerReport makeReport({List<Expense> expenses = entries}) => BuyerReport(
  vehicle: vehicle,
  generatedAt: '07.11.2026',
  expenses: expenses,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults contain service and parts without financial summary', () {
    final report = makeReport();
    expect(report.expenses.map((e) => e.id), ['oil', 'parts']);
    expect(report.totalExpensesCount, 2);
    expect(report.formattedSummary, contains('Serwis Żółć'));
    expect(report.formattedSummary, isNot(contains('Tankowanie')));
    expect(report.formattedSummary, isNot(contains('zł')));
    expect(report.formattedSummary, isNot(contains('85000')));
    expect(report.formattedSummary, isNot(contains('Diesel')));
  });

  test('selection controls entries, count, sum and optional text fields', () {
    final report = makeReport().copyWith(
      selectedExpenseIds: {'parts', 'fuel'},
      includeCosts: true,
      includeNotes: false,
      includeWorkshop: false,
      includeVin: false,
    );
    expect(report.totalExpensesCount, 2);
    expect(report.totalCostPln, 613);
    expect(report.formattedSummary, contains('Tankowanie'));
    expect(report.formattedSummary, contains('613,00 zł'));
    expect(report.formattedSummary, isNot(contains('Wymiana oleju')));
    expect(report.formattedSummary, isNot(contains(vehicle.vin)));

    final noDetails = makeReport()
        .copyWith(
          includeNotes: false,
          includeWorkshop: false,
          includeVin: false,
        )
        .formattedSummary;
    expect(noDetails, isNot(contains('Serwis Żółć')));
    expect(noDetails, isNot(contains('Olej 0W-20')));
    expect(noDetails, isNot(contains(vehicle.vin)));
  });

  test('empty selection stays empty when options change', () {
    final report = makeReport()
        .copyWith(selectedExpenseIds: {})
        .copyWith(includeCosts: true);
    expect(report.expenses, isEmpty);
    expect(report.totalCostPln, 0);
    expect(report.formattedSummary, isNot(contains('Wymiana oleju')));
    expect(makeReport().totalExpensesCount, 2);
  });

  test(
    'dates are sorted across legacy and ISO formats, other vehicles excluded',
    () {
      final report = makeReport(
        expenses: [
          entries[2].copyWith(date: '30.09.2026'),
          entries[1],
          entries[0].copyWith(vehicleId: 'other-car'),
        ],
      );
      expect(report.allExpenses.map((e) => e.id), ['parts', 'oil']);
    },
  );

  test('report snapshots do not share mutable selection or source lists', () {
    final ids = {'oil'};
    final source = entries.toList();
    final report = BuyerReport(
      vehicle: vehicle,
      generatedAt: '07.11.2026',
      expenses: source,
      selectedExpenseIds: ids,
    );
    ids.clear();
    source.clear();
    expect(report.expenses.single.id, 'oil');
    expect(() => report.allExpenses.clear(), throwsUnsupportedError);
  });

  test(
    'PDF works with bundled fonts, missing mileage and long multipage notes',
    () async {
      final report = makeReport(
        expenses: [
          for (var i = 0; i < 70; i++)
            entries[1].copyWith(
              id: 'service-$i',
              mileageKm: null,
              clearMileage: true,
              note: i == 0
                  ? List.filled(250, 'Zażółć gęślą jaźń.').join(' ')
                  : null,
            ),
        ],
      );
      final bytes = await PdfReportService.generateBuyerReportPdf(report);
      expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    },
  );

  String? copiedText;
  Future<void> openDialog(WidgetTester tester) async {
    copiedText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuyerReportDialog(report: makeReport(), onDismiss: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('category and options affect copied report on a small screen', (
    tester,
  ) async {
    await openDialog(tester);
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Kwoty i suma'),
          )
          .value,
      isFalse,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Paliwo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopiuj tekst'));
    await tester.pumpAndSettle();
    final copied = copiedText!;
    expect(copied, contains('Tankowanie'));
    expect(copied, contains('Wymiana oleju'));
    expect(copied, isNot(contains('zł')));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'individual entry can be excluded and empty selection disables PDF',
    (tester) async {
      await openDialog(tester);
      await tester.scrollUntilVisible(find.text('Wymiana oleju'), 200);
      await tester.tap(find.text('Wymiana oleju'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kopiuj tekst'));
      await tester.pumpAndSettle();
      final copied = copiedText!;
      expect(copied, isNot(contains('Wymiana oleju')));
      expect(copied, contains('Klocki hamulcowe'));
      await tester.scrollUntilVisible(
        find.text('Odznacz wszystkie').hitTestable(),
        -150,
      );
      await tester.tap(find.text('Odznacz wszystkie'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Podgląd PDF'),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
