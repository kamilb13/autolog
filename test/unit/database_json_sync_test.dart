import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:autolog/data/database/app_database.dart';
import 'package:autolog/data/repositories/expense_repository.dart';
import 'package:autolog/data/repositories/vehicle_repository.dart';
import 'package:autolog/data/services/google_drive_service.dart';
import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/vehicle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  group('AppDatabase & JSON sync tests', () {
    test('Export and import full backup JSON', () async {
      final db = AppDatabase.instance;
      final repo = VehicleRepository(db);

      final vehicle = const Vehicle(
        id: 'test-sync-1',
        brand: 'Toyota',
        model: 'Corolla',
        generationOrTrim: 'E210',
        year: 2021,
        licensePlate: 'WA 99887',
        mileageKm: 45000,
        fuelType: 'HYBRID',
        vin: 'SB1AA123456789012',
      );

      await repo.addVehicle(vehicle);

      final jsonBackup = await db.exportToJson();
      expect(jsonBackup, contains('Toyota'));
      expect(jsonBackup, contains('WA 99887'));
      expect(jsonBackup, contains('vehicles'));
      expect(jsonBackup, contains('expenses'));
      expect(jsonBackup, contains('service_reminders'));

      final counts = await db.importFromJson(jsonBackup);
      expect(counts['vehicles']! > 0, isTrue);

      final vehicles = await repo.getAllVehicles();
      expect(vehicles.any((v) => v.licensePlate == 'WA 99887'), isTrue);
    });

    test('GoogleDriveService importFromRawJson validates and restores', () async {
      final db = AppDatabase.instance;
      final jsonBackup = await db.exportToJson();

      final result = await GoogleDriveService.instance.importFromRawJson(jsonBackup);
      expect(result.isSuccess, isTrue);
      expect(result.message, contains('Pomyślnie przywrócono bazę'));
    });

    test('Expenses with null mileage_km can be inserted and fetched', () async {
      final db = AppDatabase.instance;
      final exp = Expense(
        id: 'test-null-mileage-exp',
        vehicleId: 'test-sync-1',
        category: ExpenseCategory.parts,
        title: 'Zakup kosmetyków samochodowych',
        amountPln: 79.99,
        date: '2026-09-06',
        mileageKm: null,
      );

      final expRepo = ExpenseRepository(db);
      await expRepo.addExpense(exp);

      final fetched = await expRepo.getExpenseById('test-null-mileage-exp');
      expect(fetched, isNotNull);
      expect(fetched!.mileageKm, isNull);
      expect(fetched.title, equals('Zakup kosmetyków samochodowych'));
    });
  });
}
