import 'package:autolog/domain/models/expense.dart';
import 'package:autolog/domain/models/service_reminder.dart';
import 'package:autolog/domain/models/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Domain Models tests', () {
    test('Vehicle serialization and alerts mapping', () {
      final vehicle = Vehicle(
        id: 'v123',
        brand: 'Audi',
        model: 'A4 B8',
        generationOrTrim: '2.0 TDI Avant',
        year: 2012,
        licensePlate: 'KR 12345',
        vin: 'WAUZZZ8K1CA123456',
        mileageKm: 215000,
        fuelType: 'DIESEL',
        purchasePricePln: 45000.0,
        alerts: [
          const VehicleAlert(
            id: 'a1',
            title: 'Koniec OC',
            description: 'Ważne do jutra',
            severity: AlertSeverity.critical,
            type: AlertType.insurance,
          ),
        ],
      );

      final map = vehicle.toMap();
      expect(map['id'], 'v123');
      expect(map['brand'], 'Audi');
      expect(map['license_plate'], 'KR 12345');
      expect(map['purchase_price_pln'], 45000.0);

      final fromMap = Vehicle.fromMap(map, alerts: vehicle.alerts);
      expect(fromMap.id, vehicle.id);
      expect(fromMap.brand, vehicle.brand);
      expect(fromMap.purchasePricePln, 45000.0);
      expect(fromMap.alerts.length, 1);
      expect(fromMap.alerts.first.severity, AlertSeverity.critical);
    });

    test('Expense serialization and category matching', () {
      final expense = Expense(
        id: 'e123',
        vehicleId: 'v123',
        category: ExpenseCategory.fuel,
        title: 'Tankowanie Orlen',
        amountPln: 350.50,
        date: '2026-09-01',
        mileageKm: 215200,
        note: 'PB95 do pełna',
      );

      final map = expense.toMap();
      expect(map['category'], 'FUEL');
      expect(map['amount_pln'], 350.50);

      final fromMap = Expense.fromMap(map);
      expect(fromMap.category, ExpenseCategory.fuel);
      expect(fromMap.title, 'Tankowanie Orlen');
    });

    test(
      'ServiceReminder serialization and fromMap with calculated metrics',
      () {
        final reminder = const ServiceReminder(
          id: 'r1',
          vehicleId: 'v1',
          title: 'Wymiana oleju',
          description: 'Castrol Edge 5W30',
          dueDate: '2026-10-01',
          dueMileageKm: 220000,
          daysRemaining: 25,
          kmRemaining: 5000,
          severity: AlertSeverity.warning,
          type: AlertType.oilService,
        );

        final map = reminder.toMap();
        expect(map['title'], 'Wymiana oleju');
        expect(map['severity'], 'WARNING');
        expect(map['type'], 'OIL_SERVICE');

        final fromMap = ServiceReminder.fromMap(
          map,
          daysRemaining: 25,
          kmRemaining: 5000,
          calculatedSeverity: AlertSeverity.warning,
        );
        expect(fromMap.daysRemaining, 25);
        expect(fromMap.kmRemaining, 5000);
        expect(fromMap.isMileageBased, isTrue);
        expect(fromMap.isDateBased, isTrue);
      },
    );
  });
}
