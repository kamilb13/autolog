import 'package:autolog/core/theme/app_theme.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:autolog/presentation/providers/app_providers.dart';
import 'package:autolog/presentation/screens/add_expense_screen.dart';
import 'package:autolog/presentation/screens/expenses_screen.dart';
import 'package:autolog/presentation/screens/vehicle_dashboard_screen.dart';
import 'package:autolog/presentation/widgets/polish_license_plate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ExpensesScreen & AddExpenseScreen Widget Tests', () {
    testWidgets('AddExpenseScreen updates category when suggestion is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() => _MockVehiclesNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(initialVehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial category is fuel
      expect(find.text('Paliwo'), findsWidgets);

      // Enter "Wycier" in the title text field
      final titleField = find.byType(TextFormField).at(1); // Title is second text field after amount
      await tester.enterText(titleField, 'Wycier');
      await tester.pumpAndSettle();

      // Check if suggestion "Wycieraczki szyb" appears
      expect(find.text('Wycieraczki szyb'), findsOneWidget);

      // Tap suggestion "Wycieraczki szyb"
      await tester.tap(find.text('Wycieraczki szyb'));
      await tester.pumpAndSettle();

      // Verify category switched to "Części i eksploatacja" and title field contains "Wycieraczki szyb"
      expect(find.text('Części i eksploatacja'), findsWidgets);
      expect(find.text('Wycieraczki szyb'), findsWidgets);
    });

    testWidgets('ExpensesScreen shows SnackBar with COFNIJ button on deletion', (WidgetTester tester) async {
      final testExpense = Expense(
        id: 'exp_test_1',
        vehicleId: 'veh_test_1',
        category: ExpenseCategory.fuel,
        title: 'Tankowanie testowe',
        amountPln: 250.0,
        date: '2026-09-06',
        mileageKm: 120000,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expensesNotifierProvider.overrideWith(
              (ref) => _MockExpensesNotifier(testExpense),
            ),
            vehiclesNotifierProvider.overrideWith(() => _MockVehiclesNotifier()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ExpensesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tankowanie testowe'), findsOneWidget);

      // Tap delete button on the expense item
      final deleteBtn = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Verify SnackBar with 'COFNIJ' is shown
      expect(find.text('COFNIJ'), findsOneWidget);
      expect(find.text('Usunięto wpis "Tankowanie testowe"'), findsOneWidget);
    });

    testWidgets('VehicleDashboardScreen copies license plate and VIN to clipboard on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() => _MockVehiclesNotifier()),
            expensesNotifierProvider.overrideWith((ref) => _MockExpensesNotifier(Expense(
                  id: 'exp_dummy',
                  vehicleId: 'veh_test_1',
                  category: ExpenseCategory.fuel,
                  title: 'Paliwo',
                  amountPln: 100,
                  date: '2026-09-06',
                  mileageKm: 164250,
                ))),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const VehicleDashboardScreen(vehicleId: 'veh_test_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check displayed plate and VIN
      expect(find.text('KR 7AK89'), findsOneWidget);
      expect(find.text('VIN: WBA3A5C55FP123456'), findsOneWidget);

      // Tap PolishLicensePlate to copy
      await tester.tap(find.byType(PolishLicensePlate));
      await tester.pumpAndSettle();
      expect(find.text('Skopiowano numer rejestracyjny: KR 7AK89'), findsOneWidget);

      // Tap VIN chip to copy
      await tester.tap(find.text('VIN: WBA3A5C55FP123456'));
      await tester.pumpAndSettle();
      expect(find.text('Skopiowano numer VIN: WBA3A5C55FP123456'), findsOneWidget);
    });
  });
}

class _MockVehiclesNotifier extends AsyncNotifier<List<Vehicle>> implements VehiclesNotifier {
  @override
  Future<List<Vehicle>> build() async {
    return [
      const Vehicle(
        id: 'veh_test_1',
        brand: 'BMW',
        model: 'Seria 3',
        year: 2020,
        licensePlate: 'KR 7AK89',
        vin: 'WBA3A5C55FP123456',
        mileageKm: 164250,
        fuelType: 'Diesel',
      ),
    ];
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {}
  @override
  Future<void> deleteVehicle(String vehicleId) async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> updateMileage(String vehicleId, int newMileage) async {}
  @override
  Future<void> updateVehicle(Vehicle vehicle) async {}
}

class _MockExpensesNotifier extends StateNotifier<ExpensesState> implements ExpensesNotifier {
  _MockExpensesNotifier(Expense initialExpense)
      : super(ExpensesState(expenses: [initialExpense]));

  @override
  Future<void> addExpense(Expense expense) async {
    state = state.copyWith(expenses: [expense]);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    state = state.copyWith(expenses: []);
  }

  @override
  Future<void> loadExpenses() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> setCategoryFilter(ExpenseCategory? category) async {}
  @override
  Future<void> setSearchQuery(String query) async {}
  @override
  Future<void> setVehicleFilter(String? vehicleId) async {}
}
